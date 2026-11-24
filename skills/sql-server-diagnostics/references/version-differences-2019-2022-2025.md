# Version Differences 2019, 2022 and 2025: What the Documentation Confirms

Sources: https://learn.microsoft.com/en-us/lifecycle/products/sql-server-2019 · https://learn.microsoft.com/en-us/lifecycle/products/sql-server-2022 · https://learn.microsoft.com/en-us/lifecycle/products/sql-server-2025 · https://learn.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-2022 · https://learn.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-2025 · plus the object pages listed in sources.md · Last verified 2026-11-24

This file does not repeat the per-folder script changes: see [sql2019-porting.md](sql2019-porting.md) and [sql2025-porting.md](sql2025-porting.md). It re-checks their claims against the pages and adds what affects reading results.

## 1. Cross-check of porting claims

| Claim in porting files | Result of the check |
|---|---|
| 2022 permission is `VIEW SERVER PERFORMANCE STATE`, 2019 is `VIEW SERVER STATE` | Confirmed on the pages for wait stats, index usage, missing-index group stats, query stats, io_virtual_file_stats and performance counters (all state both). |
| `dm_db_log_info` needs `VIEW DATABASE PERFORMANCE STATE` on 2022+ | Confirmed. |
| VLF formula changed slightly in 2022 | Confirmed; What's New 2022 gives the rule (one VLF for growth of at most 64 MB and above 1/8 of the log, was four). |
| `backupset.compression_algorithm` is 2022-only | Confirmed ("Introduced in SQL Server 2022"); `last_valid_restore_time` is also 2022. |
| `LastGoodCheckDbTime` since 2016 SP2, 2017 CU9 | Confirmed (re-verified 2026-11-24). |
| `dm_db_log_info` since 2016 SP2 | Confirmed. |
| 2019 Query Store off by default, 2022 on for new databases | Confirmed on the Query Store page. |
| 2025 XACT lock waits appear in wait stats | Confirmed on the wait stats page (optimized locking). |
| 2019 lifecycle: start 2019-11-04, mainstream end 2025-03-01, extended end 2030-01-09 | Page shows 11/4/2019, 3/1/2025 06:59:59, 1/9/2030 06:59:59 (Pacific time, so these are UTC-style stamps of the next day; the dates match). The "CU32" statement is not on the page. |
| 2025 optimized locking, tempdb space governance, ZSTD, vector indexes | Present on What's New 2025; vector indexes are labeled preview and need the `PREVIEW_FEATURES` database scoped configuration. |
| Query Store for readable secondaries on by default (2025) | Stated on What's New 2025 and the Query Store page; What's New 2022 also lists a secondary-replica feature, see Claims. |

## 2. Lifecycle (as listed on the pages)

| Version | Start | Mainstream end | Extended end |
|---|---|---|---|
| 2019 | 2019-11-04 | 2025-03-01 | 2030-01-09 |
| 2022 | 2022-11-16 | 2028-01-12 | 2033-01-12 |
| 2025 | 2025-11-18 | 2031-01-07 | 2036-01-07 |

All use the Fixed lifecycle. Times on the pages are Pacific; the listed 06:59:59 stamps mean the end falls on the previous local day. As of 2026-11-24, 2019 is past mainstream support (extended support only): an audit finding if the instance holds sensitive data and has no extended-support plan.

## 3. Result-reading differences between versions

- Waits: `CXPACKET` shrinks on 2022 (producers only) with `CXSYNC_PORT` and `CXSYNC_CONSUMER` added; 2025 splits hash waits into `HTBUILD_AGG`, `HTBUILD_JOIN`, `HTDELETE_AGG`, `HTDELETE_JOIN`. Wait stats before and after an upgrade are not directly comparable by name.
- Query Store: a 2019 database may have no history; a 2022 database created on 2022 usually has it; upgraded or restored databases keep their old setting.
- Backups: no `compression_algorithm` or `last_valid_restore_time` columns on 2019; ZSTD on 2025 is documented as a new algorithm (whether `backupset` records it is not on the fetched `backupset` page, whose compatibility list stops at 160).
- Permissions: a diagnostic login built for 2022 with the new granular permissions does not work on 2019; the reverse works. 2022 introduces fixed server roles such as `##MS_ServerPerformanceStateReader##` (2025 What's New mentions it as the replacement for a Purview action).
- Log: VLF counts differ by growth rule; `vlf_encryptor_thumbprint` exists from 2019.
- 2025 only: `IsOptimizedLockingOn`, `sys.vector_indexes` (preview), Resource Governor in Standard edition, ADR in tempdb.
- Compatibility level: 150 (2019), 160 (2022), 170 (2025 per the porting file; the backupset page lists up to 160 only).

## How an agent should apply this

- Pick the permission set from `ProductMajorVersion` before running anything, and report "not run on <version>" per the main skill rule.
- When comparing instances on different versions, normalize wait names before drawing conclusions.
- State support status from the lifecycle table with the date of the check; point to the live page for contract decisions.
- Treat preview features (vector indexes) as out of production scope unless the owner enabled them knowingly.
- Where this file or the porting guides disagree with a live instance, trust the instance and update the guide through the maintenance steps in `SKILL.md`.
