# Trigger evals

Last verified 2026-11-27. Hand-written prompts, not a measured run.

Should trigger `postgres-diagnostics`:

1. "Run a health check on our Postgres 17 primary and tell me what looks risky."
2. "Replication lag keeps growing and disk is filling on the primary: which slot is holding WAL?"
3. "Which indexes on this Postgres 16 database look unused, duplicate or invalid?"

Near misses (expected owner in brackets):

1. "This one orders query takes 3 s, read its plan and fix it." [`query-performance`]
2. "Audit our app's database for exposure, backups and schema constraints." [`database-audit`]
3. "Health check for our SQL Server 2022 instance." [`sql-server-diagnostics`]
