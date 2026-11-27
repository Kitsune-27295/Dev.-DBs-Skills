-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- Operating system and SQL Server memory, with Buffer Manager and Memory Manager counters.
-- Source: sys.dm_os_sys_memory, sys.dm_os_process_memory and
-- sys.dm_os_performance_counters. Read-only: a SELECT over DMVs.
-- lazyWritesPerSec is the average since the instance started: the counter is cumulative and a
-- single reading does not allow measuring the current rate.
WITH pc AS (
    SELECT
        MAX(CASE WHEN p.object_name LIKE N'%Memory Manager%'
                  AND RTRIM(p.counter_name) = N'Target Server Memory (KB)' THEN p.cntr_value END) AS targetKb,
        MAX(CASE WHEN p.object_name LIKE N'%Memory Manager%'
                  AND RTRIM(p.counter_name) = N'Total Server Memory (KB)' THEN p.cntr_value END) AS totalKb,
        MAX(CASE WHEN p.object_name LIKE N'%Memory Manager%'
                  AND RTRIM(p.counter_name) = N'Memory Grants Pending' THEN p.cntr_value END) AS grantsPending,
        MAX(CASE WHEN p.object_name LIKE N'%Buffer Manager%'
                  AND RTRIM(p.counter_name) = N'Page life expectancy' THEN p.cntr_value END) AS ple,
        MAX(CASE WHEN p.object_name LIKE N'%Buffer Manager%'
                  AND RTRIM(p.counter_name) = N'Buffer cache hit ratio' THEN p.cntr_value END) AS hitRatio,
        MAX(CASE WHEN p.object_name LIKE N'%Buffer Manager%'
                  AND RTRIM(p.counter_name) = N'Buffer cache hit ratio base' THEN p.cntr_value END) AS hitRatioBase,
        MAX(CASE WHEN p.object_name LIKE N'%Buffer Manager%'
                  AND RTRIM(p.counter_name) = N'Lazy writes/sec' THEN p.cntr_value END) AS lazyWrites
    FROM sys.dm_os_performance_counters AS p
    WHERE p.object_name LIKE N'%Memory Manager%' OR p.object_name LIKE N'%Buffer Manager%'
)
SELECT TOP (1)
    CAST(sm.total_physical_memory_kb / 1024.0 AS DECIMAL(18,2)) AS totalPhysicalMemoryMb,
    CAST(sm.available_physical_memory_kb / 1024.0 AS DECIMAL(18,2)) AS availablePhysicalMemoryMb,
    CAST(sm.system_memory_state_desc AS NVARCHAR(256)) AS systemMemoryState,
    CAST(pm.physical_memory_in_use_kb / 1024.0 AS DECIMAL(18,2)) AS sqlPhysicalMemoryInUseMb,
    CAST(pc.targetKb / 1024.0 AS DECIMAL(18,2)) AS targetServerMemoryMb,
    CAST(pc.totalKb / 1024.0 AS DECIMAL(18,2)) AS totalServerMemoryMb,
    pc.ple AS pageLifeExpectancy,
    CAST(100.0 * pc.hitRatio / NULLIF(pc.hitRatioBase, 0) AS DECIMAL(18,2)) AS bufferCacheHitRatio,
    CAST(pc.lazyWrites * 1.0
         / NULLIF(DATEDIFF(SECOND, si.sqlserver_start_time, SYSDATETIME()), 0) AS DECIMAL(18,2)) AS lazyWritesPerSec,
    pc.grantsPending AS memoryGrantsPending
FROM sys.dm_os_sys_memory AS sm
CROSS JOIN sys.dm_os_process_memory AS pm
CROSS JOIN sys.dm_os_sys_info AS si
CROSS JOIN pc
ORDER BY totalPhysicalMemoryMb
