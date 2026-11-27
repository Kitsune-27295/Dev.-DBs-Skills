-- Target: PostgreSQL 18. Tested on 18.7.
-- Indexes that are not valid or not ready, typically left behind by a failed CREATE INDEX CONCURRENTLY (pg_index).
-- Read-only: a SELECT over catalog views; nothing is dropped. The planner ignores an invalid index but every write still
-- maintains it: drop it and create it again.
SELECT
    i.indrelid::regclass::text AS tableName,
    i.indexrelid::regclass::text AS indexName,
    i.indisvalid AS isValid,
    i.indisready AS isReady,
    round(pg_relation_size(i.indexrelid) / 1048576.0, 2) AS indexMb
FROM pg_index AS i
WHERE NOT i.indisvalid OR NOT i.indisready
ORDER BY pg_relation_size(i.indexrelid) DESC, i.indexrelid
LIMIT 50
