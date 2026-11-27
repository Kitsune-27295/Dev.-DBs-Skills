# RLS speed, N+1 detection, bulk loading and upserts

Sources: https://www.postgresql.org/docs/current/ddl-rowsecurity.html · https://www.postgresql.org/docs/current/pgstatstatements.html · https://www.postgresql.org/docs/current/sql-insert.html · https://www.postgresql.org/docs/current/populate.html · https://www.postgresql.org/docs/current/routine-vacuuming.html · Last verified 2026-11-24

## Row-level security and speed

Access rules (who may read what, grants, policy design) belong to `database-exposure`. This section is only about the cost.

- The documentation says policy expressions run for each row before the user's own conditions, except for functions marked leakproof. A policy is therefore on the hot path of every query on the table.
- It calls expressions that look only at the current row the simplest and best-performing case. A policy that runs a sub-select or calls a function that reads another table adds work per row and, in READ COMMITTED, can race with concurrent changes; the page lists mitigations (row locks in the sub-select, a security-definer function) and notes that heavy row sharing can hurt performance.
- The page gives no measurements and no indexing advice. The following is this skill's inference: put the policy column (for example `tenant_id`) first in the indexes used by the hot queries, compare the plan with the policy on and off, and prefer a column on the row itself over a lookup in another table. Any "RLS costs N times" figure seen elsewhere is not adopted here.
- Check through the application's own role: owners and `BYPASSRLS` roles skip policies, so a test run as the owner hides the cost.

## Finding N+1 in the statistics

The statements view normalizes constants, so a loop that runs one query per parent row shows up as one entry with a very high `calls` count, a small `mean_exec_time` and `rows / calls` near 1 (this reading is an inference; the page documents the columns). List entries by `calls` descending, then find the loop in the code and replace it with one `JOIN` or `= ANY($1)`. The module must be listed in `shared_preload_libraries` (a restart) and its counters can be reset on request, so say which window you read (see `postgres-diagnostics`).

## Bulk loading

From the loading chapter: commit once instead of per row; use `COPY` for large loads (fastest right after `CREATE TABLE` or `TRUNCATE` in the same transaction when `wal_level` is `minimal`); on a new table create indexes after the load; dropping foreign keys speeds a load but loses checking; raise `maintenance_work_mem` and `max_wal_size` temporarily; run `ANALYZE` afterward. The vacuum chapter adds that autovacuum does not analyze partitioned tables, so run `ANALYZE` on them by hand after a big load. Never do any of this against a shared or production database without the owner.

## Upsert with ON CONFLICT

`INSERT ... ON CONFLICT (cols) DO UPDATE` is documented to give an atomic insert-or-update outcome even under concurrency, so it replaces the racy "select, then insert or update". Rules: `DO UPDATE` needs a conflict target (index inference is preferred over naming a constraint); `EXCLUDED` is the proposed row; two proposed rows in one statement that hit the same key raise a cardinality error, so de-duplicate the batch first; `RETURNING` skips rows `DO NOTHING` skipped. Webhook de-duplication design stays in `idempotency-fix`; the concurrency proof stays in `race-condition-fix`.

```sql
INSERT INTO stock (sku, qty) VALUES ('a1', 5), ('b2', 3)
ON CONFLICT (sku) DO UPDATE SET qty = stock.qty + EXCLUDED.qty;
```

## How an agent should apply this

- Report RLS cost only from a plan or timing under the application role, never from a quoted multiplier.
- Count calls, not time, to find N+1; fix with one set-based query.
- Batch writes in one transaction; use `COPY` for imports; `ANALYZE` after.
- Use `ON CONFLICT` for insert-or-update and de-duplicate the batch on the key.
