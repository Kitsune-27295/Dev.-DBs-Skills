-- Instance services (engine, Agent, Full-Text), accounts and Instant File Initialization.
-- Source: sys.dm_server_services. Read-only: a SELECT over the DMV; nothing is changed.
-- instant_file_initialization_enabled exists from 2016 SP1 onwards.
SELECT TOP (10)
    CAST(s.servicename AS NVARCHAR(256)) AS serviceName,
    CAST(s.service_account AS NVARCHAR(256)) AS serviceAccount,
    CAST(s.startup_type_desc AS NVARCHAR(60)) AS startupType,
    CAST(s.status_desc AS NVARCHAR(60)) AS status,
    CAST(CASE WHEN s.instant_file_initialization_enabled = N'Y' THEN 1 ELSE 0 END AS BIT) AS instantFileInitialization,
    CAST(CASE WHEN s.is_clustered = N'Y' THEN 1 ELSE 0 END AS BIT) AS isClustered
FROM sys.dm_server_services AS s
ORDER BY s.servicename
