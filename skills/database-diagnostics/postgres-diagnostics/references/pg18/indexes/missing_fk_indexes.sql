-- Target: PostgreSQL 18. Tested on 18.7.
-- Foreign keys whose referencing columns are not the leading columns of any valid, non-partial index (pg_constraint, pg_index).
-- Read-only: a SELECT over catalog views; no index is created. PostgreSQL does not index the referencing side
-- automatically, so deletes and updates on the parent table scan the child table.
SELECT
    c.conrelid::regclass::text AS tableName,
    c.conname AS constraintName,
    pg_get_constraintdef(c.oid) AS definition
FROM pg_constraint AS c
WHERE c.contype = 'f'
  AND NOT EXISTS (
      SELECT 1
      FROM pg_index AS i
      WHERE i.indrelid = c.conrelid
        AND i.indisvalid
        AND i.indpred IS NULL
        AND (string_to_array(i.indkey::text, ' ')::int2[])[1:cardinality(c.conkey)] @> c.conkey
  )
ORDER BY c.conrelid::regclass::text, c.conname
LIMIT 100
