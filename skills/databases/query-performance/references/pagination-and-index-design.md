# Pagination and index design

Sources: https://www.postgresql.org/docs/current/queries-limit.html · https://www.postgresql.org/docs/current/functions-comparisons.html · https://www.postgresql.org/docs/current/indexes-multicolumn.html · https://www.postgresql.org/docs/current/indexes-partial.html · https://www.postgresql.org/docs/current/indexes-index-only-scans.html · https://www.postgresql.org/docs/current/indexes-expressional.html · Last verified 2026-11-24

## Offset versus keyset pagination

The documentation says rows skipped by `OFFSET` are still computed by the server, so a large offset gets slower with every page. It also says that without an `ORDER BY` that gives a unique order, `LIMIT` returns an unpredictable subset and different offsets can give inconsistent pages. Both points apply to any pagination.

Keyset pagination (also called cursor pagination) remembers the last row seen and asks for the rows after it. Row-wise comparison is lexicographic: `(a, b) > (x, y)` means the first field decides unless the two first fields are equal. So a stable page query is:

```sql
-- first page
SELECT id, created_at, title FROM posts
ORDER BY created_at, id LIMIT 20;
-- next page, with the last row's values as parameters
SELECT id, created_at, title FROM posts
WHERE (created_at, id) > (:last_created_at, :last_id)
ORDER BY created_at, id LIMIT 20;
```

The `id` is the tie-breaker that makes the order unique. Pair it with an index on `(created_at, id)` so the engine can start at the right place. That the planner uses the index for the row comparison is expected but was not stated on the page read: check with `EXPLAIN`. Limits of the pattern (inference): no jump to page N, and a null in a sort column breaks the comparison (a null makes the result null), so keep paging columns `not null`.

## Composite index order

For a multicolumn B-tree the page says equality constraints on leading columns, plus an inequality on the first column without an equality, limit the scanned part of the index. Conditions on later columns are checked inside the index but do not narrow the scan. So put equality columns first, the range or sort column last: `where tenant_id = ? and created_at >= ?` wants `(tenant_id, created_at)`. The page warns that more than three columns rarely help unless usage is very stylized. A newer skip-scan optimization can help when the leading column has few distinct values; the page did not name the version.

## Partial, covering and expression indexes

| Kind | Use when | Rule from the docs |
|---|---|---|
| Partial (`WHERE` on the index) | queries touch a small, stable subset (unbilled orders, pending jobs); or you need uniqueness for some rows only | the planner must show the query condition implies the index condition; parameterized conditions cannot be proven, so write the constant in the query |
| Covering (`INCLUDE (col)`) | a hot query reads one or two extra columns beyond the key | index-only scans need the visibility map to be mostly set, which means vacuum must keep up; wide included columns bloat the index and an oversized entry makes inserts fail |
| Expression (`lower(email)`) | a filter wraps a column in a function | the query must use the same expression; the value is computed on every insert and non-HOT update, so it is a read-for-write trade |

Do not replace partitioning with many non-overlapping partial indexes: the page says the planner tests each one; use one multicolumn index with the category first, or real partitioning (`schema-and-constraints`).

## How an agent should apply this

- Replace `OFFSET` on any list that can grow large; add a unique tie-breaker to the order.
- Order composite index columns equality first, range last; justify a fourth column with a measured query.
- Propose a partial index only with a constant predicate in the query; check the plan before and after.
- Propose `INCLUDE` only after confirming the table is vacuumed often enough for index-only scans (`postgres-diagnostics`).
- Every index still needs a measured query (`SKILL.md` rule): write cost is the price.
