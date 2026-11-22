-- Target: PostgreSQL 16. Tested on 16.16.
-- Queries running for more than a minute and sessions idle in a transaction for more than a minute (pg_stat_activity).
-- Read-only: a SELECT over a view; no session is cancelled. The query text can hold literal values: keep the output private.
SELECT
    a.pid AS pid,
    a.datname AS databaseName,
    a.usename AS userName,
    a.application_name AS applicationName,
    a.client_addr::text AS clientAddress,
    a.state AS state,
    a.wait_event_type AS waitEventType,
    a.wait_event AS waitEvent,
    now() - a.xact_start AS transactionAge,
    now() - a.query_start AS queryAge,
    left(a.query, 2000) AS queryText
FROM pg_stat_activity AS a
WHERE a.backend_type = 'client backend'
  AND a.pid <> pg_backend_pid()
  AND ((a.state = 'active' AND now() - a.query_start > interval '1 minute')
    OR (a.state LIKE 'idle in transaction%' AND now() - a.state_change > interval '1 minute'))
ORDER BY a.xact_start NULLS LAST, a.pid
LIMIT 50
