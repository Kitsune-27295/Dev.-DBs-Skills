-- Target: SQL Server 2019 (15.x). Same query as the sql2022 pack: every object it reads exists on 2019.
-- Target permissions: on 2019 the DMVs and DMFs it reads need VIEW SERVER STATE (2022 split this into narrower ones).
-- The biggest memory consumers, summed by clerk type (sys.dm_os_memory_clerks).
-- Read-only: a SELECT over the DMV; nothing is changed.
SELECT TOP (20)
    CAST(mc.type AS NVARCHAR(60)) AS clerkType,
    CAST(SUM(mc.pages_kb) / 1024.0 AS DECIMAL(18,2)) AS memoryMb
FROM sys.dm_os_memory_clerks AS mc
GROUP BY mc.type
ORDER BY SUM(mc.pages_kb) DESC, mc.type
