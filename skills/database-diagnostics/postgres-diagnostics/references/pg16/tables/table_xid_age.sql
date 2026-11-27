-- Target: PostgreSQL 16. Tested on 16.16.
-- Tables whose oldest unfrozen transaction ID is oldest (pg_class.relfrozenxid), current database.
-- Read-only: a SELECT over a catalog view. A value close to autovacuum_freeze_max_age means a forced freeze is near.
SELECT
    n.nspname || '.' || c.relname AS tableName,
    c.relkind AS relationKind,
    age(c.relfrozenxid) AS xidAge,
    round(100.0 * age(c.relfrozenxid) / 2147483647, 2) AS xidAgePctOfWraparound
FROM pg_class AS c
JOIN pg_namespace AS n
  ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm', 't')
  AND c.relfrozenxid <> 0
ORDER BY age(c.relfrozenxid) DESC, n.nspname, c.relname
LIMIT 30
