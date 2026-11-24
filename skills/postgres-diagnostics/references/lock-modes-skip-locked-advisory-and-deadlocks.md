# Lock modes, SKIP LOCKED, advisory locks and deadlocks

Sources: https://www.postgresql.org/docs/current/explicit-locking.html · https://www.postgresql.org/docs/current/sql-select.html (locking clause) · Last verified 2026-11-24

Reading blocked sessions is in `locks-and-activity-interpretation.md`; proving a race fix is in `race-condition-fix`. This file explains the mechanics those two rely on.

## Row-level locks

Four modes, strongest first: `FOR UPDATE`, `FOR NO KEY UPDATE`, `FOR SHARE`, `FOR KEY SHARE`. They block only writers and other lockers of the same row, never plain reads, and last until the transaction ends. An `UPDATE` that does not touch key columns takes the second mode, so it does not block foreign-key checks, which take the weakest. `DELETE` takes the strongest. Locking a row can write to disk (the row is marked), so locks are not free on huge row sets.

## Table-level locks and DDL

`ACCESS EXCLUSIVE` conflicts with everything including plain reads. It is taken by `DROP TABLE`, `TRUNCATE`, `REINDEX`, `CLUSTER`, `VACUUM FULL`, many `ALTER TABLE` forms and a bare `LOCK TABLE`. `CREATE INDEX` without `CONCURRENTLY` takes `SHARE` and blocks writes; `CREATE INDEX CONCURRENTLY`, plain `VACUUM` and `ANALYZE` take `SHARE UPDATE EXCLUSIVE`. Inference worth knowing: the lock manager queues waiters, so a queued `ACCESS EXCLUSIVE` request makes later plain queries wait behind it. Run risky DDL with a short `lock_timeout` (`connection-limits-and-pooling.md`).

## NOWAIT and SKIP LOCKED

`NOWAIT` raises an error instead of waiting. `SKIP LOCKED` silently skips rows another transaction holds. The documentation warns this gives an inconsistent view and is unsuitable for general work, but fits several consumers claiming rows of a queue-like table.

```sql
BEGIN;
SELECT id, payload FROM jobs
WHERE status = 'pending'
ORDER BY id LIMIT 1
FOR UPDATE SKIP LOCKED;
-- process, set status = 'done'
COMMIT;
```

Cautions from the page: the clause cannot be combined with `GROUP BY`, `DISTINCT`, aggregates or `UNION`; with `LIMIT` the locking stops once enough rows are returned; `ORDER BY` with locking under READ COMMITTED can return rows out of order if the sort column changes while waiting. Keep the claiming transaction short, and see `background-worker-job-scheduler` for queue design.

## Advisory locks

Application-defined; the server does not enforce their meaning. Session-level locks (`pg_advisory_lock`) outlive transactions, are reentrant and must be unlocked as many times as taken. Transaction-level locks (`pg_advisory_xact_lock`) release at commit or rollback and are the safer default. They share the lock table with ordinary locks, whose size comes from `max_locks_per_transaction` and `max_connections`. With `LIMIT`, the locking function may run before the limit applies, so wrap the limit in a subquery. Under a transaction-mode pooler session-level locks are not supported (`connection-limits-and-pooling.md`).

## Deadlocks

The server detects a deadlock and aborts one transaction; which one is not predictable. Prevention in the documentation: take locks on several objects in a consistent order, take the most restrictive mode you will need first, and retry a transaction aborted by a deadlock. A waiter otherwise waits indefinitely, so never hold a transaction open across user input.

## How an agent should apply this

- Name the lock mode of each blocking statement before proposing a fix; DDL needs `ACCESS EXCLUSIVE` thinking.
- Recommend `SKIP LOCKED` only for queue claims, with a short transaction and a status column.
- Prefer transaction-level advisory locks; flag session-level ones behind a pooler.
- For deadlocks, find the two code paths and make them touch rows in one order; add a retry.
- Hand any lock-changing statement to the owner; this skill stays read-only.
