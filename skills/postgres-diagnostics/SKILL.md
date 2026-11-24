---
name: postgres-diagnostics
description: Use for a PostgreSQL health check built from ready, read-only diagnostic queries (31 scripts per version for 16, 17 and 18 - version and uptime, settings, extensions, database size and transaction-ID age, connections, long queries, blocking locks, top statements from pg_stat_statements, table and index size, dead rows and autovacuum, unused, duplicate, missing-foreign-key and invalid indexes, cache hit, checkpoints, WAL, replication and slots, archiver, roles, pg_hba rules, TLS, prepared transactions, sequences), proven on real servers of each version. Use it whenever someone asks to check, audit, tune or upgrade a Postgres server, mentions pg_stat views, bloat, wraparound, idle in transaction, replication lag or slow queries on Postgres, even without naming the scripts.
---

# PostgreSQL diagnostics (16, 17, 18)

Thirty-one `SELECT`-only scripts per version in `references/pg16/`, `pg17/`, `pg18/`. They change nothing, so the risk is load and
what they print. Cross-database fundamentals (exposure, backups, schema, performance) live in `database-audit`; this is the
Postgres tool box under it, and `query-performance` is the generic method behind its index and statement scripts.

## Steps

1. **Pick the folder from the server's version.** Run `SHOW server_version_num` (16xxxx, 17xxxx, 18xxxx) and use the matching
   folder. Five files differ between versions (checkpoints, reads by statement, I/O, WAL, slots): the table is in
   `references/README.md`. On another version use the nearest folder and expect a failing script to need that table.
2. **Choose the scripts for the question** from the table in `references/README.md`. A full health check runs them all; the
   `db` scripts run once in each database that matters, the `cluster` ones once.
3. **Use the least privilege that works:** `GRANT pg_monitor` to a login is enough for every script but `security/hba_rules.sql`
   (superuser). Run `psql -X -v ON_ERROR_STOP=1 -f <file>` so one failure stops loudly instead of printing a partial answer.
4. **Needs `pg_stat_statements`?** The three `top_queries_*` scripts fail with "relation does not exist" when the extension
   is not in `shared_preload_libraries` or not created in that database: report that as a finding, never install it yourself.
5. **Read counters in context.** Statistics accumulate since `stats_reset`; unused indexes and sequential scans need weeks of
   normal traffic to mean anything, and a replica has its own counters.
6. **Report:** per area, what the result says, what it does not prove, risk (high, medium, low) and the next check. A script that
   returns no rows is "nothing found", never "healthy".

## Rules

- Production is queried only after the owner approves the list; hand over the command when you cannot run it.
- Never change the server from here (`ALTER SYSTEM`, `VACUUM`, `REINDEX`, `DROP INDEX`, `pg_terminate_backend`); propose the
  statement and the owner runs it. An invalid index or a stuck slot is a proposal, not an action.
- Output holds query text with literal values, role names and addresses: keep it in the report, never send it to an external service.
- A port is proven only for the versions in the README; say "not run on <version>" for anything else.
- To change a script, edit every version folder it exists in and run `python scripts/check_versions.py references pg references/README.md` from the skill folder in the same change.

References: `references/README.md` (index of the scripts, differences between versions, how this was proven).

## Deep references

- [Statistics views and reset semantics](references/stats-views-and-reset-semantics.md) — read before trusting any counter-based finding (unused index, scans, statements).
- [Vacuum, bloat and wraparound concepts](references/vacuum-bloat-and-wraparound-concepts.md) — read when dead rows, autovacuum lag or transaction-ID age appears.
- [Locks and activity interpretation](references/locks-and-activity-interpretation.md) — read for blocking, idle-in-transaction, replication lag and slot results.
- [Index health queries explained](references/index-health-queries-explained.md) — read before proposing to drop, rebuild or add an index.
- [Version differences 16, 17 and 18](references/version-differences-16-17-18.md) — read when a script fails or the server is not on the tested version.
- [Sources](references/sources.md) — URLs checked and claims not confirmed.
- [Lock modes, SKIP LOCKED, advisory locks and deadlocks](references/lock-modes-skip-locked-advisory-and-deadlocks.md) — read when a blocking or deadlock result needs the lock mechanics, or a queue claim is proposed.
- [Connection limits, timeouts and pooling](references/connection-limits-and-pooling.md) — read when connection counts are high, idle-in-transaction appears, or a pooler is proposed.
