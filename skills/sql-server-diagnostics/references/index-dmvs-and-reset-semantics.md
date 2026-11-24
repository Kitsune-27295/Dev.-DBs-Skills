# Index DMVs: Missing, Unused and Their Reset Rules

Sources: https://learn.microsoft.com/en-us/sql/relational-databases/indexes/tune-nonclustered-missing-index-suggestions · https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-missing-index-group-stats-transact-sql · https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-usage-stats-transact-sql · Last verified 2026-11-24

Scripts covered: `indexes/missing_indexes`, `indexes/unused_indexes`, `indexes/index_fragmentation` (only the pointer in section 4), `indexes/vector_indexes` (2025). This is analysis of what the numbers mean; the generic index-design side belongs to `query-performance`.

## 1. Missing-index DMVs

Three views join into one suggestion: `sys.dm_db_missing_index_details` (table, equality, inequality, included columns), `sys.dm_db_missing_index_groups` (bridge via `index_handle` and `index_group_handle`) and `sys.dm_db_missing_index_group_stats` (`user_seeks`, `user_scans`, `avg_total_user_cost`, `avg_user_impact`, `unique_compiles`). `missing_indexes.sql` joins them and ranks by cost x impact fraction x (seeks + scans).

How to read the columns:
- `avg_user_impact` is the average percentage by which estimated query cost would drop. It is an estimate made at compile time and never re-tested after execution.
- `avg_total_user_cost` is the optimizer's cost of the affected queries, not seconds.
- seeks + scans is how often the suggestion would have applied. The page's own sample formula uses the raw impact percentage; the script divides by 100, which only rescales the rank and does not change the order.
- The stats row updates on every execution, not every compilation.

## 2. Limits that make suggestions unsafe to copy

From Microsoft's tuning page:
- Only nonclustered rowstore suggestions. No unique, no filtered indexes.
- Key columns are listed without a recommended order. Rule from the page: equality columns before inequality columns, most selective first among equality columns. Included-column order does not matter.
- No cost-benefit check on how many included columns, so a suggestion can be a near copy of the table.
- Similar suggestions pile up for the same table; they should be merged with each other and with existing indexes.
- No suggestion for trivial plans; cost is less accurate when only inequality predicates exist.
- The group-stats view holds at most 600 rows; the tuning page says collection stops after 600 groups. Once full, new suggestions are lost until old ones are cleared (some are cleared when you add indexes).
- Reset: instance restart, failover, database offline, and any metadata change to the table (add or drop column, create index, `ALTER INDEX`) clear that table's suggestions. Query Store can keep the plans that carried `MissingIndexes` XML across restarts.

Example of a merge decision (own illustration): existing index on `(StateProvinceID)`; suggestions `(StateProvinceID, City)` and `(StateProvinceID, City) INCLUDE (PostalCode)`. One widened index `(StateProvinceID, City) INCLUDE (PostalCode)` covers both; the page works through this exact case.

## 3. `sys.dm_db_index_usage_stats` and unused indexes

Counters: `user_seeks`, `user_scans`, `user_lookups`, `user_updates`, plus last-time columns and system_* twins. Facts from the page:
- One operation per query execution counts once. `user_updates` counts statements, not rows: deleting 1000 rows in one statement adds 1.
- Counters start empty at engine start, and all rows for a database vanish on detach, shutdown or AUTO_CLOSE.
- Memory-optimized and spatial indexes are not reported.
- A row appears only when the index is first used, so an index that was never touched may have no row at all. `unused_indexes.sql` lists rows with zero reads and some writes; an index with no row at all is invisible to it (inference from the remark on row creation).
- Upgrade note: entries were cleared on upgrade to 2008 R2, 2012 and 2014, and are kept again from 2016.

Pitfalls specific to "unused":
- A restart a week ago means a month-end or quarterly job has not run yet. Compare `sqlStartTime` with the business calendar.
- The index may enforce a unique or primary key constraint; the script filters `index_id > 1`, which excludes the clustered index, but a unique nonclustered constraint can still appear. Dropping it changes data rules, not just speed.
- Read counts include maintenance scans for statistics, because the page says internally generated queries count too.

## 4. Fragmentation (pointer only)

`index_fragmentation.sql` is the heavy script that scans index pages. The 5 percent reorganize and 30 percent rebuild rule appears in `SKILL.md` and is repeated in [sql2025-porting.md](sql2025-porting.md); the physical-stats page was not re-read for this reference, so no further claim is made here.

## Example: ranking a suggestion

```
group  seeks  scans  avgCost  avgImpact(%)  rank = cost * impact/100 * (seeks+scans)
A      12000  0      0.9      96            10368
B      40     300    45.0     70            10710
```
A looks bigger by impact and frequency but each query is cheap; B is expensive and rare. Both rank about the same, so neither is an order to create anything: check the table size, write rate and existing indexes first.

## How an agent should apply this

- Report missing indexes as "optimizer suggestions since restart, estimated, not tested", with uptime, never as a to-do list.
- Before suggesting `CREATE INDEX`, list existing indexes on that table and propose a merged definition; hand the statement to the owner.
- For unused indexes require at least one full business cycle of uptime, check constraint use, and say "candidate", not "drop".
- Treat an empty missing-index result as "nothing recorded" (restart, recent index changes, or the 600-group cap), not as proof the schema is well indexed.
- Route generic design questions (covering index, selectivity) to `query-performance`; keep this skill to reading the SQL Server DMV output.
