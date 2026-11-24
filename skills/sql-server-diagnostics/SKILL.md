---
name: sql-server-diagnostics
description: Use for a SQL Server health check built from ready, read-only diagnostic queries (30 scripts - identity and version, configuration, backups, databases and VLFs, disk, tempdb, memory, I/O, waits, top queries, missing, unused and fragmented indexes, deadlocks, suspect pages, high availability, Agent jobs, sysadmins, SQL logins, linked servers), written for SQL Server 2022, with a folder for SQL Server 2019 (checked against documentation) and one for 2025 (partly run on a real instance). Use it whenever someone asks to check, audit or upgrade a SQL Server instance, mentions DMVs, wait stats, page life expectancy, missing indexes or backup gaps, or moves between SQL Server versions, even without naming the scripts.
---

# SQL Server diagnostics (2019, 2022 and 2025)

Thirty `SELECT`-only scripts per version in `references/sql2019/`, `sql2022/` and `sql2025/` (31 on 2025), one per question about an instance. They change nothing, so the only risk
is load and exposure of what they print. Database-wide fundamentals (exposure, backups, schema, performance) live in `database-audit`;
this skill is the SQL Server tool box under them, and `query-performance` is the generic version of its index and query scripts.

## Steps

1. **Pick the version first.** Run `references/sql2022/identity/server_identity.sql` (or read `SERVERPROPERTY('ProductMajorVersion')`):
   15 is SQL Server 2019, 16 is 2022, 17 is 2025. Use the folder of that version (`references/sql2019/`, `sql2022/`, `sql2025/`) and read
   its guide (`references/sql2019-porting.md`, `references/sql2025-porting.md`) once before the first run: permissions and defaults differ.
2. **Choose the scripts for the question** from the table in `references/sql2022/README.md` (area, what it answers, cost). A full
   health check runs every *light* script, then the *medium* and *heavy* ones only with the owner's OK.
3. **Run one script at a time**, with a login that holds the permissions of the instance's version (they differ: see the porting
   guides). Keep each result next to the script name.
4. **Read counters in context.** Waits, I/O, missing and unused indexes and top queries accumulate since the last restart: compare
   with `sqlStartTime` before judging them. Index fragmentation is advice, not an order: rebuild above 30%, reorganize 5-30%.
5. **Report:** per area, what the result says, what it does not prove, risk (high, medium, low) and the next check. A script that
   returns nothing is reported as "nothing found", never as "healthy".

## Rules

- Production is queried only after the owner approves the list; hand over the command when you cannot run it.
- Never alter the instance from here (no `sp_configure`, `ALTER`, `DBCC` repair, index rebuild); propose the statement, the owner runs it.
- Output holds host names, accounts and query text: keep it in the report, do not paste it to external services.
- Run status differs by folder: 2025 was run in part on a real instance (11 scripts, listed in its guide), 2019 only checked against
  documentation, 2022 is the baseline. Say "not run on <version>" for anything not covered.
- To change a script, edit it in every version folder it exists in, name any difference in the porting guide's "differs" or "changes"
  section, and run `python scripts/check_versions.py references sql20 references/sql2019-porting.md references/sql2025-porting.md`.

References (read only the one you need):
- `references/sql2022/README.md`: the index of the 30 scripts and how to read results.
- `references/sql2019-porting.md`: what changes on 2019 (permissions, defaults, lifecycle).
- `references/sql2025-porting.md`: what changes on 2025 (breaking changes, new objects, defaults).

## Deep references

- [Wait stats, I/O and blocking](references/wait-stats-and-blocking-interpretation.md) — read when interpreting waits, latency, counters or deadlock evidence.
- [Index DMVs and reset rules](references/index-dmvs-and-reset-semantics.md) — read before reporting missing or unused indexes.
- [Top queries and Query Store](references/query-store-and-plan-regression.md) — read when cached top queries are not enough or plans regress.
- [Backup, log and CHECKDB evidence](references/backup-log-and-recovery-health.md) — read when judging backup history, VLF counts or last CHECKDB.
- [Version differences 2019, 2022, 2025](references/version-differences-2019-2022-2025.md) — read to cross-check the porting guides and lifecycle dates.
- Caveat: `backup_status.sql` does not filter `is_copy_only`, so a copy-only full can show as the last full; check `is_copy_only` before reporting restore points.
- [Sources](references/sources.md) — read for URL status and unconfirmed claims.
