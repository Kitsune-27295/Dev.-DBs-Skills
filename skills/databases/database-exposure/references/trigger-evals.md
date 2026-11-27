# Trigger evals

Last verified 2026-11-27

Should trigger `database-exposure`:

1. "We launch Friday on Supabase. Can strangers read our tables with the anon key?"
2. "Is port 5432 on my VPS open to the world? Check pg_hba.conf and the firewall."
3. "Did I ever commit the service key to git? List what to rotate."

Near-miss, belongs elsewhere:

1. "The price and the discount are computed in the React app; move them to the server." Expected: `never-trust-the-client`.
2. "Review how our RLS policies isolate tenants, including joins and views." Expected: `security-audit`.
3. "Prove that last night's backup restores." Expected: `backup-restore-drill`.
