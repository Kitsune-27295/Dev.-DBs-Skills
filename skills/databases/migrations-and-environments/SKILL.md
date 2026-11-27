---
name: migrations-and-environments
description: "Put database changes under version control and keep development away from production: numbered migration files, a baseline for an existing schema, a drift check, one database and one environment variable per environment, an application user with least privilege, and a guard that stops destructive commands from targeting production. Reports first, never runs anything against production. Not for rolling out a breaking rename or type change with zero downtime (use parallel-change-expand-contract), reviewing the schema design (use schema-and-constraints) or backups (use backup-restore-drill). Use when someone edits the schema by hand in a console, when development and production share a database or credential, or before the first real user."
---

# Migrations and environments

Two rules: every schema change is a numbered file in the repository, and a command run on a laptop can never reach production data. The lesson's cautionary case is an AI coding agent that deleted a production database (the SaaStr founder's account as reported by The Register; Replit's side is unreported in the article). Shared database rules: `database-audit`. Source handling: [references/sources.md](references/sources.md).

## 1. Steps (report first)

1. **How does the schema change today?** Name the migration tool (Prisma, Alembic, Flyway, Knex, Rails, plain SQL) or say there is none (then propose the simplest one for the stack), and how many changes were made by hand in a console. Done when each is named.
2. **Environments.** Which databases exist (development, staging, production), which **environment variable** points the app at each, and whether any two share a database or a credential. Find every place a connection string is chosen.
3. **Drift.** Compare the live schema with what the migration files produce, using the tool's drift or diff command on a copy (Prisma's `migrate dev` detects drift with a shadow database; `migrate deploy` does not). Report every difference.
4. **Baseline.** If there is no history, create a baseline migration from the current schema, numbered first, and mark it as already applied on existing databases (Prisma: `migrate diff` to generate it, `migrate resolve --applied` to record it). If history exists but drifted, write a migration that brings the files level with the live schema without losing data. Later changes are numbered files, one change each.
5. **Least privilege.** The user the running app connects with gets only the `grant` it needs (select, insert, update, delete on its tables), never ownership: in PostgreSQL the right to alter or drop an object comes with owning it and cannot be granted. Migrations run under a separate, owner-level credential used only by the migration step.
6. **Guard production.** Propose a check so destructive commands refuse to run when the target is production (a required confirmation, a different variable name, a read-only default). The generic destructive-action gate is `ops-safety`.

## 2. Rules

- **Default to the development** database in every script and example; production needs an explicit, separate step.
- Never run a migration against production yourself: hand the owner the command and its expected effect; the owner runs it.
- A migration already applied is never edited; add a new one (Flyway's docs give the same advice once a migration reached a permanent environment; Prisma warns about modified applied migrations).
- Never drop a column, index or table that exists only in the live database without the owner's OK.
- Show the plan and the environment table before creating or changing files.
- Objects the ORM cannot express (checks, filtered indexes, denies) are reconciled in SQL and verified from the catalog after a table rebuild; never verify a change against a shared database unless asked, and refuse push or reset commands there (see the ORM-gaps reference).
- Backups are `backup-restore-drill`; tests of migrations use a throwaway database, see `integration-tests`.

Source: the handout of the second database lesson of mano deyvin (prompt "migrations and separate environments"); tool and catalog facts were re-checked against vendor documentation on 2026-11-27.

## Quick Decision Checklist

- [ ] Is every schema change a numbered file, with the migration tool named or the simplest one proposed?
- [ ] Do I know which databases exist and whether any two share a database or credential?
- [ ] Have I compared the live schema with the migration files and reported every drift?
- [ ] Do scripts and examples default to the development database, with production a separate explicit step?
- [ ] Does the app user have only the grants it needs, with migrations under a separate owner-level credential?
- [ ] Am I leaving migrations against production to the owner and never editing an applied migration?
- [ ] Will I avoid dropping live-only objects without the owner's OK, and show the plan first?

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were re-verified and which are the lesson's own
- [Migrations, drift and environment separation](references/migrations-drift-and-environment-separation.md) — when you set up baselines, drift checks, dev/prod split or an app role
- [DDL an ORM cannot express, and shared databases](references/orm-gaps-and-shared-databases.md) — when a table rebuild may drop hand-written constraints or someone wants to test a change on a shared database
- [Trigger evals](references/trigger-evals.md) — when you tune the description or check whether a request belongs here or to a neighbor
