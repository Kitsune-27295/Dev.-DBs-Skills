# Sources — PostgreSQL Diagnostics

## Provenance

This skill was not derived from official documentation. The author first wrote private DDL/SQL best-practice files for SQL Server 2022 (the author's own unpublished material, no public URL); the `sql-server-diagnostics` skill and its 2022 script set were created from them. The author then researched and created the SQL Server 2019 and 2025 ports; the PostgreSQL skill and the SQLite skill followed the same pattern. The official pages below were used later, only to verify claims.

Every URL below was checked as a verification source on 2026-11-24.

Retrieval used WebFetch (Firecrawl had no credits). "200 OK" means the page returned content; the long monitoring pages were read in part (first 100,000 characters, plus a second window where noted), which is stated in the status.

| Verification source | Retrieved status | What it confirms |
|---|---|---|
| https://www.postgresql.org/docs/18/monitoring-stats.html | 200 OK (read to char ~100,000 of 117,838, two windows) | Statistics reset rules (clean shutdown keeps, crash/base backup/PITR resets), `stats_fetch_consistency`, 1-second flush lag, `wait_event_type` list, `pg_stat_activity`, `pg_stat_replication` lag columns, `pg_stat_database`, `pg_stat_checkpointer`, `pg_stat_io`, `pg_stat_wal`, table and index counters, `pg_stat_archiver`, `pg_stat_ssl` |
| https://www.postgresql.org/docs/17/monitoring-stats.html | 200 OK (read to char 100,000 of 111,754) | `pg_stat_checkpointer` columns, 4-column `pg_stat_bgwriter`, `op_bytes` still in `pg_stat_io`, `wal_write`/`wal_sync` still in `pg_stat_wal` |
| https://www.postgresql.org/docs/16/monitoring-stats.html | 200 OK (read to char 100,000 of 107,142) | Checkpoint columns in `pg_stat_bgwriter`, `buffers_backend`, `pg_stat_io` with `op_bytes`, `pg_stat_wal` write/sync columns, `last_seq_scan`/`last_idx_scan` |
| https://www.postgresql.org/docs/18/routine-vacuuming.html | 200 OK | Wraparound mechanics, 200 million default, 40 million warning, 3 million refusal, aggressive and eager vacuum, autovacuum threshold formulas, bloat and `VACUUM FULL` cost |
| https://www.postgresql.org/docs/18/view-pg-locks.html | 200 OK | `pg_locks` columns, `granted`, advice to use `pg_blocking_pids()`, snapshot and cost caveats |
| https://www.postgresql.org/docs/18/pgstatstatements.html | 200 OK | Setup, view columns, `pg_stat_statements_info`, `max` eviction and `dealloc`, normalization, visibility of query text, reset functions |
| https://www.postgresql.org/docs/16/pgstatstatements.html | 200 OK | 16 column list (`blk_read_time`, no `shared_blk_read_time`) |
| https://www.postgresql.org/docs/18/catalog-pg-index.html | 200 OK | `indisvalid`, `indisready`, `indkey`, `indclass`, `indpred`, `indexprs` semantics |
| https://www.postgresql.org/docs/18/catalog-pg-class.html | 200 OK | `reltuples` and `relpages` as estimates, `relfrozenxid`, `relkind` letters, `relallfrozen` |
| https://www.postgresql.org/docs/18/predefined-roles.html | 200 OK | `pg_monitor` and its three member roles |
| https://www.postgresql.org/docs/18/view-pg-replication-slots.html | 200 OK | Slot columns, `wal_status`, `safe_wal_size`, `invalidation_reason` values, retained-WAL risk |
| https://www.postgresql.org/docs/17/view-pg-replication-slots.html | 200 OK | `inactive_since`, `invalidation_reason`, `failover`, `synced` present in 17 |
| https://www.postgresql.org/docs/16/view-pg-replication-slots.html | 200 OK | 16 has `conflicting` and none of the 17 additions |
| https://www.postgresql.org/docs/release/16.0/ | 200 OK | `pg_stat_io` added, last scan timestamps, `n_tup_newpage_upd`, `pg_use_reserved_connections` |
| https://www.postgresql.org/docs/release/17.0/ | 200 OK | `pg_stat_checkpointer` created, `buffers_backend` removed, `pg_stat_statements` block-time renames, slot columns, `pg_wait_events` |
| https://www.postgresql.org/docs/release/18.0/ | 200 OK | `pg_stat_io` byte columns and WAL rows, `pg_stat_wal` columns removed, `num_done`, vacuum timing columns, eager freezing, `autovacuum_vacuum_max_threshold`, `idle_replication_slot_timeout` |

## Claims and caveats

Container evidence (author's own, not from docs): the README statements "93 runs, 0 failures", the exact builds 16.16/17.12/18.7, the `pg_monitor`-only second pass, and "nothing was run on 14, 15, a standby or a busy server" describe the skill author's own test runs. No documentation page can confirm them.

Confirmed against the docs:
- 17 moved checkpoint counters to `pg_stat_checkpointer`; 18 added `num_done`.
- `pg_stat_statements` `blk_read_time` is `shared_blk_read_time` from 17.
- `pg_stat_io` has `op_bytes` in 16 and 17, and `read_bytes`/`write_bytes`/`extend_bytes` in 18 with `op_bytes` removed; 18 removed `wal_write`, `wal_sync`, `wal_write_time`, `wal_sync_time` from `pg_stat_wal`.
- Slot columns: `conflicting` in 16; `inactive_since` and `invalidation_reason` added in 17.

Not confirmed or worth correcting:
- README says `pg_stat_io` came "in 16 and later": the 16 release notes confirm it.
- The 18 `pg_stat_io` docs say WAL rows exist in 18 only; the README says to use `pg_stat_io` for WAL counters but does not mention it needs `track_wal_io_timing` for times (18 release notes).
- 17 also removed `buffers_backend` and `buffers_backend_fsync` from `pg_stat_bgwriter` (release notes). (resolved 2026-11-24: the README difference table now lists it, confirmed on the 17.0 release notes.)
- 18 adds a fourth `invalidation_reason` value (`idle_timeout`); README said slots are "same as 17". (resolved 2026-11-24: README now names `idle_timeout`, confirmed on the 18 `pg_replication_slots` page.)
- The 18 `pg_stat_statements` page lists `shared_blk_read_time`; the wider 17 pg_stat_statements page was not read, so the "renamed in 17" claim rests on the 17.0 release notes only.
- "PostgreSQL does not index the referencing side of a foreign key", "`pg_hba_file_rules` needs a superuser", and "`pg_monitor` alone sees no row for a sequence without USAGE/SELECT" were not read from a page in this session; treat them as unverified here.
- Xid-age percentage is computed over 2,147,483,647; the docs describe about 2 billion usable XIDs, so the percentage is an approximation of headroom, not an exact distance.

## Added 2026-11-24

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.postgresql.org/docs/current/explicit-locking.html | 200 (summarizing fetch tool) | row and table lock modes, advisory locks, deadlock prevention; lock queueing is marked general knowledge on the fetch (added 2026-11-24) |
| https://www.postgresql.org/docs/current/sql-select.html (locking clause) | 200 (summarizing fetch tool) | NOWAIT, SKIP LOCKED, restrictions (added 2026-11-24) |
| https://www.postgresql.org/docs/current/runtime-config-connection.html, runtime-config-client.html | 200 (summarizing fetch tool) | connection limits, reserved slots, four timeouts (added 2026-11-24) |
| https://www.pgbouncer.org/features.html | 200 (summarizing fetch tool) | pool modes and transaction-mode restrictions; version of prepared-statement support not stated (added 2026-11-24) |
| Third-party skill collection on Postgres and Supabase best practices, read for topic coverage only, no text reused (license: MIT per the collection; not verified here) | read locally | topic coverage only (added 2026-11-24) |
