-- Target: PostgreSQL 18. Tested on 18.7.
-- Statements with the highest mean execution time (at least 5 calls) (pg_stat_statements), all databases.
-- Read-only: a SELECT over a view of the pg_stat_statements extension; it must be in shared_preload_libraries and created
-- in this database (see config/extensions.sql), otherwise this script fails with "relation does not exist".
-- Counters accumulate since the last reset (pg_stat_statements_info.stats_reset). Query text can hold literal values.
SELECT
    s.queryid AS queryId,
    COALESCE(d.datname, s.dbid::text) AS databaseName,
    s.calls AS calls,
    round(s.total_exec_time::numeric, 2) AS totalExecMs,
    round(s.mean_exec_time::numeric, 2) AS meanExecMs,
    round(s.max_exec_time::numeric, 2) AS maxExecMs,
    s.rows AS rows,
    s.shared_blks_hit AS sharedBlocksHit,
    s.shared_blks_read AS sharedBlocksRead,
    left(s.query, 2000) AS queryText
FROM pg_stat_statements AS s
LEFT JOIN pg_database AS d
  ON d.oid = s.dbid
WHERE s.query NOT ILIKE '%pg_stat_statements%'
  AND s.calls >= 5
ORDER BY s.mean_exec_time DESC, s.queryid
LIMIT 20
