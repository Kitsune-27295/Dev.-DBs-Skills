-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- Backup history for the last 7 days (msdb.dbo.backupset).
-- Read-only: a SELECT over an msdb table. Only records written by this instance.
SELECT TOP (100)
    CAST(bs.database_name AS NVARCHAR(128)) AS databaseName,
    CAST(CASE bs.type
            WHEN 'D' THEN N'Full'
            WHEN 'I' THEN N'Differential'
            WHEN 'L' THEN N'Log'
            WHEN 'F' THEN N'File'
            WHEN 'G' THEN N'DifferentialFile'
            WHEN 'P' THEN N'Partial'
            WHEN 'Q' THEN N'DifferentialPartial'
            ELSE bs.type END AS NVARCHAR(30)) AS backupType,
    CAST(bs.backup_start_date AS DATETIME2) AS backupStart,
    CAST(bs.backup_finish_date AS DATETIME2) AS backupFinish,
    CAST(bs.backup_size / 1048576.0 AS DECIMAL(18,2)) AS sizeMb,
    CAST(bs.compressed_backup_size / 1048576.0 AS DECIMAL(18,2)) AS compressedSizeMb,
    CAST(bs.backup_size / NULLIF(bs.compressed_backup_size, 0) AS DECIMAL(18,2)) AS compressionRatio,
    bs.is_copy_only AS isCopyOnly
FROM msdb.dbo.backupset AS bs
WHERE bs.server_name = @@SERVERNAME
  AND bs.backup_start_date >= DATEADD(DAY, -7, GETDATE())
ORDER BY bs.backup_start_date DESC, bs.database_name, bs.backup_set_id DESC
