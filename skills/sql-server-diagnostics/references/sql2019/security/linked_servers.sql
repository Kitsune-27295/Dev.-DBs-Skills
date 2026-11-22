-- Target: SQL Server 2019 (15.x). Same query as the sql2022 pack: every object it reads exists on 2019.
-- Target permissions: on 2019 the DMVs and DMFs it reads need VIEW SERVER STATE (2022 split this into narrower ones).
-- Linked servers and how they authenticate (sys.servers with sys.linked_logins).
-- Read-only: a SELECT over catalog views; no remote connection is opened.
SELECT TOP (50)
    CAST(s.name AS NVARCHAR(128)) AS name,
    CAST(s.product AS NVARCHAR(128)) AS product,
    CAST(s.provider AS NVARCHAR(128)) AS provider,
    CAST(s.data_source AS NVARCHAR(4000)) AS dataSource,
    s.is_rpc_out_enabled AS isRpcOutEnabled,
    s.is_data_access_enabled AS isDataAccessEnabled,
    CAST(CASE WHEN EXISTS (
        SELECT 1 FROM sys.linked_logins AS ll
        WHERE ll.server_id = s.server_id AND ll.uses_self_credential = 1
    ) THEN 1 ELSE 0 END AS BIT) AS usesSelfCredential,
    CAST(CASE WHEN EXISTS (
        SELECT 1 FROM sys.linked_logins AS ll
        WHERE ll.server_id = s.server_id AND ll.remote_name IS NOT NULL
    ) THEN 1 ELSE 0 END AS BIT) AS hasRemoteLogin
FROM sys.servers AS s
WHERE s.is_linked = 1
ORDER BY s.name
