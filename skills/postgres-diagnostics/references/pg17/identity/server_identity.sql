-- Target: PostgreSQL 17. Tested on 17.12.
-- Instance identity: version, uptime, role and the current database's encoding (version(), pg_settings, pg_database).
-- Read-only: a SELECT over functions and catalog views; nothing is changed.
SELECT
    version() AS serverVersion,
    current_setting('server_version_num')::int AS versionNum,
    pg_postmaster_start_time() AS startTime,
    now() - pg_postmaster_start_time() AS uptime,
    pg_is_in_recovery() AS isInRecovery,
    current_database() AS currentDatabase,
    (SELECT pg_encoding_to_char(d.encoding) FROM pg_database AS d WHERE d.datname = current_database()) AS encoding,
    current_setting('data_checksums') AS dataChecksums,
    current_setting('TimeZone') AS timeZone,
    (SELECT count(*) FROM pg_stat_activity AS a WHERE a.backend_type = 'client backend') AS clientBackends,
    current_setting('max_connections')::int AS maxConnections
