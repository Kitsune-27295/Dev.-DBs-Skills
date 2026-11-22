-- Target: PostgreSQL 17. Tested on 17.12.
-- WAL volume since the statistics reset and the current WAL position (pg_stat_wal, pg_current_wal_lsn).
-- Read-only: a SELECT over a statistics view and functions. walBuffersFull > 0 often means wal_buffers is too small.
SELECT
    w.wal_records AS walRecords,
    w.wal_fpi AS fullPageImages,
    round(w.wal_bytes / 1048576.0, 2) AS walMb,
    w.wal_buffers_full AS walBuffersFull,
    w.wal_write AS walWrites,
    w.wal_sync AS walSyncs,
    round(w.wal_write_time::numeric, 2) AS walWriteMs,
    round(w.wal_sync_time::numeric, 2) AS walSyncMs,
    CASE WHEN pg_is_in_recovery() THEN pg_last_wal_replay_lsn() ELSE pg_current_wal_lsn() END AS currentLsn,
    w.stats_reset AS statsReset
FROM pg_stat_wal AS w
