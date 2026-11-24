# Version Differences 16, 17 and 18

Sources: https://www.postgresql.org/docs/release/16.0/, https://www.postgresql.org/docs/release/17.0/, https://www.postgresql.org/docs/release/18.0/, https://www.postgresql.org/docs/16/monitoring-stats.html, https://www.postgresql.org/docs/17/monitoring-stats.html, https://www.postgresql.org/docs/18/monitoring-stats.html, https://www.postgresql.org/docs/16/pgstatstatements.html, https://www.postgresql.org/docs/18/pgstatstatements.html, https://www.postgresql.org/docs/16/view-pg-replication-slots.html, https://www.postgresql.org/docs/17/view-pg-replication-slots.html · Last verified 2026-11-24

This checks the five-file table in `references/README.md` against the documentation and adds changes that needed no script split.

## The five differing scripts

| Script | 16 | 17 | 18 | Doc basis |
|---|---|---|---|---|
| `checkpoints/checkpoint_stats` | counters in `pg_stat_bgwriter` | new `pg_stat_checkpointer` (`num_timed`, `num_requested`, `write_time`, `sync_time`, `buffers_written`, restartpoint columns) | adds `num_done` | 17 and 18 release notes |
| `queries/top_queries_reads` | `blk_read_time` | `shared_blk_read_time` | same | 17 notes; 16 and 18 pg_stat_statements pages |
| `io/io_overview` | `op_bytes` | `op_bytes` | `read_bytes`, `write_bytes`, `extend_bytes`; `op_bytes` removed (it always equalled the block size) | 18 notes |
| `wal/wal_stats` | `wal_write`, `wal_sync` and times in `pg_stat_wal` | same | those four columns removed; WAL rows appear in `pg_stat_io`, timed by `track_wal_io_timing` | 18 notes |
| `replication/replication_slots` | `conflicting` | adds `inactive_since`, `invalidation_reason` (and `failover`, `synced`) | same columns; `idle_timeout` becomes a possible reason | slot pages |

All five rows match the docs. Also in 17: `buffers_backend` and `buffers_backend_fsync` left `pg_stat_bgwriter` as redundant with `pg_stat_io`. The README table does not list this, but it is why the 16 checkpoint script reads a column that is gone later.

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
