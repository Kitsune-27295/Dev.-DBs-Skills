# dbstat and Space Analysis

Sources: https://www.sqlite.org/dbstat.html · https://www.sqlite.org/fileformat2.html · https://www.sqlite.org/pragma.html · https://www.sqlite.org/compile.html · Last verified 2026-11-24

Maps to: `storage/object_sizes.sql`, `storage/file_size_and_free_space.sql`, `config/compile_options.sql`, `config/database_settings.sql` (auto_vacuum, page size).

## The two views of space

1. **File level** (`file_size_and_free_space.sql`): `page_count * page_size` is the file size; `freelist_count` is the number of unused pages. The header stores the same two numbers (page size at offset 16, freelist count at offset 36, first trunk page at 32).
2. **Object level** (`object_sizes.sql`): the `dbstat` virtual table, one row per b-tree page, or one row per b-tree with `aggregate=1`.

The freelist is a linked list of trunk pages, each listing leaf pages that hold nothing. Free pages are reusable by later inserts but do not shrink the file unless auto_vacuum or `VACUUM` runs (`auto_vacuum`: 0 none, 1 full, 2 incremental; changing it from NONE needs `VACUUM`, and none of these run from the pack).

## dbstat availability

- Needs the build option `SQLITE_ENABLE_DBSTAT_VTAB` (off by default). Check `compile_options.sql` or `SELECT sqlite_compileoption_used('ENABLE_DBSTAT_VTAB')`.
- Without it, `no such table: dbstat` means a build choice, not a damaged database. The skill author saw this on the Python-bundled 3.49.1 and not on the Alpine 3.53.4 CLI (author's test, not from the docs).
- It is eponymous: no `CREATE VIRTUAL TABLE` is needed, and the docs' own recommendation for a named one is a temp table.

## Columns that matter

| Column | Meaning |
|---|---|
| `name` | table or index the page belongs to |
| `pagetype` | internal, leaf, overflow (NULL in aggregate mode) |
| `payload` / `unused` | bytes used and bytes wasted on the page or b-tree |
| `pgsize` | page size |
| `pageno` | page number, or total page count in aggregate mode (3.31.0+) |

Docs example for efficiency: `sum(pgsize-unused)*100.0/sum(pgsize)` per object; closer to 100 is better. The script reports `unusedPct` the same way inverted.

## Reading the totals

- dbstat omits freelist pages, pointer-map pages and the lock-byte page. So `sum(pgsize)` over dbstat is **less** than the file size; the gap is roughly the freelist plus those special pages (inference, consistent with the omissions the doc lists). Do not call the gap "lost".
- Overflow pages count toward the owning object: a table with large blobs shows many overflow pages, not many leaf pages.
- High `unusedPct` on an index or table after heavy deletes suggests fragmentation; the docs show a sequential-page fraction query as a guide for when `VACUUM` is worth it.
- Index names such as `sqlite_autoindex_<table>_N` are internal objects; the script labels names missing from `sqlite_schema` as `internal`.
- Docs inconsistency: the page writes `'internal'` in the schema and `'interior'` in another table. Filter with `'internal'` as the docs example does, and confirm against output.

## Cost and safety

- dbstat is read-only. It reads every page of the objects asked for; the docs say nothing about cost, so treat "heavy on large files" as the author's inference. Filter with `WHERE name = ...` to limit work.
- Run on a copy: reading all pages evicts the application's cache and competes for locks.
- Do not read dbstat while another connection is writing and expect exact numbers (inference; the page is silent on concurrency).

## Example

```sql
-- top 5 objects by size, aggregate mode (3.31.0+)
SELECT name, pageno AS pages, round(100.0*unused/pgsize,1) AS unusedPct
FROM dbstat WHERE aggregate = 1 ORDER BY pgsize DESC LIMIT 5;
```

## How an agent should apply this

- Run `file_size_and_free_space.sql` first: it needs no extension and answers "is there reclaimable space".
- Only then try `object_sizes.sql`; if dbstat is absent, report that and stop, do not suggest rebuilding SQLite unless asked.
- Explain the dbstat-versus-file gap before anyone asks where the pages went.
- Recommend `VACUUM`, `VACUUM INTO` or `incremental_vacuum` as owner actions only, never run them.
- For growth caused by dead rows versus the WAL file, check `wal-journal-and-connection-health.md` before blaming the main file.
