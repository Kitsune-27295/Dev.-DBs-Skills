# DDL an ORM cannot express, and shared databases

Sources: https://www.prisma.io/docs/orm/prisma-schema/data-model/unsupported-database-features · https://www.prisma.io/docs/orm/prisma-migrate/workflows/customizing-migrations · https://www.prisma.io/docs/orm/prisma-migrate/workflows/prototyping-your-schema · https://www.prisma.io/docs/orm/prisma-migrate/workflows/development-and-production · https://www.postgresql.org/docs/current/catalog-pg-constraint.html · https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-indexes-transact-sql · https://learn.microsoft.com/en-us/sql/relational-databases/indexes/create-filtered-indexes (all re-read 2026-11-27) · Two lessons taken from an internal project (method only; no names, hosts or pipelines) · Last verified 2026-11-27

## Lesson 1: reconcile what the ORM cannot express, then check the catalog

A schema file written for an ORM describes only what that ORM models. Constraints, filtered or partial indexes, permissions such as `DENY` and similar objects may live outside it, in hand-written SQL inside a migration. Support differs by tool and version. The Prisma page read says views cannot be represented in the schema (include them in a migration), unsupported column types use `Unsupported("...")` and are not available in the generated client, native database functions use `dbgenerated(...)`, and partial indexes are supported through a `where` argument. It does not mention `CHECK` constraints, so test your tool and version. Its migration-editing guide shows editing a draft created with `--create-only` to replace a destructive drop-and-recreate with a rename; the staged rename pattern itself is `parallel-change-expand-contract`.

The risk: an operation that rebuilds a table from the model (a recreate, a diff that drops and re-adds) silently loses objects the model does not know. Rules:

1. Keep every hand-written object in a versioned SQL file that runs after the ORM step, and re-apply it in each migration that recreates a table.
2. Verify from the catalog, not from the migration text. PostgreSQL `pg_constraint` lists constraints with `contype` codes `c` check, `f` foreign key, `n` not-null, `p` primary key, `u` unique, `t` constraint trigger, `x` exclusion (the not-null code is in the version 19 page; older versions may lack it). `pg_get_constraintdef()` is the documented way to read a check definition, and `convalidated` shows whether a `NOT VALID` constraint was validated. In SQL Server, `sys.indexes` has `has_filter` and `filter_definition`; a filtered index indexes only the rows matching a predicate, and filters cannot be applied to primary key or unique constraints (they can to `UNIQUE` indexes). Catalog views for check constraints and permissions on SQL Server were not read.
3. Compare the catalog result with a list of the objects that must exist, after every table rebuild.

```sql
-- PostgreSQL: expected check constraints on one table
SELECT conname, convalidated, pg_get_constraintdef(oid)
FROM pg_constraint WHERE conrelid = 'orders'::regclass AND contype = 'c';
```

## Lesson 2: never verify against a shared database unless asked

"Run it just to see" is not a dry run on a shared database. A migration, a schema push or a database-backed test writes to state other people use. Rules:

- Verify a change with the generated SQL and a review of it; say in the change description that the migration was not applied.
- Run a migration or a database test only when the owner asked, and only against a throwaway database.
- Refuse the quick-sync command on a shared database. Prisma's docs: `db push` is for prototyping, creates no migration history, errors on possible data loss unless `--accept-data-loss` is passed, and is not recommended for changes that must reach other environments; `migrate reset` is development-only and drops and recreates the database or schema (the earlier wording "total data loss" was not on the pages read). Wire the refusal into the script, not into memory: a wrapper that exits with an error when the target is not the local one.

## How an agent should apply this

- List, per table, the objects the ORM model does not carry; keep them in versioned SQL.
- After any rebuild, query the catalog and show the owner the result.
- Prepare the migration command and its expected effect; never apply it to a shared database without being asked.
- Propose a script-level refusal for push or reset commands when the target is shared.
