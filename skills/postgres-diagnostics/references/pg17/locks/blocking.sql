-- Target: PostgreSQL 17. Tested on 17.12.
-- Sessions waiting on a lock and the session that blocks each one (pg_stat_activity, pg_blocking_pids).
-- Read-only: a SELECT over a view and a function; nothing is cancelled. Query text can hold literal values.
-- pg_blocking_pids takes the lock manager's shared state briefly for each call, so only sessions that wait on a lock are asked.
SELECT
    w.pid AS waitingPid,
    w.usename AS waitingUser,
    left(w.query, 1000) AS waitingQuery,
    now() - w.query_start AS waitingFor,
    b.pid AS blockingPid,
    b.usename AS blockingUser,
    b.state AS blockingState,
    left(b.query, 1000) AS blockingQuery,
    now() - b.xact_start AS blockingTransactionAge
FROM pg_stat_activity AS w
CROSS JOIN LATERAL unnest(pg_blocking_pids(w.pid)) AS bp(pid)
JOIN pg_stat_activity AS b
  ON b.pid = bp.pid
WHERE w.wait_event_type = 'Lock'
ORDER BY waitingFor DESC, w.pid, b.pid
LIMIT 50
