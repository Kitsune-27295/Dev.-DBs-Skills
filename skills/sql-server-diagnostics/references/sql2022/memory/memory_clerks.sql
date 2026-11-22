-- The biggest memory consumers, summed by clerk type (sys.dm_os_memory_clerks).
-- Read-only: a SELECT over the DMV; nothing is changed.
SELECT TOP (20)
    CAST(mc.type AS NVARCHAR(60)) AS clerkType,
    CAST(SUM(mc.pages_kb) / 1024.0 AS DECIMAL(18,2)) AS memoryMb
FROM sys.dm_os_memory_clerks AS mc
GROUP BY mc.type
ORDER BY SUM(mc.pages_kb) DESC, mc.type
