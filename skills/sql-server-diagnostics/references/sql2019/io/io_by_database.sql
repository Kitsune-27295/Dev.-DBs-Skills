-- Target: SQL Server 2019 (15.x). Same query as the sql2022 pack: every object it reads exists on 2019.
-- Target permissions: on 2019 the DMVs and DMFs it reads need VIEW SERVER STATE (2022 split this into narrower ones).
-- Accumulated I/O per database since the last restart (sys.dm_io_virtual_file_stats).
-- Read-only: a SELECT over the DMF; nothing is changed.
-- pctOfTotalIo is the share of bytes read and written by the database over the instance total.
WITH db AS (
    SELECT
        vfs.database_id,
        SUM(vfs.num_of_reads) AS numReads,
        SUM(vfs.num_of_writes) AS numWrites,
        SUM(vfs.num_of_bytes_read) AS bytesRead,
        SUM(vfs.num_of_bytes_written) AS bytesWritten,
        SUM(vfs.io_stall_read_ms) AS stallReadMs,
        SUM(vfs.io_stall_write_ms) AS stallWriteMs
    FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
    WHERE vfs.database_id <> 32767
    GROUP BY vfs.database_id
)
SELECT TOP (100)
    CAST(DB_NAME(db.database_id) AS NVARCHAR(128)) AS databaseName,
    db.numReads,
    db.numWrites,
    CAST(db.bytesRead / 1073741824.0 AS DECIMAL(18,2)) AS readGb,
    CAST(db.bytesWritten / 1073741824.0 AS DECIMAL(18,2)) AS writeGb,
    db.stallReadMs AS ioStallReadMs,
    db.stallWriteMs AS ioStallWriteMs,
    CAST(db.stallReadMs * 1.0 / NULLIF(db.numReads, 0) AS DECIMAL(18,2)) AS avgReadLatencyMs,
    CAST(db.stallWriteMs * 1.0 / NULLIF(db.numWrites, 0) AS DECIMAL(18,2)) AS avgWriteLatencyMs,
    CAST(100.0 * (db.bytesRead + db.bytesWritten)
         / NULLIF(SUM(db.bytesRead + db.bytesWritten) OVER (), 0) AS DECIMAL(18,2)) AS pctOfTotalIo
FROM db
ORDER BY db.bytesRead + db.bytesWritten DESC, db.database_id
