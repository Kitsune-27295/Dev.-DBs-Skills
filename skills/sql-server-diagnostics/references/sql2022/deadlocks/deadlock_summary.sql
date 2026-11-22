-- Deadlocks recorded by the system_health session in the last 7 days, read from the
-- .xel files with sys.fn_xe_file_target_read_file. Read-only: a SELECT over the function; the
-- event session is not changed. Costly: reads every system_health file in the log directory.
-- firstSeen and lastSeen are in UTC (the event's own timestamp).
-- The timestamp comes from the XML because the timestamp_utc column only exists from SQL Server 2017.
WITH dl AS (
    SELECT CAST(xf.event_data AS XML).value('(event/@timestamp)[1]', 'datetime2') AS eventTimeUtc
    FROM sys.fn_xe_file_target_read_file(N'system_health*.xel', NULL, NULL, NULL) AS xf
    WHERE xf.object_name = N'xml_deadlock_report'
)
SELECT TOP (1)
    COUNT(*) AS deadlocksLast7Days,
    MIN(dl.eventTimeUtc) AS firstSeen,
    MAX(dl.eventTimeUtc) AS lastSeen
FROM dl
WHERE dl.eventTimeUtc >= DATEADD(DAY, -7, SYSUTCDATETIME())
ORDER BY deadlocksLast7Days
