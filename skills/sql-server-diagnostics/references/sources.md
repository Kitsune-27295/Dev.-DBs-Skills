# Sources — SQL Server Diagnostics

Every URL below was checked during skill authoring (2026-11-24).

Retrieved with WebFetch (Firecrawl had no credits). "200 OK" means the page content was returned. Learn serves some DMV pages from `system-dynamic-management-objects/` while older links use `system-dynamic-management-views/`; both resolved to the same page. The "ver17" rendering was read, and it carries per-version "Applies to" and permission notes for 2019 and 2022.

All paths below start with `https://learn.microsoft.com/en-us/sql/` unless a full URL is given.

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| **Waits, I/O, memory counters** | | |
| `relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql?view=sql-server-ver17` | 200 OK; first 100000 of 156344 characters read (later wait-type entries not read) | Columns, reset by restart or `DBCC SQLPERF CLEAR`, signal wait, CXPACKET split in 2022, optimized-locking and 2025 hash waits; permissions by version |
| `relational-databases/system-dynamic-management-views/sys-dm-io-virtual-file-stats-transact-sql?view=sql-server-ver17` | 200 OK | Latency columns, counters empty at service start, permissions by version |
| `relational-databases/system-dynamic-management-views/sys-dm-os-performance-counters-transact-sql?view=sql-server-ver17` | 200 OK | Cumulative per-second counters, ratio and base counters, counters not persisted across restart |
| **Deadlocks and blocking** | | |
| `relational-databases/extended-events/use-the-system-health-session?view=sql-server-ver17` | 200 OK | What `system_health` records, file target size and retention |
| **Indexes** | | |
| `relational-databases/indexes/tune-nonclustered-missing-index-suggestions?view=sql-server-ver17` | 200 OK | Limits of missing-index suggestions, 600-group cap, reset events, column order rule |
| `relational-databases/system-dynamic-management-views/sys-dm-db-missing-index-group-stats-transact-sql?view=sql-server-ver17` | 200 OK | Column meanings, 600-row cap, not persisted, permissions |
| `relational-databases/system-dynamic-management-views/sys-dm-db-index-usage-stats-transact-sql?view=sql-server-ver17` | 200 OK | Counter semantics, reset conditions, excluded index types, permissions |
| **Queries and Query Store** | | |
| `relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql?view=sql-server-ver17` | 200 OK | Units, plan-lifetime rule, offsets, `query_hash`, permissions by version |
| `relational-databases/performance/monitoring-performance-by-using-the-query-store?view=sql-server-ver17` | 200 OK | Defaults per version, three stores, views, wait categories, 2025 secondary replicas |
| `relational-databases/system-catalog-views/sys-query-store-runtime-stats-transact-sql?view=sql-server-ver17` | 200 OK | Units, `execution_type`, interval aggregation, permissions |
| **Backup, log, database properties** | | |
| `relational-databases/system-tables/backupset-transact-sql?view=sql-server-ver17` | 200 OK | `type` codes, LSN columns, copy-only, compression, 2022-only columns, history cleanup |
| `relational-databases/system-dynamic-management-views/sys-dm-db-log-info-transact-sql?view=sql-server-ver17` | 200 OK | VLF columns, 2022 formula note, permissions, 100-VLF example |
| `t-sql/functions/databasepropertyex-transact-sql?view=sql-server-ver17` | 200 OK | `LastGoodCheckDbTime` rules and versions, `IsOptimizedLockingOn`, `Status` caveat |
| **Lifecycle and what's new** | | |
| `https://learn.microsoft.com/en-us/lifecycle/products/sql-server-2019` | 200 OK | Support dates 2019 |
| `https://learn.microsoft.com/en-us/lifecycle/products/sql-server-2022` | 200 OK | Support dates 2022 |
| `https://learn.microsoft.com/en-us/lifecycle/products/sql-server-2025` | 200 OK | Support dates 2025 |
| `sql-server/what-s-new-in-sql-server-2022?view=sql-server-ver16` | 200 OK (page served the ver17 rendering) | VLF growth rule, Query Store default, `last_valid_restore_time`, new server roles |
| `sql-server/what-s-new-in-sql-server-2025?view=sql-server-ver17` | 200 OK | Optimized locking, tempdb governance, ZSTD, vector index (preview), deprecated features |

Pages named in the porting guides (breaking changes 2025, deprecated features 2025, compatibility level, `sys.databases`, `sys.vector_indexes`, linked servers, `sys.sql_logins`, backup compression) were not re-fetched in this pass; their claims remain as the porting guides state them.

## Claims and caveats

- **CU32 on the lifecycle page.** `sql2019-porting.md` says the latest cumulative update shown was CU32 (15.0.4430.1). The 2019 lifecycle page read on 2026-11-24 lists no update. Unconfirmed; do not quote it.
- **`LastGoodCheckDbTime` start version.** The porting file says 2016 SP2; the page says 2016 SP2, 2017 CU9, 2019 and later. No effect on 2019, 2022 or 2025.
- **Query Store on secondary replicas.** What's New 2022 lists "Query Store on secondary replicas" in its 2022 table, while the Query Store page and What's New 2025 apply it to 2025 ("now on by default" in 2025). The Query Store page is treated as authoritative; the discrepancy is in Microsoft's pages.
- **Missing-index cap.** Both the tuning page and the group-stats page say 600; some older community material says 500. The pages win.
- **Missing-index rank formula.** The script divides the impact percentage by 100; the Microsoft example does not. Only the scale differs, not the order.
- **`backup_status.sql` and copy-only fulls.** The script does not filter `is_copy_only`, so a copy-only full can count as "last full". Observed in the script text (author's reading), not a documentation claim.
- **ZSTD in `backupset`.** The fetched `backupset` page (latest revision 2024) lists compatibility levels up to 160 and does not say ZSTD is recorded. Unconfirmed, as the porting file already states.
- **Compatibility level 170.** Not on any page fetched here; kept as in `sql2025-porting.md`.
- **`xml_deadlock_report` event name.** The `system_health` page says deadlocks and the deadlock graph are collected but does not name the event. Unconfirmed on the page, on every version.
- **Latency and VLF thresholds.** Only the "above 100 VLFs" illustration is from Microsoft. Disk-latency rules of thumb and the 5 and 30 percent fragmentation bands are not on the pages read in this pass; they are convention.
- **Real-instance evidence.** The statement that 11 scripts ran on a 17.0.4065.4 instance comes from the skill author's own test notes in `sql2025-porting.md`; it was not checked here. 2019 and 2022 pack behavior was not run in this pass either.
- **Blocking.** No script reads live blocking; the blocking guidance in the references is from the wait-stats page only. `sys.dm_exec_requests` and `sys.dm_os_waiting_tasks` were not fetched.
