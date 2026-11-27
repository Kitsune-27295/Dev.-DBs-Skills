# Trigger evals: schema-and-constraints

Last verified 2026-11-27 (mental test against the description; not run in a host).

## Should trigger

1. "Customers keep ending up with two profiles and some orders point to users that no longer exist. Fix the schema." -> `schema-and-constraints`
2. "Review my Prisma-generated Postgres tables: prices are Float and created_at has no timezone." -> `schema-and-constraints`
3. "Design the tables for invoices and payments so bad data can't get in." -> `schema-and-constraints`

## Near-misses

1. "The invoices page is slow once we passed a million rows." -> `query-performance`
2. "Rename orders.total to total_cents with zero downtime." -> `parallel-change-expand-contract`
3. "Set up numbered migrations and a separate dev database." -> `migrations-and-environments`
