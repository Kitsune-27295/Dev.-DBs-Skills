# Distributed and In-Memory Cache Design Decisions

Sources: https://learn.microsoft.com/en-us/azure/architecture/best-practices/caching · https://learn.microsoft.com/en-us/azure/architecture/patterns/cache-aside · Last verified 2026-11-27

## Private vs shared cache

| | Private (in-process or local disk) | Shared (Redis-style service) |
|---|---|---|
| Speed | Fastest; no network | Slower: network hop |
| Consistency | Each instance holds a snapshot at its own time; same query can return different results across instances | All instances see the same view |
| Scaling | Bounded by one machine's memory (spill to local disk is still faster than remote) | Clusters shard data; add nodes to scale |
| Complexity | Minimal | Extra service to run, secure and monitor |

Use private for small, static or short-lived data and when a few seconds of divergence is fine. Use shared when instances must agree or the working set is large. Both can be layered: check local, then shared, then store. The local layer is a buffer if the shared cache is down, but must be configured so it does not drift too far from the shared one (short TTL).

## When caching pays off

Data read often and changed rarely; origin slow, contended, or far away. Caching also keeps reads available when DB connections are exhausted or the DB is briefly down. Cache computed results too, not just rows (Azure caching guidance). Caching only the stable parts of an entity and fetching a volatile part live is our suggestion.

## The cache is never the source of truth

Do not store the only copy of anything valuable in the cache; it can vanish at any time. Persist important changes to the data store. The app must keep working if the cache is unavailable: detect failure, fall back to the store, and wrap cache calls in a circuit breaker (see `circuit-breaker-retry-telemetry`). Warning from the article: fallback to the store while a cache recovers can swamp the store with timeouts and failed connections, so combine fallback with limits and stampede protection (see `stampede-and-thundering-herd.md`).

## Concurrency on shared cache entries

- Optimistic: check the entry did not change since read before writing (compare-and-set, version field); good when collisions are rare.
- Pessimistic: lock the entry while modifying; only for short operations or multi-key updates that must be consistent; hurts scalability.

## High availability and scale

- Replication to a secondary with automatic failover; replication is often asynchronous so a small amount of cached data can be lost on failover (acceptable for a cache).
- Partition/cluster the cache to reduce contention; clustering also limits blast radius of node loss.
- Use batch operations for seeding or bulk reads instead of many tiny round trips.
- Most distributed caches (Redis included) favor availability and partition tolerance over strong consistency (CAP). Reads from replicas may be stale after a write elsewhere. Decide tolerated staleness per key class and set TTLs to match; for must-be-current data use a short TTL or bypass the cache.

## Client-side caches

A service cannot force a client to evict. For web resources, change the URI when content changes (versioned or fingerprinted URLs), since clients key their cache by URI. For HTTP APIs use explicit freshness and conditional requests; see `http-caching-rfc9111.md`.

## Protecting cached data

- Authenticate identities and restrict which can read/write.
- To restrict subsets: split caches by server, or encrypt each subset with different keys.
- Use TLS when the cache is reached over a network you do not control (our advice; the Azure page documents TLS only for its own product).
- Do not put sensitive or security-related data in a shared cache; fetch it from the primary source (Azure cache-aside guidance). Never key by something that mixes users (see "private" below for HTTP).

## Anti-patterns

- Cache as primary store; hard dependency on the cache for availability.
- One global TTL/eviction policy for items with very different rebuild cost.
- Session state cached on a web farm in a way that creates client-server affinity.
- Large synchronous seed at startup.
- Local caches per instance for data that must be consistent.

## How an agent should apply this

- Choose private vs shared by consistency need and size, not by habit; if layering, give the local layer a much shorter TTL.
- Every cache call needs a timeout and a fallback; add a breaker so a dead cache does not add latency to every request.
- Declare per key class: owner, TTL, tolerated staleness, invalidation trigger, and whether it may hold user-specific data.
- Version cache keys when the value schema changes so old and new deployments do not read each other's shapes.
- Keep secrets, tokens and PII out of shared caches unless encrypted and access-controlled; defer authz questions to `authn-authz-guard`.
