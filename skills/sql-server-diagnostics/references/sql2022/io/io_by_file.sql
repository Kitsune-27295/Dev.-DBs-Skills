-- I/O and latency per data and log file (sys.dm_io_virtual_file_stats with
-- sys.master_files). Read-only: a SELECT over a DMF and a catalog view.
SELECT TOP (200)
    CAST(DB_NAME(vfs.database_id) AS NVARCHAR(128)) AS databaseName,
    CAST(mf.name AS NVARCHAR(128)) AS logicalName,
    CAST(mf.physical_name AS NVARCHAR(260)) AS physicalName,
    CAST(mf.type_desc AS NVARCHAR(60)) AS fileType,
    CAST(vfs.size_on_disk_bytes / 1048576.0 AS DECIMAL(18,2)) AS sizeMb,
    CAST(vfs.io_stall_read_ms * 1.0 / NULLIF(vfs.num_of_reads, 0) AS DECIMAL(18,2)) AS avgReadLatencyMs,
    CAST(vfs.io_stall_write_ms * 1.0 / NULLIF(vfs.num_of_writes, 0) AS DECIMAL(18,2)) AS avgWriteLatencyMs,
    CAST(vfs.num_of_bytes_read / 1073741824.0 AS DECIMAL(18,2)) AS readGb,
    CAST(vfs.num_of_bytes_written / 1073741824.0 AS DECIMAL(18,2)) AS writeGb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
JOIN sys.master_files AS mf
  ON mf.database_id = vfs.database_id
 AND mf.file_id = vfs.file_id
ORDER BY vfs.io_stall_read_ms + vfs.io_stall_write_ms DESC, vfs.database_id, vfs.file_id
