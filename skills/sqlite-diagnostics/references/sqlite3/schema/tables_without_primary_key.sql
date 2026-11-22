-- Ordinary tables that have no primary key (PRAGMA table_list with table_info, SQLite 3.37+). Read-only: a SELECT.
-- Without a primary key the only stable row identity is the internal rowid, which VACUUM may renumber.
SELECT
    t.name AS tableName,
    t.ncol AS columns
FROM pragma_table_list AS t
WHERE t.schema = 'main'
  AND t.type = 'table'
  AND t.name NOT LIKE 'sqlite_%'
  AND NOT EXISTS (SELECT 1 FROM pragma_table_info(t.name) AS c WHERE c.pk > 0)
ORDER BY t.name
LIMIT 200
