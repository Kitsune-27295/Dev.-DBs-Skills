# Statistics Views and Reset Semantics

Sources: https://www.postgresql.org/docs/18/monitoring-stats.html, https://www.postgresql.org/docs/18/pgstatstatements.html, https://www.postgresql.org/docs/18/predefined-roles.html · Last verified 2026-11-24

Almost every script in this skill reads a cumulative statistics view. Whether its number means anything depends on when the counters last started from zero.

## How the counters live

- Each backend collects counters locally and flushes them to shared memory when it goes idle, at most about once per second. A view can trail reality by a second or so; `pg_stat_activity` is the exception and is current.
- Inside one transaction, repeated reads of a view return the same cached values (`stats_fetch_consistency = cache`, the default). A long `psql` session inside a transaction will not see new numbers: end the transaction or call `pg_stat_clear_snapshot()`.
- A clean shutdown writes the counters to disk and restores them at start, a physical standby included. An immediate shutdown, a crash, a start from a base backup or point-in-time recovery resets all of them.
- Most views carry `stats_reset`. `pg_stat_statements` has its own clock in `pg_stat_statements_info.stats_reset`, and each entry has `stats_since` (18 docs).
- Non-superusers see other sessions' details as NULL; `pg_read_all_stats` lifts that. `pg_monitor` includes `pg_read_all_stats`, `pg_read_all_settings` and `pg_stat_scan_tables`, which is why one grant covers the scripts.

## Mapping to the skill's queries

| Query | View | Reset clock |
|---|---|---|
| `tables/dead_tuples_autovacuum`, `seq_scan_heavy` | `pg_stat_user_tables` | no per-table clock in the output; use `pg_stat_database.stats_reset` and uptime |
| `indexes/unused_indexes` | `pg_stat_user_indexes` | same database-level clock |
| `queries/top_queries_*` | `pg_stat_statements` | `pg_stat_statements_info.stats_reset` |
| `checkpoints/checkpoint_stats` | `pg_stat_bgwriter`, `pg_stat_checkpointer` | their own `stats_reset` |
| `wal/wal_stats`, `io/io_overview` | `pg_stat_wal`, `pg_stat_io` | their own `stats_reset` |
| `databases/database_inventory`, `deadlocks/deadlock_counters` | `pg_stat_database` | `statsReset` column |

## Pitfalls

- **Zero is not proof.** An index with `idx_scan = 0` two days after a crash recovery has seen no representative traffic. Compare the reset time with uptime (`identity/server_identity`) before calling anything unused.
- **Estimates.** `n_live_tup`, `n_dead_tup` and `n_mod_since_analyze` are documented as estimated; `pg_class.reltuples` is a planner estimate, and -1 means never analyzed (the page does not say from which version that convention applies).
- **A scan counter can exceed the number of executed scans.** An `= ANY (array)` lookup or a B-tree skip scan (18) increments `idx_scan` per search, so the count says "used at least this much", not an exact query tally.
- **Replicas keep separate counters.** An index unused on the primary may serve a reporting replica.
- **`pg_stat_statements` gaps.** Min/max times are zero until the first run after a min-max reset; planning columns stay zero unless `track_planning` is on; I/O times stay zero unless `track_io_timing` is on. When distinct statements exceed `pg_stat_statements.max`, the least-executed entries are dropped (`dealloc` in `pg_stat_statements_info`), so a rising `dealloc` means the top list is incomplete.
- Queries that differ only in constants are merged into one entry with parameter markers, so `queryText` shows a pattern, not a real execution.

Example reading (own illustration):

```
tableName: public.orders  deadRows: 4,200,000  autovacuumCount: 3
database statsReset: yesterday
```

The low `autovacuumCount` is meaningless on its own: the counters restarted yesterday. Look at `lastAutovacuum` and the dead-row count instead, and say which window the numbers cover.

## How an agent should apply this

- Print the reset time and uptime next to every counter-based finding.
- Phrase zero or low counters as "not seen since <reset>", never "unused" or "healthy".
- Run counter queries on the primary and on each read replica before proposing a drop.
- Quote estimate columns to at most two significant digits.
- If activity columns come back NULL, report a missing `pg_monitor` membership as the cause, not an idle system.
