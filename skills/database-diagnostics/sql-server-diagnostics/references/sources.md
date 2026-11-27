# Sources: SQL Server Diagnostics

Last verified 2026-11-27.

## Provenance

This skill was not derived from official documentation. The author first wrote private DDL/SQL best-practice files for SQL Server 2022 (the author's own unpublished material, no public URL); the `sql-server-diagnostics` skill and its 2022 script set were created from them. The author then researched and created the SQL Server 2019 and 2025 ports; the PostgreSQL skill and the SQLite skill followed the same pattern. The official pages below are used only to verify claims, in the author's own words; no page text is copied.

## Retrieved sources

Every URL below was re-fetched with WebFetch on 2026-11-27 (Firecrawl had no credits); all returned 200 with page content. All paths start with `https://learn.microsoft.com/en-us/` and, for `sql/` pages, were read as `?view=sql-server-ver17` (it carries "Applies to" and permission notes for 2019 and 2022). Learn now serves DMV pages from `system-dynamic-management-objects/`; the old `-views/` path still resolved.

| Source (path) | Status | What it confirms |
|---|---|---|
| `sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql` | 200; first 100000 of 156344 characters read | Reset by restart or `DBCC SQLPERF CLEAR`, signal wait, CXPACKET/CXCONSUMER/CXSYNC split, LOGBUFFER, HADR_SYNC_COMMIT, XACT lock waits, hash wait types and their platforms, permissions by version |
| `sql/relational-databases/system-dynamic-management-views/sys-dm-io-virtual-file-stats-transact-sql` | 200 | Stall columns, queued-stall meaning, counters start at service start, permissions by version |
| `sql/relational-databases/system-dynamic-management-views/sys-dm-os-performance-counters-transact-sql` | 200 | Cumulative per-second counters, snapshot, ratio and base counter types, error 3409, not persisted across restart |
| `sql/relational-databases/extended-events/use-the-system-health-session` | 200 | What `system_health` records, 15 s latch and 30 s lock thresholds, 4x5 MB files (10x100 MB on Standard and Enterprise); no event name given |
| `sql/relational-databases/indexes/tune-nonclustered-missing-index-suggestions` | 200 | Limits list, 600-group cap, reset events, key-order rule, merge example |
| `sql/relational-databases/system-dynamic-management-views/sys-dm-db-missing-index-group-stats-transact-sql` | 200 | Columns, 600-row cap, not persisted, updated per execution, permissions |
| `sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-usage-stats-transact-sql` | 200 | Counter semantics, reset on start and detach, first-use row creation, excluded index types, permissions |
| `sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql` | 200 | Plan-lifetime rows, units and accuracy, offsets, `query_hash`, spill and grant columns, permissions |
| `sql/relational-databases/performance/monitoring-performance-by-using-the-query-store` | 200 | Defaults per version, three stores, wait stats since 2017, secondary replicas "Applies to 2025", `master`/`tempdb` limit, DDL not captured, consistency check |
| `sql/relational-databases/system-catalog-views/sys-database-query-store-options-transact-sql` | 200 | `desired_state_desc`, `actual_state_desc`, storage columns, `readonly_reason`, permissions |
| `sql/relational-databases/system-catalog-views/sys-query-store-runtime-stats-transact-sql` | 200 | Units, `execution_type` 0/3/4, per-interval aggregation, DOP reporting quirk, permissions |
| `sql/relational-databases/system-tables/backupset-transact-sql` | 200 (page dated 2024-02; compatibility list stops at 160) | `type` codes, copy-only, compression columns, 2022-only columns, `time_zone`, history cleanup |
| `sql/relational-databases/system-dynamic-management-views/sys-dm-db-log-info-transact-sql` | 200 | VLF columns, 2022 formula note, permissions by version, 100-VLF example |
| `sql/t-sql/functions/databasepropertyex-transact-sql` | 200 | `LastGoodCheckDbTime` rules and versions, `IsOptimizedLockingOn` (2025), `Status` caveat |
| `sql/relational-databases/backup-restore/backup-compression-sql-server` | 200 | ZSTD in 2025, `ALGORITHM = ZSTD`, server option value 3, ratio from `backupset` columns |
| `sql/database-engine/breaking-changes-to-database-engine-features-in-sql-server-2025` | 200 | Linked server and replication encryption defaults, `trust_distributor_certificate`, log shipping monitor, Full-Text `index_version = 1` |
| `sql/t-sql/statements/alter-database-transact-sql-compatibility-level` | 200 (output saved to a file, searched for "170") | 170 is the SQL Server 2025 level |
| `sql/sql-server/what-s-new-in-sql-server-2022` | 200 (served the ver17 rendering) | VLF growth rule, Query Store on by default, `last_valid_restore_time`, new server roles, Query Store on secondary replicas listed |
| `sql/sql-server/what-s-new-in-sql-server-2025` | 200 | Optimized locking, tempdb governance, ADR in tempdb, ZSTD, vector index (preview, `PREVIEW_FEATURES`), Resource Governor in Standard, Linux platforms, PBKDF2, discontinued and deprecated items |
| `lifecycle/products/sql-server-2019` | 200 | Fixed policy; 2019-11-04, mainstream end 2025-03-01, extended end 2030-01-09 (Pacific time) |
| `lifecycle/products/sql-server-2022` | 200 | 2022-11-16, 2028-01-12, 2033-01-12 |
| `lifecycle/products/sql-server-2025` | 200 | 2025-11-18, 2031-01-07, 2036-01-07 |

## Reading limits

- The wait-stats page was read only up to character 100000 of 156344; later wait-type entries were not read.
- Pages were read through a summarizing extractor; "no change found" on a very long page is weaker than on a short one.
- The `.sql` scripts, `scripts/check_versions.py` and the `sql2019`, `sql2022` and `sql2025` folders were not edited, run or re-verified in this pass.
- Pages named in the porting guides but not re-fetched on 2026-11-27: `deprecated-database-engine-features-in-sql-server-2025`, `sys-databases`, `sys-vector-indexes`, `linked-servers-database-engine`, `optimized-locking`, `sys-sql-logins`, `sys-dm-os-sys-info`, `sys.dm_exec_requests`, `sys.dm_os_waiting_tasks`. Their claims stand as the guides state them and carry the 2026-11-16 check date.

## Claims not adopted

- **CU32 on the lifecycle page.** The 2019 page lists no update; the CU32 (15.0.4430.1) statement in `sql2019-porting.md` is an author note, not to be quoted.
- **Hash wait names on the 2025 engine.** The wait-stats page ties `HTBUILD_AGG`, `HTBUILD_JOIN`, `HTDELETE_AGG`, `HTDELETE_JOIN` to Azure SQL, Synapse and Managed Instance policies and keeps unsuffixed types for on-premises. That the SQL Server 2025 engine splits them is not stated; the earlier claim was weakened.
- **Windows Server 2025 support** for SQL Server 2025: not on any page read; removed from the 2025 guide.
- **Password hash leading byte `0x03` and the RFC2898 label:** What's New 2025 only says PBKDF2 is the default; the `sys.sql_logins` page was not re-fetched.
- **ZSTD recorded in `backupset`.** The `backupset` page lists compression algorithm only as introduced in 2022 with default `MS_XPRESS`; it does not say ZSTD appears. Unconfirmed.
- **`xml_deadlock_report` event name.** The `system_health` page says deadlock graphs are collected but does not name the event. Unconfirmed on every version.
- **Query Store on secondary replicas in 2022.** What's New 2022 still lists it; the Query Store page applies it to 2025. Treat 2025 as documented.
- **Plan changes under compatibility level 170** (optional parameters, estimator): author's reading, not re-checked against the 160-to-170 differences table.
- **Latency and VLF thresholds.** Only the "above 100 VLFs" illustration is Microsoft's. Disk-latency rules of thumb and the 5 and 30 percent fragmentation bands are convention; the physical-stats page was not read.
- **Missing-index rank formula.** The script divides impact by 100; the Microsoft example does not. Only the scale differs, not the order.
- **`backup_status.sql` and copy-only fulls.** Observed in the script text (author's reading), not a documentation claim; caveat kept in `SKILL.md`.
- **Real-instance evidence.** The 11 scripts run on a 17.0.4065.4 instance come from the author's own test notes in `sql2025-porting.md`; not checked here. 2019 and 2022 pack behavior was not run either.
- **Blocking.** No script reads live blocking; the guidance comes from the wait-stats page only.
