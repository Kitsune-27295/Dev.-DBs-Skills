-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- 2025 note: the xml_deadlock_report event name was not re-verified against 2025 documentation; an empty result needs a check of sys.dm_xe_objects.
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
