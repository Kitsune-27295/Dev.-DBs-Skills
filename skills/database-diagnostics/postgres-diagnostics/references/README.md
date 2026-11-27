# PostgreSQL diagnostics: 31 read-only queries for versions 16, 17 and 18

Folders `pg16/`, `pg17/`, `pg18/` hold the same 31 queries, one file per question. Each is one `SELECT` over catalog or
statistics views, capped with `LIMIT`, with camelCase aliases. None changes state. Pick the folder of the server's major version
(`SHOW server_version_num`: 16xxxx, 17xxxx, 18xxxx); on another version start from the nearest folder and read the differences
below.

## How this was proven

Every file was run on a throwaway container of its own version: PostgreSQL 16.16, 17.12 and 18.7 (93 runs, 0 failures), against a
database with a foreign key without index, a duplicate index, an unused index, an invalid index, dead rows and
`pg_stat_statements` loaded. A second pass ran them as a role holding only `pg_monitor`: everything passed except
`security/hba_rules.sql`, which needs a superuser. Cross-version runs proved the differences below: the 16 scripts of
`checkpoints/checkpoint_stats` and `queries/top_queries_reads` fail on 17 and 18; `io/io_overview` and `wal/wal_stats` fail only on 18
(17 behaves like 16 there); `replication/replication_slots` runs everywhere but omits the 17+ columns. Nothing was run on 14, 15,
on a standby, on a replica with traffic or on a busy server.

## Scripts

No script reads table data: they read catalog and statistics views and size functions, so all are cheap on a normal server.
Scripts marked `db` describe the database you are connected to; run them in each database you care about, the `cluster` ones once.

| Area | File | What it answers | Scope |
|---|---|---|---|
| identity | `identity/server_identity.sql` | version, uptime, role, encoding, checksums, connection headroom | cluster |
| config | `config/instance_configuration.sql` | the settings that matter and where each value comes from | cluster |
| config | `config/extensions.sql` | installed extensions and available updates | db |
| databases | `databases/database_inventory.sql` | size, cache hit, temp files, deadlocks, transaction-ID age | cluster |
| connections | `connections/connections_by_state.sql` | connections by database, user and state | cluster |
| connections | `connections/long_running.sql` | long queries and long idle-in-transaction sessions | cluster |
| locks | `locks/blocking.sql` | who waits and who blocks | cluster |
| deadlocks | `deadlocks/deadlock_counters.sql` | deadlocks and rollbacks per database | cluster |
| queries | `queries/top_queries_time.sql`, `top_queries_mean.sql`, `top_queries_reads.sql` | heaviest statements (needs `pg_stat_statements`) | cluster |
| tables | `tables/table_sizes.sql` | the biggest tables, table and index size | db |
| tables | `tables/dead_tuples_autovacuum.sql` | dead rows and the last vacuum and analyze | db |
| tables | `tables/seq_scan_heavy.sql` | big tables read mostly by sequential scan | db |
| tables | `tables/table_xid_age.sql` | tables nearest to a forced freeze | db |
| indexes | `indexes/unused_indexes.sql` | indexes never scanned | db |
| indexes | `indexes/duplicate_indexes.sql` | indexes that repeat each other | db |
| indexes | `indexes/missing_fk_indexes.sql` | foreign keys without a supporting index | db |
| indexes | `indexes/invalid_indexes.sql` | indexes left invalid by a failed concurrent build | db |
| io | `io/io_overview.sql` | cluster I/O by backend, object and context (`pg_stat_io`) | cluster |
| io | `io/cache_hit_ratio.sql` | heap and index cache hit of the tables that read most | db |
| checkpoints | `checkpoints/checkpoint_stats.sql` | timed versus requested checkpoints, writes | cluster |
| wal | `wal/wal_stats.sql` | WAL volume, full-page images, current position | cluster |
| replication | `replication/replication_status.sql` | replicas and their lag | cluster |
| replication | `replication/replication_slots.sql` | slots and the WAL they hold back | cluster |
| backup | `backup/archiver_status.sql` | WAL archiving health | cluster |
| security | `security/roles_overview.sql` | superusers and powerful attributes, password expiry | cluster |
| security | `security/hba_rules.sql` | `pg_hba.conf` rules (superuser only) | cluster |
| security | `security/ssl_connections.sql` | connections with and without TLS | cluster |
| maintenance | `maintenance/prepared_transactions.sql` | forgotten two-phase transactions | cluster |
| maintenance | `maintenance/sequence_exhaustion.sql` | sequences nearest their maximum | db |

## What differs between 16, 17 and 18

| File | 16 | 17 | 18 |
|---|---|---|---|
| `checkpoints/checkpoint_stats.sql` | `pg_stat_bgwriter` holds the checkpoint columns | checkpoint columns moved to `pg_stat_checkpointer` | same, plus `num_done` |
| `queries/top_queries_reads.sql` | `blk_read_time` | renamed `shared_blk_read_time` | same as 17 |
| `io/io_overview.sql` | bytes = reads x `op_bytes` | same as 16 | `read_bytes` and `write_bytes` columns, `op_bytes` gone |
| `wal/wal_stats.sql` | write and sync counters and times in `pg_stat_wal` | same as 16 | those columns are gone: use `pg_stat_io` |
| `replication/replication_slots.sql` | `conflicting` | adds `inactive_since`, `invalidation_reason` | same columns; `invalidation_reason` adds `idle_timeout` (`idle_replication_slot_timeout`) |

The 16 `pg_stat_bgwriter` also has `buffers_backend` and `buffers_backend_fsync`; 17 removed both (see `pg_stat_io`), so the 17 and 18 scripts omit them.

Every other file is identical across the three folders apart from the first comment line. After any edit run
`python scripts/check_versions.py references pg references/README.md` from the skill folder: it fails when a file differs between versions and
this section does not name it.

## Reading the results

- Counters (`pg_stat_*`, `pg_statio_*`) accumulate since the last statistics reset (`stats_reset` in the output). A restart
  after a crash also resets them: compare with `startTime` from `identity/server_identity.sql`.
- Query text, host names and role names appear in the output. Treat it as sensitive and keep it in the report folder.
- `maintenance/sequence_exhaustion.sql` shows only sequences the role may read: `pg_monitor` alone can see no row for a sequence it
  has no `USAGE` or `SELECT` on, so grant that on the sequences you need checked.
- A least-privilege login: `GRANT pg_monitor TO <role>` covers every script but `hba_rules`. Superuser is not needed.
- A result is evidence, not a verdict: say what it means for this server and what to check next.
