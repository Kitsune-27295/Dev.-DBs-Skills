-- Statistics that the query planner reads after ANALYZE (sqlite_stat1). Read-only: a SELECT.
-- sqlite_stat1 exists only after ANALYZE or PRAGMA optimize ran: if this fails with "no such table", the planner has no
-- statistics. The first number of stat is the row count of the table or index; later numbers are rows per distinct prefix.
SELECT
    s.tbl AS tableName,
    s.idx AS indexName,
    s.stat AS statistics
FROM sqlite_stat1 AS s
ORDER BY s.tbl, s.idx
LIMIT 200
