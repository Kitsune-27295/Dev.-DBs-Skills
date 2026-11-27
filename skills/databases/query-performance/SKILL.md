---
name: query-performance
description: "Make slow relational queries fast, with evidence, once the schema is right: find the handful of most used or slowest queries, read each plan with EXPLAIN ANALYZE on a realistic development copy, then apply the smallest fix (missing index including foreign keys, loop replaced by a join, keyset instead of offset paging, function wrapped around an indexed column, EXISTS instead of counting) and measure before and after. Covers PostgreSQL first. Use when a page, list or report slows down as data grows or before launch. Not for a whole-server health check (use postgres-diagnostics), end-to-end page or job slowness across layers (use application-performance), or a usage-priced database bill (use database-cost-guard)."
---

# Query performance

One idea: **measure first, change one thing, measure again.** An index that no query uses still costs time on every write. Sources and unverified claims: [references/sources.md](references/sources.md). Per-call cost on usage-priced databases belongs to `database-cost-guard`; shared database rules to `database-audit`; constraints and keys to `schema-and-constraints`.

> **Scope boundary:** this skill owns query-level tuning on a copy of the data. Server-wide health (locks, pooling, vacuum, settings) is `postgres-diagnostics`. A slow screen with no known slow query starts at [end-to-end triage](references/end-to-end-triage-order.md) and may belong to `application-performance`.

## 1. Find the queries

List the five most used queries (code, logs, or the statements view `pg_stat_statements`) plus any the owner calls slow. Done when each has `file:line` and its SQL. The statements view needs the module in `shared_preload_libraries` (a restart) and query ids enabled; its figures cover the window since the last reset, so say which window you read.

## 2. Measure on a realistic copy

Run `EXPLAIN ANALYZE` on each query against a **development database** with production-sized, anonymized data, never production. Record time and plan. Mind three facts from the PostgreSQL documentation: the statement really runs, so wrap `INSERT`, `UPDATE`, `DELETE` and `MERGE` in `BEGIN` ... `ROLLBACK`; reported times are per loop, so multiply by `loops`; and a large gap between estimated and actual rows is the first thing to check. A sequential scan is correct when most rows are needed or the table is tiny. How to read the output: [references/query-rewrites-and-explain-reading.md](references/query-rewrites-and-explain-reading.md).

## 3. Write the finding, then the smallest fix

For each query: what the plan shows and one fix.

- **Missing index** on the filter, sort or join column, and on every **foreign key** column used in joins or parent deletes: PostgreSQL indexes primary and unique keys, not the referencing side of a foreign key ([references/missing-foreign-key-index.md](references/missing-foreign-key-index.md)).
- **Query in a loop (N+1):** one `JOIN` or `= ANY($1)`.
- **Large `OFFSET`:** skipped rows are still computed, so use keyset paging with a unique tie-breaker; composite, partial, covering and expression index rules are in [references/pagination-and-index-design.md](references/pagination-and-index-design.md).
- **Function around an indexed column** (`lower(email)`, `date(created_at)`): rewrite as a range, or add an expression index that uses the same expression.
- **Existence test with `count(*) > 0`:** `EXISTS`; `NOT IN (subquery)`: `NOT EXISTS` (NULL-safe, and it can become an anti-join).
- **Policy-protected table, bulk import or insert-or-update:** [references/rls-bulk-writes-and-upserts.md](references/rls-bulk-writes-and-upserts.md).

## 4. Apply one fix at a time, as a migration

Create indexes on a live table with `CREATE INDEX CONCURRENTLY`, in a migration of its own marked non-transactional for your tool: it cannot run inside a transaction block. It does not block writes, but it scans the table twice, only one concurrent build runs per table, and it is not supported on a partitioned parent (build each partition, then the parent non-concurrently). A failed run leaves an `INVALID` index that still costs writes: drop it and retry. Run `ANALYZE` after a new expression index.

## 5. Measure again

Re-run the same `EXPLAIN ANALYZE` and report before and after for each query, with the command that produced both. Keep the tests green: a faster wrong answer is not a fix.

## Rules

- Justify every index by a named, measured query; each one slows writes and uses disk.
- Production is never queried or altered by this skill; it hands over the statements.
- Do not rewrite business logic for speed without asking.
- This skill creates no data: use a copy or generated rows and say which.
- The millisecond figures in the source lesson (58 ms to 0.37 ms and similar) are the author's claims, not reproduced here: never quote them as findings.

## Quick Decision Checklist

- [ ] Do I have the most used queries plus any reported slow, each with `file:line` and SQL?
- [ ] Did I run `EXPLAIN ANALYZE` on a realistic development copy, with writes wrapped in a rolled-back transaction?
- [ ] Do joined and deleted foreign key columns have an index?
- [ ] Did I check N+1, `OFFSET`, wrapped columns and `count(*) > 0`?
- [ ] Is each index justified by a measured query?
- [ ] One fix per migration, indexes with `CONCURRENTLY` in their own non-transactional migration?
- [ ] Did I re-measure and report before and after?

## Deep references

- [Sources and caveats](references/sources.md) — which claims were verified on 2026-11-27 and which are not adopted
- [The missing foreign key index](references/missing-foreign-key-index.md) — a join or lookup on a foreign key is slow, or you audit foreign keys
- [Query rewrites and reading the plan](references/query-rewrites-and-explain-reading.md) — reading `EXPLAIN ANALYZE` or rewriting a slow pattern
- [Pagination and index design](references/pagination-and-index-design.md) — replacing offset paging or choosing composite, partial, covering or expression indexes
- [RLS speed, N+1, bulk loading and upserts](references/rls-bulk-writes-and-upserts.md) — a policy-protected table is slow, you hunt N+1, import data or write insert-or-update
- [End-to-end triage order](references/end-to-end-triage-order.md) — a screen is slow and the layer is unknown
- [PostgreSQL coverage gap table](references/postgres-coverage-gap-table.md) — which skill owns a Postgres topic (locks, pooling, upserts, RLS, partitioning)
- [Trigger evals](references/trigger-evals.md) — should-trigger and near-miss prompts for tuning the description
