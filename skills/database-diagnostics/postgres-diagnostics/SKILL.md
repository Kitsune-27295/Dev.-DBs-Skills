---
name: postgres-diagnostics
description: Use when a PostgreSQL server (16, 17 or 18) needs a read-only health check from ready SELECT scripts, 31 per version: uptime and settings, connections and long queries, blocking locks, top statements, table and index bloat and dead rows, transaction-ID age, unused, duplicate, invalid and missing-foreign-key indexes, cache hit, checkpoints, WAL, replication slots, archiver, roles, pg_hba, TLS, prepared transactions and sequences. Not for tuning one slow query (query-performance), a cross-database audit (database-audit) or SQL Server and SQLite (their own diagnostics skills). Use when someone asks to check, audit or upgrade-review a Postgres server, or mentions pg_stat views, bloat, wraparound, idle in transaction, replication lag or slot growth.
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

## Quick Decision Checklist

- [ ] Did I check the server version and pick the matching pg16, pg17 or pg18 folder?
- [ ] Did I choose scripts for the question from the references table?
- [ ] Am I using the least privilege that works (pg_monitor) and psql with ON_ERROR_STOP?
- [ ] Has the owner approved the script list before I query production?
- [ ] Am I avoiding any server change, only proposing the statement for the owner to run?
- [ ] Did a missing pg_stat_statements become a finding rather than something I install?
- [ ] Do I read counters since stats_reset and treat zero rows as nothing found, not healthy?
- [ ] Is the output kept out of external services?

## Deep references

- [Query pack index](references/README.md) — read to pick the script that answers a question, per version folder.
- [Statistics views and reset semantics](references/stats-views-and-reset-semantics.md) — read before trusting any counter-based finding (unused index, scans, statements).
- [Vacuum, bloat and wraparound concepts](references/vacuum-bloat-and-wraparound-concepts.md) — read when dead rows, autovacuum lag or transaction-ID age appears.
- [Locks and activity interpretation](references/locks-and-activity-interpretation.md) — read for blocking, idle-in-transaction, replication lag and slot results.
- [Index health queries explained](references/index-health-queries-explained.md) — read before proposing to drop, rebuild or add an index.
- [Version differences 16, 17 and 18](references/version-differences-16-17-18.md) — read when a script fails or the server is not on the tested version.
- [Sources](references/sources.md) — URLs checked, reading limits and claims not adopted.
- [Trigger evals](references/trigger-evals.md) — three should-trigger and three near-miss prompts for this skill's description.
- [Lock modes, SKIP LOCKED, advisory locks and deadlocks](references/lock-modes-skip-locked-advisory-and-deadlocks.md) — read when a blocking or deadlock result needs the lock mechanics, or a queue claim is proposed.
- [Connection limits, timeouts and pooling](references/connection-limits-and-pooling.md) — read when connection counts are high, idle-in-transaction appears, or a pooler is proposed.
