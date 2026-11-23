# Client-Side Rate Limiting and Capacity Leasing

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/rate-limiting-pattern · https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling · Last verified 2026-11-23

## Why a caller needs its own limiter

The server-side throttle protects the service; the **client-side rate limiter** protects the caller's throughput. Retry-on-reject wastes traffic. The source's worked example: ingest 10,000 records costing 10 RU each (100,000 RU) into a store provisioned at 20,000 RU per second. Blind sending: 10,000 sent (2,000 accepted), then 8,000, 6,000, 4,000, 2,000 re-sent, totalling 30,000 sends for 10,000 records and about 20,000 errors to log and process, with no predictable finish time. Pacing at the allowed rate sends each record once and lets you compute duration.

Throttled services meter by operations (20 req/s), data volume (2 GiB/min) or operation cost (20,000 RU/s). The client limiter must use the same metric.

## Pattern

1. Put work in a **durable** messaging system that can absorb the full ingest rate (not an in-memory buffer; if the app dies, buffered data is lost).
2. Run job processors that dequeue only what the current budget allows (also saves memory).
3. Pace releases **finer than the service window**: if the limit is 100/s, release 20 every 200 ms rather than 100 once per second, avoiding bursts and keeping CPU, memory, network smooth.
4. Handle residual throttle errors anyway: honour 429 and `Retry-After`, use bounded retries with small random delays, avoid retry storms (backoff mechanics belong to `circuit-breaker-retry-telemetry`).

```python
async def drain(queue, send, per_second=100, slice_ms=200):
    batch = per_second * slice_ms // 1000      # 20 per 200 ms
    while True:
        t0 = monotonic()
        msgs = await queue.receive(max=batch)
        await send_all(send, msgs)
        await sleep(max(0, slice_ms/1000 - (monotonic() - t0)))
```

## Several uncoordinated processes share one throttled service

Partition the service capacity into units and have processes lease units through distributed mutual exclusion:

- Throttle 500 req/s becomes 20 partitions of 25 req/s. A process needing 100 req/s asks for four, may get two for a limited time (say 10 s), rate-limits itself to 50 req/s, finishes, releases.
- Implementation in the source: one zero-byte blob per partition; exclusive short lease (e.g. 15 s) per blob; the holder may use that partition's capacity until the lease expires and must track the expiry itself. Pick a random partition to attempt to reduce collisions. Alternatives: ZooKeeper, etcd, Redis (Redsync).
- Reserve a small exclusive baseline per process to cut latency; lease shared capacity only when exceeding the baseline.
- Worked example: 8 partitions x 100 rec/s = 800 rec/s database limit; processor A holds three leases (300/s), processor B five (500/s); as leases expire a processor must lower its dequeue rate.

Own inference: a token-bucket in a shared store (central atomic counter) is a simpler alternative when sub-millisecond latency is not needed and a single store is acceptable; leasing wins when the coordination service is slow or per-request calls are too costly.

## Considerations

- Rate limiting reduces throttle errors; it does not eliminate them. Keep error handling.
- Gate **every** workstream hitting the same throttled service (bulk loads and interactive queries) through the same mechanism, or reserve separate capacity pools.
- A service shared with other applications: an unexpected rise in throttle errors signals contention; temporarily reduce your rate until others quiet down (adaptive back-off, own inference extending the source).
- Not suitable when work must complete synchronously with very low latency (no queueing allowed) or the bottleneck is concurrency or resource contention instead of request rate; then use concurrency limits or scaling.

## Anti-patterns

- Retry loop as the rate control.
- In-memory buffer ahead of a throttled sink.
- Releasing once per window (burst at window start).
- Separate limiters per process that sum above the service limit.
- Ignoring `Retry-After`.

## How an agent should apply this

- For bulk/batch calls to a throttled API, drive the loop from a durable queue and a pacing budget matching the service's metric, not from try/retry.
- Pace in small slices (about one-fifth of the window or finer).
- If multiple processes share the quota, add a lease or central counter with expiry; never rely on each process guessing its share.
- Combine with workers: this is the pairing of `background-worker-job-scheduler` (consumers) and this skill (pacing).
- Report expected completion time from the budget so operators can trust the job.
