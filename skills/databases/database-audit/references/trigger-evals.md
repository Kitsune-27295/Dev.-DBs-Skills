# Trigger evals: database-audit

Last verified 2026-11-27 (mental test against the description; not run in a host).

## Should trigger

1. "Launch is next week. Can you X-ray my Supabase app's database and tell me what to fix first?" -> `database-audit`
2. "We keep orders and payments in Firestore. Stay, or move to Postgres?" -> `database-audit` (choice note, no migration)
3. "Write a DB-AUDIT report for this repo: backups, constraints, migrations, slow queries." -> `database-audit`

## Near-misses

1. "Audit my app for missing tests, race conditions and prices computed in the browser." -> `fundamentals-audit`
2. "Audit this SQL Server instance: waits, VLFs, missing indexes, with severity per finding." -> `sql-server-audit`
3. "The orders list takes 4 seconds; find the right index." -> `query-performance`
