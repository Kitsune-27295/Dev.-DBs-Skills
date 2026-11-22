-- Target: PostgreSQL 17. Tested on 17.12.
-- Sequences closest to their maximum value (pg_sequences), current database. Read-only: a SELECT over a view.
-- A serial column on integer ends at 2147483647: the sequence can pass what the column holds, so check the column type too.
SELECT
    s.schemaname || '.' || s.sequencename AS sequenceName,
    s.data_type::text AS dataType,
    s.last_value AS lastValue,
    s.max_value AS maxValue,
    round(100.0 * s.last_value / NULLIF(s.max_value, 0), 4) AS usedPct
FROM pg_sequences AS s
WHERE s.last_value IS NOT NULL
ORDER BY s.last_value::numeric / NULLIF(s.max_value, 0) DESC, s.schemaname, s.sequencename
LIMIT 30
