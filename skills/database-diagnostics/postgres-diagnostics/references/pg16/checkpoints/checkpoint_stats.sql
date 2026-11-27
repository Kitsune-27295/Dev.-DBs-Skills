-- Target: PostgreSQL 16. Tested on 16.16.
-- Checkpoints and background writer activity since the statistics reset (pg_stat_bgwriter, PostgreSQL 16).
-- Read-only: a SELECT over a statistics view. Many requested checkpoints (checkpointsRequested) mean max_wal_size is too
-- small for the write load. From PostgreSQL 17 the checkpoint columns moved to pg_stat_checkpointer.
SELECT
    b.checkpoints_timed AS checkpointsTimed,
    b.checkpoints_req AS checkpointsRequested,
    round(100.0 * b.checkpoints_req / NULLIF(b.checkpoints_timed + b.checkpoints_req, 0), 2) AS requestedPct,
    round(b.checkpoint_write_time::numeric / 1000.0, 2) AS checkpointWriteSeconds,
    round(b.checkpoint_sync_time::numeric / 1000.0, 2) AS checkpointSyncSeconds,
    b.buffers_checkpoint AS buffersWrittenByCheckpoints,
    b.buffers_clean AS buffersWrittenByBgwriter,
    b.maxwritten_clean AS bgwriterStopsMaxWritten,
    b.buffers_backend AS buffersWrittenByBackends,
    b.buffers_alloc AS buffersAllocated,
    b.stats_reset AS statsReset
FROM pg_stat_bgwriter AS b
