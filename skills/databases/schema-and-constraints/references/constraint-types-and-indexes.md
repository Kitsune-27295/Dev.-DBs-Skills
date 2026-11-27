# Constraint types, their edge cases and the indexes they imply

Sources: PostgreSQL docs https://www.postgresql.org/docs/current/ddl-constraints.html and https://www.postgresql.org/docs/current/sql-altertable.html (both re-read 2026-11-27; the pages served were the PostgreSQL 19 docs); author's handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, section "1. Modelagem e constraints" · Last verified 2026-11-27

## The idea

A constraint is a rule stored in the database that rejects any write breaking it, whether it comes from the app, a script, an AI tool or an admin session. Code validation does not always run (handout); front-end validation saves a round trip but does not replace validation on the server or in the database.

## Types as the documentation describes them

| Type | What it enforces | Edge cases to know | Index created? |
|---|---|---|---|
| NOT NULL | Column never null | Equivalent to `CHECK (col IS NOT NULL)` but more efficient | No |
| UNIQUE | No duplicates | NULLs are distinct by default, so duplicates containing NULL pass; `NULLS NOT DISTINCT` changes that | Yes (unique B-tree) |
| PRIMARY KEY | Unique and not null, one per table | The docs recommend one; PostgreSQL does not require it | Yes (unique B-tree) |
| CHECK | A boolean expression per row | Passes when the result is true or NULL; cannot see other rows or tables; assumed immutable, so a function whose behavior changes can leave rows violating it unnoticed | No |
| FOREIGN KEY | Value must exist in the referenced table | A null in a referencing column skips the check unless `MATCH FULL` (declare the columns `NOT NULL` to prevent skipping altogether) | No (referencing side) |
| EXCLUSION | No two rows satisfy given operator comparisons (e.g. overlapping ranges) | Needs a suitable index type | Yes |

Foreign key actions: `NO ACTION` (default; checked at statement end, can be deferred), `RESTRICT` (immediate, not deferrable), `CASCADE` (delete or update the children), `SET NULL`, `SET DEFAULT`. `ON DELETE SET NULL` accepts a column list (so a tenant column stays intact); `ON UPDATE` does not. Choose deliberately: cascade is convenient and also deletes more than expected.

## Adding a rule to a table that already has rows

- `NOT VALID` on `ADD CONSTRAINT` skips the check of existing rows; new writes are checked at once. The ALTER TABLE page (PostgreSQL 19) allows it for foreign-key, `CHECK` and not-null constraints, not for `UNIQUE` or `PRIMARY KEY`. Whether not-null `NOT VALID` exists in older versions was not checked: read your version's page.
- `VALIDATE CONSTRAINT` scans for violations under `SHARE UPDATE EXCLUSIVE`, which does not block concurrent updates (a foreign key also needs `ROW SHARE` on the referenced table). Plain `ADD FOREIGN KEY` takes `SHARE ROW EXCLUSIVE` on both tables; most other `ADD` forms take `ACCESS EXCLUSIVE`.
- Unique or primary key without a long lock: build `CREATE UNIQUE INDEX CONCURRENTLY` first, then `ADD CONSTRAINT ... USING INDEX` (the index must be a plain b-tree, not partial, no expressions; not supported on partitioned tables; for a primary key, columns not yet `NOT NULL` need a full scan).
- Rollout order and the large-table playbook belong to `parallel-change-expand-contract`.

## The index asymmetry

Referenced columns always have an index (they are a primary key or unique); the referencing column does not get one from the foreign key declaration, and the docs recommend indexing it because deletes and updates on the referenced table scan the referencing table. The rule and the fix are owned by `query-performance`.

## Example: rule in the database, not only the code

```sql
CREATE TABLE orders (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id bigint NOT NULL REFERENCES customers(id),
  total_cents integer NOT NULL CHECK (total_cents >= 0),
  created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX orders_customer_id_idx ON orders (customer_id);
-- count rows that would already break a new rule (read-only)
SELECT count(*) FROM orders o LEFT JOIN customers c ON c.id = o.customer_id WHERE c.id IS NULL;
```

A rule that applies to only some rows ("one active subscription per user") cannot be a unique constraint; the docs point to a unique partial index.

## How an agent should apply this

- For every relation without a foreign key, every must-have column without `NOT NULL`, every natural identifier without `UNIQUE` and every bounded value without `CHECK`, write the proposed constraint and count existing violations first.
- Remember `UNIQUE` on a nullable column does not block duplicate NULLs; say so when it matters.
- Pair each new foreign key with an index on the referencing column, or state why not.
- Pick `ON DELETE` behavior explicitly and explain the risk of `CASCADE`.
- Do not delete or alter rows to make a constraint pass; report and let the owner choose.
