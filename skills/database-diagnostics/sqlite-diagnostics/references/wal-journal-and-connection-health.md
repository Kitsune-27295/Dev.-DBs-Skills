# WAL, Journal Mode, Statistics and Counters

Sources: https://www.sqlite.org/wal.html · https://www.sqlite.org/pragma.html · https://www.sqlite.org/lang_analyze.html · https://www.sqlite.org/autoinc.html · https://www.sqlite.org/fileformat2.html · https://www.sqlite.org/compile.html · Last verified 2026-11-24

Maps to: `config/database_settings.sql`, `identity/attached_databases.sql`, `config/extension_modules.sql`, `indexes/optimizer_statistics.sql`, `schema/autoincrement_headroom.sql`.

## Journal mode and WAL

- `journal_mode` values: DELETE (default), TRUNCATE, PERSIST, MEMORY, WAL, OFF. WAL persists in the file (header bytes 18-19 both 2); the others are per connection.
- Reading the pragma in `database_settings.sql` is read-only; setting it is not, so the pack never does.
- WAL adds `-wal` and `-shm` files. The `-wal` is part of the database state: copying the main file alone can lose committed transactions. Use `.backup` or `VACUUM INTO`, as `backup-restore-drill` explains.
- Automatic checkpoint happens at about 1000 pages and on last close. A checkpoint cannot finish while an old reader needs the WAL: a long diagnostic read (such as `integrity_check`) can delay it, and with constant overlapping readers the WAL grows without bound (checkpoint starvation).
- WAL needs all processes on the same host; network filesystems are unsupported. A leftover `-wal` after a crash is normal; the only safe cleanup is opening and closing the database.
- Checkpoint pragmas write to the file (except `NOOP`, added in 3.51.0), so they stay out of the pack; propose them.

## Per-connection settings

`foreign_keys`, `synchronous`, `busy_timeout`, `cache_size`, `temp_store`, `locking_mode` describe the connection that runs the script. `synchronous` default is FULL; in WAL, NORMAL is consistent but may lose recent commits on power loss. `locking_mode=EXCLUSIVE` makes other connections get SQLITE_BUSY, a typical "database is locked" cause. Persistent facts (page size, encoding, `user_version`, `application_id`, auto_vacuum) live in the file header.

## Statistics: sqlite_stat1

Exists only after `ANALYZE` or `PRAGMA optimize` ran. `stat` is a space-separated list: first number is the approximate row count; each later number is the average rows per distinct prefix of the index columns; last is 1 for a unique index. Trailing tokens (`sz=`, `unordered`, `noskipscan`) are normal. `idx` NULL means table-level row count. Statistics go stale silently as data changes. `PRAGMA optimize` (preferred since 3.46.0) and `analysis_limit` (3.32.0) change the file and are owner actions. `sqlite_stat4` appears only with `SQLITE_ENABLE_STAT4`, and a non-zero analysis limit prevents it.

## AUTOINCREMENT headroom

`sqlite_sequence(name, seq)` exists once any AUTOINCREMENT table is created; `seq` is the largest rowid ever inserted. At 9223372036854775807, inserts fail with `SQLITE_FULL` (no random fallback, unlike plain rowids). A counter far above `max(id)` signals large deletes or bulk loads; exhaustion is practically unreachable unless values are inserted manually. The docs advise avoiding AUTOINCREMENT unless never-reused ids are required, because it costs extra I/O.

## Example

```sql
SELECT (SELECT journal_mode FROM pragma_journal_mode) AS mode,
       (SELECT synchronous FROM pragma_synchronous)   AS sync;
-- "wal" + 1 (NORMAL) is a common, valid pairing; judge against the app's intent
```

## How an agent should apply this

- State the journal mode and whether a `-wal` file sits beside the database before any copy.
- Say that connection settings are the script's, then ask for the application's open-time pragmas.
- Treat missing `sqlite_stat1` or `sqlite_sequence` as "feature unused", not as corruption.
- When a user reports "locked" errors, ask about `locking_mode`, `busy_timeout`, long readers and checkpoint starvation; point query-level causes to `query-performance`.
- Hand wider audits to `database-audit`.
