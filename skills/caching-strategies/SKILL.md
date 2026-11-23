---
name: caching-strategies
description: "Design and review caching in applications: in-memory (private) and distributed (shared) caches, cache-aside, read-through, write-through, write-behind, TTL and jitter, eviction, invalidation, stampede/thundering-herd protection, and HTTP caching semantics per RFC 9111 (freshness, validation, Cache-Control, Vary, shared vs private caches, stale-while-revalidate, stale-if-error). Use when adding a cache, choosing a write strategy or TTL, fixing stale data or cache-induced load spikes, or setting Cache-Control/ETag headers."
---

# Caching Strategies (in-memory, distributed, HTTP)

One idea: a cache is a **disposable, possibly stale copy** of data owned by something else. Every caching decision is a choice about *who may serve a copy, for how long, and how it is refreshed or killed* — never a place where truth lives. Sources and claims: [references/sources.md](references/sources.md).

Boundary: this skill is **data reuse**. Asynchronous execution belongs to `background-worker-job-scheduler`; admission control and overload protection belong to `rate-limiter-throttler` (a cache lowers average load but does not bound peak load, so it is not a limiter). Retry/backoff/breaker for a failing cache or origin is `circuit-breaker-retry-telemetry`. Gateway-level response caching is configured via `api-gateway-reverse-proxy`; reusable cache middleware belongs to `middleware-interceptor-chain`; data-access abstractions to `repository-unit-of-work`; cache entries holding user data must respect `authn-authz-guard`.

---

## 1. First Question: Should This Be Cached at All?

Cache when **all/most** hold: read-heavy vs write; origin slow, contended or distant; value can tolerate a stated staleness; rebuild cost is high; keys repeat (hit ratio will be meaningful).

Do **not** cache (or cache very carefully) when: data is sensitive/security-related and the cache is shared; most requests would miss (overhead exceeds gain); data is small and static (preload it instead, no expiry); consistency must be strict (balances, stock at checkout, authorization decisions); the key space is unbounded with no repetition.

Rule: write the **tolerated staleness** (e.g. "60 s") and the **invalidation trigger** next to every cache. No number, no cache.

## 2. Where the Cache Lives

| Layer | Examples | Use for | Risk |
|---|---|---|---|
| Private in-process | dict/LRU in the process | Hot, small, static, short-lived data | Instances diverge; lost on restart |
| Shared distributed | Redis/Memcached-style service | Data every instance must agree on; large working sets | Network hop; new dependency; CAP trade-off (mostly AP) |
| Layered (local then shared then store) | L1 + L2 | Latency plus resilience when shared cache is down | L1 drift; keep L1 TTL much shorter |
| HTTP (browser, CDN, proxy) | `Cache-Control` | Responses reusable by many clients | Outside your control once sent; see section 6 |

Details: [references/distributed-cache-design.md](references/distributed-cache-design.md).

## 3. Pattern Selection (Default: Cache-Aside)

| Pattern | Choose when | Reject when |
|---|---|---|
| **Cache-aside / lazy loading** | Default. Cache has no native read-through; demand unpredictable; must survive cache loss | You need read-after-write freshness on a hot read path |
| **Read-through** | Cache product loads on miss for you; want loader in one place | Cache is not trusted to load, or loader needs request context |
| **Write-through** | Read-heavy key that must show the new value immediately after write; accept higher write latency | Data rarely read after write; constantly changing; you cannot make both writes succeed atomically enough |
| **Write-behind** (not read from source: common definition) | Throughput on non-critical, loss-tolerant writes | Anything valuable: data can be lost before flush. Use a durable queue instead |
| **Refresh-ahead / seeding** | Predictable reference data | Large seeds that spike the origin at startup |

Cache-aside algorithm: read cache, on miss load the store, put into cache **with TTL**, return; on write, **update the store first, then delete the cache key** (the reverse order lets a concurrent reader re-cache the old value). Do not cache null without a short, separate negative TTL. Details and code: [references/cache-aside-and-write-strategies.md](references/cache-aside-and-write-strategies.md).

## 4. TTL, Eviction, Invalidation

- **TTL on every entry.** It bounds staleness but does not remove it. Too short = constant origin hits; too long = stale.
- **Add jitter** (about plus/minus 10%) so keys written together do not expire together.
- **Per-class TTL**, not one global: reference data minutes to hours; per-user views seconds to minutes; anything with high rebuild cost may deserve exemption from aggressive eviction.
- **Eviction**: LRU by default; know the alternatives (MRU, FIFO, explicit). Disabling eviction risks failing writes when memory is full.
- **Invalidation order**: store write, then cache delete. Prefer *delete* over *update-in-place* in cache-aside (avoids races between two writers).
- **Eventual consistency trap**: if the store is replicated, repopulating from a lagging replica re-caches old data; read from the primary for refills or shorten TTL.
- **Versioned keys** (`entity:v3:id`) make schema/format changes safe and make wholesale invalidation a config change.
- **Client-side caches** cannot be force-invalidated; change the URI (fingerprint) or use short freshness plus validation.

## 5. Stampede / Thundering Herd

A hot key expiring (or a cache flush) sends all concurrent misses to the origin at once. Layer defenses:

