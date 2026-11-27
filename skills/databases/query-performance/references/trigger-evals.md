# Trigger evals

Last verified 2026-11-27

Should trigger `query-performance`:

1. "My orders list takes 4 seconds now that the table has 5 million rows. Find out why." (plan reading, index)
2. "Page 800 of our paginated feed is very slow, page 1 is fine." (offset to keyset)
3. "Review these ten SQL queries before launch and tell me which indexes are missing, including foreign keys."

Near-miss, belongs elsewhere:

1. "Is my Postgres server healthy? Check locks, connections and vacuum." Expected: `postgres-diagnostics`.
2. "The checkout page is slow; I do not know if it is the database, the API or the browser." Expected: `application-performance`.
3. "My Firestore bill tripled; find the reads inside loops." Expected: `database-cost-guard`.
