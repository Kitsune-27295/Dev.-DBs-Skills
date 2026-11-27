# Query rewrites and reading the plan

Sources: video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 04 15:50-21:28 (prompt walk-through 20:16-21:28); handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe section "3. Performance"; PostgreSQL docs https://www.postgresql.org/docs/current/using-explain.html; PostgreSQL wiki https://wiki.postgresql.org/wiki/Don%27t_Do_This (for `NOT IN`, `BETWEEN`) · Last verified 2026-11-27

## The four rewrites in the handout

The handout shows four before/after pairs (author's timings on 5 million rows; not reproduced here). Each pair is a pattern, independent of the numbers:

| Pattern | Why it is slow | Rewrite |
|---|---|---|
| `where date(created_at) = '2026-11-01'` | A function around the column hides it from a plain index | Range: `created_at >= '2026-11-01' and created_at < '2026-11-02'` (or an expression index if the function must stay) |
| `select count(*) ... > 0` to test existence | Counts every match | `exists (select 1 ...)`, which stops at the first match |
| Large `OFFSET` | The engine reads and discards all skipped rows | Cursor: `where id > :last_id order by id limit 50` |
| Query inside a loop (N+1) | One round trip per item | `JOIN` or `IN (...)` |

Wiki cross-reference (re-read): `NOT IN (subquery)` cannot become an anti-join and returns no rows when the list holds a NULL, so use `NOT EXISTS`; `BETWEEN` includes both ends, so a timestamp range should be `>= start and < end`. Inference: both belong in the same review pass.

## Reading the plan

Run `EXPLAIN ANALYZE` on the five most used queries. It executes the statement, so use a development copy, and wrap `INSERT`, `UPDATE`, `DELETE` and `MERGE` in `BEGIN` ... `ROLLBACK` (PostgreSQL documentation, using-explain, re-read 2026-11-27). What to check:

- estimated versus actual rows: the documentation calls this usually the most important check; a large gap often means stale statistics (`ANALYZE`) or a wrong scan or join choice;
- `actual time` and `rows` are averages per execution: multiply by `loops` for the node's total;
- `Rows Removed by Filter` large relative to rows returned: a selective filter reads and discards many rows, so an index may help;
- `Buffers` (on by default with `ANALYZE`): `hit` versus `read` shows cache use;
- with `LIMIT`, a node may stop early, so actual rows below the estimate is not an error;
- a Seq Scan is right on small tables or when most rows are needed (the documentation's own 7,000-of-10,000 example);
- reported time excludes network transfer and, unless `SERIALIZE` is given, output conversion.

```
Seq Scan on orders  (cost=0.00..95000 rows=12 ...) (actual time=58.1..58.1 rows=12 loops=1)
  Filter: (customer_id = 42)
  Rows Removed by Filter: 4999988
```
That "Rows Removed by Filter" figure is the smell of a missing index.

## Index trade-offs

- Each index slows writes and takes disk; the video calls indexing everything a bad practice.
- Create an index only where a measured query needs it, and say which query it serves.
- Order matters in multicolumn indexes: see `pagination-and-index-design.md`.

## Environment

The handout asks to run the plans in a development database with production-like volume, never in production. On a live big table, create indexes concurrently and warn first.

## How an agent should apply this

- Collect the five most used queries and scan each for the four patterns plus `NOT IN`.
- Run `EXPLAIN ANALYZE` only on a development copy; report the plan line that proves the problem.
- Prefer the smallest rewrite (range, `EXISTS`, cursor, `JOIN`) before adding an index.
- Add one index per migration, tied to a named query; re-measure and report before and after.
- Do not rewrite business logic to gain speed without asking.
