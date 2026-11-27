# Sources — Rate Limiter & Throttler

Every URL below was re-checked during the 2026-11-27 rebuild (earlier pass: 2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling | 200 OK (WebFetch, 2026-11-27); page dated 2026-05-29 | Control-loop framing, five strategies, algorithm table, counters, proactive shedding, 429 vs 503, propagation, cheap rejection, edge vs app layers |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/rate-limiting-pattern | 200 OK (WebFetch, 2026-11-27); page dated 2026-06-08 | Client-side pacing, 30,000-sends example, 20 ops per 200 ms, lease partitions (500 req/s into 20x25; 8x100 example), when not to use |
| https://stripe.com/blog/rate-limiters | 200 OK (WebFetch, 2026-11-27); Paul Tarjan, 2017-03-30 | Four limiters, token bucket on Redis, fail open, kill switches, dark launches, 12,000 concurrency-limiter triggers and 100 shedder rejections in the month described |

## Reading limits

The linked Stripe implementation gist was not read. Stripe figures are from 2017 and illustrate, not recommend. Code sketches are our own and were not run.

## Claims not adopted as fact

- Corrected 2026-11-27: the shedding order "test, then GETs, then POSTs, critical last" is not ranked in the article (only test-mode first is stated); the 20% reserve is a hypothetical, not a Stripe production figure; "rejected millions" and "prevented outages in other months" were not confirmed and were removed.
- The `RateLimit-*` header shape: ecosystem convention, not read from these sources.
- Fixed-window "about double rate" at the boundary: our inference.
- Central token bucket as a simpler alternative to leasing: our inference.
