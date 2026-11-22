-- Target: PostgreSQL 17. Tested on 17.12.
-- Prepared (two-phase) transactions that are still open (pg_prepared_xacts). Read-only: a SELECT over a view.
-- A forgotten prepared transaction keeps its locks and stops vacuum from removing rows: commit or roll it back.
SELECT
    p.gid AS globalId,
    p.database AS databaseName,
    p.owner AS owner,
    p.prepared AS preparedAt,
    now() - p.prepared AS openFor
FROM pg_prepared_xacts AS p
ORDER BY p.prepared, p.gid
LIMIT 50
