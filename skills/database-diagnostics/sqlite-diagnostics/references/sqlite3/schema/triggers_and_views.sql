-- Triggers and views with the table they belong to (sqlite_schema). Read-only: a SELECT. The definition is cut at 500
-- characters. Triggers run on every write: read them before explaining a slow insert or an unexpected change.
SELECT
    s.type AS objectType,
    s.name AS objectName,
    s.tbl_name AS tableName,
    substr(s.sql, 1, 500) AS definition
FROM sqlite_schema AS s
WHERE s.type IN ('trigger', 'view')
ORDER BY s.type, s.tbl_name, s.name
LIMIT 200
