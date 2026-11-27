-- Target: PostgreSQL 18. Tested on 18.7.
-- Checkpoints and background writer activity since the statistics reset (pg_stat_checkpointer and pg_stat_bgwriter,
-- PostgreSQL 18). Read-only: a SELECT over statistics views. Many requested checkpoints (checkpointsRequested) mean
-- max_wal_size is too small for the write load. checkpointsDone counts checkpoints that finished (new in 18).
SELECT
    c.num_timed AS checkpointsTimed,
    c.num_requested AS checkpointsRequested,
    c.num_done AS checkpointsDone,
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
