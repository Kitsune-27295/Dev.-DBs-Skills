-- Target: SQL Server 2019 (15.x). Same query as the sql2022 pack: every object it reads exists on 2019.
-- Target permissions: on 2019 the DMVs and DMFs it reads need VIEW SERVER STATE (2022 split this into narrower ones).
-- Presence of the most common DBA tools in master (First Responder Kit,
-- sp_WhoIsActive, Ola Hallengren's maintenance routines), looked up by name in
-- master.sys.objects. Read-only: the names are literals being looked for, nothing is executed.
SELECT TOP (20)
    CAST(t.toolName AS NVARCHAR(128)) AS toolName,
    CAST(CASE WHEN EXISTS (
        SELECT 1 FROM master.sys.objects AS o
        WHERE o.name = t.toolName AND o.type IN ('P', 'PC')
    ) THEN 1 ELSE 0 END AS BIT) AS isPresent
FROM (VALUES
    (1, N'sp_Blitz'),
    (2, N'sp_BlitzCache'),
    (3, N'sp_BlitzIndex'),
    (4, N'sp_BlitzFirst'),
    (5, N'sp_BlitzLock'),
    (6, N'sp_WhoIsActive'),
    (7, N'CommandExecute'),
    (8, N'DatabaseBackup'),
    (9, N'IndexOptimize'),
    (10, N'DatabaseIntegrityCheck')
) AS t (sortOrder, toolName)
ORDER BY t.sortOrder
