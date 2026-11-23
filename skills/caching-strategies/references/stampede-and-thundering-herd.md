# Cache Stampede (Thundering Herd) Mitigation

Sources: https://upstash.com/kb/thundering-herd-problem-cache-stampede · https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling (caching is not a throttle) · Last verified 2026-11-23

## The failure

A hot key expires (or is evicted/flushed). Every request arriving in the next hundreds of milliseconds misses, none knows another is rebuilding, and all hit the database. The window lasts as long as one rebuild takes: the Upstash example is 10 req/s with a 3 s query giving roughly 30 rebuilds. Triggers: hot-key expiry under peak load, slow rebuilds, bulk warm-up jobs that write thousands of keys with the same TTL, cache restarts. Symptom: hits drop while misses and database load spike right after expiry or a flush. The same shape appears in client retries against a recovering server; jitter spreads those too.

## Five mitigations (and what each does not solve)

| Strategy | Prevents | Waits? | Serves stale? | Cost / caveat |
|---|---|---|---|---|
| Single-flight lock in the cache | Duplicate rebuilds across the whole fleet | Yes, for one rebuild | No | Lock key per miss; waiters poll then fall back to DB, so a failed winner can still cause a small stampede |
| In-process coalescing | Duplicate rebuilds inside one process | Yes | No | Free (a map of in-flight promises) but only per process: 20 servers still run 20 queries |
| TTL jitter | Many keys expiring together | No | No | Does nothing for one hot key |
| Probabilistic early refresh (XFetch) | Hot key hitting hard expiry | Rarely | No | Stores rebuild time and expiry per value; no lock, so some parallel fetches remain |
| Stale-while-revalidate | Readers waiting on a hot key | No | Briefly | Needs a soft and a hard TTL plus a refresh lock; wrong for balances or stock at checkout |

### Lock details

Acquire with an atomic set-if-absent plus expiry (Redis `SET key token NX PX ms`). The lock must expire so a crashed holder cannot block forever. Release only if the stored token still matches (use a small server-side script), otherwise a slow holder deletes a lock that someone else acquired after its timeout. Waiters poll the cache (the article used 50 ms intervals, up to 50 tries) and finally fall back to the database. In the benchmark (50 concurrent requests, 300 ms query) loads fell from 50 to 1. Cost: waiters are delayed by the slowest rebuild plus up to one polling interval.

```python
def get(key, loader, ttl):
    v = cache.get(key)
    if v is not None: return v
    token = uuid4().hex
    if cache.set(f"lock:{key}", token, nx=True, px=5000):
        try:
            v = loader()
            cache.set(key, v, ex=jitter(ttl))
            return v
        finally:
            release_if_token_matches(f"lock:{key}", token)  # server-side compare-and-delete
    for _ in range(50):                    # lost the race: wait for winner
        time.sleep(0.05)
        v = cache.get(key)
        if v is not None: return v
    return loader()                        # bounded fallback
```

### Coalescing

Keep a dict `key -> in-flight future`; later callers await the same future and remove it on completion. In serverless/edge each instance has its own map, so the shared lock does most of the work. The article recommends both: coalescing reduces each process to one query, the lock reduces the fleet to one.

### Jitter

Randomize each TTL by a small percentage (the example used plus/minus 10%: a 300 s base gave about 277 to 324 s). Cheap, always do it for bulk writes.

### XFetch (probabilistic early expiration)

Store the value with its rebuild duration `delta` and `expiry`. On read, refresh early when `now - delta * beta * ln(random()) >= expiry`; `beta=1` is the suggested default. Slower rebuilds refresh earlier, and refresh probability rises as expiry nears. Benchmark: 40 reads over about 2 s with a 2 s TTL gave 4 recomputes and no misses.

### Stale-while-revalidate (application level)

Soft lifetime (value becomes stale) and hard TTL (example 10x). After the soft lifetime, one request wins a refresh lock and refreshes in the background while everyone else instantly receives the stale value (benchmark: 50 requests all answered in 191 ms, 1 refresh). In serverless runtimes the background refresh can be cut off when the response is sent; use the platform's after-response/wait-until hook.

## Choosing

- Hot key that must be current: lock plus coalescing.
- Key tolerant of seconds of staleness (listings, counts, feeds): stale-while-revalidate.
- Many keys written together: add jitter in addition.
- Caching does not bound peak load: every miss reaches the origin, so also protect the origin with a limiter or bulkhead (see `rate-limiter-throttler`), and add retries with backoff via `circuit-breaker-retry-telemetry`.

## Anti-patterns

- Releasing a lock with a plain delete (no token check).
- Unbounded waiting on a lock, or no fallback if the holder dies.
- Identical TTLs on a bulk warm-up.
- Using stale-while-revalidate for data where staleness is a correctness bug.
- Treating jitter as the whole fix for a single hot key.

## How an agent should apply this

- Add jitter to every TTL written by a batch or warm-up job.
- For any key with high read rate and expensive rebuild, add in-process coalescing first; add a token-guarded fleet lock when multiple instances exist.
- Use soft/hard TTL (stale-while-revalidate) only where staleness is explicitly acceptable and document it.
- Bound all lock waits and always have a fallback path; never let the lock TTL be shorter than the p99 rebuild time without a token check.
- Load-test the post-expiry/flush scenario and watch miss rate and origin QPS.
