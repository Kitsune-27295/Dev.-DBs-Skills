---
name: sqlite-diagnostics
description: Use for a SQLite health check built from ready, read-only diagnostic queries (19 scripts - engine version and compile options, journal mode and connection settings, file size and free space, size per table and index, quick and full integrity check, foreign key violations, schema inventory, tables without primary key, risky column types, foreign keys without index, duplicate indexes, triggers, AUTOINCREMENT headroom, optimizer statistics), tested on SQLite 3.49 and 3.53. Use it whenever someone asks to check, audit, shrink or debug a SQLite file, mentions PRAGMA integrity_check, a database that is locked, corrupted, bloated or has orphan rows, or an app that uses SQLite in production, even without naming the scripts.
---

# SQLite diagnostics

Nineteen `SELECT`-only scripts in `references/sqlite3/`. They read `sqlite_schema` and table-valued `PRAGMA` functions, which SQLite
documents as free of side effects, so a diagnosis never changes the file. Cross-database fundamentals live in `database-audit`;
`schema-and-constraints` is the generic method behind the schema scripts, `backup-restore-drill` the backup one.

## Steps

1. **Work on a copy.** Running against a live file is safe for the schema scripts, but the integrity and size scripts read every
   page and compete with the application for the lock. Make the copy from a read-only connection (`sqlite3 -readonly live.db
   ".backup copy.db"`, or `VACUUM INTO 'copy.db'` on a connection opened as `file:live.db?mode=ro`, which writes only the new file;
   never a plain file copy of a WAL database in use), diagnose the copy, and say that you did.
2. **Check the engine first:** `identity/engine_identity.sql`. Below 3.16 nothing here runs; below 3.37 the five `table_list`
   scripts need rewriting; the minimum versions are in `references/README.md`.
3. **Run in this order:** identity and config, then `integrity/quick_check.sql` (a failure there makes the rest unreliable:
   stop and report), then the schema scripts, then storage. `integrity/integrity_check.sql` only when the quick check passes
   and corruption is still suspected, or before a migration.
4. **Name what the connection is.** `config/database_settings.sql` shows this connection's defaults, not the application's
   (`foreign_keys` is OFF unless the application turns it on). Ask for the open-time settings and compare.
5. **Report:** per area, what the result says, what it does not prove, risk (high, medium, low) and the next check. A script
   that returns no rows is "nothing found", never "healthy"; SQLite has no usage or wait statistics, so there is no unused-index
   or slow-query script: use `EXPLAIN QUERY PLAN` on the application's statements.

## Rules

- Never run a pragma that writes (`wal_checkpoint`, `optimize`, `vacuum`, `incremental_vacuum`, `journal_mode=`, `foreign_keys=` as
  a setter) from here; propose it and the owner runs it.
- A failing script that says "no such table: sqlite_stat1", "sqlite_sequence" or "dbstat" means the feature is absent, not that the
  database is broken: report it as such (the README says which).
- Never open the owner's live database file in write mode, and never copy it by hand while the application runs.
- Output holds table and column names and trigger text: keep it in the report.
- To change a script, test it on a seeded and on an empty database and update the README row in the same change.

References: `references/README.md` (index, minimum versions, how this was proven).

## Deep references

- [Integrity and foreign key pragmas](references/integrity-and-foreign-key-pragmas.md) — read when interpreting quick_check, integrity_check or foreign_key_check output.
- [dbstat and space analysis](references/dbstat-and-space-analysis.md) — read when dbstat is missing or file size and free pages need explaining.
- [WAL, journal mode, statistics and counters](references/wal-journal-and-connection-health.md) — read for locked databases, WAL copies, sqlite_stat1 or AUTOINCREMENT.
- [Version differences, 3.49 to 3.53](references/version-differences-3-49-to-3-53.md) — read before claiming a version-specific behavior.
