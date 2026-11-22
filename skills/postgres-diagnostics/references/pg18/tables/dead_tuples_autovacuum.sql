-- Target: PostgreSQL 18. Tested on 18.7.
-- Tables with dead rows and when vacuum and analyze last ran on them (pg_stat_user_tables), current database.
-- Read-only: a SELECT over a statistics view; nothing is vacuumed. Counters reset with the statistics.
SELECT
    t.schemaname || '.' || t.relname AS tableName,
    t.n_live_tup AS liveRows,
    t.n_dead_tup AS deadRows,
    round(100.0 * t.n_dead_tup / NULLIF(t.n_live_tup + t.n_dead_tup, 0), 2) AS deadPct,
    t.n_mod_since_analyze AS modifiedSinceAnalyze,
    t.last_vacuum AS lastVacuum,
    t.last_autovacuum AS lastAutovacuum,
    t.last_analyze AS lastAnalyze,
    t.last_autoanalyze AS lastAutoanalyze,
    t.autovacuum_count AS autovacuumCount
FROM pg_stat_user_tables AS t
WHERE t.n_dead_tup > 0
ORDER BY t.n_dead_tup DESC, t.schemaname, t.relname
LIMIT 30
