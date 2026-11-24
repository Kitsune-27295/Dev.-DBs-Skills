# Version Differences, 3.49 to 3.53

Sources: https://www.sqlite.org/changes.html · https://www.sqlite.org/releaselog/3_49_0.html · https://www.sqlite.org/releaselog/3_51_0.html · https://www.sqlite.org/releaselog/3_53_0.html · https://www.sqlite.org/releaselog/3_53_4.html · https://www.sqlite.org/pragma.html · https://www.sqlite.org/compile.html · Last verified 2026-11-24

## Do the 3.53 pages exist?

Yes. The release list has 3.49.0 (2025-02-06) through 3.53.4 (2026-07-24), and also 3.54.0 (2026-10-09) and 3.54.1 (2026-10-16). 3.52.0 (2026-03-06) was withdrawn and its features moved into 3.53.0 (2026-04-09). 3.53.4 is a patch release.

## What the skill's scripts depend on, and since when

| Feature | Since | Scripts |
|---|---|---|
| table-valued `pragma_*` | 3.16.0 | all |
| `analysis_limit` | 3.32.0 | none (owner action) |
| partial `integrity_check(table)` | 3.33.0 | optional |
| `table_list` | 3.37.0 | five schema scripts |
| dbstat `aggregate` mode | 3.31.0 | optional |
| `PRAGMA optimize` enhanced | 3.46.0 | none (owner action) |
| `wal_checkpoint=NOOP` | 3.51.0 | none |

## What changed between 3.49 and 3.53 (official notes)

- Nothing in the notes touches `integrity_check`, `quick_check`, `foreign_key_check`, `dbstat`, `table_list`, `ANALYZE`, `optimize` or the pragma table-valued functions. The README's claim that all 19 scripts pass unchanged on 3.49.1 and 3.53.4 is consistent with that (the README's test run itself is the author's evidence).
- Relevant to health, not to the scripts: 3.50.2 avoids writing checksum-less WAL frames after a savepoint rollback; 3.51.0 hardens against applications that break POSIX locks with `close()`, and adds `wal_checkpoint=NOOP`; 3.51.3 and 3.53.0 fix a WAL-reset corruption bug (details are on `wal.html`, anchor `walresetbug`, not read here).
- 3.53.0 adds `REINDEX EXPRESSIONS` and self-healing for stale expression indexes. Relevant to `duplicate_indexes.sql`: that script already skips expression indexes because `index_xinfo` does not show the expression.
- 3.53.0 changes default float-to-text rounding from 15 to 17 significant digits: textual output of `REAL` values (for example in a report) can differ between 3.49 and 3.53. Compare numbers, not strings.
- 3.54.0 adds a `diskused()` extension and deprecates `sqlite3_analyzer`: a future alternative to dbstat reports, outside the tested range.
- The only observed difference between the two tested builds, dbstat, comes from a compile option, not from the version.

## Example

```sql
SELECT sqlite_version(), sqlite_compileoption_used('ENABLE_DBSTAT_VTAB');
-- 3.49.1|0 on a build without dbstat; 3.53.4|1 with it
```

## How an agent should apply this

- Report the version from `engine_identity.sql` and compare against the table above before relying on a pragma.
- Do not claim version-specific behavior for integrity or dbstat output; the notes show none.
- Warn that a WAL-reset fix is in 3.51.3 and 3.53.0 or later; a 3.49 WAL database is worth an upgrade conversation with the owner.
- Say plainly when a version was not tested (older than 3.49, newer than 3.53.4).
- Leave upgrades and general audits to `database-audit`.
