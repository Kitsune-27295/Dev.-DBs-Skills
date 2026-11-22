-- Compile-time options of this SQLite build (PRAGMA compile_options as a table-valued function).
-- Read-only: a SELECT. Look for ENABLE_DBSTAT_VTAB (needed by storage/*_sizes.sql), ENABLE_FTS5, ENABLE_JSON1 (default in
-- recent versions), SECURE_DELETE, THREADSAFE and OMIT_* flags: a missing feature is a build choice, not a database defect.
SELECT
    o.compile_options AS compileOption
FROM pragma_compile_options AS o
ORDER BY o.compile_options
