-- Engine identity: library version, source id and the number of compile options (sqlite_version, sqlite_source_id).
-- Read-only: a SELECT over functions. The compileOptionCount column uses a table-valued PRAGMA function, which needs
-- SQLite 3.16 or later (as does the rest of this pack); on an older build run SELECT sqlite_version(); alone.
SELECT
    sqlite_version() AS sqliteVersion,
    sqlite_source_id() AS sourceId,
    (SELECT count(*) FROM pragma_compile_options) AS compileOptionCount
