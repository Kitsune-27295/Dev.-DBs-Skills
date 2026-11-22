-- Target: PostgreSQL 16. Tested on 16.16.
-- Streaming replicas connected to this server and how far behind each one is (pg_stat_replication).
-- Read-only: a SELECT over a view; no row on a server with no replicas or on a standby.
-- Lag in bytes is measured from the current WAL position to what the replica replayed.
SELECT
    r.pid AS pid,
    r.usename AS userName,
    r.application_name AS applicationName,
    r.client_addr::text AS clientAddress,
    r.state AS state,
    r.sync_state AS syncState,
    CASE WHEN pg_is_in_recovery() THEN NULL
         ELSE pg_wal_lsn_diff(pg_current_wal_lsn(), r.replay_lsn) END AS replayLagBytes,
    r.write_lag AS writeLag,
    r.flush_lag AS flushLag,
    r.replay_lag AS replayLag
FROM pg_stat_replication AS r
ORDER BY r.application_name, r.pid
LIMIT 50
