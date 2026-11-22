-- Target: PostgreSQL 17. Tested on 17.12.
-- WAL archiving: last archived and last failed segment (pg_stat_archiver). Read-only: a SELECT over a statistics view.
-- A failed_count that grows, or a last_failed_time later than last_archived_time, means archiving is broken and WAL piles
-- up on disk. Empty counters with archive_mode = off are normal (see config/instance_configuration.sql).
SELECT
    a.archived_count AS archivedCount,
    a.last_archived_wal AS lastArchivedWal,
    a.last_archived_time AS lastArchivedTime,
    a.failed_count AS failedCount,
    a.last_failed_wal AS lastFailedWal,
    a.last_failed_time AS lastFailedTime,
    (a.last_failed_time IS NOT NULL
     AND (a.last_archived_time IS NULL OR a.last_failed_time > a.last_archived_time)) AS isFailingNow,
    a.stats_reset AS statsReset
FROM pg_stat_archiver AS a
