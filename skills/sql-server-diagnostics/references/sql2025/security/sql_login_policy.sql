-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- SQL authentication logins and whether password policy and expiration are checked
-- (sys.sql_logins). Read-only: a SELECT over a catalog view; no hash is read.
SELECT TOP (200)
    CAST(l.name AS NVARCHAR(128)) AS loginName,
    l.is_disabled AS isDisabled,
    l.is_policy_checked AS isPolicyChecked,
    l.is_expiration_checked AS isExpirationChecked,
    CAST(l.create_date AS DATETIME2) AS createDate
FROM sys.sql_logins AS l
ORDER BY l.name
