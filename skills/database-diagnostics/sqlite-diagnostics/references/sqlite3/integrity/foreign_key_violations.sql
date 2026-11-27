-- Rows that break a declared foreign key (PRAGMA foreign_key_check). Read-only: a SELECT.
-- SQLite stores foreign keys but enforces them only while PRAGMA foreign_keys = ON for the connection, so a file written by
-- a connection that left it OFF can hold orphans. Heavy on big tables without an index on the referencing column.
SELECT
    f."table" AS childTable,
    f.rowid AS childRowId,
    f.parent AS parentTable,
    f.fkid AS foreignKeyId
FROM pragma_foreign_key_check AS f
ORDER BY f."table", f.rowid
LIMIT 200
