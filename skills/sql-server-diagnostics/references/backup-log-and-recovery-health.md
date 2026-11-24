# Backup History, Log (VLF) and CHECKDB Evidence

Sources: https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/backupset-transact-sql · https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-log-info-transact-sql · https://learn.microsoft.com/en-us/sql/t-sql/functions/databasepropertyex-transact-sql · https://learn.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-2022 · Last verified 2026-11-24

Scripts covered: `backup/backup_status`, `backup/backup_history`, `databases/vlf_counts`, `databases/database_inventory` (last good CHECKDB). Proving a restore actually works is `backup-restore-drill`; broader exposure and audit checks are `database-audit` and `database-exposure`. This file explains what the history tables can and cannot prove.

## 1. `msdb.dbo.backupset`

One row per successful backup operation. Failed backups leave no row, so a missing row can mean "failed" or "never ran".

Columns that matter:
- `type`: D full, I differential, L log, F file or filegroup, G differential file, P partial, Q differential partial. `backup_status.sql` reads D, I and L.
- `backup_finish_date` (and start date): local time of the instance; `time_zone` stores the offset in 15-minute units (127 unknown).
- `is_copy_only`: a copy-only full does not reset the differential base, so it must not count as "the last full" for restore planning. The page's example separates the two (own note: the script `backup_status.sql` does not filter on it; check section "Claims" in sources.md).
- `backup_size` versus `compressed_backup_size`: compression ratio is the quotient; NULL after an msdb upgrade means "treat as uncompressed".
- `has_backup_checksums`, `is_damaged`: a backup with `is_damaged = 1` was taken despite detected damage; `has_backup_checksums = 0` means page checksums were not verified during the backup.
- `begins_log_chain`, `first_lsn`, `last_lsn`, `database_backup_lsn`, `differential_base_lsn`: the LSN chain. A log backup restores only if its first LSN continues the previous one.
- `key_algorithm`, `encryptor_type`, `encryptor_thumbprint`: show whether the backup is encrypted; `NO_Encryption` otherwise.
- 2022 and later only: `last_valid_restore_time` (helps pick the last log backup for a `STOPAT`), and `compression_algorithm` (default `MS_XPRESS`). Neither exists on 2019.

Filtering: the scripts keep rows where `server_name = @@SERVERNAME`, because restoring a backup writes the source's history into the target's msdb. Without that filter a restored copy appears to have been "backed up" by this server.

Retention: history grows until `sp_delete_backuphistory` runs. A short retention (job cleaning at 30 days) means history older than that does not exist; "no full backup found" can be a pruning artifact. Backups taken by another tool that bypasses SQL Server's own history (some snapshot or third-party agents) may not appear at all (VSS backups write estimated sizes; own note: some tools write nothing).

## 2. What backup history proves

It proves SQL Server completed an operation and when. It does not prove the file still exists, is readable, restores cleanly, is offsite, or meets the recovery objective. Recovery objective checks: log backup cadence against minutes since last log (`minutesSinceLog`), full cadence against `daysSinceFull`, and recovery model: a database in FULL recovery with no log backups grows its log forever; a SIMPLE database has no log chain, so no point-in-time restore.

Example reading:
```
databaseName  recoveryModel  lastFull  lastLog  daysSinceFull  minutesSinceLog
Sales         FULL           3 days    NULL     3              NULL
Hr            SIMPLE         1 day     NULL     1              NULL
```
`Sales` is the finding (FULL recovery without log backups). `Hr` NULL log is expected.

## 3. Virtual log files (`sys.dm_db_log_info`)

One row per VLF across all log files of a database; `vlf_active` (and `vlf_status` 0 inactive, 1 initialized unused, 2 active), `vlf_size_mb`, `vlf_sequence_number`. It replaces `DBCC LOGINFO`. The page's own example flags databases above 100 VLFs because many VLFs can slow database startup, restore and recovery; that is Microsoft's illustrative threshold, not a hard limit.

- The count depends on growth history. The growth formula changed slightly in 2022: when a growth is at most 64 MB and more than 1/8 of the current log size, one VLF is created instead of four. VLF counts between 2019 and 2022 databases are therefore not strictly comparable.
- `activeVlfCount` shows how much of the log is in use. A log that cannot truncate shows a large active share; the reason is in `sys.databases.log_reuse_wait_desc` (general knowledge, not on the fetched page).
- 2019 adds `vlf_encryptor_thumbprint` (TDE-encrypted VLFs).
- Permission: `VIEW SERVER STATE` up to 2019; `VIEW DATABASE PERFORMANCE STATE` on 2022 and later.
- The script skips offline databases, snapshots and secondary AG replicas.

## 4. `DATABASEPROPERTYEX(..., 'LastGoodCheckDbTime')`

Date of the last successful `DBCC CHECKDB`. Returns `1900-01-01 00:00:00.000` if never run, and for AG databases it reports the primary's value regardless of the replica queried. Applies to 2016 SP2, 2017 CU9 and 2019 or later. It returns NULL for unstarted or inaccessible databases (AUTO_CLOSE or offline). A date from months ago, or 1900, is a finding; a recent date is not proof of a clean database for later corruption.

Also on the page: the `Status` property can say ONLINE while the database is still opening; the `Collation` property being non-null is the page's test that it accepts connections. `IsOptimizedLockingOn` exists from 2025 (the script `database_inventory.sql` on 2025 uses the catalog column instead).

## How an agent should apply this

- Report backup coverage per database with recovery model, and treat FULL recovery without a recent log backup as high risk.
- Exclude or label copy-only fulls and say which rows were filtered by `server_name`.
- State that history is not a restore test; recommend `backup-restore-drill` for proof, and give the RTO/RPO question back to the owner.
- Show VLF counts with growth context and the 2022 formula caveat; do not apply a universal VLF limit.
- Treat `1900-01-01` for CHECKDB as "never recorded" and ask for the CHECKDB job; do not run CHECKDB yourself.
- Send encryption and exposure aspects of backup files to `database-audit` or `database-exposure`.
