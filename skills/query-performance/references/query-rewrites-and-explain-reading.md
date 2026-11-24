# Query rewrites and reading the plan

Sources: video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 04 15:50-21:28 (prompt walk-through 20:16-21:28); handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe section "3. Performance"; PostgreSQL wiki https://wiki.postgresql.org/wiki/Don%27t_Do_This (for `NOT IN`, `BETWEEN`) · Last verified 2026-11-24

## The four rewrites in the handout

The handout shows four before/after pairs (author's timings on 5 million rows; not reproduced here). Each pair is a pattern, independent of the numbers:

| Pattern | Why it is slow | Rewrite |
|---|---|---|
| `where date(created_at) = '2026-11-01'` | A function around the column hides it from a plain index | Range: `created_at >= '2026-11-01' and created_at < '2026-11-02'` (or an expression index if the function must stay) |
| `select count(*) ... > 0` to test existence | Counts every match | `exists (select 1 ...)`, which stops at the first match |
| Large `OFFSET` | The engine reads and discards all skipped rows | Cursor: `where id > :last_id order by id limit 50` |
| Query inside a loop (N+1) | One round trip per item | `JOIN` or `IN (...)` |

Wiki cross-reference: `NOT IN` with a subquery cannot become an anti-join and misbehaves with NULLs, so use `NOT EXISTS`; `BETWEEN` on timestamps double-counts the boundary. Inference: both belong in the same review pass.

## Reading the plan

Run `EXPLAIN ANALYZE` (it executes the query, so on a development copy only) on the five most used queries. The lesson's flag: a `Seq Scan` on a big table when the query is selective. Things to check in the output, from general PostgreSQL practice (not read from a source page here):

- node type (Seq Scan, Index Scan, Bitmap, joins);
- estimated vs actual rows (large gaps point to stale statistics);
- actual time and loops;
- a Seq Scan is fine on small tables or when most rows are needed.

```
Seq Scan on orders  (cost=0.00..95000 rows=12 ...) (actual time=58.1..58.1 rows=12 loops=1)
  Filter: (customer_id = 42)
  Rows Removed by Filter: 4999988
```
That "Rows Removed by Filter" figure is the smell of a missing index.

## Index trade-offs

- Each index slows writes and takes disk; the video calls indexing everything a bad practice.
- Create an index only where a measured query needs it, and say which query it serves.
- Order matters in multicolumn indexes (inference: general knowledge); match the query's filter and sort.

## Environment

The handout asks to run the plans in a development database with production-like volume, never in production. On a live big table, create indexes concurrently and warn first.

## How an agent should apply this

- Collect the five most used queries and scan each for the four patterns plus `NOT IN`.
- Run `EXPLAIN ANALYZE` only on a development copy; report the plan line that proves the problem.
- Prefer the smallest rewrite (range, `EXISTS`, cursor, `JOIN`) before adding an index.
- Add one index per migration, tied to a named query; re-measure and report before and after.
- Do not rewrite business logic to gain speed without asking.
