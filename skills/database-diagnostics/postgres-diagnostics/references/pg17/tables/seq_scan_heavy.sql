-- Target: PostgreSQL 17. Tested on 17.12.
-- Tables read mostly by sequential scan although they are not small (pg_stat_user_tables), current database.
-- Read-only: a SELECT over a statistics view. A sequential scan is normal on a small table or a full read; check the
-- query before adding an index (see the query-performance skill).
SELECT
    t.schemaname || '.' || t.relname AS tableName,
    t.n_live_tup AS liveRows,
    t.seq_scan AS seqScans,
    t.seq_tup_read AS seqRowsRead,
    COALESCE(t.idx_scan, 0) AS indexScans,
    round(100.0 * t.seq_scan / NULLIF(t.seq_scan + COALESCE(t.idx_scan, 0), 0), 2) AS seqScanPct
FROM pg_stat_user_tables AS t
WHERE t.n_live_tup >= 10000
  AND t.seq_scan > 0
ORDER BY t.seq_tup_read DESC, t.schemaname, t.relname
LIMIT 30
