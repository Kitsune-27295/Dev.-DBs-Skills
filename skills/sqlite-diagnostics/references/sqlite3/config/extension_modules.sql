-- Virtual-table modules available to this connection, for example fts5, rtree, json_each (PRAGMA module_list).
-- Read-only: a SELECT over a table-valued function (SQLite 3.16+).
SELECT
    m.name AS moduleName
FROM pragma_module_list AS m
ORDER BY m.name
