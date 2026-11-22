-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- Indexes suggested by the optimizer since the last restart (sys.dm_db_missing_index_*).
-- Read-only: a SELECT over DMVs; no index is created.
-- improvementMeasure = average cost x average impact x (seeks + scans). System databases excluded.
-- When the object name is not visible to the login, it falls back to the DMV's 'statement' text.
WITH mi AS (
    SELECT
        mid.database_id,
        mid.object_id,
        mid.statement,
        mid.equality_columns,
        mid.inequality_columns,
        mid.included_columns,
        migs.user_seeks,
        migs.user_scans,
        migs.avg_total_user_cost,
        migs.avg_user_impact,
        migs.avg_total_user_cost * (migs.avg_user_impact / 100.0)
            * (migs.user_seeks + migs.user_scans) AS improvement
    FROM sys.dm_db_missing_index_details AS mid
    JOIN sys.dm_db_missing_index_groups AS mig
      ON mig.index_handle = mid.index_handle
    JOIN sys.dm_db_missing_index_group_stats AS migs
      ON migs.group_handle = mig.index_group_handle
    WHERE mid.database_id > 4
)
SELECT TOP (25)
    CAST(DB_NAME(mi.database_id) AS NVARCHAR(128)) AS databaseName,
    CAST(COALESCE(OBJECT_SCHEMA_NAME(mi.object_id, mi.database_id) + N'.'
                  + OBJECT_NAME(mi.object_id, mi.database_id), mi.statement) AS NVARCHAR(512)) AS tableName,
    CAST(mi.equality_columns AS NVARCHAR(4000)) AS equalityColumns,
    CAST(mi.inequality_columns AS NVARCHAR(4000)) AS inequalityColumns,
    CAST(mi.included_columns AS NVARCHAR(4000)) AS includedColumns,
    mi.user_seeks AS userSeeks,
    mi.user_scans AS userScans,
    CAST(mi.avg_total_user_cost AS DECIMAL(18,2)) AS avgTotalUserCost,
    CAST(mi.avg_user_impact AS DECIMAL(18,2)) AS avgUserImpact,
    CAST(mi.improvement AS DECIMAL(18,2)) AS improvementMeasure
FROM mi
ORDER BY mi.improvement DESC, mi.database_id, mi.object_id, mi.statement
