---
name: query-performance
description: Use when pages or queries get slow as data grows, or before launch on a relational database - find the five most used queries, read their plans with EXPLAIN ANALYZE, add the missing indexes (including on foreign keys), replace queries inside loops, offset pagination and functions wrapped around indexed columns, and measure before and after. Use after the schema is right and the data is big enough to matter.
---

# Query performance

Measure first, change one thing, measure again. An index that is never used still costs time on every write. Per-call cost on usage-priced databases: `database-cost-guard`. Shared database rules: `database-audit`.

## Steps

1. **Find the five most used queries** (from the code, the logs or `pg_stat_statements`) plus any the owner calls slow. Done when each has `file:line` and its SQL.
2. **Measure on a realistic copy:** run `EXPLAIN ANALYZE` on each against the **development database** filled with production-sized, anonymized data. Record time and plan. A `Seq Scan` on a large table with a selective filter is the usual suspect.
3. **Write the findings:** for each query, what the plan shows and the smallest fix. Typical fixes:
   - an index on the filter, sort or join column, and on every **foreign key** column used in joins or deletes (PostgreSQL does not create these automatically);
   - a query inside a **loop** (N+1) replaced by a `JOIN` or an `IN` list;
   - `OFFSET` pagination replaced by a **cursor** (`where id > :last order by id limit n`);
   - a function that **wraps** an indexed column (`lower(email)`, `date(created_at)`) replaced by an expression index or a rewritten condition;
   - `count(*) > 0` used only to test existence replaced by `EXISTS` (and `NOT IN (subquery)` by `NOT EXISTS`, which also handles NULLs).
4. **Apply one fix at a time** as a migration. Create indexes with `CREATE INDEX CONCURRENTLY` on a live table so writes are not blocked, in a migration of its own marked non-transactional for your tool (many wrap each migration in a transaction); it cannot run inside a transaction block, and a failed run leaves an invalid index to drop and retry (PostgreSQL documentation).
5. **Measure again** with `EXPLAIN ANALYZE` and report before and after for each query.

## Rules

- Every added index **slows writes** a little and uses disk: justify each by a measured query.
- Production is never queried or altered by this skill; it hands over the statements.
- Do not rewrite business logic to gain speed; ask first.
- This skill does not create data; use a copy or generated rows, and say which.
- The statistics in the lesson (a large drop in milliseconds on millions of orders) are the author's, not measured here.

Source: the handout of the second database lesson of mano deyvin (prompt "the slow page").
