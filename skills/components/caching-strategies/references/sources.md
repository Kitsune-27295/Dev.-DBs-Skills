# Sources — Caching Strategies

Every URL below was checked during skill authoring (2026-11-23) and re-checked in a from-zero rebuild (2026-11-27). Last verified 2026-11-27.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/architecture/patterns/cache-aside | 200 OK via WebFetch, 2026-11-27 (page ms.date 2025-09-11), read in full | Cache-aside steps, update-store-then-invalidate ordering and its rationale, lifetime, eviction, per-item configuration, priming, consistency, staleness after writes, local cache, semantic cache, when not to use (sensitive data, static set, low hit rate, session affinity); names read-through, write-through and write-behind as features of commercial caches |
| https://learn.microsoft.com/en-us/azure/architecture/best-practices/caching | 200 OK via WebFetch, 2026-11-27 (page ms.date 2026-03-25); the long result was saved and the relevant sections read, Redis and .NET implementation sections skipped | Private vs shared cache, invalidate-on-write vs write-through, expiration (absolute or sliding), eviction (LRU, MRU, FIFO, effect of disabling it), client-side invalidation by URI change, optimistic and pessimistic concurrency, fallback and circuit breaker, replication and clustering, eventual consistency and CAP, protecting cached data |
| https://docs.aws.amazon.com/whitepapers/latest/database-caching-strategies-using-redis/caching-patterns.html | 200 OK, 2026-11-27, but the served body is the ElastiCache page "Caching strategies for Memcached" (read replicas, lazy loading, write-through, TTL), the same as in 2026-11-23; the Redis whitepaper text was not obtained | Lazy loading and write-through pros, cons and pseudocode, TTL semantics |
| https://upstash.com/kb/thundering-herd-problem-cache-stampede | 200 OK via WebFetch, 2026-11-27 | Stampede definition, five mitigations (lock, coalescing, jitter, XFetch, stale-while-revalidate), lock parameters, benchmark figures (vendor-run) |
| https://httpwg.org/specs/rfc9111.html | 200 OK via WebFetch, 2026-11-27; two summarizing fetches covered roughly characters 0-100000 of 117326; the last ~17 KB (appendices, IANA) not read | Storing and reuse rules, freshness and age formulas, directives, Vary, serving stale, validation, invalidation, security considerations, Pragma and Warning status |
| https://www.rfc-editor.org/rfc/rfc5861.txt | 200 OK via WebFetch, 2026-11-27 | stale-while-revalidate and stale-if-error semantics, error statuses, Informational status |
| https://www.rfc-editor.org/rfc/rfc8246.txt (added 2026-11-27) | 200 OK via WebFetch | `immutable` extension, Standards Track, applies only during freshness lifetime |

## Reading limits

- Fetches go through a summarizing model, not raw text, so quotes and section numbers are as reported by that summary; recheck a clause before quoting it.
- Firecrawl was not used (no credits); WebFetch only.
- Redis and .NET sections of the Azure caching page, and the RFC 9111 appendices, were not read.
- No scripts or data files exist in this skill.

## Claims not adopted as fact

- Write-behind risks (data loss before flush, ordering, cache becoming the system of record): our inference; no fetched source analyzes them.
- Per-class TTL ranges, "delete rather than update in place" as a rule, negative-cache TTL, versioned key format, stampede signature in metrics, "no cache for authorization decisions or checkout stock": our judgment.
- The Upstash benchmark numbers describe one vendor test, not general performance.
- The exact wording of RFC 9111 section 3 storage conditions: summarized, not quoted.
- The one-year `max-age` for fingerprinted assets: convention, not from a source read.
- The Redis whitepaper wording on write-behind: never obtained.
