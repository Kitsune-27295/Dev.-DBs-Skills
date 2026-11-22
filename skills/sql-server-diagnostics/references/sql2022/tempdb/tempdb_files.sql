-- tempdb files with size and growth (sys.master_files, database_id = 2).
-- Read-only: a SELECT over a catalog view.
-- sizeMb is the size configured for the instance start, not the current size on disk.
-- maxSizeMb NULL means unlimited. growth is in MB, or in % when isPercentGrowth = 1.
SELECT TOP (64)
    CAST(mf.name AS NVARCHAR(128)) AS logicalName,
    CAST(mf.type_desc AS NVARCHAR(60)) AS fileType,
    CAST(mf.physical_name AS NVARCHAR(260)) AS physicalName,
    CAST(CAST(mf.size AS BIGINT) * 8 / 1024.0 AS DECIMAL(18,2)) AS sizeMb,
    CAST(CASE WHEN mf.max_size = -1 THEN NULL
              ELSE CAST(mf.max_size AS BIGINT) * 8 / 1024.0 END AS DECIMAL(18,2)) AS maxSizeMb,
    CAST(CASE WHEN mf.is_percent_growth = 1 THEN mf.growth
              ELSE CAST(mf.growth AS BIGINT) * 8 / 1024.0 END AS DECIMAL(18,2)) AS growth,
    mf.is_percent_growth AS isPercentGrowth
FROM sys.master_files AS mf
WHERE mf.database_id = 2
ORDER BY mf.type, mf.file_id
