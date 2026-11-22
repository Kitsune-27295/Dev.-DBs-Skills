-- Target: PostgreSQL 18. Tested on 18.7.
-- The 30 biggest tables of the current database: table, index and total size (pg_class).
-- Read-only: a SELECT over catalog views and size functions. estimatedRows is the planner's estimate, not a count.
SELECT
    n.nspname || '.' || c.relname AS tableName,
    c.reltuples::bigint AS estimatedRows,
    round(pg_table_size(c.oid) / 1048576.0, 2) AS tableMb,
    round(pg_indexes_size(c.oid) / 1048576.0, 2) AS indexMb,
    round(pg_total_relation_size(c.oid) / 1048576.0, 2) AS totalMb
FROM pg_class AS c
JOIN pg_namespace AS n
  ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
ORDER BY pg_total_relation_size(c.oid) DESC, n.nspname, c.relname
LIMIT 30
