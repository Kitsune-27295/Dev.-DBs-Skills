# Constraint types, their edge cases and the indexes they imply

Sources: PostgreSQL docs https://www.postgresql.org/docs/current/ddl-constraints.html; video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 02 06:25-11:46 · Last verified 2026-11-24

## The idea

A constraint is a rule stored in the database that rejects any write breaking it, whether it comes from the app, a script, an AI tool or an admin session. The lesson's image: a doorman. Front-end validation (the video mentions Zod) saves a round trip; it does not replace validation on the server or in the database.

## Types as the documentation describes them

| Type | What it enforces | Edge cases to know | Index created? |
|---|---|---|---|
| NOT NULL | Column never null | Same as `CHECK (col IS NOT NULL)` but cheaper | No |
| UNIQUE | No duplicates | NULLs are not equal by default, so duplicates containing NULL pass; `NULLS NOT DISTINCT` changes that | Yes (unique B-tree) |
| PRIMARY KEY | Unique and not null, one per table | The docs note PostgreSQL does not force a table to have one | Yes (unique B-tree) |
| CHECK | A boolean expression per row | Passes when the result is true or NULL; cannot look at other rows or tables | No |
| FOREIGN KEY | Value must exist in the referenced table | Null in a referencing column skips the check unless `MATCH FULL` | No (on the referencing side) |
| EXCLUSION | No two rows satisfy given operator comparisons (e.g. overlapping ranges) | Needs a suitable index type | Yes |

Foreign key actions on delete or update: `NO ACTION` (default, checked at statement end, can be deferred), `RESTRICT` (immediate), `CASCADE` (delete or update the children), `SET NULL`, `SET DEFAULT`. Choose deliberately: cascade is convenient and also deletes more than expected.

## The index asymmetry

Referenced columns always have an index (they must be a primary key or unique); the referencing column does not get one from the foreign key declaration. The rule and the fix are owned by `query-performance`.

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

Partial uniqueness ("one active subscription per user") cannot be a unique constraint but can be a unique partial index (the docs say so).

## How an agent should apply this

- For every relation without a foreign key, every must-have column without `NOT NULL`, every natural identifier without `UNIQUE` and every bounded value without `CHECK`, write the proposed constraint and count existing violations first.
- Remember `UNIQUE` on a nullable column does not block duplicate NULLs; say so when it matters.
- Pair each new foreign key with an index on the referencing column, or state why not.
- Pick `ON DELETE` behavior explicitly and explain the risk of `CASCADE`.
- Do not delete or alter rows to make a constraint pass; report and let the owner choose.
