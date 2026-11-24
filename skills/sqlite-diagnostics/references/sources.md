# Sources — SQLite Diagnostics

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| https://www.sqlite.org/pragma.html | 200 OK (page is ~100 KB; the last 492 characters, the `writable_schema` tail, were not read) | Table-valued `pragma_*` functions (3.16.0) and the no-side-effects rule; `integrity_check`/`quick_check` semantics; `foreign_key_check` columns; `foreign_keys` default OFF; `journal_mode`; `page_count`, `freelist_count`, `auto_vacuum`; `table_list` (3.37.0); which pragmas write (`optimize`, `wal_checkpoint`, `analysis_limit`, setters) |
| https://www.sqlite.org/dbstat.html | 200 OK | Compile option `SQLITE_ENABLE_DBSTAT_VTAB`, eponymous table, columns, aggregate mode (3.31.0), pages it omits |
| https://www.sqlite.org/foreignkeys.html | 200 OK | Enforcement off by default, no-op inside a transaction, why child key columns should be indexed |
| https://www.sqlite.org/autoinc.html | 200 OK | `sqlite_sequence`, limit 9223372036854775807, `SQLITE_FULL` behavior, advice to avoid AUTOINCREMENT |
| https://www.sqlite.org/wal.html | 200 OK | WAL persistence, `-wal`/`-shm`, checkpoint modes and starvation, copy-together rule, same-host limit |
| https://www.sqlite.org/lang_analyze.html | 200 OK | `sqlite_stat1`, `PRAGMA optimize`, `analysis_limit`, staleness, version history of those |
| https://www.sqlite.org/fileformat2.html | 200 OK | Header offsets (freelist at 32/36, WAL bytes 18-19), freelist trunk/leaf layout, `sqlite_schema`, `sqlite_sequence`, `sqlite_stat1` format, ptrmap pages |
| https://www.sqlite.org/compile.html | 200 OK (108 KB; the last ~8 KB were not read) | `SQLITE_ENABLE_DBSTAT_VTAB`, `SQLITE_DEFAULT_FOREIGN_KEYS`, `SQLITE_OMIT_*` pragma options, `sqlite_compileoption_used()` |
| https://www.sqlite.org/releaselog/3_49_0.html | 200 OK | 3.49.0 dated 2025-02-06; no change to any pragma or dbstat used here |
| https://www.sqlite.org/releaselog/3_51_0.html | 200 OK | `PRAGMA wal_checkpoint=NOOP`; POSIX-lock corruption resistance; carray/percentile off by default |
| https://www.sqlite.org/releaselog/3_53_0.html | 200 OK | 3.53.0 dated 2026-04-09; WAL-reset bug fix, `REINDEX EXPRESSIONS`; nothing on the pragmas used here |
| https://www.sqlite.org/releaselog/3_53_4.html | 200 OK | 3.53.4 dated 2026-07-24, a patch release; same feature summary |
| https://www.sqlite.org/changes.html | 200 OK (408 KB; only the first ~100 KB read, which covers 3.49.0 to 3.54.1) | Release list 3.49.0 to 3.54.1 and dates; 3.52.0 withdrawn |

3.53 pages do exist (3.53.0 to 3.53.4; newer 3.54.0 and 3.54.1 are also listed). The pages were read with WebFetch, which summarizes with a small model, not as raw HTML.

## Claims and caveats

- **Not confirmed by any page read:** the README statements that rowids can be renumbered by `VACUUM` for tables without a primary key, that `VACUUM INTO` on a `mode=ro` connection writes only the new file, and that `.backup` from `-readonly` is safe. `lang_vacuum.html` and the shell page were not fetched.
- **Author's own test evidence (README, not re-verified here):** all 19 scripts passed on SQLite 3.49.1 (Python build) and 3.53.4 (Alpine CLI); the Python build lacked `dbstat`. The official release notes neither confirm nor contradict that build detail.
- **Differences 3.49 versus 3.53:** the official notes show no change to `integrity_check`, `quick_check`, `foreign_key_check`, `dbstat`, `table_list` or `optimize`. The README reports no behavior difference either, only the dbstat availability gap, which is a build option, not a version difference.
- **Docs inconsistency:** `dbstat.html` lists `pagetype` as `'internal'` in the schema but `'interior'` in the aggregate-mode table.
- **Page details missing:** `dbstat.html` says nothing about cost or WAL behavior, and `autoinc.html` gives no reset procedure; the cost statements in the reference files are the skill author's inference.
- `foreign_key_list` output columns are only partly listed on `pragma.html`; the script uses `id`, `seq`, `from`, which the author tested but the page does not fully list.
