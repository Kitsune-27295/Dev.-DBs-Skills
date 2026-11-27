# Trigger evals

Last verified 2026-11-27. Mental test of the description against six prompts.

Should trigger `sqlite-diagnostics`:
1. "Our app.db is 4 GB after deleting millions of rows; where is the space?" (size and free-space scripts)
2. "PRAGMA integrity_check printed a few rows, what do they mean and what next?"
3. "Check this SQLite file for orphan rows and missing indexes before we migrate, read-only."

Near-misses (expected owner):
1. "This query on SQLite is slow, why?" -> `query-performance` (EXPLAIN QUERY PLAN on the statement).
2. "Add foreign keys and NOT NULL to our SQLite schema." -> `schema-and-constraints`.
3. "Prove we can restore our SQLite backup." -> `backup-restore-drill`.
