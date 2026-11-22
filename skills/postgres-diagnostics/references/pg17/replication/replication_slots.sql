-- Target: PostgreSQL 17. Tested on 17.12.
-- Replication slots, whether each one is active and how much WAL it holds back (pg_replication_slots).
-- Read-only: a SELECT over a view; no slot is dropped. An inactive slot keeps WAL on disk until it is consumed or dropped.
SELECT
    s.slot_name AS slotName,
    s.slot_type AS slotType,
    s.database AS databaseName,
    s.active AS isActive,
    s.wal_status AS walStatus,
    round(s.safe_wal_size / 1048576.0, 2) AS safeWalMb,
    CASE WHEN pg_is_in_recovery() OR s.restart_lsn IS NULL THEN NULL
         ELSE round(pg_wal_lsn_diff(pg_current_wal_lsn(), s.restart_lsn) / 1048576.0, 2) END AS retainedWalMb,
    s.conflicting AS isConflicting,
    s.inactive_since AS inactiveSince,
    s.invalidation_reason AS invalidationReason
FROM pg_replication_slots AS s
ORDER BY s.slot_name
LIMIT 50
