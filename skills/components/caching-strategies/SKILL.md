---
name: caching-strategies
description: "Decide whether, where and how to cache data so that copies stay safe, boundedly stale and cheap to refresh: private (in-process) vs shared (distributed) caches, cache-aside, read-through, write-through, write-behind, TTL with jitter, eviction, invalidation, stampede protection, and HTTP caching per RFC 9111 (Cache-Control, ETag, Vary, stale-while-revalidate). Not for rate limiting or load shedding (`rate-limiter-throttler`), retry or breaker design (`circuit-breaker-retry-telemetry`), job queues (`background-worker-job-scheduler`) or gateway routing and configuration (`api-gateway-reverse-proxy`). Use when adding or reviewing a cache, choosing a write strategy or TTL, fixing stale data or load spikes after expiry, or setting Cache-Control and ETag headers."
---

# Caching Strategies (in-memory, distributed, HTTP)

One idea: a cache is a **disposable, possibly stale copy** of data owned by something else. Every caching decision answers *who may serve a copy, for how long, and how it is refreshed or killed*; a cache is never where truth lives. Sources, retrieved statuses and unverified claims: [references/sources.md](references/sources.md).

Boundary: this skill is **data reuse**. A cache lowers average load but does not bound peak load, so it is not a limiter (`rate-limiter-throttler`). Retry, backoff and breaker for a failing cache or origin belong to `circuit-breaker-retry-telemetry`. Asynchronous execution belongs to `background-worker-job-scheduler`. Gateway-level response caching is configured via `api-gateway-reverse-proxy`; reusable cache middleware sits in `middleware-interceptor-chain`; data-access abstractions in `repository-unit-of-work`; cache entries holding user data must respect `authn-authz-guard`.

## 1. First Question: Should This Be Cached at All?

Cache when most of these hold: reads dominate writes; the origin is slow, contended or distant; the value tolerates a stated staleness; rebuild cost is high; keys repeat (a hit ratio will be meaningful). Azure's guidance adds that a cache can also keep reads working while DB connections are exhausted or the DB is briefly down.

Do **not** cache, or cache very carefully, when: the data is sensitive or security-related and the cache is shared (Azure cache-aside page: fetch it from the primary source); most requests would miss, so overhead exceeds gain; the data set is small and static (preload it with no expiry instead); consistency must be strict (balances, stock at checkout, authorization decisions; this last list is our judgment, not a quoted rule); the key space is unbounded with no repetition.

Rule: write the **tolerated staleness** (for example "60 s") and the **invalidation trigger** next to every cache. No number, no cache.

## 2. Where the Cache Lives

| Layer | Examples | Use for | Risk |
|---|---|---|---|
| Private in-process | dict/LRU in the process | Hot, small, static or short-lived data | Instances hold different snapshots; lost on restart |
| Shared distributed | Redis/Memcached-style service | Data every instance must agree on; large working sets | Network hop; new dependency to run and secure; usually favors availability over strong consistency |
| Layered (local, then shared, then store) | L1 + L2 | Latency, plus a buffer when the shared cache is down | L1 drift; keep L1 TTL much shorter |
| HTTP (browser, CDN, proxy) | `Cache-Control` | Responses reusable by many clients | Outside your control once sent; see section 6 |

Details: [references/distributed-cache-design.md](references/distributed-cache-design.md).

## 3. Pattern Selection (Default: Cache-Aside)

| Pattern | Choose when | Reject when |
|---|---|---|
| **Cache-aside (lazy loading)** | Default. The cache has no native read-through; demand is unpredictable; you must survive cache loss | You need read-after-write freshness on a hot read path |
| **Read-through** | The cache product loads on a miss for you; you want the loader in one place | The loader needs request context, or you do not trust the cache layer to load |
| **Write-through** | A read-heavy key must show the new value right after a write; slower writes are acceptable | Data is rarely read after write or changes constantly |
| **Write-behind (write-back)** | Throughput on non-critical, loss-tolerant writes | Anything valuable: data can be lost before the flush (inference from the definition). Use a durable queue instead |
| **Seeding / priming** | Predictable reference data, for example the daily-active subset | Large seeds that spike the origin at startup |

Cache-aside: read the cache; on a miss load the store, put into the cache **with a TTL**, return. On write, **update the store first, then invalidate the cache key**; the reverse order lets a concurrent reader re-cache the old row (Azure cache-aside page). Do not cache a null result without a short, separate negative TTL (the Azure sample skips null; the negative-TTL option is our suggestion). Details and code: [references/cache-aside-and-write-strategies.md](references/cache-aside-and-write-strategies.md).

## 4. TTL, Eviction, Invalidation

- **TTL on every entry.** It bounds staleness but does not remove it (AWS ElastiCache page). Too short means constant origin hits; too long means stale data.
- **Jitter** the TTL (the Upstash example uses plus or minus 10 percent) so keys written together do not expire together.
- **Per-class TTL**, not one global value. Ranges such as minutes for reference data or seconds for per-user views are rules of thumb of ours, not sourced.
- **Eviction** is LRU by default in most services; alternatives are MRU and FIFO. Preventing eviction risks a full cache that rejects new items with an error (Azure caching guidance).
- **Invalidation order:** store write, then cache delete. Prefer delete over update-in-place in cache-aside, so two writers cannot leave an old value behind (our reasoning).
- **Replica lag:** if the store is replicated, a refill from a lagging replica re-caches old data; refill from the primary or shorten the TTL.
- **Versioned keys** (`entity:v3:id`) make format changes safe and turn wholesale invalidation into a config change (our practice).
- **Client-side copies** cannot be force-evicted; change the URI or use short freshness plus validation.

## 5. Stampede / Thundering Herd

A hot key expiring, or a flush, sends every concurrent miss to the origin at once.

