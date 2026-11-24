# The missing foreign key index

Sources: PostgreSQL docs https://www.postgresql.org/docs/current/ddl-constraints.html; video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 04 15:50-21:28; handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe section "3. Performance" · Last verified 2026-11-24

## The case

A "my orders" screen runs `select id, total, created_at from orders where customer_id = 42`. `orders.customer_id` is a foreign key. Without an index the engine reads the table row by row (the lesson's image: the bakery owner leafing through the whole notebook for every "42"). With a B-tree index it jumps to the matching rows, like a book index sending you to page 82.

Why it is easy to miss: PostgreSQL builds an index for you on primary keys and unique constraints, but not on the referencing side of a foreign key. The documentation says why: deletes or updates on the referenced table need a scan of the referencing table, so indexing it is often wise, but it is not always needed and there are several index choices, so the declaration alone does not create one. The video's point: AI-generated schemas often declare the foreign key and stop there.

## The author's measurement (a claim, not reproduced)

On 5 million orders, the lookup went from 58 ms to 0.37 ms after one `CREATE INDEX`. Even a single-user 58 ms looks harmless, the author argues, but it becomes a capacity problem when many users load the page at once, and the fix can postpone a server upgrade. Treat the numbers as the author's.

## Two costs of the fix

- The index uses disk and every insert or update on the table must maintain it. The lesson is explicit: do not index every column.
- On a large live table, build it with `CREATE INDEX CONCURRENTLY` (the handout asks to warn the owner first). This is the lesson's rule; the cannot-run-inside-a-transaction detail is general PostgreSQL knowledge.

## Also affects deletes

Deleting a customer forces the engine to check `orders` for children; without the index that check scans the table. So the same index speeds writes on the parent table (documentation point).

## Example

```sql
-- find foreign keys with no index starting on the referencing column (sketch)
SELECT c.conrelid::regclass AS tbl, a.attname AS fk_column
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = c.conkey[1]
WHERE c.contype = 'f'
  AND NOT EXISTS (SELECT 1 FROM pg_index i
                  WHERE i.indrelid = c.conrelid AND i.indkey[0] = c.conkey[1]);
-- fix, as its own migration:
CREATE INDEX CONCURRENTLY orders_customer_id_idx ON orders (customer_id);
```

(The catalog query is my own sketch for single-column keys; verify on a copy.)

## How an agent should apply this

- List every foreign key whose referencing column has no index, starting here, before other tuning.
- Index only where a real join, lookup or delete path uses the column; justify each index by a query.
- Measure with `EXPLAIN ANALYZE` before and after on a realistic copy, never on production.
- Ship each index as its own migration; use `CONCURRENTLY` for big live tables and tell the owner first.
- Do not quote the author's millisecond numbers as findings.
