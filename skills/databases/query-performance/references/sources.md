# Sources — Query Performance

Every URL below was re-fetched and checked during the 2026-11-27 rebuild. Last verified 2026-11-27. "current" PostgreSQL documentation was version 19 on that date; versions 15 to 18 remain supported.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.postgresql.org/docs/current/ddl-constraints.html | 200 (summarizing fetch tool) | Primary and unique keys create an index; a foreign key does not on the referencing columns; referenced side must be indexed |
| https://www.postgresql.org/docs/current/sql-createindex.html | 200 (summarizing fetch tool) | `CONCURRENTLY`: no transaction block, two scans, invalid index on failure, one build per table, no partitioned parents; `INCLUDE` limits; expression index notes (added 2026-11-27) |
| https://www.postgresql.org/docs/current/using-explain.html | 200 (summarizing fetch tool) | Reading `EXPLAIN ANALYZE`, per-loop averages, rows removed by filter, rollback for writes (added 2026-11-27) |
| https://www.postgresql.org/docs/current/queries-limit.html | 200 (summarizing fetch tool) | Offset cost; unique `ORDER BY` for stable pages |
| https://www.postgresql.org/docs/current/functions-comparisons.html | 200 (summarizing fetch tool) | Lexicographic row comparison, null stops the comparison; index use is not stated on the page |
| https://www.postgresql.org/docs/current/indexes-multicolumn.html | 200 (summarizing fetch tool) | Leading equality plus first range limit the scan; three-column advice; skip scan described without a version |
| https://www.postgresql.org/docs/18/release-18.html | 200 (summarizing fetch tool) | Skip scan for multicolumn B-tree is new in 18 (added 2026-11-27) |
| https://www.postgresql.org/docs/current/indexes-partial.html | 200 (summarizing fetch tool) | Implication matching, parameter caveat, many partial indexes warning, partial unique |
| https://www.postgresql.org/docs/current/indexes-index-only-scans.html | 200 (summarizing fetch tool) | Visibility map, `INCLUDE` support, oversized entries, GIN has no index-only scans |
| https://www.postgresql.org/docs/current/indexes-expressional.html | 200 (summarizing fetch tool) | Write cost, same-expression rule, unique on `lower()` |
| https://www.postgresql.org/docs/current/ddl-rowsecurity.html | 200 (summarizing fetch tool) | Per-row evaluation, row-local policies best, sub-select races, bypass rules; no indexing advice or benchmarks |
| https://www.postgresql.org/docs/current/pgstatstatements.html | 200 (summarizing fetch tool) | Preload and restart, query ids, columns, normalization, `track` default, `queryid` stability |
| https://www.postgresql.org/docs/current/sql-insert.html | 200 (summarizing fetch tool) | `ON CONFLICT` target, `EXCLUDED`, atomic outcome, cardinality error, `RETURNING` |
| https://www.postgresql.org/docs/current/populate.html | 200 (summarizing fetch tool) | Bulk loading advice |
| https://www.postgresql.org/docs/current/routine-vacuuming.html | 200 (summarizing fetch tool) | No autovacuum analyze on partitioned parents; visibility map |
| https://wiki.postgresql.org/wiki/Don%27t_Do_This | 200 (summarizing fetch tool) | `NOT IN` and `BETWEEN` pitfalls (added 2026-11-27 as re-read) |
| https://web.dev/articles/vitals | 200 (summarizing fetch tool) | Three Core Web Vitals and thresholds; page last updated 2024-10-31 |
| https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe | 200 (summarizing fetch tool) | The four measured pairs, the CONCURRENTLY remark; server named only as a VPS plan |
| https://www.youtube.com/watch?v=TL4T9ZESamI | 200 but only navigation text returned | Title only; channel, date and chapters could not be re-verified |
| Third-party skill collection on Postgres and Supabase practices, read for topic coverage only, no text reused (MIT per the collection, not verified) | read locally, not re-fetched | Topic list for the gap table |
| Internal project skill, read for method only, no text, names or figures reused | read locally | Triage order |

## Reading limits

- Pages were read through a summarizing fetch tool, not raw HTML; quotes are paraphrased.
- The documentation fetched is the "current" version (19); statements about older versions rest on the release notes cited.
- No script or data file in this skill was edited or run in this rebuild.

## Claims not adopted

- The author's millisecond figures (58 to 0.37 ms, 151 to 0.64 ms, 104 to 0.15 ms, 232 to 0.18 ms): not reproduced; illustrative only.
- The earlier "2 vCPU, 8 GB" test server: the handout names only a VPS plan, so it is dropped.
- The video's throughput remarks (requests per second): not interpretable, not quoted.
- The internal skill's "about 4x" RLS cost: unverified.
- Planner use of an index for the row-comparison keyset pattern: not stated on the page; check with `EXPLAIN`.
- Indexing advice for RLS policy columns: the documentation gives none; it is the skill's inference.
