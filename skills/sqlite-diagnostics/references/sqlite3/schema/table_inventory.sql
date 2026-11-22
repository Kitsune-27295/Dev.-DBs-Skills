-- Every table with its kind and the options that change its behavior: WITHOUT ROWID, STRICT, column count
-- (PRAGMA table_list, SQLite 3.37+). Read-only: a SELECT. STRICT enforces column types; a table that is not STRICT accepts
-- any value in any column.
SELECT
    t.schema AS schemaName,
    t.name AS tableName,
    t.type AS tableType,
    t.ncol AS columns,
    t.wr AS withoutRowid,
    t.strict AS isStrict
FROM pragma_table_list AS t
WHERE t.name NOT LIKE 'sqlite_%'
ORDER BY t.schema, t.name
LIMIT 500
