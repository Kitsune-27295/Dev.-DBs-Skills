# Version Differences 16, 17 and 18

Sources: https://www.postgresql.org/docs/release/16.0/, https://www.postgresql.org/docs/release/17.0/, https://www.postgresql.org/docs/release/18.0/, https://www.postgresql.org/docs/16/monitoring-stats.html, https://www.postgresql.org/docs/17/monitoring-stats.html, https://www.postgresql.org/docs/18/monitoring-stats.html, https://www.postgresql.org/docs/16/pgstatstatements.html, https://www.postgresql.org/docs/18/pgstatstatements.html, https://www.postgresql.org/docs/16/view-pg-replication-slots.html, https://www.postgresql.org/docs/17/view-pg-replication-slots.html · Last verified 2026-11-27

This checks the five-file table in `references/README.md` against the documentation and adds changes that needed no script split.

## Doc basis for the five differing scripts

The per-script table is `references/README.md` (the single owner). Checked 2026-11-27 against the pages above, all five rows hold:

- Checkpoints: 17 notes (`pg_stat_checkpointer` created, columns moved) and 18 notes (`num_done`).
- Reads by statement: 17 notes (rename to `shared_blk_read_time`); the 16 and 18 `pg_stat_statements` pages.
- I/O: 18 notes (`read_bytes`, `write_bytes`, `extend_bytes`; `op_bytes`, which always equalled the block size, removed).
- WAL: 18 notes (`wal_write`, `wal_sync` and their times removed from `pg_stat_wal`; WAL rows in `pg_stat_io`, timed by `track_wal_io_timing`).
- Slots: the 16, 17 and 18 slot pages. 16 has 16 columns including `conflicting`; 17 adds `inactive_since`, `invalidation_reason`, `failover`, `synced`; 18 adds the `idle_timeout` reason.

Also in 17: `buffers_backend` and `buffers_backend_fsync` left `pg_stat_bgwriter` as redundant with `pg_stat_io`.

## Changes that matter for interpretation

- 16: `pg_stat_io` is new; table and index views gain last-scan timestamps (`last_seq_scan`, `last_idx_scan`, confirmed on the 16 page), which help judge "unused" before counts accumulate; `n_tup_newpage_upd` counts updates that moved rows to a new page; `pg_use_reserved_connections` reserves connection slots.
- 17: `pg_stat_statements` gains `stats_since`, `minmax_stats_since`, local block times and a `minmax_only` reset option; `pg_wait_events` describes wait events; vacuum is no longer capped at 1 GB for dead-item memory.
- 18: `total_vacuum_time`, `total_autovacuum_time`, `total_analyze_time`, `total_autoanalyze_time` in table views; `pg_stat_statements` adds parallel-worker and `wal_buffers_full` columns; `autovacuum_vacuum_max_threshold`; eager freezing; per-backend I/O functions; `pg_upgrade` keeps optimizer statistics but not extended ones.

## How an agent should apply this

- Choose the folder from `server_version_num`; on any other version expect exactly these five scripts to fail first.
- Do not compare backend-written buffers across versions: on 17 and later that count lives in `pg_stat_io`.
- Do not carry `queryid` values across major versions; the docs do not guarantee stability.
- After `pg_upgrade` to 18, expect planner statistics to be kept, but extended statistics still need `ANALYZE`.
- On "column does not exist", report the version mismatch first.
