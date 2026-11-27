-- Cached queries with the highest elapsed time (sys.dm_exec_query_stats).
-- Read-only: a SELECT over DMVs; nothing is changed or executed.
-- Pre-selects the top 200 and only then resolves the database of each plan, so as not to scan the
-- whole cache with dm_exec_plan_attributes. System databases are left out.
WITH candidates AS (
    SELECT TOP (200)
        qs.plan_handle,
        qs.sql_handle,
        qs.statement_start_offset,
        qs.statement_end_offset,
        qs.execution_count,
        qs.total_worker_time,
        qs.total_logical_reads,
        qs.total_elapsed_time,
        qs.last_execution_time
    FROM sys.dm_exec_query_stats AS qs
    ORDER BY qs.total_elapsed_time DESC, qs.sql_handle, qs.statement_start_offset
),
t AS (
    SELECT c.*, CAST(pa.value AS INT) AS dbid
    FROM candidates AS c
    OUTER APPLY (
        SELECT a.value
        FROM sys.dm_exec_plan_attributes(c.plan_handle) AS a
        WHERE a.attribute = N'dbid'
    ) AS pa
)
SELECT TOP (20)
    CAST(DB_NAME(t.dbid) AS NVARCHAR(128)) AS databaseName,
    t.execution_count AS executionCount,
    CAST(t.total_elapsed_time / 1000.0 AS DECIMAL(18,2)) AS totalElapsedMs,
    CAST(t.total_elapsed_time / 1000.0 / NULLIF(t.execution_count, 0) AS DECIMAL(18,2)) AS avgElapsedMs,
    CAST(t.total_worker_time / 1000.0 AS DECIMAL(18,2)) AS totalCpuMs,
    CAST(t.total_worker_time / 1000.0 / NULLIF(t.execution_count, 0) AS DECIMAL(18,2)) AS avgCpuMs,
    t.total_logical_reads AS totalLogicalReads,
    CAST(t.total_logical_reads * 1.0 / NULLIF(t.execution_count, 0) AS DECIMAL(18,2)) AS avgLogicalReads,
    CAST(t.last_execution_time AS DATETIME2) AS lastExecutionTime,
    CAST(LEFT(SUBSTRING(st.text, t.statement_start_offset / 2 + 1,
        (CASE WHEN t.statement_end_offset = -1 THEN DATALENGTH(st.text)
              ELSE t.statement_end_offset END - t.statement_start_offset) / 2 + 1), 4000) AS NVARCHAR(4000)) AS queryText
FROM t
CROSS APPLY sys.dm_exec_sql_text(t.sql_handle) AS st
WHERE t.dbid > 4 AND t.dbid <> 32767
ORDER BY t.total_elapsed_time DESC, t.sql_handle, t.statement_start_offset
