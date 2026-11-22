-- Target: PostgreSQL 16. Tested on 16.16.
-- Indexes that were never scanned since the statistics reset, with their size (pg_stat_user_indexes), current database.
-- Read-only: a SELECT over a statistics view; no index is dropped. Unique and primary-key indexes are left out because they
-- enforce a rule. On a replica the counters are separate: check the primary and every replica that serves reads.
SELECT
    s.schemaname || '.' || s.relname AS tableName,
    s.indexrelname AS indexName,
    s.idx_scan AS scans,
    round(pg_relation_size(s.indexrelid) / 1048576.0, 2) AS indexMb
FROM pg_stat_user_indexes AS s
JOIN pg_index AS i
  ON i.indexrelid = s.indexrelid
WHERE s.idx_scan = 0
  AND NOT i.indisunique
  AND NOT i.indisprimary
ORDER BY pg_relation_size(s.indexrelid) DESC, s.schemaname, s.indexrelname
LIMIT 30
