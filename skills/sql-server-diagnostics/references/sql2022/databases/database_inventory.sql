-- Database inventory: state, options and sizes (sys.databases with sys.master_files).
-- Read-only: a SELECT over catalog views; no option is changed.
-- lastGoodCheckDb comes from DATABASEPROPERTYEX (2016 SP2 onwards); 1900-01-01 means that
-- the database never went through CHECKDB, and NULL that the property is not available.
WITH sz AS (
    SELECT
        mf.database_id,
        SUM(CASE WHEN mf.type <> 1 THEN CAST(mf.size AS BIGINT) ELSE 0 END) AS dataPages,
        SUM(CASE WHEN mf.type = 1 THEN CAST(mf.size AS BIGINT) ELSE 0 END) AS logPages
    FROM sys.master_files AS mf
    GROUP BY mf.database_id
)
SELECT TOP (200)
    CAST(d.name AS NVARCHAR(128)) AS databaseName,
    CAST(d.state_desc AS NVARCHAR(60)) AS state,
    CAST(d.recovery_model_desc AS NVARCHAR(60)) AS recoveryModel,
    CAST(d.compatibility_level AS INT) AS compatibilityLevel,
    CAST(d.page_verify_option_desc AS NVARCHAR(60)) AS pageVerify,
    CAST(d.log_reuse_wait_desc AS NVARCHAR(60)) AS logReuseWait,
    d.is_trustworthy_on AS isTrustworthy,
    d.is_auto_create_stats_on AS autoCreateStats,
    d.is_auto_update_stats_on AS autoUpdateStats,
    d.is_read_committed_snapshot_on AS isReadCommittedSnapshot,
    CAST(sz.dataPages * 8 / 1024.0 AS DECIMAL(18,2)) AS dataMb,
    CAST(sz.logPages * 8 / 1024.0 AS DECIMAL(18,2)) AS logMb,
    CAST(CAST(DATABASEPROPERTYEX(d.name, 'LastGoodCheckDbTime') AS DATETIME) AS DATETIME2) AS lastGoodCheckDb
FROM sys.databases AS d
LEFT JOIN sz
  ON sz.database_id = d.database_id
ORDER BY d.name
