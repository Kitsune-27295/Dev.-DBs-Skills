-- Target: PostgreSQL 18. Tested on 18.7.
-- Indexes on the same table with the same columns, operator classes, expression and predicate (pg_index), current database.
-- Read-only: a SELECT over catalog views; no index is dropped. Keep the one that backs a constraint.
SELECT
    d.tableName,
    d.indexNames,
    d.duplicates
FROM (
    SELECT
        i.indrelid::regclass::text AS tableName,
        array_agg(i.indexrelid::regclass::text ORDER BY i.indexrelid) AS indexNames,
        count(*) AS duplicates
    FROM pg_index AS i
    JOIN pg_class AS c
      ON c.oid = i.indrelid
    JOIN pg_namespace AS n
      ON n.oid = c.relnamespace
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema', 'pg_toast')
    GROUP BY i.indrelid, i.indkey::text, i.indclass::text, i.indcollation::text,
             COALESCE(i.indexprs::text, ''), COALESCE(i.indpred::text, '')
    HAVING count(*) > 1
) AS d
ORDER BY d.tableName, d.indexNames
LIMIT 50
