-- Members of the sysadmin role (sys.server_role_members with sys.server_principals).
-- Read-only: a SELECT over catalog views; no permission is changed.
SELECT TOP (50)
    CAST(m.name AS NVARCHAR(128)) AS loginName,
    CAST(m.type_desc AS NVARCHAR(60)) AS loginType,
    m.is_disabled AS isDisabled,
    CAST(m.create_date AS DATETIME2) AS createDate
FROM sys.server_role_members AS rm
JOIN sys.server_principals AS r
  ON r.principal_id = rm.role_principal_id
JOIN sys.server_principals AS m
  ON m.principal_id = rm.member_principal_id
WHERE r.name = N'sysadmin'
ORDER BY m.name
