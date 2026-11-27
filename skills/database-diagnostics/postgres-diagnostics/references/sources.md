# Sources — PostgreSQL Diagnostics

## Provenance

This skill was not derived from official documentation. The author first wrote private DDL/SQL best-practice files for SQL Server 2022 (the author's own unpublished material, no public URL); the `sql-server-diagnostics` skill and its 2022 script set were created from them. The author then researched and created the SQL Server 2019 and 2025 ports; the PostgreSQL skill and the SQLite skill followed the same pattern. The official pages below were used later, only to verify claims.

Every URL below was re-fetched with WebFetch on 2026-11-27 (a small summarizing model reads the page; Firecrawl had no credits). No URL was dead or redirected.

| Source | Retrieved status | What it confirms |
|---|---|---|
| https://www.postgresql.org/docs/18/monitoring-stats.html | 200 OK, first 100,000 of 117,838 characters | reset rules, `stats_fetch_consistency`, flush rate, wait event types, replication lag columns going NULL, `pg_stat_io`/`pg_stat_wal`/`pg_stat_checkpointer` columns, `pg_stat_ssl` |
| https://www.postgresql.org/docs/17/monitoring-stats.html | 200 OK, first 100,000 of 111,754 | `pg_stat_checkpointer` (9 columns), 4-column `pg_stat_bgwriter`, `op_bytes`, `wal_write`/`wal_sync` |
| https://www.postgresql.org/docs/16/monitoring-stats.html | 200 OK, first 100,000 of 107,142 | checkpoint and backend columns in `pg_stat_bgwriter`, `op_bytes`, WAL write/sync, last scan timestamps, `n_tup_newpage_upd` |
| https://www.postgresql.org/docs/18/routine-vacuuming.html | 200 OK | 200 million, 40 million warning, 3 million refusal, threshold formula, eager freezing, temp and partitioned tables, 0.95 cap |
| https://www.postgresql.org/docs/18/view-pg-locks.html | 200 OK | `pg_blocking_pids`, row locks absent, snapshot and cost caveats, `granted` |
| https://www.postgresql.org/docs/18/pgstatstatements.html | 200 OK | setup, `shared_blk_read_time`, `pg_stat_statements_info`, `max` 5000 and eviction, normalization, `queryid` not stable across major versions |
| https://www.postgresql.org/docs/16/pgstatstatements.html | 200 OK | 16 has `blk_read_time`, no `stats_since` |
| https://www.postgresql.org/docs/18/catalog-pg-index.html | 200 OK | `indisvalid`, `indisready`, `indislive`, `indkey`, `indnkeyatts`, `indpred`, `indexprs` |
| https://www.postgresql.org/docs/18/catalog-pg-class.html | 200 OK | `reltuples` estimate and -1, `relfrozenxid`, `relallfrozen` |
| https://www.postgresql.org/docs/18/predefined-roles.html | 200 OK | `pg_monitor` members |
| https://www.postgresql.org/docs/18/view-pg-replication-slots.html | 200 OK | slot columns, `wal_status`, `safe_wal_size`, four `invalidation_reason` values |
| https://www.postgresql.org/docs/17/view-pg-replication-slots.html | 200 OK | 20 columns incl. `conflicting`, `inactive_since`, `failover`, `synced`; three reasons |
| https://www.postgresql.org/docs/16/view-pg-replication-slots.html | 200 OK | 16 columns, `conflicting` only |
| https://www.postgresql.org/docs/release/16.0/ | 200 OK | `pg_stat_io`, last scans, `n_tup_newpage_upd`, `reserved_connections` |
| https://www.postgresql.org/docs/release/17.0/ | 200 OK | checkpointer view, `buffers_backend` removal, statements renames and `stats_since`, `pg_wait_events`; slot `failover`/`synced` columns are not named there (the slot page has them) |
| https://www.postgresql.org/docs/release/18.0/ | 200 OK | byte columns, WAL I/O, removed WAL columns, `num_done`, timing columns, eager freezing, max threshold, idle slot timeout, skip scan, `pg_upgrade` statistics |
| https://www.postgresql.org/docs/current/explicit-locking.html | 200 OK | lock modes, DDL locks, advisory locks, deadlock advice; lock queueing is not stated |
| https://www.postgresql.org/docs/current/sql-select.html | 200 OK | `NOWAIT`, `SKIP LOCKED`, restrictions, `LIMIT`, `ORDER BY` caveat |
| https://www.postgresql.org/docs/current/runtime-config-connection.html | 200 OK | connection limits and reserved slots; no per-connection memory figure |
| https://www.postgresql.org/docs/current/runtime-config-client.html | 200 OK | four timeouts, defaults 0, cautions |
| https://www.pgbouncer.org/features.html | 200 OK | pool modes, features unsupported in transaction mode; no default for `max_prepared_statements` |
| https://www.postgresql.org/docs/18/view-pg-hba-file-rules.html | 200 OK (added 2026-11-27) | readable only by superusers by default |
| https://www.postgresql.org/docs/18/ddl-constraints.html | 200 OK (added 2026-11-27) | foreign key creates no index on referencing columns; often worth adding |
| https://www.postgresql.org/docs/18/sql-createindex.html | 200 OK (added 2026-11-27) | failed `CONCURRENTLY` leaves an invalid index; drop and retry or `REINDEX INDEX CONCURRENTLY` |
| https://www.postgresql.org/docs/18/sql-dropindex.html | 200 OK (added 2026-11-27) | `DROP INDEX CONCURRENTLY` lock and restrictions |
| https://www.postgresql.org/docs/18/view-pg-sequences.html | 200 OK (added 2026-11-27) | `last_value` NULL without `USAGE`/`SELECT` |

## Reading limits

- The three `monitoring-stats` pages were read to character 100,000 only; the tail (including the index scan counters text) was not read.
- Pages were read through a summarizing fetch, not verbatim; quoted numbers come from that summary.
- The `.sql` scripts, `scripts/check_versions.py` and the README's "How this was proven" runs (93 runs, builds 16.16, 17.12, 18.7, `pg_monitor`-only pass) were not re-run or re-verified. They are the author's own evidence; no documentation page can confirm them.
- A third-party skill collection (MIT per the collection, not verified here) was read earlier for topic coverage only; no text reused.

## Claims not adopted

- "`idx_scan` can exceed executed queries because of array lookups and skip scans": removed. The 18 release notes confirm skip scans but say nothing about counting; the stats page tail was not read.
- "A waiting `ACCESS EXCLUSIVE` request makes later plain queries queue behind it": the locking page does not state it; kept only as labeled own inference.
- The `pg_stat_activity.state` value list and "non-superusers see other sessions' details as NULL" were not re-read this pass.
- Insert-threshold autovacuum and multixact warning/refusal behavior: removed from the vacuum file as not re-read.
- The 1 billion escalation point for XID age is the author's own threshold; the docs give 200 million, 40 million and 3 million. The percentage divides by 2,147,483,647, an approximation of headroom.
- `reltuples = -1` for never-analyzed: the page confirms it but not the starting version.
- Earlier claim that `pg_monitor` alone sees no sequence row without `USAGE`: contradicted by the `pg_sequences` page (row visible, `last_value` NULL); corrected in the README.
- Earlier claim that PgBouncer temporary tables never work in transaction mode: corrected, only `PRESERVE`/`DELETE ROWS` ones fail.
