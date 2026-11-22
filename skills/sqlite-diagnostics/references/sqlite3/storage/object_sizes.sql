-- Size per table and index in pages and MB (the dbstat virtual table).
-- Read-only: a SELECT. dbstat exists only when SQLite was compiled with SQLITE_ENABLE_DBSTAT_VTAB (check
-- config/compile_options.sql); without it this script fails with "no such table: dbstat". Costly on a big file: it reads
-- every page.
SELECT
    s.name AS objectName,
    COALESCE(m.type, 'internal') AS objectType,
    COALESCE(m.tbl_name, s.name) AS tableName,
    count(*) AS pageCount,
    round(sum(s.pgsize) / 1048576.0, 2) AS sizeMb,
    round(sum(s.unused) / 1048576.0, 2) AS unusedMb,
    round(100.0 * sum(s.unused) / NULLIF(sum(s.pgsize), 0), 2) AS unusedPct
FROM dbstat AS s
LEFT JOIN sqlite_schema AS m
  ON m.name = s.name
WHERE s.aggregate = 0
GROUP BY s.name, m.type, m.tbl_name
ORDER BY sum(s.pgsize) DESC, s.name
LIMIT 50
