# Integrity and Foreign Key Pragmas

Sources: https://www.sqlite.org/pragma.html · https://www.sqlite.org/foreignkeys.html · https://www.sqlite.org/fileformat2.html · Last verified 2026-11-27

Maps to: `integrity/quick_check.sql`, `integrity/integrity_check.sql`, `integrity/foreign_key_violations.sql`, `schema/foreign_keys_without_index.sql`.

## What each pragma returns

| Pragma | Output | Skips or adds |
|---|---|---|
| `quick_check` | one row `ok`, or one text row per problem | skips the UNIQUE check and the comparison of index content with table content |
| `integrity_check` | same shape | full check, including every index against its table |
| `foreign_key_check` | rows of (child table, rowid, parent table, fk id) | rowid is NULL for a WITHOUT ROWID child; fk id equals `id` in `foreign_key_list` |

Both integrity pragmas take an optional number N (default 100, the cap on reported errors) or a table name. A table name makes it a partial check (3.33.0+), not a whole-file verdict. `integrity_check` does **not** report foreign key problems: that is `foreign_key_check`'s job. Per the docs, `quick_check` runs in linear time and `integrity_check` in O(N log N) of the row count.

## Reading the output

- One row `ok` is the only clean result. Any other text is a finding: keep the exact message, do not paraphrase it.
- The scripts add `LIMIT 100` or `200`, so a full list needs a second run; say when the limit was hit.
- A foreign-key row means a child row points at a missing parent. It is a data problem, not file corruption. The usual cause is a writer connection that never ran `PRAGMA foreign_keys = ON` (the default is OFF unless the build changed it with `SQLITE_DEFAULT_FOREIGN_KEYS`).
- `foreign_keys` is a no-op inside a transaction and per connection, so what `database_settings.sql` shows is the diagnosing connection's value only.

## Why foreign keys need an index on the child side

Parent key columns must be a primary key or unique. Child columns need no index, but when a parent row is deleted or its key updated, SQLite searches the child table for dependents. Without an index that search is a full scan per parent change. The docs call such indexes almost always beneficial and say they need not be unique. `foreign_keys_without_index.sql` flags the foreign keys where no non-partial index starts with the referencing columns in order. (Pitfall, from the script's own notes: the same columns in another order are reported on purpose.)

## Cost and safety

- Read-only: all three pragmas are documented as having no side effects, hence usable as `pragma_*` table-valued functions since 3.16.0.
- Cost (inference from the documented O(N) and O(N log N)): `quick_check` is one pass; `integrity_check` is the heavy one. `foreign_key_check` is slow on big child tables with no index on the referencing column, because each child row triggers a parent lookup or the reverse.
- They hold a read transaction: in a rollback-journal database a long check can delay a writer; in WAL mode it pins the WAL and delays checkpoints (see `wal-journal-and-connection-health.md`).

## Example

```sql
-- quick first, full only if needed
SELECT quick_check FROM pragma_quick_check LIMIT 100;
-- partial check of one table (3.33.0+)
PRAGMA integrity_check(orders);
```

## How an agent should apply this

- Run `quick_check` first; stop and report if it returns anything but `ok`.
- Run `integrity_check` only on a copy or off-peak, and say it was skipped when it was.
- Always pair an `ok` integrity result with `foreign_key_violations.sql`, since the first never covers orphans.
- Report orphans as data findings with the child table and fk id, and recommend `schema-and-constraints` for the fix.
- Treat "no rows" from the foreign key script as "no orphans found on this connection's view", not proof the application enforces keys.
