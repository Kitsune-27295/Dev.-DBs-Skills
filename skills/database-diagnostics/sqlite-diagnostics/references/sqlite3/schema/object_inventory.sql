-- Count of schema objects by type, and whether the database uses AUTOINCREMENT or virtual tables (sqlite_schema).
-- Read-only: a SELECT. sqlite_schema is the name since 3.33; older versions call it sqlite_master (same columns).
SELECT
    s.type AS objectType,
    count(*) AS objects,
    sum(CASE WHEN substr(s.name, 1, 7) = 'sqlite_' THEN 1 ELSE 0 END) AS internalObjects
FROM sqlite_schema AS s
GROUP BY s.type
ORDER BY s.type
