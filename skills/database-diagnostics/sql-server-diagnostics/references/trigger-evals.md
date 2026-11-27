# Trigger evals: sql-server-diagnostics

Last verified 2026-11-27. Run in a fresh context, about 3 times each; a prompt passes at a trigger rate above 0.5.

## Should trigger

1. "Run a health check on our SQL Server 2022 instance and tell me what looks risky." Expected: `sql-server-diagnostics`.
2. "Top waits show PAGEIOLATCH_SH and LCK_M_X, how do I read that?" Expected: `sql-server-diagnostics` (waits reference).
3. "We are moving from SQL Server 2019 to 2025: which of these DMV queries break?" Expected: `sql-server-diagnostics` (porting guides).

## Near-misses (should not trigger)

1. "Write the audit report with severities and a sign-off verdict for this SQL Server." Expected: `sql-server-audit`.
2. "This Postgres query is slow, add the right index." Expected: `query-performance` or `postgres-diagnostics`.
3. "Prove our backups really restore into a scratch database." Expected: `backup-restore-drill`.
