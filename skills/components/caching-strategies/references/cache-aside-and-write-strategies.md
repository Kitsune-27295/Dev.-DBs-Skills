# Cache-Aside, Read-/Write-Through, Write-Behind and TTL

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/cache-aside · https://learn.microsoft.com/en-us/azure/architecture/best-practices/caching · https://docs.aws.amazon.com/whitepapers/latest/database-caching-strategies-using-redis/caching-patterns.html (served body was the ElastiCache lazy-loading/write-through/TTL page) · Last verified 2026-11-23

## Vocabulary

| Pattern | Who talks to the data store | Read path | Write path |
|---|---|---|---|
| Cache-aside (lazy loading) | The application | App checks cache, on miss loads store, fills cache | App writes store, then invalidates (or overwrites) the cache entry |
| Read-through | The cache layer | App only asks cache; cache loads on miss | n/a |
| Write-through | The cache layer or app, synchronously | Reads served from cache | Store and cache updated in the same operation; success returned only after both succeed |
| Write-behind (write-back) | The cache layer, asynchronously | Reads served from cache | Cache acknowledges, store updated later (not read from source; common definition, treat as inference) |

Cache-aside is how an application emulates read-through when the cache product does not provide it (Azure cache-aside page). It is the default choice because it works with any cache and survives cache loss.

## Cache-aside mechanics

1. Read the cache by key. Hit: return it.
2. Miss: read the data store.
3. Put the result into the cache with a TTL, then return it.
4. Write: update the data store first, then delete the cache key.

The ordering in step 4 matters. If you delete the cache key first, a concurrent reader can miss, read the old row, and re-cache it before your store write lands, leaving stale data until TTL. Do not cache null/missing results blindly (the Azure sample skips caching null); if you want negative caching, give it a short, separate TTL.

```python
def get_user(uid):
    v = cache.get(f"user:{uid}")
    if v is not None:
        return v
    v = db.load_user(uid)                 # miss path
    if v is not None:
        cache.set(f"user:{uid}", v, ttl=300 + jitter(30))
    return v

def update_user(u):
    db.save_user(u)                       # 1. store first
    cache.delete(f"user:{u.id}")          # 2. then invalidate
```

## What cache-aside does not guarantee

- No consistency: an external process can change the store at any time and the cache stays stale until expiry or invalidation.
- Staleness window after a write: between invalidation and the next read a reader sees a miss or a briefly stale value. If read-after-write freshness matters on a read-heavy path, use write-through.
- Under eventual consistency (replicated store) the instance that repopulates the cache may read an old replica and re-cache old data. Read from the primary, or use shorter TTLs for such keys.
- A local in-process cache is private per instance, so instances diverge. Expire private caches sooner or move to a shared cache.

## Lazy loading vs write-through (AWS/ElastiCache page)

| | Lazy loading | Write-through |
|---|---|---|
| Strength | Only requested data is cached; node loss is survivable (misses just hit the DB) | Cache never stale relative to writes; read penalty moves to write path (users tolerate slower writes more than slower reads) |
| Weakness | Miss costs three trips (cache, DB, cache write); data can go stale | New/empty node lacks data until written; most written data is never read (cache churn) |
| Fix | Add TTL or write-through | Add TTL, combine with lazy loading |

The page's conclusion: combine them, and put a TTL on every write. TTL does not guarantee freshness; it bounds how stale data can get and forces occasional refresh. Expired keys behave as not found.

## Azure guidance on write consistency

- Invalidate on write: simple write path, brief stale/miss window.
- Write-through: update store and cache in one write and answer only after both succeed; higher write latency and more coordination. Use only for read-heavy paths needing read-after-write freshness. For data rarely read after write, or constantly changing, invalidate or bypass the cache.
- Highly dynamic, non-critical data (e.g. device telemetry) may live only in the cache if losing an occasional change is acceptable (inference: never for audited data).

## Write-behind (not read from source)

Write-behind batches or delays store writes for throughput. Risks that follow from the definition (own inference): data loss if the cache node dies before flush, ordering and retry complexity, and the cache effectively becoming the system of record. Reject it for critical data; if needed, front it with a durable queue (see `background-worker-job-scheduler`) instead of trusting volatile memory.

## Lifetime, eviction, priming

- TTL too short: constant store hits; too long: stale data. Match TTL to access pattern and to how much staleness the business tolerates.
- Absolute vs sliding expiration: sliding keeps hot items alive; absolute bounds staleness. Per-item overrides beat a single global policy, especially for items expensive to rebuild.
- Eviction is LRU by default; alternatives are MRU, FIFO and explicit removal on a triggering event. Disabling eviction risks exceeding memory and failing writes.
- Priming (seeding) at startup suits reference data, but a large seed causes a sudden load spike on the store; seed the daily-active subset only.
- Semantic (embedding-keyed) caching for LLM calls is only safe when equivalent questions get equivalent answers and no user-specific or sensitive data is cached.

## How an agent should apply this

- Default to cache-aside with update-store-then-delete-key and a jittered TTL on every set; state the max tolerated staleness in the code comment.
- Pick write-through only when a stated requirement needs read-after-write freshness on a read-heavy key; otherwise invalidate.
- Never make the cache the only copy of data worth keeping; reject write-behind on critical data.
- Namespace keys with entity and version (`user:v2:{id}`), and never cache per-user or sensitive data in a shared key space without a user-scoped key and access control.
- Do not cache null results without a short, explicit negative TTL.
