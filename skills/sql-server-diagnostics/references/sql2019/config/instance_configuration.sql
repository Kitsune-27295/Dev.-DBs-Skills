-- Target: SQL Server 2019 (15.x). Same query as the sql2022 pack: every object it reads exists on 2019.
-- Target permissions: on 2019 the DMVs and DMFs it reads need VIEW SERVER STATE (2022 split this into narrower ones).
-- Instance configuration options (what sp_configure shows), read from sys.configurations.
-- Read-only: a SELECT over the catalog view; nothing is reconfigured.
SELECT TOP (60)
    CAST(c.name AS NVARCHAR(128)) AS name,
    CAST(c.value AS BIGINT) AS configuredValue,
    CAST(c.value_in_use AS BIGINT) AS runningValue,
    c.is_dynamic AS isDynamic,
    c.is_advanced AS isAdvanced
FROM sys.configurations AS c
WHERE c.name IN (
    N'max degree of parallelism', N'cost threshold for parallelism',
    N'max server memory (MB)', N'min server memory (MB)',
    N'optimize for ad hoc workloads', N'backup compression default',
    N'backup checksum default', N'remote admin connections', N'xp_cmdshell',
    N'clr enabled', N'clr strict security', N'Ole Automation Procedures',
    N'Ad Hoc Distributed Queries', N'Database Mail XPs', N'cross db ownership chaining',
    N'remote access', N'priority boost', N'lightweight pooling', N'affinity mask',
    N'affinity I/O mask', N'max worker threads', N'fill factor (%)',
    N'default trace enabled', N'contained database authentication',
    N'scan for startup procs', N'external scripts enabled', N'blocked process threshold (s)',
    N'recovery interval (min)', N'network packet size (B)', N'min memory per query (KB)',
    N'index create memory (KB)', N'query wait (s)', N'remote query timeout (s)',
    N'user connections', N'show advanced options', N'allow updates',
    N'common criteria compliance enabled', N'c2 audit mode', N'filestream access level',
    N'max text repl size (B)', N'access check cache bucket count',
    N'access check cache quota', N'locks'
)
ORDER BY c.name
