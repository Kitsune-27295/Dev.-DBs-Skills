-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- Instance identity: SERVERPROPERTY, sys.dm_os_sys_info and sys.dm_os_nodes.
-- Read-only: a SELECT over properties and DMVs; nothing is changed or executed.
-- The platform comes from @@VERSION because sys.dm_os_host_info does not exist on SQL Server 2016.
-- socket_count and cores_per_socket exist from 2016 SP2 onwards.
SELECT TOP (1)
    CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(256)) AS serverName,
    CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)) AS productVersion,
    CAST(SERVERPROPERTY('ProductLevel') AS NVARCHAR(128)) AS productLevel,
    CAST(SERVERPROPERTY('ProductUpdateLevel') AS NVARCHAR(128)) AS updateLevel,
    CAST(SERVERPROPERTY('Edition') AS NVARCHAR(128)) AS edition,
    CAST(SERVERPROPERTY('EngineEdition') AS INT) AS engineEdition,
    CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) AS majorVersion,
    CAST(CASE WHEN @@VERSION LIKE N'%on Linux%' THEN N'Linux' ELSE N'Windows' END AS NVARCHAR(32)) AS hostPlatform,
    -- the part of @@VERSION between ' on ' and ' <', for example 'Windows Server 2019 Standard 10.0'
    CAST(LTRIM(RTRIM(SUBSTRING(v.txt, v.onPos + 4,
        CASE WHEN CHARINDEX(N' <', v.txt, v.onPos) > v.onPos
             THEN CHARINDEX(N' <', v.txt, v.onPos) - v.onPos - 4
             ELSE 256 END))) AS NVARCHAR(256)) AS hostDistribution,
    si.cpu_count AS cpuCount,
    si.scheduler_count AS schedulerCount,
    si.socket_count AS socketCount,
    si.cores_per_socket AS coresPerSocket,
    n.numaNodes,
    CAST(si.physical_memory_kb / 1024.0 AS DECIMAL(18,2)) AS physicalMemoryMb,
    CAST(si.committed_target_kb / 1024.0 AS DECIMAL(18,2)) AS committedTargetMb,
    CAST(si.sqlserver_start_time AS DATETIME2) AS sqlStartTime,
    DATEDIFF(MINUTE, si.sqlserver_start_time, SYSDATETIME()) AS uptimeMinutes,
    CAST(SERVERPROPERTY('Collation') AS NVARCHAR(128)) AS collation,
    CAST(ISNULL(SERVERPROPERTY('IsClustered'), 0) AS BIT) AS isClustered,
    CAST(ISNULL(SERVERPROPERTY('IsHadrEnabled'), 0) AS BIT) AS isHadrEnabled,
    CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(512)) AS defaultDataPath,
    CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS NVARCHAR(512)) AS defaultLogPath
FROM sys.dm_os_sys_info AS si
CROSS JOIN (
    SELECT CAST(@@VERSION AS NVARCHAR(4000)) AS txt,
           CHARINDEX(N' on ', CAST(@@VERSION AS NVARCHAR(4000))) AS onPos
) AS v
CROSS JOIN (
    -- the DAC node is not a real NUMA node
    SELECT COUNT(*) AS numaNodes
    FROM sys.dm_os_nodes
    WHERE node_state_desc <> N'ONLINE DAC'
) AS n
ORDER BY serverName
