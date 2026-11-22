-- Number of Virtual Log Files per database (sys.dm_db_log_info, 2016 SP2 onwards).
-- Read-only: a SELECT over a DMF; nothing is changed.
-- Offline databases, snapshots and secondary AG replicas are left out, where the DMF
-- does not answer or repeats what the primary already shows.
SELECT TOP (200)
    CAST(d.name AS NVARCHAR(128)) AS databaseName,
    COUNT(*) AS vlfCount,
    SUM(CASE WHEN li.vlf_active = 1 THEN 1 ELSE 0 END) AS activeVlfCount,
    CAST(SUM(li.vlf_size_mb) AS DECIMAL(18,2)) AS logSizeMb
FROM sys.databases AS d
CROSS APPLY sys.dm_db_log_info(d.database_id) AS li
WHERE d.state = 0
  AND d.source_database_id IS NULL
  AND d.database_id NOT IN (
      SELECT drs.database_id
      FROM sys.dm_hadr_database_replica_states AS drs
      WHERE drs.is_local = 1 AND drs.is_primary_replica = 0
  )
GROUP BY d.name
ORDER BY COUNT(*) DESC, d.name
