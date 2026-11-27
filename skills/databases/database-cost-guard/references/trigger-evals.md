# Trigger evals

Last verified 2026-11-27

Should trigger `database-cost-guard`:

1. "We launch on Firestore next week. Will the bill explode if we get ten times the users?"
2. "My Firebase bill tripled; find the reads inside loops and listeners."
3. "Set a spending limit that actually stops the app from running up a bill."

Near-miss, belongs elsewhere:

1. "Page 800 of our Postgres feed is slow; page 1 is fine." Expected: `query-performance`.
2. "Checkout is slow and I do not know whether it is the database, API or browser." Expected: `application-performance`.
3. "Can strangers read our Firestore collections?" Expected: `database-exposure`.
