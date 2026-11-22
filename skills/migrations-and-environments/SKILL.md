---
name: migrations-and-environments
description: Use to put database changes under version control and separate development from production - a migration tool with numbered files, a baseline for the existing schema, a drift check, separate environment variables and databases per environment, and an application user with least privilege. Use when someone edits the schema by hand, when development and production share a database, or before the first real user.
---

# Migrations and environments

Two rules: every schema change is a numbered file in the repository, and a command run on a laptop can never reach production data. The lesson's cautionary case is an AI coding agent that deleted a production database (the SaaStr founder's account, reported by The Register; Replit's response was not verified). Shared database rules: `database-audit`.

## Steps (report first)

1. **How does the schema change today?** Name the migration tool (Prisma, Alembic, Flyway, Knex, Rails, plain SQL) or say there is none (then propose the simplest one for the stack), and how many changes were made by hand in a console. Done when each is named.
2. **Environments.** Which databases exist (development, staging, production), which **environment variable** points the app at each, and whether any two share a database or a credential. Find every place a connection string is chosen.
3. **Drift.** Compare the live schema with what the migration files produce (the tool's drift or diff command, run on a copy). Report every difference.
4. **Baseline.** If there is no history, create a baseline migration from the current schema, numbered first, and mark it as already applied on existing databases. If history exists but drifted, write a migration that brings the files level with the live schema without losing data. Later changes are **numbered** files, one change each.
5. **Least privilege.** The user the running app connects with gets only the `grant` it needs (select, insert, update, delete on its tables), never ownership and never the right to drop or alter. Migrations run under a separate, owner-level credential used only by the migration step.
6. **Guard production.** Propose a check so destructive commands refuse to run when the target is production (a required confirmation, a different variable name, a read-only default).

## Rules

- **Default to the development** database in every script and example; production needs an explicit, separate step.
- Never run a migration against production yourself: hand the owner the command and its expected effect; the owner runs it.
- A migration already applied is never edited; add a new one.
- Never drop a column, index or table that exists only in the live database without the owner's OK.
- Show the plan and the environment table before creating or changing files.
- Backups are `backup-restore-drill`; tests of migrations use a throwaway database, see `integration-tests`.

Source: the handout of the second database lesson of mano deyvin (prompt "migrations and separate environments").
