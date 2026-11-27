# Running the sql2022 pack on SQL Server 2019 (15.x)

The folder `sql2019/` holds the 30 scripts of `sql2022/`, unchanged except for a two-line header that states the target version and
its permission. Verdict: **no script needs a code change** for the objects the pack reads; what differs is the permission to run them and a few
defaults. Checked on 2026-11-16 against Microsoft Learn (one page per object, URLs below). Nothing here was executed on a live
2019 instance: run each script once on a non-production 2019 instance before trusting a result.

## Contents
1. Objects the scripts use, and their earliest version
2. What differs on 2019
3. Not verified
4. Lifecycle

## 1. Objects the scripts use, and their earliest version

All of them exist on 2019. Earliest version where the page states one:

| Object or column | Earliest version | Scripts |
|---|---|---|
| `sys.dm_os_sys_info.socket_count`, `cores_per_socket` | 2016 SP2 | `identity/server_identity` |
| `sys.dm_os_sys_info.sql_memory_model_desc` | 2012 SP4 / 2016 SP1 | `memory/memory_model` |
| `sys.dm_server_services.instant_file_initialization_enabled` | 2016 SP1 | `config/service_accounts` |
| `sys.dm_db_log_info` | 2016 SP2 | `databases/vlf_counts` |
| `DATABASEPROPERTYEX(..., 'LastGoodCheckDbTime')` | 2016 SP2, 2017 CU9 | `databases/database_inventory` |
| `sys.dm_exec_plan_attributes` | 2016 | `queries/top_queries_*` |
| `sys.dm_server_memory_dumps` | 2008 R2 SP1 | `errorlog/memory_dumps` |
| `sys.dm_hadr_database_replica_states.is_primary_replica` | 2014 | `databases/vlf_counts`, `ha/ha_status` |
| `sys.fn_xe_file_target_read_file` (`timestamp_utc` column) | 2017; the deadlock script reads the XML timestamp instead, so it does not depend on it | `deadlocks/deadlock_summary` |
| `msdb.dbo.backupset` `compressed_backup_size`, `is_copy_only` | before 2019 | `backup/*` |
| `sys.configurations` options of `config/instance_configuration` | none is 2022-only; `clr strict security` is 2017+, `external scripts enabled` 2016+ | `config/instance_configuration` |
| `ProductMajorVersion`, `ProductUpdateLevel`, `InstanceDefaultDataPath`, `InstanceDefaultLogPath`, `IsHadrEnabled` | available | `identity/server_identity` |

`msdb.dbo.backupset.compression_algorithm` is **2022-only** ("Introduced in SQL Server 2022"). No script selects it; do not add it
when you extend the backup scripts for 2019.

## 2. What differs on 2019

| Topic | 2022 | 2019 | What to do |
|---|---|---|---|
| Permission for `dm_os_sys_info`, `dm_os_process_memory`, `dm_os_volume_stats`, `dm_server_memory_dumps`, `dm_exec_plan_attributes` | `VIEW SERVER PERFORMANCE STATE` | `VIEW SERVER STATE` | grant the 2019 permission to the diagnostic login; a login created for 2022 will get empty or denied results |
| Permission for `dm_server_services` | `VIEW SERVER SECURITY STATE` | `VIEW SERVER STATE` | same |
| Permission for `dm_db_log_info` | `VIEW DATABASE PERFORMANCE STATE` | `VIEW SERVER STATE` | same |
| VLF formula of `dm_db_log_info` | changed in 2022 (one VLF for a growth of at most 64 MB and above 1/8 of the log, was four) | earlier formula | compare VLF counts across versions with care |
| Query Store | on by default for new databases | off by default | the pack does not read Query Store; do not assume plans are retained after a restart |
| `sys.dm_os_volume_stats.incurs_seek_penalty` | not used | exists since 2019 | optional extra column for `disk/volume_space` |
| Compatibility level | 160 | 150 | the scripts do not depend on it |

The permission statement for each DMV is quoted from its Microsoft Learn page ("On SQL Server 2019 and earlier versions ... you
require VIEW SERVER STATE permission"). A hardened least-privilege login is the only place this bites; a `sysadmin` is unaffected.

## 3. Not verified

- The `xml_deadlock_report` event name in `system_health` on 2019 (the script relies on it; it has been in the session for
  many versions, but no page was read for this check).
- The `_desc` column `sys.databases.page_verify_option_desc` on the 2019 page (the extract showed `page_verify_option`).
- Wait types of `waits/wait_stats` that exist only on 2022: absent names in a `NOT IN` list are harmless.
- The exact `@@VERSION` string of 2019 on Windows and on Linux; `identity/server_identity` parses ` on ` and ` <` out of it, so
  run it once and read `hostDistribution`.

## 4. Lifecycle

Microsoft's lifecycle page (re-read 2026-11-27) lists SQL Server 2019 as: start 2019-11-04, mainstream support ended 2025-03-01, extended support
ends 2030-01-09. Check the page before quoting dates in a client document. (Author note, not verified against docs: CU32, 15.0.4430.1, 2025-02-27 was the latest CU when the port was written; the lifecycle page does not list it.)

Sources: Microsoft Learn pages of each object, for example
`https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-log-info-transact-sql`,
`.../sys-dm-os-sys-info-transact-sql`, `.../sys-dm-server-services-transact-sql`,
`https://learn.microsoft.com/en-us/sql/t-sql/functions/databasepropertyex-transact-sql`,
`https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/backupset-transact-sql`,
`https://learn.microsoft.com/en-us/lifecycle/products/sql-server-2019`.