| Defense | Solves | Does not solve |
|---|---|---|
| In-process coalescing (single flight) | Duplicate loads in one process | Multiple instances |
| Token-guarded lock (`SET NX PX`, compare-and-delete release) | Duplicate loads fleet-wide | Failed holder fallback storms |
| TTL jitter | Many keys expiring together | One hot key |
| Probabilistic early refresh (XFetch) | Hard expiry on hot key without locks | Occasional parallel loads |
| Stale-while-revalidate (soft + hard TTL, one background refresher) | Waiting on hot key | Data where staleness is a bug |

Default for a hot, must-be-fresh key: coalescing plus lock plus jitter. For staleness-tolerant keys: stale-while-revalidate. Always bound lock waits and keep a fallback. Details: [references/stampede-and-thundering-herd.md](references/stampede-and-thundering-herd.md).

Also protect the origin itself: cap concurrent rebuilds with a bulkhead or limiter (`rate-limiter-throttler`), because a cold cache is a normal operating mode (restart, failover, deploy), not an exception.

## 6. HTTP Caching (RFC 9111) in Five Rules

1. **Send explicit freshness**: `Cache-Control: max-age=N` (browser/private), `s-maxage=N` (shared). Heuristic freshness (about 10% of time since `Last-Modified`) is a fallback, never a design.
2. **Send a validator**: `ETag` (preferred) and/or `Last-Modified`; clients revalidate with `If-None-Match`/`If-Modified-Since` and you answer `304`.
3. **Know the directives**: `no-store` = never store; `no-cache` = store but revalidate every time; `private` = not for shared caches; `public` = shared storage allowed (and required if the request carried `Authorization`, with `s-maxage` or `must-revalidate` as alternatives); `must-revalidate` = no stale reuse once expired.
4. **Declare `Vary`** for every request header that changes the representation (`Accept-Encoding`, `Accept-Language`); `Vary: *` is never matched; varying on `Cookie` shreds the hit ratio.
5. **Stale extensions** (RFC 5861, not core RFC 9111): `stale-while-revalidate=N` and `stale-if-error=N` smooth latency and mask 5xx for a bounded window.

Unsafe methods (POST/PUT/DELETE) invalidate only the target URI in caches they pass through; plan versioned URLs or purge for related resources. Details, formulas, recipes: [references/http-caching-rfc9111.md](references/http-caching-rfc9111.md).

## 7. Failure Modes to Reject in Review

| Smell | Why it hurts | Fix |
|---|---|---|
| Cache holds the only copy | Cache loss = data loss | Persist to the store; cache is derived |
| Delete-cache-then-write-store | Stale refill race | Store first, then invalidate |
| No TTL | Permanently stale if invalidation is missed once | TTL plus jitter on every set |
| Cache failure takes the request down | Hard dependency | Timeout, fallback, breaker (`circuit-breaker-retry-telemetry`) |
| Per-user data under a shared key or `public` header | Cross-user leakage | User-scoped key; `private`; `Cache-Control: no-store` for secrets |
| Caching as an overload shield | Misses are unbounded | Add limiter/bulkhead (`rate-limiter-throttler`) |
| Unbounded key cardinality (query strings, raw user input) | Memory blowup, poisoning | Normalize keys; cap size; allowlist params |
| Identical TTL on bulk warm-up | Synchronized expiry | Jitter |
| Different instances see different data silently | Heisenbugs | Shared cache, or short L1 TTL |

## 8. Observability

Track hit ratio per key class, miss latency, origin QPS right after expiry/flush, eviction count, memory use, lock wait time, and stale-served count. Alert on hit-ratio drop plus origin QPS rise (stampede signature). Test cold start and cache-down scenarios explicitly.

## Quick Decision Checklist

- [ ] Is the data read-heavy, repeated, and tolerant of stated staleness? (If not, skip caching.)
- [ ] Is the cache clearly derived data, with the store as source of truth?
- [ ] Pattern chosen deliberately (default cache-aside; write-through only for read-after-write need)?
- [ ] Write path: store first, then invalidate; no null caching without negative TTL?
- [ ] TTL on every entry, jittered, per data class; versioned keys?
- [ ] Hot keys protected against stampede (coalescing/lock/soft TTL); lock waits bounded?
- [ ] Cache outage handled (timeout, fallback, breaker) without swamping the origin?
- [ ] No sensitive or per-user data in shared keys; HTTP `private`/`public`/`Vary` correct?
- [ ] HTTP responses carry explicit `Cache-Control` plus a validator; `no-cache` vs `no-store` not confused?
- [ ] Metrics and cold-start tests exist?

## Deep references

- [Cache-aside, read/write-through, write-behind, TTL](references/cache-aside-and-write-strategies.md) — read when choosing a pattern or fixing stale-after-write bugs.
- [Stampede and thundering-herd mitigation](references/stampede-and-thundering-herd.md) — read when hot keys, flushes or bulk TTLs cause origin spikes.
- [Distributed and in-memory cache design](references/distributed-cache-design.md) — read when choosing private vs shared caches, HA, concurrency, security.
- [HTTP caching per RFC 9111](references/http-caching-rfc9111.md) — read when setting Cache-Control, ETag, Vary, or serving stale.
- [Sources](references/sources.md) — retrieval status and what each source contributed.
