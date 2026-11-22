-- Target: PostgreSQL 17. Tested on 17.12.
-- Cluster I/O by backend type, object and context since the statistics reset (pg_stat_io, PostgreSQL 16 and later).
-- Read-only: a SELECT over a statistics view. Times are zero unless track_io_timing = on.
-- Rows with no activity are left out.
SELECT
    io.backend_type AS backendType,
    io.object AS objectKind,
    io.context AS context,
    io.reads AS reads,
    round(COALESCE(io.reads, 0) * io.op_bytes / 1048576.0, 2) AS readMb,
    io.writes AS writes,
    round(COALESCE(io.writes, 0) * io.op_bytes / 1048576.0, 2) AS writeMb,
    io.hits AS hits,
    io.evictions AS evictions,
    round(io.read_time::numeric, 2) AS readMs,
    round(io.write_time::numeric, 2) AS writeMs
FROM pg_stat_io AS io
WHERE COALESCE(io.reads, 0) + COALESCE(io.writes, 0) > 0
ORDER BY COALESCE(io.read_time, 0) + COALESCE(io.write_time, 0) DESC, io.reads DESC NULLS LAST,
         io.backend_type, io.object, io.context
LIMIT 50
