-- Target: PostgreSQL 18. Tested on 18.7.
-- WAL volume since the statistics reset and the current WAL position (pg_stat_wal, pg_current_wal_lsn).
-- Read-only: a SELECT over a statistics view and functions. walBuffersFull > 0 often means wal_buffers is too small.
-- PostgreSQL 18 moved the write and sync counters and times of WAL to pg_stat_io (object = 'wal'); see io/io_overview.sql.
SELECT
    w.wal_records AS walRecords,
    w.wal_fpi AS fullPageImages,
    round(w.wal_bytes / 1048576.0, 2) AS walMb,
    w.wal_buffers_full AS walBuffersFull,
    CASE WHEN pg_is_in_recovery() THEN pg_last_wal_replay_lsn() ELSE pg_current_wal_lsn() END AS currentLsn,
    w.stats_reset AS statsReset
FROM pg_stat_wal AS w
