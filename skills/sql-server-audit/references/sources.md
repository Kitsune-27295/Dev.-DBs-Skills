# Sources — SQL Server Audit

Every URL below was checked during skill authoring (2026-11-24).

Retrieved with WebFetch (Firecrawl had no credits) or a plain HTTP request with text extraction. All Microsoft Learn paths start with `https://learn.microsoft.com/en-us/sql/`. "200 OK" means content was returned; a page cut short by the reader is noted. No page was read in full unless stated.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [BrentOzarULTD/SQL-Server-First-Responder-Kit](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit) (README) | 200 OK; first 100000 of 104870 characters read | What each procedure does, key parameters (health-check detail switch, real-time sampling seconds, sort orders, index modes, "bring the pain" for many databases), the one-time permission grant, kill procedure safe by default, update procedure downloads code (pin a tag), platform support, MIT license |
| [ola.hallengren.com — backup](https://ola.hallengren.com/sql-server-backup.html) | 200 OK | Parameters and defaults: verify off by default, checksum and compression follow instance settings, cleanup after success, log backups kept to preserve point-in-time restore, change-backup-type default off, copy-only |
| [ola.hallengren.com — index and statistics maintenance](https://ola.hallengren.com/sql-server-index-and-statistics-maintenance.html) | 200 OK | Default fragmentation levels (5 and 30 percent) and minimum page count (1000), stated as based on the vendor's guidance; statistics update options off by default |
| [ola.hallengren.com — integrity check](https://ola.hallengren.com/sql-server-integrity-check.html) | 200 OK | Default check command, physical-only and extended-logical options and their exclusion, time limit, execute switch that only prints commands |
| [sqlskills.com — Wait statistics, or please tell me where it hurts](https://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/) | 200 OK; first 100000 of 122445 characters read | Waits-and-queues method, signal versus resource time, benign-wait filtering, no universal threshold, a wait points to a resource not a root cause, persist snapshots over time |
| [sqlskills.com — Wait types library](https://www.sqlskills.com/help/waits/) | 200 OK; first 100000 of 123323 characters read; only the A-Z list of names was visible, no descriptions | Existence and scope of the library; usage terms forbid republishing, so nothing was copied |
| [sqlskills.com — Backup myths (30 of 30)](https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-3030-backup-myths/) | 200 OK | The 30 backup myths and their one-line corrections (restore proof, log clearing, chain, differentials, checksum, retention, system databases, plan restore first) |
| [sqlskills.com — Use BACKUP WITH CHECKSUM to replace CHECKDB (27 of 30)](https://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-2730-use-backup-with-checksum-to-replace-dbcc-checkdb/) | 200 OK | Why checksum backups do not replace consistency checks |
| [sqlskills.com — Why you should not shrink your data files](https://www.sqlskills.com/blogs/paul/why-you-should-not-shrink-your-data-files/) | 200 OK | Shrink fragmentation, cost, regrowth, exceptions, alternatives |
| [sqlskills.com — tempdb configuration survey results and advice](https://www.sqlskills.com/blogs/paul/tempdb-configuration-survey-results-and-advice/) | 200 OK | Survey of file counts, check latency and avoidable use first, equal file sizes, contention cause; the per-core rule is only linked, not explained |
| sqlskills.com — site search for the myth-a-day series (`/blogs/paul/?s=myth+a+day`) | 200 OK; listed only five posts (26 to 30) | URLs of posts 26 to 30 |
| sqlskills.com — guessed myth index and category URLs (`.../a-sql-server-dba-myth-a-day-30-of-30/`, `/category/myths/`, `/tag/myths/`, and four guessed post slugs) | 404 | Nothing; no content was invented for them |
| `relational-databases/security/sql-server-security-best-practices?view=sql-server-ver17` | 200 OK | Layered security, authentication and least-privilege guidance, service accounts, sysadmin versus a narrower grant, surface area, encryption, auditing, backup security |
| `relational-databases/backup-restore/back-up-and-restore-of-sql-server-databases?view=sql-server-ver17` | 200 OK | Strategy before backups, separate storage, "testing is required", restore then run the consistency check, verification options, untrusted-backup risk |
| `t-sql/database-console-commands/dbcc-checkdb-transact-sql?view=sql-server-ver17` | 200 OK | What the check covers, physical-only for frequent use and full run periodically, repair options as last resort, restore as primary recovery, permissions |
| `database-engine/configure-windows/server-memory-server-configuration-options?view=sql-server-ver17` | 200 OK | Defaults, upper limit recommended, buffer pool only, starting formula, minimum on virtual machines, locked pages caution |
| `database-engine/configure-windows/configure-the-max-degree-of-parallelism-server-configuration-option?view=sql-server-ver17` | 200 OK | MAXDOP recommendation table by NUMA layout, zero not recommended for most cases, overrides, effect on consistency checks |
| `relational-databases/indexes/reorganize-and-rebuild-indexes?view=sql-server-ver17` | 200 OK | Fragmentation versus page density, no fixed thresholds, rebuild updates statistics with a full scan, maintenance strategy, small indexes |
| `database-engine/availability-groups/windows/overview-of-always-on-availability-groups-sql-server?view=sql-server-ver17` | 200 OK; first 4500 of about 31000 characters read | Secondaries are not backups; failover is not caused by database-level problems; replica roles and synchronization |
| `relational-databases/performance/best-practice-with-the-query-store?view=sql-server-ver17` | 200 OK; first 5500 of about 24500 characters read | Query Store troubleshooting views (regressed queries, top consumers) used as the before and after measurement tool |

## Reading limits

- Pages cut short as noted above; later sections of the First Responder Kit README, the wait-statistics post, the waits library and the two Learn pages read by plain request were not read.
- The Hallengren pages were read for the three procedures named; the main solution page and the command-log and job pages were not.
- No page of the Learn security section on auditing, TDE or vulnerability assessment beyond the best-practices summary was read.
- Microsoft Learn text was summarized by the reader tool or read as extracted text; quoted fragments were kept below 15 words.

## Claims not adopted as fact

- A page life expectancy target, NOLOCK guidance, local variables as a parameter-sniffing fix, implicit-conversion rules, and a cost-threshold number: no fetched source settled them.
- "One tempdb file per core is a myth": the survey post links a myth entry with that title but the entry was not read; the audit judges tempdb by contention evidence only.
- Page verify setting severity and the severity of an unbacked-up data-at-rest encryption certificate are this skill's own judgment (the second is an inference from the vendor statement that encrypted files cannot be read without the certificates).
- The severity scale, the confidence levels, the evidence ledger and the deliverable template are this skill's own convention, not taken from any source.

## Provenance note

Method ideas on evidence before opinion, severity with confidence and read-only defaults were prompted by a third-party skill read for ideas, no text reused. Its scripts and references were not available and were not used. The collectors are the ones already in `sql-server-diagnostics`.
