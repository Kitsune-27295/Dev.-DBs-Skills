---
name: sql-server-diagnostics
description: "Run ready, read-only SQL Server health-check scripts (30 per version, 31 on 2025; folders for 2019, 2022 and 2025) covering identity and version, configuration, backups, VLFs, disk, tempdb, memory, I/O, waits, top queries, missing, unused and fragmented indexes, deadlocks, suspect pages, availability, Agent jobs, sysadmins, SQL logins and linked servers, then read the output with its reset and version caveats. 2022 is the baseline, 2019 was checked against documentation only, 2025 was partly run on a real instance. Not the audit method or sign-off verdict (`sql-server-audit`), not generic query tuning (`query-performance`), not PostgreSQL (`postgres-diagnostics`). Use when someone asks to check, audit or upgrade a SQL Server instance, mentions DMVs, wait stats, page life expectancy, missing indexes, backup gaps or VLFs, or moves between SQL Server versions."
---

# SQL Server diagnostics (2019, 2022 and 2025)

One idea: **one read-only script per question, run against the right version folder, read with the counter reset in mind.** Thirty `SELECT`-only scripts per version live in `references/sql2019/`, `sql2022/` and `sql2025/` (31 on 2025). They change nothing, so the only risks are load and exposure of what they print. Database-wide fundamentals (exposure, backups, schema, performance) belong to `database-audit`; the audit method and verdict belong to `sql-server-audit`; `query-performance` is the generic version of the index and query scripts. Sources and statuses: [references/sources.md](references/sources.md).

## 1. Steps

1. **Pick the version first.** Run `references/sql2022/identity/server_identity.sql` (or read `SERVERPROPERTY('ProductMajorVersion')`): 15 is SQL Server 2019, 16 is 2022, 17 is 2025. Use that version's folder and read its guide once before the first run (`references/sql2019-porting.md`, `references/sql2025-porting.md`): permissions and defaults differ.
2. **Choose the scripts for the question** from the table in `references/sql2022/README.md` (area, what it answers, cost). A full health check runs every *light* script; *medium* and *heavy* ones only with the owner's OK.
3. **Run one script at a time**, with a login that holds the permission of that version (2019: `VIEW SERVER STATE`; 2022 and 2025: `VIEW SERVER PERFORMANCE STATE`, see the porting guides). Keep each result next to the script name.
4. **Read counters in context.** Waits, I/O, missing and unused indexes, and top queries accumulate since the last restart (or plan creation): compare with `sqlStartTime` before judging them. Fragmentation bands (reorganize 5-30%, rebuild above 30%) are common convention, not a Microsoft rule, and advice rather than an order.
5. **Report** per area: what the result says, what it does not prove, risk (high, medium, low) and the next check. A script that returns nothing is "nothing found", never "healthy".

## 2. Rules

- Production is queried only after the owner approves the list; hand over the command when you cannot run it.
- Never alter the instance from here (no `sp_configure`, `ALTER`, `DBCC` repair, index rebuild, plan forcing); propose the statement, the owner runs it.
- Output holds host names, accounts and query text: keep it in the report, do not paste it to external services.
- Run status differs by folder: 2025 ran in part on a real instance (11 scripts, listed in its guide), 2019 was only checked against documentation, 2022 is the baseline. Say "not run on <version>" for anything not covered.
- `backup_status.sql` does not filter `is_copy_only`, so a copy-only full can show as the last full: check that column before reporting restore points.
- To change a script, edit it in every version folder where it exists, name the difference in the porting guide's "differs" or "changes" section, and run `python scripts/check_versions.py references sql20 references/sql2019-porting.md references/sql2025-porting.md`.

## Quick Decision Checklist

- [ ] Did I identify the SQL Server version first and pick the matching script folder and porting guide?
- [ ] Have I chosen scripts for the question, running medium and heavy ones only with the owner's OK?
- [ ] Am I running one script at a time with a login that has that version's permission?
- [ ] Did I compare counters with sqlStartTime before judging waits, I/O or index results?
- [ ] Is empty output reported as "nothing found" rather than "healthy"?
- [ ] Am I leaving instance changes (sp_configure, ALTER, DBCC repair, rebuilds) to the owner?
- [ ] Do I say "not run on <version>" for anything not covered, and keep output out of external services?

## Deep references

- [references/sql2022/README.md](references/sql2022/README.md): index of the 30 scripts and cost class. Read in step 2.
- [references/sql2019-porting.md](references/sql2019-porting.md): what changes on 2019. Read before running the pack on 15.x.
- [references/sql2025-porting.md](references/sql2025-porting.md): what changes on 2025. Read before running the pack on 17.x.
- [references/wait-stats-and-blocking-interpretation.md](references/wait-stats-and-blocking-interpretation.md): read when interpreting waits, latency, counters or deadlock evidence.
- [references/index-dmvs-and-reset-semantics.md](references/index-dmvs-and-reset-semantics.md): read before reporting missing or unused indexes.
- [references/query-store-and-plan-regression.md](references/query-store-and-plan-regression.md): read when cached top queries are not enough or plans regress.
- [references/backup-log-and-recovery-health.md](references/backup-log-and-recovery-health.md): read when judging backup history, VLF counts or last CHECKDB.
- [references/version-differences-2019-2022-2025.md](references/version-differences-2019-2022-2025.md): read to cross-check the porting guides and lifecycle dates.
- [references/trigger-evals.md](references/trigger-evals.md): trigger prompts and near-misses. Read when tuning the description.
- [references/sources.md](references/sources.md): URL statuses, reading limits and claims not adopted.
