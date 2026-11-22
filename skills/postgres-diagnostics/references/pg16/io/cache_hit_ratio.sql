-- Target: PostgreSQL 16. Tested on 16.16.
-- Heap and index cache hit ratio of the tables that read the most from disk (pg_statio_user_tables), current database.
-- Read-only: a SELECT over a statistics view. A hit means the block was in shared buffers; the operating system cache
-- may still have served a miss. Compare with the same table over time, not with a fixed target.
SELECT
    t.schemaname || '.' || t.relname AS tableName,
    t.heap_blks_read AS heapBlocksRead,
    t.heap_blks_hit AS heapBlocksHit,
    round(100.0 * t.heap_blks_hit / NULLIF(t.heap_blks_hit + t.heap_blks_read, 0), 2) AS heapHitPct,
    COALESCE(t.idx_blks_read, 0) AS indexBlocksRead,
    COALESCE(t.idx_blks_hit, 0) AS indexBlocksHit,
    round(100.0 * t.idx_blks_hit / NULLIF(t.idx_blks_hit + t.idx_blks_read, 0), 2) AS indexHitPct
FROM pg_statio_user_tables AS t
WHERE t.heap_blks_read + COALESCE(t.idx_blks_read, 0) > 0
ORDER BY t.heap_blks_read + COALESCE(t.idx_blks_read, 0) DESC, t.schemaname, t.relname
LIMIT 30
