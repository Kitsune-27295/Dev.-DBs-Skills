-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- 2025 note: linked servers on OLE DB 19 default to Encrypt=Mandatory; a linked server that worked on 2022 can fail after the upgrade.
-- Columns are unchanged; review dataSource and the provider string of each row before upgrading.
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
