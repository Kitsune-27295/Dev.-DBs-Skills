# DDL an ORM cannot express, and shared databases

Sources: https://www.prisma.io/docs/orm/prisma-schema/data-model/unsupported-database-features · https://www.prisma.io/docs/orm/prisma-migrate/workflows/customizing-migrations · https://www.prisma.io/docs/orm/prisma-migrate/workflows/prototyping-your-schema · https://www.postgresql.org/docs/current/catalog-pg-constraint.html · https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-indexes-transact-sql · Last verified 2026-11-24 · Two lessons taken from internal project skills (method only; no names, hosts or pipelines)

## Lesson 1: reconcile what the ORM cannot express, then check the catalog

A schema file written for an ORM describes only what that ORM models. Constraints, filtered or partial indexes, permissions such as `DENY` and similar objects may live outside it, in hand-written SQL inside a migration. Support differs by tool and version: the Prisma page read says views cannot be represented, that unsupported column types and database functions need special syntax, and that partial indexes are now supported through a `where` argument; it does not mention `CHECK` constraints. Do not assume; test your tool and version.

The risk: any operation that rebuilds a table from the model (an ORM-generated recreate, a diff that drops and re-adds) silently loses the objects the model does not know about. Rules:

1. Keep every hand-written object in a versioned SQL file that runs after the ORM step, and re-apply it in each migration that recreates a table.
2. Verify from the catalog, not from the migration text. In PostgreSQL, `pg_constraint` lists check, unique, primary, foreign and exclusion constraints (`contype` codes `c`, `u`, `p`, `f`, `x`) and `pg_get_constraintdef()` shows a definition; its `convalidated` flag shows whether a `NOT VALID` constraint was ever validated. In SQL Server, `sys.indexes` has `has_filter` and `filter_definition` for filtered indexes (the catalog views for check constraints and permissions were not read for this file).
3. Compare the catalog result with a list of the objects that must exist, after every table rebuild.

```sql
-- PostgreSQL: expected check constraints on one table
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint WHERE conrelid = 'orders'::regclass AND contype = 'c';
```

## Lesson 2: never verify against a shared database unless asked

"Run it just to see" is not a dry run when the database is shared. A migration, a schema push or a database-backed test writes to state other people use. Rules:

- Verify a change with the generated SQL and a review of it; say in the change description that the migration was not applied.
- Run a migration or a database test only when the owner asked, and only against a throwaway database.
- Refuse the quick-sync command on a shared database. For Prisma the documentation says `db push` leaves no migration history, can need `--accept-data-loss`, and is meant for local prototyping, not production or sharing schema changes; `migrate reset` is stated to cause total data loss. Wire the refusal into the script, not into memory: a wrapper that exits with an error when the target is not the local one.

## How an agent should apply this

- List, per table, the objects the ORM model does not carry; keep them in versioned SQL.
- After any rebuild, query the catalog and show the owner the result.
- Prepare the migration command and its expected effect; never apply it to a shared database without being asked.
- Propose a script-level refusal for push or reset commands when the target is shared.
