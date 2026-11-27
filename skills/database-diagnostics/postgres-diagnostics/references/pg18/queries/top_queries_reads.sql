-- Target: PostgreSQL 18. Tested on 18.7.
-- Statements that read the most blocks from outside shared buffers or spill to temporary files (pg_stat_statements).
-- Read-only: a SELECT over a view of the pg_stat_statements extension (see queries/top_queries_time.sql for the setup).
-- ioReadMs needs track_io_timing = on, otherwise it is 0. Query text can hold literal values.
SELECT
    s.queryid AS queryId,
    COALESCE(d.datname, s.dbid::text) AS databaseName,
    s.calls AS calls,
    s.shared_blks_read AS sharedBlocksRead,
    round(s.shared_blks_read::numeric / NULLIF(s.calls, 0), 2) AS avgSharedBlocksRead,
    s.temp_blks_read + s.temp_blks_written AS tempBlocks,
    round(s.shared_blk_read_time::numeric, 2) AS ioReadMs,
    round(s.total_exec_time::numeric, 2) AS totalExecMs,
    left(s.query, 2000) AS queryText
FROM pg_stat_statements AS s
LEFT JOIN pg_database AS d
  ON d.oid = s.dbid
WHERE s.query NOT ILIKE '%pg_stat_statements%'
ORDER BY s.shared_blks_read + s.temp_blks_read + s.temp_blks_written DESC, s.queryid
LIMIT 20
