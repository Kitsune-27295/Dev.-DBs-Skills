# End-to-end triage order for a slow screen

Sources: https://www.postgresql.org/docs/current/pgstatstatements.html · https://www.postgresql.org/docs/current/queries-limit.html · https://web.dev/articles/vitals · Last verified 2026-11-27 · Method adapted from an internal project's performance procedure (method only; no text, names or figures reused)

## The question first

Ask: is it one slow thing, or many fast things? They have opposite fixes. One slow query needs a plan and an index. Many fast queries (hundreds of calls of a sub-millisecond statement) need fewer round trips, and no index will help. Measure before choosing; the usual mistake is tuning the wrong layer.

## Order to check

| Step | Layer | How to see it | Typical fix |
|---|---|---|---|
| 1 | One slow query | statements view sorted by total or mean time; `EXPLAIN ANALYZE` on a copy | index, rewrite (`query-rewrites-and-explain-reading.md`) |
| 2 | Many fast queries (N+1) | same view sorted by `calls`; count queries per request in the log | one `JOIN` or `= ANY($1)`; see `rls-bulk-writes-and-upserts.md` |
| 3 | Index under row-level security | plan run as the application role, policy column leading in the index | policy column indexed, row-local policy |
| 4 | Payload | response size, unbounded lists | paginate (`pagination-and-index-design.md`), return only the fields the screen needs |
| 5 | Cache | what is cached, for how long, under which key | tune freshness to the data's rate of change; a shared cache key must include the tenant or the response can leak across tenants (`caching-strategies`) |
| 6 | Browser | bundle size, re-render count, the field metrics in the web.dev vitals guidance: Largest Contentful Paint (good at 2.5 s or less), Interaction to Next Paint (200 ms or less) and Cumulative Layout Shift (0.1 or less), read at the 75th percentile; that page was last updated 2024-10-31, so check current thresholds | lazy-load, split, memoize derived values |

Independent calls made one after another on the server side are a fast-things problem too: run them in parallel. The statements view only helps if the module is preloaded and query ids are on. Count queries, do not guess: N+1 is invisible when you profile a single request and obvious when you count.

## Closing

State the number before and after, with the command that produced both. A faster wrong answer is not an optimization: keep the tests green (`integration-tests`).

## How an agent should apply this

- Classify the problem as one slow thing or many fast things before touching code.
- Walk the table top to bottom and stop at the first layer where the measurement explains the delay.
- Never add an index to fix a loop; never cache to hide a missing index.
- Hand over any production measurement to the owner; this order runs on a copy.
