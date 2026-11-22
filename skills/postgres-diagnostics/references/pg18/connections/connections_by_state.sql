-- Target: PostgreSQL 18. Tested on 18.7.
-- Client connections by database, user and state, against max_connections (pg_stat_activity).
-- Read-only: a SELECT over a view. Other users' rows are complete only for roles with pg_read_all_stats or superuser.
SELECT
    COALESCE(a.datname, '(none)') AS databaseName,
    COALESCE(a.usename, '(none)') AS userName,
    COALESCE(a.state, '(unknown)') AS state,
    count(*) AS connections,
    max(now() - a.state_change) AS longestInState,
    current_setting('max_connections')::int AS maxConnections
FROM pg_stat_activity AS a
WHERE a.backend_type = 'client backend'
GROUP BY a.datname, a.usename, a.state
ORDER BY count(*) DESC, a.datname, a.usename, a.state
LIMIT 100
