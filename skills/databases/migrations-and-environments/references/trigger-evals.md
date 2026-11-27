# Trigger evals: migrations-and-environments

Last verified 2026-11-27 (mental test against the description; not run in a host).

## Should trigger

1. "I've been adding columns through the Supabase dashboard and now staging and prod differ. Put this under version control." -> `migrations-and-environments`
2. "Cursor keeps running prisma commands against the same DATABASE_URL we use live. Separate dev from prod." -> `migrations-and-environments`
3. "We have an old Postgres with no migration history; set up Alembic with a baseline." -> `migrations-and-environments`

## Near-misses

1. "Rename users.name to full_name without downtime." -> `parallel-change-expand-contract`
2. "Money is stored as float and created_at has no time zone." -> `schema-and-constraints`
3. "Do our backups actually restore?" -> `backup-restore-drill`
