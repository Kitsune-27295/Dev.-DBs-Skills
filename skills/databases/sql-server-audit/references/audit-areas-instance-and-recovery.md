# Audit Areas: Instance, Backups and Integrity

Sources: https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-set-options · https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/server-memory-server-configuration-options · https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/configure-the-max-degree-of-parallelism-server-configuration-option · https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases · https://learn.microsoft.com/en-us/sql/t-sql/database-console-commands/dbcc-checkdb-transact-sql · Last verified 2026-11-27

Each area gives: the question, the collector in `sql-server-diagnostics` (paths relative to its `references/sql20xx/` folder; use the folder of the instance's version), how to judge, and the usual severity. How to read each result set lives in that skill; this page says what to conclude and how bad it is. Severity levels are this skill's own convention. Sections 0-3 are here; sections 4-7 are in [audit-areas-performance-security-ha.md](audit-areas-performance-security-ha.md).

## 0. Scope and context (always first)

| Question | Collector | Judge |
|---|---|---|
| What is it, how long has it run? | `identity/server_identity.sql` | Version (major 15, 16, 17), edition, platform, `sqlStartTime`. Record it in the report header. Check lifecycle dates in `sql-server-diagnostics` `references/version-differences-2019-2022-2025.md`; an unsupported version is a finding by itself (MEDIUM to HIGH by exposure). |
| Which databases matter? | `databases/database_inventory.sql` | Ask for the RPO and RTO per database. If none is given, state the assumption (for example "RPO 60 min, RTO 4 h, assumed") and mark every finding that depends on it `needs-confirmation`. |
| Who is running the audit? | (login permissions) | Note whether the login is sysadmin. A sysadmin audit login is itself an INFO or LOW finding; ask for a least-privilege login instead. |

## 1. Instance configuration

Collectors: `config/instance_configuration.sql`, `config/service_accounts.sql`, `memory/memory_overview.sql`, `memory/memory_model.sql`, `tempdb/tempdb_files.sql`.

- **Max server memory.** The default is effectively unlimited, and the vendor page recommends an explicit upper limit on every version. The setting bounds the buffer pool only; thread stacks, backup buffers, extended procedures, linked-server providers and other components live outside it. Judge: unbounded on a shared host is MEDIUM (HIGH with lock-pages-in-memory enabled, because the vendor page warns of instability when the limit ignores other consumers). A value very close to physical memory is the same finding. Do not state a percentage as law; the page gives a starting formula (OS memory, minus thread-stack allowance, minus about a quarter for outside allocations), a quick figure of 75 percent of memory not used by other processes, and says to monitor first. Setup on Windows has suggested a value since 2019, so an untouched default there is a missed step.
- **Min server memory.** The vendor page calls a minimum essential on virtual machines so host reclaim cannot shrink the buffer pool below what is needed; setting min equal or near max is discouraged by the same page.
- **MAXDOP.** Zero (all processors) is not the recommended value for most cases. Vendor guidance for 2016 and later is a table by NUMA layout: at most 8 on a single NUMA node with more than 8 logical processors; with several nodes, at most the processors per node, or half of them capped at 16 when a node has more than 16. Setup has suggested a value since 2019, and per-query, per-database and workload-group overrides exist, so check them before blaming the server value. Judge against the table; MEDIUM or LOW, confirm with wait and plan evidence before proposing a change.
- **Cost threshold for parallelism.** No source in this pass gives a number; treat the default as a hypothesis to test with plans, not as a finding on its own (`heuristic`).
- **Tempdb.** Check file count, equal sizes, growth settings and free space. Count and size problems are `likely` only when allocation contention waits (`PAGELATCH_*` on allocation pages) agree; otherwise `heuristic`.
- **Service accounts and instant file initialization.** Managed accounts are preferred by the vendor security page; shared or interactive accounts are MEDIUM.
- **Database options.** Auto-shrink on is MEDIUM (see myths). Auto-close on is MEDIUM. Page verify not set to checksum is HIGH for a user database: checksum is the default, the vendor page recommends changing an upgraded database to it, and the other settings give only partial or no detection (severity is this skill's judgment). The vendor page advises against auto-shrink on; auto-close on makes the first access slow and clears the plan cache on each close. Compatibility level far behind the engine version is INFO to LOW with a plan note.

## 2. Backups and recovery

Collectors: `backup/backup_status.sql`, `backup/backup_history.sql`, `databases/vlf_counts.sql`, `disk/volume_space.sql`. Deep reading: `sql-server-diagnostics` `references/backup-log-and-recovery-health.md`. Restore proof: `backup-restore-drill`.

- **RPO test.** For each database in full recovery: latest full (or differential) and the log backup chain. Gap between now and the latest log backup is the realistic data-loss window today. Compare it with the RPO. Judge: no restorable chain inside the RPO is CRITICAL; full recovery with no log backups is HIGH (the log grows and point-in-time recovery does not exist).
- **Copy-only caveat.** Check `is_copy_only` before calling a full backup the base of a chain (the diagnostics skill documents that its script does not filter it).
- **Same storage.** Backups on the same physical device as the data files are HIGH; vendor guidance is separate storage, off-site copies and encryption where possible. Backups an administrator account can delete are a MEDIUM ransomware exposure.
- **System databases.** Not backed up is MEDIUM.
- **Checksum and verify.** Check whether backups use checksum. It detects only pages that already carry a checksum, so it supports but never replaces integrity checks or restores.
- **Restore test.** No evidence of a restore test with a consistency check afterwards is MEDIUM at least, because the vendor page says a restore strategy does not exist until backups of every type used have been restored and checked. If the owner claims a test exists, ask for the date and the proof.
- **Log health.** Many virtual log files, a log near disk limit, or a log that cannot truncate point to missing log backups or a long transaction. Say which with evidence.
- **Untrusted backups.** The vendor page warns that restoring a backup from an untrusted source is a high-risk operation; if the runbook restores third-party files, record it as MEDIUM and recommend an isolated instance.

## 3. Integrity

Collectors: `databases/database_inventory.sql` (last good consistency check), `errorlog/suspect_pages.sql`, `errorlog/memory_dumps.sql`.

- **Last good CHECKDB older than the owner's target** (state the target; without one say "7 days, assumed"): MEDIUM; for a database that holds the main business data and has no other check, HIGH.
- **Suspect pages or reported corruption:** CRITICAL, `verified` when the row exists. First action is to protect backups (do not overwrite the last good chain) and plan a restore; the vendor page says restoring from the last known good backup is the primary recovery and the repair option that can lose data is an emergency last resort.
- **Physical-only checks.** The vendor page recommends a physical-only run for frequent use on production systems and a full run periodically. A schedule that only ever runs physical-only is LOW to MEDIUM; it skips logical, column-value and FILESTREAM checks. The check also does not examine disabled indexes.
- **Memory dumps** near the time of other symptoms are `likely` evidence of an engine problem; report with dates, ask for a support case, do not guess a cause.

## How an agent should apply this

- Walk areas in order, running only the collectors the question needs; record result and window per collector.
- Raise or lower the severity here only by named compensating controls or combinations (`SKILL.md` section 3).
- Treat every "typical" value you remember as unusable until a source or result shows it.
- Hand the owner the collector or proposed script for each open item; do not run changes. An area that cannot be checked is a coverage gap with its cause.