| Defense | Solves | Does not solve |
|---|---|---|
| In-process coalescing (single flight) | Duplicate loads inside one process | Multiple instances |
| Token-guarded lock (`SET key token NX PX ms`, compare-and-delete release) | Duplicate loads fleet-wide | A failed holder: waiters fall back and can still stampede |
| TTL jitter | Many keys expiring together | One hot key |
| Probabilistic early refresh (XFetch) | Hard expiry of a hot key, without a lock | Some parallel loads remain |
| Stale-while-revalidate (soft and hard TTL, one background refresher) | Readers waiting on a hot key | Data where staleness is a bug |

Default for a hot, must-be-fresh key: coalescing plus lock plus jitter. For staleness-tolerant keys: stale-while-revalidate. Always bound lock waits and keep a fallback. Details: [references/stampede-and-thundering-herd.md](references/stampede-and-thundering-herd.md).

A cold cache is a normal mode (restart, failover, deploy), so also cap concurrent rebuilds with a bulkhead or limiter (`rate-limiter-throttler`, `circuit-breaker-retry-telemetry`).

## 6. HTTP Caching (RFC 9111) in Five Rules

1. **Send explicit freshness:** `Cache-Control: max-age=N`, plus `s-maxage=N` for shared caches. Heuristic freshness (RFC 9111 mentions about 10 percent of the time since `Last-Modified` as a typical setting, and only as a permission) is a fallback, never a design.
2. **Send a validator:** `ETag` (preferred) and/or `Last-Modified`. Clients revalidate with `If-None-Match` or `If-Modified-Since` and you answer `304`.
3. **Know the directives:** `no-store` = do not store; `no-cache` = store but revalidate before every reuse; `private` = shared caches must not store; `public` = storage allowed even where otherwise prohibited; `must-revalidate` = no stale reuse once expired. A shared cache may reuse a response to an `Authorization` request only if the response has `must-revalidate`, `public` or `s-maxage` (section 3.5).
4. **Declare `Vary`** for every request header that changes the representation; `Vary: *` never matches; varying on `Cookie` shreds the hit ratio.
5. **Stale extensions** are not in RFC 9111: `stale-while-revalidate` and `stale-if-error` come from RFC 5861 (Informational); `stale-if-error` applies only to 500, 502, 503 and 504. `immutable` is RFC 8246 (Standards Track) for content that never changes during its freshness lifetime.

An unsafe method (POST, PUT, DELETE) invalidates only the target URI, and `Location` or `Content-Location` if same-origin, in the caches it passes through. Plan versioned URLs or purge for related resources. Details and formulas: [references/http-caching-rfc9111.md](references/http-caching-rfc9111.md).

## 7. Failure Modes to Reject in Review

| Smell | Why it hurts | Fix |
|---|---|---|
| Cache holds the only copy | Cache loss is data loss | Persist to the store; the cache is derived |
| Delete cache, then write store | Stale refill race | Store first, then invalidate |
| No TTL | Permanently stale if one invalidation is missed | TTL plus jitter on every set |
| Cache failure fails the request | Hard dependency on the cache | Timeout, fallback, breaker (`circuit-breaker-retry-telemetry`), and bound the fallback load |
| Per-user data under a shared key or `public` | Cross-user leakage | User-scoped key; `private`; `no-store` for secrets |
| Cache used as an overload shield | Misses are unbounded | Limiter or bulkhead (`rate-limiter-throttler`) |
| Unbounded key cardinality (raw query strings, user input) | Memory blowup, poisoning | Normalize keys; cap size; allowlist params |
| Identical TTL on a bulk warm-up | Synchronized expiry | Jitter |
| Instances silently see different data | Hard-to-reproduce bugs | Shared cache, or a short L1 TTL |

## 8. Observability

Track hit ratio per key class, miss latency, origin QPS just after expiry or flush, eviction count, memory use, lock wait time and stale-served count. A hit-ratio drop together with an origin-QPS rise is the stampede signature (our heuristic). Test cold start and cache-down scenarios explicitly. Metric and trace conventions: `circuit-breaker-retry-telemetry`.

## Quick Decision Checklist

- [ ] Is the data read-heavy, repeated and tolerant of a stated staleness? If not, skip caching.
- [ ] Is the cache clearly derived data, with the store as the source of truth?
- [ ] Pattern chosen deliberately (default cache-aside; write-through only for a read-after-write need)?
- [ ] Write path: store first, then invalidate; no null caching without a negative TTL?
- [ ] TTL on every entry, jittered, per data class; versioned keys?
- [ ] Hot keys protected against stampede; lock waits bounded; origin rebuilds capped?
- [ ] Cache outage handled (timeout, fallback, breaker) without swamping the origin?
- [ ] No sensitive or per-user data in shared keys; `private`, `public` and `Vary` correct?
- [ ] HTTP responses carry explicit `Cache-Control` plus a validator; `no-cache` and `no-store` not confused?
- [ ] Metrics and cold-start tests exist?

## Deep references

- [references/cache-aside-and-write-strategies.md](references/cache-aside-and-write-strategies.md): read when choosing a pattern or fixing stale-after-write bugs.
- [references/stampede-and-thundering-herd.md](references/stampede-and-thundering-herd.md): read when hot keys, flushes or bulk TTLs cause origin spikes.
- [references/distributed-cache-design.md](references/distributed-cache-design.md): read when choosing private vs shared caches, availability, concurrency or cache security.
- [references/http-caching-rfc9111.md](references/http-caching-rfc9111.md): read when setting Cache-Control, ETag, Vary, or serving stale.
- [references/trigger-evals.md](references/trigger-evals.md): read when tuning the description or checking neighbor boundaries.
- [references/sources.md](references/sources.md): retrieved status of every source, reading limits and claims not adopted.
