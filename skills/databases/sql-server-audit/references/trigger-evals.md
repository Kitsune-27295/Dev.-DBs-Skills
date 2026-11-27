# Trigger Evals

Last verified 2026-11-27. Starting points for a description check, not a measured result.

## Should trigger (this skill)
1. "Audit our production SQL Server before the renewal and give me a report I can hand to the CIO."
2. "Here is sp_Blitz output from a customer. Which findings are real, and how bad are they?"
3. "I collected these DMV results; turn them into a ranked remediation plan, with severity and confidence."

## Near-misses (other skill)
1. "Give me the read-only queries that show waits, VLFs and missing indexes on SQL Server 2022." -> `sql-server-diagnostics`
2. "Audit my app's database across exposure, backups, cost and migrations." -> `database-audit`
3. "Prove our backups restore and write the disaster runbook." -> `backup-restore-drill`
