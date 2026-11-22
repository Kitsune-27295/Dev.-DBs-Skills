-- Target: SQL Server 2019 (15.x). Same query as the sql2022 pack: every object it reads exists on 2019.
-- Target permissions: on 2019 the DMVs and DMFs it reads need VIEW SERVER STATE (2022 split this into narrower ones).
-- Memory model and process pressure signals.
-- Source: sys.dm_os_sys_info and sys.dm_os_process_memory. Read-only: a SELECT over DMVs.
-- sql_memory_model_desc exists from 2016 SP1 onwards.
SELECT TOP (1)
    CAST(si.sql_memory_model_desc AS NVARCHAR(60)) AS sqlMemoryModel,
    CAST(pm.locked_page_allocations_kb / 1024.0 AS DECIMAL(18,2)) AS lockedPagesMb,
    CAST(pm.large_page_allocations_kb / 1024.0 AS DECIMAL(18,2)) AS largePageMb,
    CAST(pm.memory_utilization_percentage AS DECIMAL(18,2)) AS memoryUtilizationPct,
    pm.process_physical_memory_low AS processPhysicalMemoryLow,
    pm.process_virtual_memory_low AS processVirtualMemoryLow
FROM sys.dm_os_sys_info AS si
CROSS JOIN sys.dm_os_process_memory AS pm
ORDER BY sqlMemoryModel
