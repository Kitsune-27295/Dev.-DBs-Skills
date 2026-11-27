# Sources — SQL Server Audit

Every URL below was checked during skill authoring (2026-11-24) and re-fetched in the rebuild on 2026-11-27.

Retrieved with WebFetch (Firecrawl had no credits). All Microsoft Learn paths start with `https://learn.microsoft.com/en-us/sql/` and were read for `?view=sql-server-ver17`; the page date is the `ms.date` front matter. "200 OK" means content was returned. A page read in part is noted. Nothing was copied, only restated in own words.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [BrentOzarULTD/SQL-Server-First-Responder-Kit](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit) (README) | 200 OK (2026-11-27); first 100000 of 104871 characters read | Priority 1-49 means act now; the main check skips user-database checks above 50 databases unless a "bring the pain" switch is set; real-time sample default 5 s and a since-startup switch; index procedure modes 0-4; session killer read-only unless its execute switch is Y; the update procedure runs code fetched from GitHub (pin a release tag; it needs SQL Server 2025 or Azure SQL DB); platform support; one-time permission grant; MIT license |
| [ola.hallengren.com — backup](https://ola.hallengren.com/sql-server-backup.html) | 200 OK (2026-11-27) | Verify off by default; checksum and compression follow instance settings; no cleanup unless a time is set, then only after success; log backups newer than the last full or differential are kept; change-backup-type off; copy-only off |
| [ola.hallengren.com — index and statistics maintenance](https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html) | 200 OK (2026-11-27) | Defaults 5% and 30% fragmentation and 1000 minimum pages, attributed by the page to vendor guidance; statistics update off by default |
| [ola.hallengren.com — integrity check](https://ola.hallengren.com/sql-server-integrity-check.html) | 200 OK (2026-11-27) | Execute defaults to Y, N only prints the commands; default command is the full check; physical-only and extended-logical options are exclusive; time limit |
| [sqlskills.com — Wait statistics, or please tell me where it hurts](https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/) | 200 OK (2026-11-27); first 100000 of 122259 characters read | Waits-and-queues method, signal versus resource time, benign-wait filtering, no universal threshold, persist snapshots over time |
| [sqlskills.com — Wait types library](https://www.sqlskills.com/help/waits/) | 200 OK (2026-11-27); first 100000 of 123323 characters read | Library exists and covers 2005 to 2025; usage terms forbid republishing, so nothing was copied |
| [sqlskills.com — Backup myths (30 of 30)](https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-3030-backup-myths/) | 200 OK (2026-11-27) | The 30 backup myths and corrections (restore proof, log clearing, chain, cumulative differentials, checksum, retention, system databases, plan restore first) |
| [sqlskills.com — BACKUP WITH CHECKSUM does not replace CHECKDB (27 of 30)](https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-2730-use-backup-with-checksum-to-replace-dbcc-checkdb/) | 200 OK (2026-11-27) | Three reasons: pages without checksums after old upgrades, infrequent or partial coverage, corruption in memory before the write |
| [sqlskills.com — Why you should not shrink your data files](https://www.sqlskills.com/blogs/paul/why-you-should-not-shrink-your-data-files/) | 200 OK (2026-11-27) | Fragmentation example (about 0.4% to 99.3%), cost, exceptions, new-filegroup alternative |
| [sqlskills.com — tempdb configuration survey results and advice](https://www.sqlskills.com/blogs/paul/tempdb-configuration-survey-results-and-advice/) | 200 OK (2026-11-27) | Just over half of 600+ systems use one file; equal sizes; check file latency and avoidable use first; per-core ratio only linked |
| `database-engine/configure-windows/server-memory-server-configuration-options` | 200 OK (2026-11-27); page dated 2025-08-26 | Upper limit recommended in all versions; quick figure 75% of memory not used by others; buffer pool only; starting formula; setup suggests a value on Windows since 2019; min essential on virtual machines; min near max discouraged; locked pages need an upper limit |
| `database-engine/configure-windows/configure-the-max-degree-of-parallelism-server-configuration-option` | 200 OK (2026-11-27); page dated 2025-08-26 | NUMA table for 2016 and later, 0 not recommended (up to 64 processors), setup recommendation since 2019, overrides, effect on consistency checks |
| `t-sql/database-console-commands/dbcc-checkdb-transact-sql` | 200 OK (2026-11-27); page dated 2026-07-10 | What the full check covers; physical-only recommended for frequent use plus a periodic full run, and it skips column-value and FILESTREAM checks; repair as last resort, restore first; disabled indexes not examined |
| `relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases` | 200 OK (2026-11-27); page dated 2026-08-27 | Testing is required, restore then run the consistency check; separate storage; encrypt backups; verify options; untrusted-backup risk and auditing of backup events |
| `relational-databases/indexes/reorganize-and-rebuild-indexes` | 200 OK (2026-11-27); page dated 2026-10-27 | No fixed thresholds; page density often matters more; rebuild updates statistics with a full scan except partitioned or resumable builds; reorganize does not update statistics; offline rebuild can repair a nonclustered index; small indexes; fill factor; measure with Query Store |
| `relational-databases/security/sql-server-security-best-practices` | 200 OK (2026-11-27); page dated 2026-05-07 | Least privilege, group-based access, control-server grant instead of sysadmin (sysadmin ignores deny), no command-shell procedures, surface area, file encryption needs certificates, Always Encrypted over masking, server-level audit, strict encryption from 2022, backups separate from a common administrator |
| `t-sql/statements/alter-database-transact-sql-set-options` | 200 OK (2026-11-27); page date not read; first 100000 of 271606 characters read (page-verify, auto-shrink, auto-close) | Page verify default is checksum and upgraded databases keep the old setting; auto-shrink not recommended; auto-close effects |
| `database-engine/availability-groups/windows/overview-of-always-on-availability-groups-sql-server` | 200 OK (2026-11-27); page dated 2026-01-26 | Secondaries are not backups; failover is not caused by database-level problems; the backup preference is not enforced for ad hoc backups |
| `relational-databases/performance/best-practice-with-the-query-store` | 200 OK (2026-11-27); page dated 2026-01-26 | Regressed-queries and top-consumers views for before and after comparison |

## Reading limits

- First Responder Kit README, the wait-statistics post and the waits library were cut short as noted; later sections were not read.
- Hallengren pages were read for the three procedures named only; sibling procedures' execute switches were not read.
- The Learn security section on auditing, TDE and vulnerability assessment beyond the best-practices summary was not read; lifecycle dates come from `sql-server-diagnostics` and were not re-checked here.
- The collector scripts of `sql-server-diagnostics` named in the areas files were not opened, edited or run in this rebuild.

## Claims not adopted as fact

- A page life expectancy target, NOLOCK guidance, local variables as a parameter-sniffing fix, implicit-conversion rules, and a cost-threshold number: no fetched source settled them.
- "One tempdb file per core is a myth": the survey post only links to that entry (unread); the audit judges tempdb by contention evidence. The survey's roughly 15 ms latency cue was not adopted as a threshold.
- The severity of a missing page-verify checksum setting and of an unbacked-up data-at-rest encryption certificate are this skill's own judgment (the second inferred from the vendor statement that protected files cannot be read without the certificates).
- The severity scale, confidence levels, evidence ledger and deliverable template are this skill's own convention.

## Provenance note

Method ideas on evidence before opinion, severity with confidence and read-only defaults were prompted by a third-party skill read for ideas, no text reused. The collectors are the ones already in `sql-server-diagnostics`.
