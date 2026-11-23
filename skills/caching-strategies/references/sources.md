# Sources — Caching Strategies

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/architecture/patterns/cache-aside | 200 OK (via WebFetch; Firecrawl had no credits). Page dated 2025-09 | Cache-aside steps, update-then-invalidate ordering, lifetime/eviction/priming/consistency/local/semantic-cache considerations, when not to use |
| https://learn.microsoft.com/en-us/azure/architecture/best-practices/caching | 200 OK (WebFetch, full text saved and read; page updated 2026-03) | Private vs shared cache, invalidate-on-write vs write-through, expiration/eviction, client-side invalidation by URI change, optimistic/pessimistic concurrency, HA/fallback, eventual consistency/CAP, protecting cached data. Redis/.NET implementation sections skimmed by heading only |
| https://docs.aws.amazon.com/whitepapers/latest/database-caching-strategies-using-redis/caching-patterns.html | 200 OK but the fetched body was the ElastiCache page "Caching strategies for Memcached" (lazy loading, write-through, adding TTL, read replicas), not the Redis whitepaper text. Retried once with the same result | Lazy loading / write-through / TTL pros, cons and pseudocode as served. Write-behind and the whitepaper's own wording were NOT read from source; any write-behind statement in this skill is labelled "not read from source" |
| https://upstash.com/kb/thundering-herd-problem-cache-stampede | 200 OK (WebFetch) | Stampede definition, five mitigations (lock, coalescing, TTL jitter, XFetch, stale-while-revalidate), benchmarks, comparison table, caveats |
| https://httpwg.org/specs/rfc9111.html | 200 OK (WebFetch, read in two segments covering roughly sections 1-7; the last ~17 KB of the text, appendices and IANA, not read) | Storing rules, Vary matching, freshness/age formulas, validation, invalidation, Cache-Control directives, security considerations |
| https://www.rfc-editor.org/rfc/rfc5861.txt (extra page) | 200 OK (WebFetch) | stale-while-revalidate and stale-if-error semantics, which RFC 9111 only cites as extensions in 4.2.4 |
