-- Target: PostgreSQL 17. Tested on 17.12.
-- Settings that matter for capacity, durability and safety, with where each value comes from (pg_settings).
-- Read-only: a SELECT over a view; nothing is reconfigured. pendingRestart = true means the new value waits for a restart.
SELECT
    s.name AS name,
    s.setting AS value,
    s.unit AS unit,
    s.source AS source,
    s.context AS context,
    s.pending_restart AS pendingRestart
FROM pg_settings AS s
WHERE s.name IN (
    'max_connections', 'superuser_reserved_connections', 'shared_buffers', 'work_mem', 'maintenance_work_mem',
    'effective_cache_size', 'huge_pages', 'wal_level', 'max_wal_size', 'min_wal_size', 'checkpoint_timeout',
    'checkpoint_completion_target', 'synchronous_commit', 'fsync', 'full_page_writes', 'wal_compression',
    'archive_mode', 'max_wal_senders', 'max_replication_slots', 'hot_standby', 'random_page_cost',
    'effective_io_concurrency', 'max_worker_processes', 'max_parallel_workers', 'max_parallel_workers_per_gather',
    'autovacuum', 'autovacuum_max_workers', 'autovacuum_naptime', 'autovacuum_vacuum_scale_factor',
    'autovacuum_analyze_scale_factor', 'autovacuum_freeze_max_age', 'log_min_duration_statement',
    'log_lock_waits', 'deadlock_timeout', 'track_io_timing', 'track_activity_query_size',
    'idle_in_transaction_session_timeout', 'statement_timeout', 'lock_timeout', 'jit', 'listen_addresses',
    'ssl', 'password_encryption', 'shared_preload_libraries', 'data_checksums', 'timezone'
)
ORDER BY s.name
LIMIT 100
