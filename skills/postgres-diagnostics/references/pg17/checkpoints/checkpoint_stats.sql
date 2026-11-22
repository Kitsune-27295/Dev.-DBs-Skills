-- Target: PostgreSQL 17. Tested on 17.12.
-- Checkpoints and background writer activity since the statistics reset (pg_stat_checkpointer and pg_stat_bgwriter,
-- PostgreSQL 17). Read-only: a SELECT over statistics views. Many requested checkpoints (checkpointsRequested) mean
-- max_wal_size is too small for the write load.
SELECT
    c.num_timed AS checkpointsTimed,
    c.num_requested AS checkpointsRequested,
    round(100.0 * c.num_requested / NULLIF(c.num_timed + c.num_requested, 0), 2) AS requestedPct,
    round(c.write_time::numeric / 1000.0, 2) AS checkpointWriteSeconds,
    round(c.sync_time::numeric / 1000.0, 2) AS checkpointSyncSeconds,
    c.buffers_written AS buffersWrittenByCheckpoints,
    b.buffers_clean AS buffersWrittenByBgwriter,
    b.maxwritten_clean AS bgwriterStopsMaxWritten,
    b.buffers_alloc AS buffersAllocated,
    c.stats_reset AS statsReset
FROM pg_stat_checkpointer AS c
CROSS JOIN pg_stat_bgwriter AS b
