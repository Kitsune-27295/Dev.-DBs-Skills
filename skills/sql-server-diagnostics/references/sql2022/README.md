# sql2022: 30 read-only diagnostic queries

Written for SQL Server 2022 (16.x). Every file is one `SELECT` (or `WITH ... SELECT`) over catalog views, DMVs, DMFs or `msdb`
tables, capped with `TOP`, with explicit column aliases in camelCase. None changes state. Run one file at a time. Other versions, each with its own folder of scripts:
`../sql2019/` ([what changes](../sql2019-porting.md)) and `../sql2025/` ([what changes](../sql2025-porting.md), 31 scripts).

Cost: **light** reads a small view; **medium** sorts the plan cache (the scripts pre-select 200 rows to limit it); **heavy** scans files or
index pages, as the script's own comment warns (run off-peak, ask first).

| Area | File | What it answers | Cost |
|---|---|---|---|
| identity | `identity/server_identity.sql` | version, edition, host, CPUs, NUMA, memory, uptime, paths | light |
| config | `config/instance_configuration.sql` | the `sp_configure` options that matter, configured vs running | light |
| config | `config/service_accounts.sql` | service accounts, instant file initialization | light |
| databases | `databases/database_inventory.sql` | state, recovery model, options, sizes, last good CHECKDB | light |
| databases | `databases/vlf_counts.sql` | virtual log files per database | light |
| backup | `backup/backup_status.sql` | last full, differential and log backup per database | light |
| backup | `backup/backup_history.sql` | the last 7 days of backups of this instance | light |
| disk | `disk/volume_space.sql` | free space of volumes that hold database files | light |
| tempdb | `tempdb/tempdb_files.sql` | tempdb files, size and growth | light |
| memory | `memory/memory_overview.sql` | OS and SQL memory, page life expectancy, grants pending | light |
| memory | `memory/memory_model.sql` | memory model, locked and large pages, pressure flags | light |
| memory | `memory/memory_clerks.sql` | biggest memory clerks | light |
| io | `io/io_by_database.sql` | reads, writes and stalls per database since restart | light |
| io | `io/io_by_file.sql` | latency per data and log file | light |
| waits | `waits/wait_stats.sql` | top non-benign waits since restart | light |
| queries | `queries/top_queries_cpu.sql`, `top_queries_duration.sql`, `top_queries_reads.sql` | heaviest cached statements | medium |
| indexes | `indexes/missing_indexes.sql` | optimizer suggestions since restart | light |
| indexes | `indexes/unused_indexes.sql` | nonclustered indexes with writes and no reads | light |
| indexes | `indexes/index_fragmentation.sql` | fragmentation of indexes with 1000+ pages | heavy |
| deadlocks | `deadlocks/deadlock_summary.sql` | deadlocks of 7 days from `system_health` files | heavy |
| errorlog | `errorlog/suspect_pages.sql` | suspect pages in `msdb` | light |
| errorlog | `errorlog/memory_dumps.sql` | memory dumps of the instance | light |
| ha | `ha/ha_status.sql` | AlwaysOn, cluster, mirroring, log shipping, replication | light |
| jobs | `jobs/agent_jobs.sql` | Agent jobs and their last result | light |
| jobs | `jobs/dba_tools.sql` | whether First Responder Kit, `sp_WhoIsActive`, Ola Hallengren are installed | light |
| security | `security/sysadmin_members.sql` | members of `sysadmin` | light |
| security | `security/sql_login_policy.sql` | SQL logins and password policy checks | light |
| security | `security/linked_servers.sql` | linked servers and how they authenticate | light |

## Reading the results

- Counters (`wait_stats`, `io_*`, `missing_indexes`, `unused_indexes`, `top_queries_*`) are cumulative since the last restart:
  check `sqlStartTime` in `identity/server_identity.sql` before judging them.
- Output carries host names, account names and query text: treat it as sensitive, keep it in the report folder and never send it to
  an external service.
- A result is evidence, not a verdict: say what the number means for this instance and what to check next.
