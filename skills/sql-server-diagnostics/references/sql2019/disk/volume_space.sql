-- Target: SQL Server 2019 (15.x). Same query as the sql2022 pack: every object it reads exists on 2019.
-- Target permissions: on 2019 the DMVs and DMFs it reads need VIEW SERVER STATE (2022 split this into narrower ones).
-- Space of the volumes that contain database files (sys.master_files with
-- sys.dm_os_volume_stats). Read-only: a SELECT over a catalog view and a DMF.
-- ONLINE databases only: the DMF does not answer for the files of an offline database.
WITH v AS (
    SELECT
        vs.volume_mount_point,
        vs.logical_volume_name,
        vs.file_system_type,
        vs.total_bytes,
        vs.available_bytes,
        COUNT(*) AS databaseFiles
    FROM sys.master_files AS mf
    JOIN sys.databases AS d
      ON d.database_id = mf.database_id
    CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS vs
    WHERE d.state = 0
    GROUP BY vs.volume_mount_point, vs.logical_volume_name, vs.file_system_type,
             vs.total_bytes, vs.available_bytes
)
SELECT TOP (30)
    CAST(v.volume_mount_point AS NVARCHAR(512)) AS volumeMountPoint,
    CAST(v.logical_volume_name AS NVARCHAR(512)) AS logicalVolumeName,
    CAST(v.file_system_type AS NVARCHAR(512)) AS fileSystemType,
    CAST(v.total_bytes / 1073741824.0 AS DECIMAL(18,2)) AS totalGb,
    CAST(v.available_bytes / 1073741824.0 AS DECIMAL(18,2)) AS availableGb,
    CAST(100.0 * (v.total_bytes - v.available_bytes) / NULLIF(v.total_bytes, 0) AS DECIMAL(18,2)) AS usedPct,
    v.databaseFiles
FROM v
ORDER BY v.volume_mount_point, v.logical_volume_name
