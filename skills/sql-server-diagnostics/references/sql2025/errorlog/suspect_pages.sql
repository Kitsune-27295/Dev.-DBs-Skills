-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- Suspect pages recorded in msdb (msdb.dbo.suspect_pages).
-- Read-only: a SELECT over an msdb table; no page is repaired.
-- eventType follows the documentation codes: 1 error 823/824, 2 bad checksum,
-- 3 torn page, 4 restored, 5 repaired, 7 deallocated by DBCC.
SELECT TOP (100)
    CAST(DB_NAME(sp.database_id) AS NVARCHAR(128)) AS databaseName,
    sp.file_id AS fileId,
    sp.page_id AS pageId,
    CAST(CASE sp.event_type
            WHEN 1 THEN N'Error823_824'
            WHEN 2 THEN N'BadChecksum'
            WHEN 3 THEN N'TornPage'
            WHEN 4 THEN N'Restored'
            WHEN 5 THEN N'Repaired'
            WHEN 7 THEN N'Deallocated'
            ELSE CONCAT(N'Unknown', sp.event_type)
         END AS NVARCHAR(30)) AS eventType,
    sp.error_count AS errorCount,
    CAST(sp.last_update_date AS DATETIME2) AS lastUpdateDate
FROM msdb.dbo.suspect_pages AS sp
ORDER BY sp.last_update_date DESC, sp.database_id, sp.file_id, sp.page_id
