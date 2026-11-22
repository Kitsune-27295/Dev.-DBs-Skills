# SQLite diagnostics: 19 read-only queries

All in `sqlite3/`, one file per question. Each is one `SELECT` over `sqlite_schema` or over a table-valued `PRAGMA` function, so
nothing changes: SQLite documents those functions as "PRAGMAs that return results and that have no side-effects". Pragmas that
change a file or the connection (`wal_checkpoint`, `optimize`, `vacuum`, `incremental_vacuum`, `analysis_limit`, any setter) are
**not** in the pack and never belong in a diagnosis.

SQLite has no server, no wait or usage statistics and no query history: a diagnosis is about the file, its schema, its integrity
and the settings of the connection that asks. Slow queries are found with `EXPLAIN QUERY PLAN` on the statement from the
application (see the `query-performance` skill), not with a script from this pack.

## How this was proven

Each file ran on a seeded database (an orphan row, a duplicate index, a foreign key without index, a `REAL` money column, a
trigger, a view, a STRICT table, `ANALYZE` done) and on an empty one, with two SQLite builds: **3.49.1** (the library inside
Python) and **3.53.4** (the Alpine `sqlite3` command line). All 19 passed on both, except what is documented below:
`storage/object_sizes.sql` needs the `dbstat` module, which the Python build lacks (it passed on the Alpine build), and two
files fail on a database where their table does not exist yet, as their comments say. Nothing was run on a version older than 3.49.

## Minimum version

| Need | Version | Source |
|---|---|---|
| table-valued PRAGMA functions (every script) | 3.16.0 (2017-01-02) | sqlite.org/pragma.html, "PRAGMA functions" |
| `PRAGMA table_list` (`schema/table_inventory`, `tables_without_primary_key`, `column_type_audit`, `foreign_keys_without_index`, `duplicate_indexes`) | 3.37.0 (2021-11-27) | sqlite.org/pragma.html |
| name `sqlite_schema` (the older name `sqlite_master` works everywhere) | 3.33.0 | the scripts use `sqlite_schema`; on an older build replace it with `sqlite_master` |
| `STRICT` tables (shown by `table_inventory`) | 3.37.0 | sqlite.org/stricttables.html |
| `dbstat` (`storage/object_sizes`) | any build compiled with `SQLITE_ENABLE_DBSTAT_VTAB` | check `config/compile_options.sql` |

Below 3.37 the five `table_list` scripts need rewriting over `sqlite_schema` (`type = 'table'`); the others run from 3.16.

## Scripts

Cost: **light** reads the schema or a pragma; **heavy** reads the whole file (run on a copy or off-peak).

| Area | File | What it answers | Cost |
|---|---|---|---|
| identity | `identity/engine_identity.sql` | library version, source id, compile option count | light |
| identity | `identity/attached_databases.sql` | attached databases and their files | light |
| config | `config/compile_options.sql` | what this build was compiled with (dbstat, FTS5, thread safety) | light |
| config | `config/database_settings.sql` | journal mode, page size, encoding, foreign keys, synchronous, busy timeout | light |
| config | `config/extension_modules.sql` | virtual-table modules available (fts5, rtree, json) | light |
| storage | `storage/file_size_and_free_space.sql` | file size and the share of free pages | light |
| storage | `storage/object_sizes.sql` | size per table and index, unused space (needs dbstat) | heavy |
| integrity | `integrity/quick_check.sql` | fast structural check | heavy on big files |
| integrity | `integrity/integrity_check.sql` | full check including every index against its table | heavy |
| integrity | `integrity/foreign_key_violations.sql` | rows that break a declared foreign key | heavy on big tables |
| schema | `schema/object_inventory.sql` | count of tables, indexes, views, triggers | light |
| schema | `schema/table_inventory.sql` | tables with WITHOUT ROWID and STRICT flags | light |
| schema | `schema/tables_without_primary_key.sql` | tables with no primary key | light |
| schema | `schema/column_type_audit.sql` | columns with no type, or floating point on a money-like name | light |
| schema | `schema/foreign_keys_without_index.sql` | foreign keys without a supporting index | light |
| schema | `schema/duplicate_indexes.sql` | indexes repeating each other | light |
| schema | `schema/triggers_and_views.sql` | triggers and views with their text | light |
| schema | `schema/autoincrement_headroom.sql` | AUTOINCREMENT counters (fails if no table uses it) | light |
| indexes | `indexes/optimizer_statistics.sql` | what `ANALYZE` recorded (fails if it never ran) | light |

## Reading the results

- `config/database_settings.sql` describes the connection that runs it: `foreign_keys`, `synchronous`, `busy_timeout` and
  `cache_size` are per connection and default to what the library compiled in, not to what your application sets. Ask what the
  application executes right after opening the file.
- `PRAGMA foreign_keys` is OFF by default: a file written by a connection that never turned it on can hold orphans, and
  `integrity/foreign_key_violations.sql` finds them.
- A copy of only the main file without its `-wal` file is not a copy of a WAL database. Copy with the `.backup` command or
  `VACUUM INTO`, never by file copy while the application uses it.
- A result is evidence, not a verdict: say what it means for this file and what to check next.
