-- Persistent and per-connection settings of the main database in one row (table-valued PRAGMA functions, SQLite 3.16+).
-- Read-only: a SELECT; no pragma is set. Per-connection settings (foreign_keys, synchronous, busy_timeout, cache_size,
-- temp_store) describe THIS connection, not what your application opens with: read them from the application's own connection.
SELECT
    (SELECT journal_mode FROM pragma_journal_mode) AS journalMode,
    (SELECT page_size FROM pragma_page_size) AS pageSize,
    (SELECT encoding FROM pragma_encoding) AS encoding,
    (SELECT auto_vacuum FROM pragma_auto_vacuum) AS autoVacuum,
    (SELECT user_version FROM pragma_user_version) AS userVersion,
    (SELECT application_id FROM pragma_application_id) AS applicationId,
    (SELECT foreign_keys FROM pragma_foreign_keys) AS foreignKeys,
    (SELECT synchronous FROM pragma_synchronous) AS synchronous,
    (SELECT timeout FROM pragma_busy_timeout) AS busyTimeoutMs,
    (SELECT cache_size FROM pragma_cache_size) AS cacheSize,
    (SELECT temp_store FROM pragma_temp_store) AS tempStore,
    (SELECT locking_mode FROM pragma_locking_mode) AS lockingMode
