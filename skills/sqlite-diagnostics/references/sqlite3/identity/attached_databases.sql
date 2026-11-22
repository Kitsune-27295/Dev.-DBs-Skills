-- Databases attached to this connection and their files (PRAGMA database_list as a table-valued function, SQLite 3.16+).
-- Read-only: a SELECT. An empty file means an in-memory or temporary database.
SELECT
    d.seq AS sequence,
    d.name AS databaseName,
    d.file AS filePath
FROM pragma_database_list AS d
ORDER BY d.seq
