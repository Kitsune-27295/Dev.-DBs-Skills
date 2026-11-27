# Wait Stats, I/O Latency and Blocking: How to Read the Output

Sources: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql · https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-io-virtual-file-stats-transact-sql · https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-performance-counters-transact-sql · https://learn.microsoft.com/en-us/sql/relational-databases/extended-events/use-the-system-health-session · Last verified 2026-11-27

Scripts covered: `waits/wait_stats`, `io/io_by_file`, `io/io_by_database`, `memory/memory_overview`, `deadlocks/deadlock_summary`. Version permission differences live in [sql2019-porting.md](sql2019-porting.md) and [version-differences-2019-2022-2025.md](version-differences-2019-2022-2025.md); this file is about reading results.

## 1. What `sys.dm_os_wait_stats` holds

One row per wait type, aggregated over every wait that has finished. It does not show waits in progress. Columns: `waiting_tasks_count` (waits started), `wait_time_ms` (total, and it already includes the signal part), `max_wait_time_ms`, `signal_wait_time_ms` (time between being signaled and getting back on a CPU).

- Resource wait is roughly `wait_time_ms - signal_wait_time_ms`. A large signal share means tasks queue for a scheduler; the page does not spell out that interpretation, so treat it as an inference from the definition.
- Average wait = `wait_time_ms / waiting_tasks_count`. Total time alone favors frequent short waits; `max_wait_time_ms` exposes rare long ones.
- Three families: resource waits (locks, latches, I/O, network), queue waits (background tasks idle), external waits (the thread may still be running outside code). `wait_stats.sql` drops the idle queue types through its `NOT IN` list.

## 2. Reset behavior (the main pitfall)

Counters reset on engine restart and on `DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR)`. They are cumulative, so a server up for 200 days shows an average over 200 days; a spike last night disappears in the noise. Always read `sqlStartTime` from `identity/server_identity` first. For a current picture, take two snapshots a known interval apart and subtract (own recommendation; the page only says counters accumulate).

## 3. Wait types the pages describe

| Wait | Page says | Reading hint |
|---|---|---|
| `LCK_M_*` | data contention between queries; many modes (S, X, U, IX, SCH_M, range variants) | blocking exists; find the head blocker live, the DMV cannot name it |
| `PAGEIOLATCH_*` | buffer being read from or written to disk | slow I/O or too little memory; cross-check `io/io_by_file` latency |
| `PAGELATCH_*` | page latch, no I/O; `PAGELATCH_EX` last-page insert, `PAGELATCH_UP` on PFS/GAM/SGAM common with tempdb allocation | contention in memory, not disk; look at tempdb file count (`tempdb/tempdb_files`) |
| `CXPACKET`, `CXCONSUMER` | parallel exchange; consumer threads moved to CXCONSUMER from 2016 SP2 and 2017 CU3 | high CXPACKET: review cost threshold and MAXDOP |
| `CXSYNC_PORT`, `CXSYNC_CONSUMER` | from 2022, CXPACKET covers only producer threads; port open/close/sync and the consumer sync point have their own types | do not compare CXPACKET totals across 2019 and 2022 |
| `ASYNC_NETWORK_IO` | client is slow to take results | often the application, not the server |
| `HADR_SYNC_COMMIT` | expected on synchronous availability groups | normal; judge by size relative to commit volume |
| `LOGBUFFER` | consistently high suggests log device cannot keep up | check `io_by_file` for the log file |
| `LCK_M_S_XACT*` | waiting for a shared lock on an XACT resource when optimized locking is on (the entries carry no version note; optimized locking itself is a 2025 feature on What's New) | real waits, kept by the script |
| `HTBUILD_AGG/JOIN`, `HTDELETE_AGG/JOIN` | the page lists these split types for Azure SQL Database, Synapse and Managed Instance on the 2025 or always-up-to-date policy; on-premises types are the unsuffixed `HTBUILD` and `HTDELETE` | the page does not say the split reaches the 2025 engine itself: expect either name and treat as renames, not a new problem |

Many entries on the page are marked internal or unsupported: do not build rules on them.

## 4. I/O latency (`sys.dm_io_virtual_file_stats`)

`io_stall_read_ms / num_of_reads` gives average read latency, same for writes; `io_by_file.sql` does exactly this with `NULLIF` against zero. Counters start at zero when the service starts (page remark), so a file with few operations gives noisy averages. `io_stall_queued_*` is delay added by I/O resource governance, not the disk. Latency thresholds are not on the page; common rules of thumb (about 5 to 20 ms for data reads, lower for log writes) are community convention, not Microsoft documentation: quote them as such.

## 5. Performance counters (`sys.dm_os_performance_counters`)

`cntr_value` for per-second counters is cumulative: sample twice and subtract. Ratio counters (for example buffer cache hit ratio) need the matching "base" counter as denominator; `memory_overview.sql` divides by `NULLIF(base, 0)`. Page life expectancy is a snapshot value (type 65792 are snapshots). The script computes `lazyWritesPerSec` as an average since start for that reason. If the view returns 0 rows, counters are disabled (setup error 3409).

## 6. Deadlocks and `system_health`

The `system_health` session starts with the engine and records deadlock graphs, long lock waits (over 30 s), long latch waits (over 15 s), and memory and scheduler errors. Its file target keeps few files (4 files of 5 MB; Standard and Enterprise: 10 files of 100 MB), so history is short on a busy server: zero deadlocks in 7 days can mean rolled-over files. The page names "deadlocks, including the deadlock graph" but the exact event name `xml_deadlock_report` is not stated on it (it is used by `deadlock_summary.sql`; see Claims in sources.md).

## 7. Blocking (not scripted)

The pack has no live-blocking script. Waits only show that blocking happened. To name a head blocker an owner must look at live sessions (for example `sys.dm_exec_requests` and `sys.dm_os_waiting_tasks`, not fetched for this version of the skill) or `sp_WhoIsActive` if `jobs/dba_tools.sql` reports it installed.

## How an agent should apply this

- Quote `sqlStartTime` next to every wait, I/O and counter result; refuse to call a number "current" without it.
- Report top waits as total, average and signal share, and name what each family usually points to, with the next script (`io_by_file`, `tempdb_files`, `memory_overview`).
- Never recommend changing MAXDOP, cost threshold or file layout from one wait table; propose it as a hypothesis with the check that would confirm it.
- For lock waits, say that blocking occurred and ask the owner to capture a live snapshot; do not invent the blocker.
- State the latency rule you used and that it is a convention, not a Microsoft threshold.
- When comparing versions, remember the CXPACKET split and the hash-wait names before concluding anything changed.
