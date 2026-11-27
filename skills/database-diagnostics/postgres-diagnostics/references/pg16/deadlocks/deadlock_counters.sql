-- Target: PostgreSQL 16. Tested on 16.16.
-- Deadlocks, conflicts and rolled-back transactions per database since the statistics reset (pg_stat_database).
-- Read-only: a SELECT over a statistics view. It counts events; the deadlock details are in the server log
-- (set log_lock_waits and deadlock_timeout, see config/instance_configuration.sql).
SELECT
    s.datname AS databaseName,
    s.deadlocks AS deadlocks,
    s.xact_rollback AS rollbacks,
    round(100.0 * s.xact_rollback / NULLIF(s.xact_commit + s.xact_rollback, 0), 2) AS rollbackPct,
    s.stats_reset AS statsReset
FROM pg_stat_database AS s
WHERE s.datname IS NOT NULL
ORDER BY s.deadlocks DESC, s.datname
LIMIT 50
