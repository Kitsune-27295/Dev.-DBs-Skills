# Trigger evals

Last verified 2026-11-27

Should trigger `backup-restore-drill`:

1. "We back up Postgres every night to the same VPS. Is that enough? Nobody has restored it."
2. "Write a daily pg_dump script and a test that restores it and compares row counts."
3. "Our managed database says backups are on. How do I know they work before the migration?"

Near-miss, belongs elsewhere:

1. "I am about to run DROP TABLE on production; show me what I would lose." Expected: `ops-safety`.
2. "Check the backup history and log chain health of our SQL Server instance." Expected: `sql-server-diagnostics`.
3. "Write the postmortem for last week's outage." Expected: `blameless-postmortem`.
