# Running the sql2022 pack on SQL Server 2025 (17.x)

The folder `sql2025/` holds the 30 scripts of `sql2022/` plus one new script, adapted where Microsoft's documentation shows a
change. Checked on 2026-11-16 against Microsoft Learn (URLs in section 4) and by running part of the pack on a real SQL Server
2025 instance (build 17.0.4065.4, `SERVERPROPERTY('ProductMajorVersion')` = 17), read-only, as a login without server-state
permission. 11 of 29 scripts ran (the two heavy ones, `index_fragmentation` and `deadlock_summary`, were not tried): `backup/backup_history`,
`backup/backup_status`, `config/instance_configuration`, `databases/database_inventory` (with the new column),
`errorlog/suspect_pages`, `indexes/vector_indexes`, `jobs/dba_tools`, `security/linked_servers`, `security/sql_login_policy`,
`security/sysadmin_members`, `tempdb/tempdb_files`. The other 18 read DMVs and need `VIEW SERVER PERFORMANCE STATE`
(or `VIEW SERVER SECURITY STATE` for `dm_server_services`), which that login lacks, so they were not run: run them once with a
login that holds it before trusting a result.

## Contents
1. Verdict
2. What changes on 2025 in the scripts
3. What changes on 2025 around the scripts
4. Not verified, and sources

## 1. Verdict

No object read by the pack was removed or renamed in 2025 (no change found on any of the system objects checked). The pack runs as
written. Four files carry an edit and one file is new, listed in section 2. The permissions are the 2022 ones: a login that
works on 2022 works on 2025.

## 2. What changes on 2025 in the scripts

| File | Change | Why |
|---|---|---|
| `databases/database_inventory.sql` | adds `isOptimizedLocking` (`sys.databases.is_optimized_locking_on`) | new column, "Applies to SQL Server 2025 and Azure SQL Database" |
| `indexes/vector_indexes.sql` | new script over `sys.vector_indexes` (table, index id, type, distance metric, build parameters) | new catalog view for vector indexes; per database |
| `config/instance_configuration.sql` | comment only: `lightweight pooling` is deprecated in 2025 | deprecated feature list; it stays in the list so a non-default value still shows |
| `security/linked_servers.sql` | comment only: OLE DB 19 defaults to `Encrypt=Mandatory` for linked servers | breaking change; columns unchanged |
| `deadlocks/deadlock_summary.sql` | comment only: the event name was not re-verified on 2025 | the documentation names a "deadlock graph", not the event |

## 3. What changes on 2025 around the scripts

These do not need a script edit but change how to read the results or what to check before upgrading.

| Topic | 2025 behavior | Where to look |
|---|---|---|
| Linked servers | with Microsoft OLE DB Driver 19, linked servers default to `Encrypt=Mandatory` and need a valid certificate; existing linked servers can fail after an upgrade | `security/linked_servers.sql`, then test each linked server |
| Replication | a remote distributor can fail after an upgrade when no trusted certificate is configured; the documented workaround is `trust_distributor_certificate` | `ha/ha_status.sql` (replication row) |
| Log shipping | monitoring can break when the monitor is a remote 2025 instance and the others run an older version; `log_shipping_primary_databases` gains `primary_connection_options` and `monitor_connection_options` | `ha/ha_status.sql` |
| Full-Text | legacy word breakers and filters are removed; existing indexes become `index_version = 1` and fail until rebuilt | `sys.fulltext_indexes` |
| Password hashing | SQL logins use an iterated hash (RFC2898) from 2025; the hash starts with byte `0x03` | `security/sql_login_policy.sql` (no hash is read) |
| Compatibility level | 170 is the 2025 default; it changes plans for optional parameters and the cardinality estimator | `databases/database_inventory.sql` (`compatibilityLevel`) |
| Optimized locking | new XACT lock waits (`LCK_M_S_XACT_READ`, `LCK_M_S_XACT_MODIFY`, `LCK_M_S_XACT`) can appear in `sys.dm_os_wait_stats`; they are real waits, so `waits/wait_stats.sql` leaves them in | `waits/wait_stats.sql` |
| Tempdb governance | Resource Governor can cap tempdb use per workload group | `tempdb/tempdb_files.sql` shows files only; no limit check was added |
| Query Store | on by default for readable secondary replicas | the pack does not read Query Store |
| Backup | ZSTD compression is available (`ALGORITHM = ZSTD`); `backup compression algorithm` accepts 3 | `backup/*`; whether `backupset` records ZSTD is not verified |
| Windows hosts | Windows Server 2025 is supported; Linux adds Ubuntu 24.04 and Red Hat 10 | `identity/server_identity.sql` parses `@@VERSION`: read `hostDistribution` once |
| Removed products | Data Quality Services, Master Data Services and Synapse Link are discontinued | not read by the pack |
| Fragmentation advice | still "reorganize above 5%, rebuild above 30%" | `indexes/index_fragmentation.sql` |

## 4. Not verified, and sources

Not verified: the `@@VERSION` text (the `ProductMajorVersion` value 17 is confirmed by the run above); whether `backupset.compression_algorithm` holds ZSTD; the `xml_deadlock_report` name on 2025; the three new
`sys.stats` columns; the other log shipping tables; the full compatibility-170 table; 2025-only memory clerks; four pages
that Microsoft Learn served from an Azure fallback (`dm_os_volume_stats`, `dm_hadr_database_replica_states`,
`dm_server_services`, `dm_server_memory_dumps`). The research read pages through a summarising extractor, so a "no change found" on
a very long page (wait stats, index physical stats) is weaker than on a short one.

Sources, all `https://learn.microsoft.com/en-us/sql/...?view=sql-server-ver17`:
`database-engine/breaking-changes-to-database-engine-features-in-sql-server-2025`,
`database-engine/deprecated-database-engine-features-in-sql-server-2025`,
`sql-server/what-s-new-in-sql-server-2025`,
`t-sql/statements/alter-database-transact-sql-compatibility-level`,
`relational-databases/system-catalog-views/sys-databases-transact-sql`,
`relational-databases/system-catalog-views/sys-vector-indexes-transact-sql`,
`relational-databases/linked-servers/linked-servers-database-engine`,
`relational-databases/performance/optimized-locking`,
`relational-databases/system-catalog-views/sys-sql-logins-transact-sql`,
`relational-databases/backup-restore/backup-compression-sql-server`.
