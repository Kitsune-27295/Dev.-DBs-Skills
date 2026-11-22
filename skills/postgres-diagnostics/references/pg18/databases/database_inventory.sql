-- Target: PostgreSQL 18. Tested on 18.7.
-- Database inventory: size, connections, cache hit ratio, temp files, deadlocks and transaction-ID age
-- (pg_database with pg_stat_database). Read-only: a SELECT over catalog views.
-- xidAgePctOfWraparound is the age of datfrozenxid over 2^31: autovacuum starts a forced freeze at autovacuum_freeze_max_age
-- (200 million by default), so a value near 10 means that freeze is about to start and near 100 means danger.
-- Size is NULL when the role cannot CONNECT to the database.
SELECT
    d.datname AS databaseName,
    pg_get_userbyid(d.datdba) AS owner,
    pg_encoding_to_char(d.encoding) AS encoding,
    d.datallowconn AS allowConnections,
    d.datconnlimit AS connectionLimit,
    CASE WHEN has_database_privilege(d.datname, 'CONNECT')
         THEN round(pg_database_size(d.datname) / 1048576.0, 2) END AS sizeMb,
    age(d.datfrozenxid) AS xidAge,
    round(100.0 * age(d.datfrozenxid) / 2147483647, 2) AS xidAgePctOfWraparound,
    mxid_age(d.datminmxid) AS multixactAge,
    s.numbackends AS connections,
    s.xact_commit AS commits,
    s.xact_rollback AS rollbacks,
    round(100.0 * s.blks_hit / NULLIF(s.blks_hit + s.blks_read, 0), 2) AS cacheHitPct,
    s.temp_files AS tempFiles,
    round(s.temp_bytes / 1048576.0, 2) AS tempMb,
    s.deadlocks AS deadlocks,
    s.checksum_failures AS checksumFailures,
    s.stats_reset AS statsReset
FROM pg_database AS d
LEFT JOIN pg_stat_database AS s
  ON s.datid = d.oid
WHERE NOT d.datistemplate
ORDER BY d.datname
LIMIT 200
