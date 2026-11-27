# Trigger Evals

Last verified 2026-11-27. Starting points for a description check, not a measured result.

## Should trigger (this skill)
1. "Should I create a GenericRepository<T> with GetAll and Update for every table?"
2. "Where should SaveChanges be called: in the repository, the handler or the controller?"
3. "Write in-memory fake repositories and tests that keep them honest against Postgres."

## Near-misses (other skill)
1. "This query scans 40M rows; add the right index." -> `query-performance`
2. "Design the orders table constraints and foreign keys." -> `schema-and-constraints`
3. "Our transaction deadlocks and rolls back half a write; find out why." -> `transaction-fix`
