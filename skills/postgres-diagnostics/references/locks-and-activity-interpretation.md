# Locks and Activity Interpretation

Sources: https://www.postgresql.org/docs/18/view-pg-locks.html, https://www.postgresql.org/docs/18/monitoring-stats.html, https://www.postgresql.org/docs/18/view-pg-replication-slots.html · Last verified 2026-11-24

Covers `locks/blocking`, `connections/connections_by_state`, `connections/long_running`, `deadlocks/deadlock_counters`, `replication/replication_status`, `replication/replication_slots`, `backup/archiver_status`.

## Sessions

`pg_stat_activity.state` is `active`, `idle`, `idle in transaction` or `idle in transaction (aborted)` (also `starting`, `fastpath function call`, `disabled`). State and wait event are independent: an active backend may or may not be waiting. `xact_start` is when the transaction began; `state_change` is when the state last moved, so `now() - state_change` is how long a session has idled. `backend_xmin` is the horizon that holds back vacuum.

`wait_event_type` values: `Lock` (heavyweight lock), `LWLock`, `IO`, `IPC`, `Client`, `Activity`, `BufferPin`, `Timeout`, `Extension`. The blocking script filters on `Lock`.

## Locks

`pg_locks` has one row per lockable object, mode and process, for the whole cluster. `granted = false` means a wait behind a conflicting holder or queued waiter; a process waits for one lock at a time. Row-level locks are not stored there: a row-lock waiter normally shows as waiting on the holder's `transactionid`. The docs recommend `pg_blocking_pids()` over a self-join of `pg_locks`, because the function knows conflict rules, queue order and parallel workers. The view merges lock managers that are not frozen together, so a snapshot can be slightly inconsistent, and frequent polling adds load.

Example (own illustration): `waitingFor` 12 minutes, `blockingState` `idle in transaction`, `blockingTransactionAge` 3 hours. The blocker is running nothing; the cause is client transaction handling, and the proposal for the owner is to fix the client or, as a last resort, `pg_terminate_backend`, never run by this skill.

## Replication and slots

The lag columns in `pg_stat_replication` (`write_lag`, `flush_lag`, `replay_lag`) measure time from a local WAL flush until the standby reports write, flush or replay. They revert to NULL after a short idle period, so NULL on a quiet link does not mean broken. `pg_stat_replication` lists only directly connected standbys. The script's byte lag compares the current LSN with `replay_lsn`.

A slot's `restart_lsn` pins WAL on the primary. With `max_slot_wal_keep_size = -1` retention is unbounded, a stalled slot can fill the disk, and `safe_wal_size` is NULL. `wal_status` runs `reserved`, `extended`, `unreserved`, `lost`. From 17, `invalidation_reason` (`wal_removed`, `rows_removed`, `wal_level_insufficient`; 18 adds `idle_timeout`) explains an invalid slot and `inactive_since` shows how long it idled. For archiving, `pg_stat_archiver` has `failed_count` and `last_failed_time`.

## How an agent should apply this

- Report blockers with their `state` and transaction age; an idle-in-transaction blocker is a client finding.
- Say "no blocking at the time of the run", not "no blocking": locks are momentary.
- For an inactive slot, state the retained WAL and the disk it threatens; dropping the slot is the owner's decision.
- On a standby `replication_status` returns no rows by design; say so.
- Run lock checks once unless the owner approves repetition.
