# Sources — Rate Limiter & Throttler

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling | 200 OK (WebFetch; Firecrawl had no credits). Page dated 2026-05 | Throttling as a control loop, five strategies, algorithm table (token/leaky bucket, fixed/sliding window), distributed counters, proactive shedding, 429 vs 503 with Retry-After, propagation of overload, cheap rejection, per-operation cost, runtime config, adaptive limits |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/rate-limiting-pattern | 200 OK (WebFetch). Page dated 2026-06 | Client-side rate limiting, retry-on-error amplification example (30,000 sends for 10,000 records), durable queue plus job processors, even release (20 ops per 200 ms), capacity partitioning with leases, when not to use |
| https://stripe.com/blog/rate-limiters | 200 OK (WebFetch). Article by Paul Tarjan, 2017-03-30 | Four limiters (request rate, concurrent requests, fleet usage load shedder, worker utilization load shedder), traffic priorities, token bucket on Redis, fail-open, kill switches, dark launches, rollout order. Linked implementation gist not read |
