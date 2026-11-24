# PostgreSQL coverage gap table

Sources: https://www.postgresql.org/docs/current/ ( explicit-locking, sql-select, queries-limit, indexes-partial, indexes-index-only-scans, indexes-multicolumn, indexes-expressional, ddl-rowsecurity, sql-insert, populate, routine-vacuuming, runtime-config-connection, runtime-config-client, ddl-partitioning, ddl-identity-columns, sql-syntax-lexical, pgstatstatements ) · Last verified 2026-11-24

This table records a topic-level audit of the Postgres and Supabase guidance in the repository. The audit used a third-party skill collection about Postgres and Supabase best practices (38 rule files grouped by prefix: connections, data, locks, monitoring, query, schema, security, advanced) only as a list of topics; no text from it is reused. Every gap was filled from the official PostgreSQL documentation listed above, in the files named in the last column. Rule: one owner per topic; a neighbor links instead of repeating.

| Topic | Where it was covered before | Gap | Action (owner file) |
|---|---|---|---|
| Missing indexes, FK indexes | `query-performance` `missing-foreign-key-index.md` | none | none |
| EXPLAIN ANALYZE, rewrites | `query-rewrites-and-explain-reading.md` | none | none |
| Composite index column order | only "index on the filter, sort or join column" | order rule, range-stops-the-scan rule | `pagination-and-index-design.md` |
| Partial indexes | `postgres-diagnostics` mentions partial only as an exclusion in FK checks | when to use, planner matching rule, partial unique | `pagination-and-index-design.md` |
| Covering indexes (`INCLUDE`), index-only scans | none | `INCLUDE`, visibility map dependence | `pagination-and-index-design.md` |
| Expression indexes | one line in `SKILL.md` | maintenance cost, same-expression rule, unique on `lower()` | `pagination-and-index-design.md` |
| Keyset pagination | one line (`where id > :last`) | tie-breaker, row comparison, no random page jump | `pagination-and-index-design.md` |
| Index type choice (GIN, BRIN, GiST) | none | only the facts verified above are added (GIN has no index-only scans); the rest is not added | noted, not expanded |
| N+1 detection | loop-to-`JOIN` fix only | how to see it in the statistics view | `rls-bulk-writes-and-upserts.md` |
| Upsert, `ON CONFLICT` | none in DB skills (`idempotency-fix` is about webhooks) | conflict target, `EXCLUDED`, duplicate-in-batch error | `rls-bulk-writes-and-upserts.md` |
| Bulk loading | none | single transaction, `COPY`, indexes after load, `ANALYZE` | `rls-bulk-writes-and-upserts.md` |
| RLS performance | `database-exposure` covers access, not speed | per-row policy cost, row-local expressions, index the policy column | `rls-bulk-writes-and-upserts.md`; access rules stay in `database-exposure` |
| RLS policy patterns (`USING` / `WITH CHECK`, restrictive, default deny) | `database-exposure` `supabase-grants-and-rls.md`, `security-audit` | none | none (link only) |
| Row locks, `NOWAIT`, `SKIP LOCKED` | `race-condition-fix` mentions `FOR UPDATE` | lock modes, queue claim pattern, caveats | `postgres-diagnostics` `lock-modes-skip-locked-advisory-and-deadlocks.md` |
| Advisory locks | one bullet in `background-worker-job-scheduler` | session vs transaction level, pooling caveat | same file |
| Deadlocks | counter script only | cause and prevention (consistent order), retry | same file |
| Lock timeouts, idle-in-transaction | `locks-and-activity-interpretation.md` reads them | the settings to prevent them | `postgres-diagnostics` `connection-limits-and-pooling.md` |
| Connection limits and pooling | `connections_by_state` script | `max_connections`, reserved slots, transaction pooling restrictions | same file |
| Vacuum and statistics pitfalls | `postgres-diagnostics` `vacuum-bloat-and-wraparound-concepts.md` | `ANALYZE` after bulk change, partitioned tables are not auto-analyzed (added to `rls-bulk-writes-and-upserts.md` section on bulk loading) | linked |
| Primary key choice, identity vs serial, UUID | `postgres-column-type-pitfalls.md` mentions `serial` | identity semantics, UUID versions | `schema-and-constraints` `keys-identifiers-and-partitioning.md` |
| Identifier case folding | none | quoted vs unquoted, 63-byte truncation | same file |
| Partitioning | none | benefits, key must be in unique constraints, pruning | same file |
| Privileges and grants | `database-exposure` | none | none |
| Full-text search, JSONB indexing | none | out of scope for these skills; not verified here | not added |

## How an agent should apply this

- Before adding Postgres guidance to a skill, look up the topic here to find its owner and link to it.
- When a topic shows "none" in the gap column, do not add text: the existing skill already owns it.
- Topics marked "not added" need a new, separately sourced reference before anyone relies on them.
