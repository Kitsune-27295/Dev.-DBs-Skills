-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- Fragmentation of indexes with at least 1000 pages, in all user databases
-- (sys.dm_db_index_physical_stats in LIMITED mode). Read-only: a SELECT over the DMF;
-- no index is rebuilt. Costly on large databases: it scans the upper-level pages.
-- REBUILD above 30%, REORGANIZE between 5% and 30%, NONE below.
SELECT TOP (20)
    CAST(DB_NAME(ps.database_id) AS NVARCHAR(128)) AS databaseName,
    CAST(OBJECT_SCHEMA_NAME(ps.object_id, ps.database_id) + N'.'
         + OBJECT_NAME(ps.object_id, ps.database_id) AS NVARCHAR(512)) AS tableName,
    ps.index_id AS indexId,
    CAST(ps.index_type_desc AS NVARCHAR(60)) AS indexType,
    CAST(ps.avg_fragmentation_in_percent AS DECIMAL(18,2)) AS fragmentationPct,
    ps.page_count AS pageCount,
    CAST(CASE WHEN ps.avg_fragmentation_in_percent > 30 THEN N'REBUILD'
              WHEN ps.avg_fragmentation_in_percent >= 5 THEN N'REORGANIZE'
              ELSE N'NONE' END AS NVARCHAR(20)) AS recommendedAction
FROM sys.dm_db_index_physical_stats(NULL, NULL, NULL, NULL, 'LIMITED') AS ps
WHERE ps.database_id > 4
  AND ps.index_id > 0
  AND ps.alloc_unit_type_desc = N'IN_ROW_DATA'
  AND ps.page_count >= 1000
ORDER BY ps.avg_fragmentation_in_percent DESC, ps.page_count DESC, ps.database_id, ps.object_id, ps.index_id
