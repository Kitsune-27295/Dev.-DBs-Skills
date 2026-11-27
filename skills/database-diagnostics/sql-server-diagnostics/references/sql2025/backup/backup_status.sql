-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- Last full, differential and log backup of each database (sys.databases with
-- msdb.dbo.backupset). Read-only: a SELECT over a catalog view and an msdb table.
-- Only records written by this instance are included (server_name = @@SERVERNAME): a restore
-- also writes the source's history into msdb. tempdb is left out.
WITH b AS (
    SELECT
        bs.database_name,
        MAX(CASE WHEN bs.type = 'D' THEN bs.backup_finish_date END) AS lastFull,
        MAX(CASE WHEN bs.type = 'I' THEN bs.backup_finish_date END) AS lastDiff,
        MAX(CASE WHEN bs.type = 'L' THEN bs.backup_finish_date END) AS lastLog
    FROM msdb.dbo.backupset AS bs
    WHERE bs.server_name = @@SERVERNAME
    GROUP BY bs.database_name
)
SELECT TOP (200)
    CAST(d.name AS NVARCHAR(128)) AS databaseName,
    CAST(d.recovery_model_desc AS NVARCHAR(60)) AS recoveryModel,
    CAST(b.lastFull AS DATETIME2) AS lastFullBackup,
    CAST(b.lastDiff AS DATETIME2) AS lastDiffBackup,
    CAST(b.lastLog AS DATETIME2) AS lastLogBackup,
    DATEDIFF(DAY, b.lastFull, GETDATE()) AS daysSinceFull,
    DATEDIFF(MINUTE, b.lastLog, GETDATE()) AS minutesSinceLog
FROM sys.databases AS d
LEFT JOIN b
  ON b.database_name = d.name
WHERE d.database_id <> 2
  AND d.source_database_id IS NULL
ORDER BY d.name
