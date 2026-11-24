# Top Queries, the Plan Cache and Query Store

Sources: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-query-stats-transact-sql · https://learn.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store · https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-runtime-stats-transact-sql · https://learn.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-2022 · https://learn.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-2025 · Last verified 2026-11-24

Scripts covered: `queries/top_queries_cpu`, `top_queries_duration`, `top_queries_reads`. The pack has no Query Store script; this file explains where the cache-based scripts stop and when to ask for Query Store data. Generic tuning workflow belongs to `query-performance`.

## 1. What `sys.dm_exec_query_stats` is

One row per statement inside a cached plan. The row lives exactly as long as the plan: when the plan is evicted (memory pressure, recompile, restart, `DBCC FREEPROCCACHE`), its counters vanish. Statistics update when a query finishes, so running queries are not counted.

Units that trip people up:
- `total_worker_time` (CPU) and `total_elapsed_time` are in microseconds but accurate only to milliseconds. The scripts divide by 1000 to show milliseconds.
- `execution_count` is since the plan was last compiled, not since restart. Two plans for the same text have separate rows (`plan_generation_num` tells recompiles apart).
- `statement_start_offset` and `statement_end_offset` are bytes inside the batch text; the scripts divide by 2 for characters because the text is UTF-16. An end offset of -1 means to the end.
- `query_hash` groups statements that differ only by literals; `query_plan_hash` groups similar plans. The page's example aggregates by `query_hash` to find the true heaviest "shape". The pack groups per plan row, so one query with many literal variants can hide below one-off heavy ones.
- Memory-optimized or natively compiled objects report zeros for several columns (reads, writes); CPU may be inaccurate under 1 ms.

## 2. Pitfalls of cache-based "top queries"

- Survivorship: expensive but evicted plans are missing; cheap queries running a million times are present. A quiet cache after a restart looks "healthy".
- Ad hoc workloads fill the cache with single-use plans, pushing out useful ones.
- The pack pre-selects 200 rows and then resolves the database with `sys.dm_exec_plan_attributes` (attribute `dbid`), because resolving on the whole cache is costly; databases 1 to 4 and the resource database (32767) are excluded.
- Averages hide variance: min and max columns exist (`min_worker_time`, `max_worker_time`, `max_elapsed_time`) and are worth selecting when a query is "sometimes slow".
- Column `total_spills` and the memory grant columns (`total_grant_kb`, `total_used_grant_kb`) exist from 2016 SP2 / 2017 CU3 and 2016; they are not selected by the pack but answer "does it spill".

## 3. Query Store: what it adds

Query Store persists queries, plans and runtime stats per database, in time buckets, so it survives restarts and plan eviction and keeps several plans per query. Three stores: plan, runtime stats, wait stats (wait stats capture since 2017). Key views: `sys.query_store_query`, `query_store_query_text`, `query_store_plan`, `query_store_runtime_stats`, `query_store_runtime_stats_interval`, `query_store_wait_stats`, and `sys.database_query_store_options` for the current mode and state.

Reading `runtime_stats`: one row per plan, execution type and interval; the current interval can have several rows (flushed and in-memory), so aggregate by plan, execution type and interval. Durations and CPU are in microseconds, reads and writes in 8 KB pages, memory in 8 KB pages. `execution_type` 0 is regular, 3 client-aborted, 4 exception: filter on 0 before comparing averages. A documented reporting quirk: DOP columns can show very large numbers on many-core systems.

Plan regression workflow in words: find a query whose average duration or CPU rose after a time T; see whether a second plan id appeared around T; compare the plans; if the older plan was better, force it (`sp_query_store_force_plan`) or fix the cause (statistics, parameter sniffing, compatibility level). Only plans that Query Store holds can be forced. Forcing is a change to the instance, so the owner runs it.

Defaults by version, from the Query Store page and What's New pages:
- 2019: off by default for new databases.
- 2022: on by default in read-write mode for new databases; upgraded or restored databases keep their previous setting.
- Readable secondary replicas: the Query Store page and What's New 2025 apply it to 2025; What's New 2022 also lists it. Uncertain; see Claims in sources.md.
- Cannot be enabled on `master` or `tempdb`. Plans for DDL are not captured; natively compiled procedures need an explicit switch.

## 4. Query Store state can lie

`sys.database_query_store_options` has `actual_state_desc` versus `desired_state_desc`. A store that hit its size limit or an error is read-only or in error and silently stops collecting. `sp_query_store_consistency_check` can recover an error state (2017 and later). Check state before trusting a "no regression found".

Example check to hand to the owner (read-only):
```
SELECT actual_state_desc, desired_state_desc, current_storage_size_mb, max_storage_size_mb
FROM sys.database_query_store_options;   -- run in each user database
```
(Column names are from general knowledge of the view; the options-view page was not fetched, only referenced by the monitoring page.)

## How an agent should apply this

- Present `top_queries_*` as "heaviest statements currently cached", with plan creation time or uptime, never as "the slowest queries".
- If the question is about regression or history, say the pack cannot answer it, and ask the owner to run a Query Store query or open the Regressed Queries report.
- Check Query Store state and version default before assuming history exists (2019 databases usually have none).
- Convert units explicitly (microseconds to milliseconds, pages to MB) in the report.
- Never force a plan or change Query Store settings; propose, with the query id and plan ids as evidence.
- Hand generic tuning (rewrites, hints) to `query-performance`.
