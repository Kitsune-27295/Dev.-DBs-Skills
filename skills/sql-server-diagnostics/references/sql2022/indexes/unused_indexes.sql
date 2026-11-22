-- Nonclustered indexes with writes and no reads since the last restart
-- (sys.dm_db_index_usage_stats). Read-only: a SELECT over the DMV; no index is dropped.
-- System databases and objects are left out. tableName is NULL when the login cannot see the object.
SELECT TOP (25)
    CAST(DB_NAME(us.database_id) AS NVARCHAR(128)) AS databaseName,
    CAST(OBJECT_SCHEMA_NAME(us.object_id, us.database_id) + N'.'
         + OBJECT_NAME(us.object_id, us.database_id) AS NVARCHAR(512)) AS tableName,
    us.index_id AS indexId,
    us.user_seeks AS userSeeks,
    us.user_scans AS userScans,
    us.user_lookups AS userLookups,
    us.user_updates AS userUpdates
FROM sys.dm_db_index_usage_stats AS us
WHERE us.database_id > 4
  AND us.index_id > 1
  AND us.user_seeks + us.user_scans + us.user_lookups = 0
  AND us.user_updates > 0
  AND ISNULL(OBJECT_SCHEMA_NAME(us.object_id, us.database_id), N'') <> N'sys'
ORDER BY us.user_updates DESC, us.database_id, us.object_id, us.index_id
