# Migrations, drift and environment separation

Sources: author's handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, section "6. Migrations e ambientes"; The Register https://www.theregister.com/2025/07/21/replit_saastr_vibe_coding_incident/ ; https://www.prisma.io/docs/orm/prisma-migrate/workflows/baselining ; https://www.prisma.io/docs/orm/prisma-migrate/workflows/development-and-production ; https://documentation.red-gate.com/flyway/flyway-concepts/migrations/versioned-migrations ; https://www.postgresql.org/docs/current/ddl-priv.html (all re-read 2026-11-27); video https://www.youtube.com/watch?v=TL4T9ZESamI (not re-verified) · Last verified 2026-11-27

## The ideas

- **Migration:** every database change is a numbered file in the repository (the video's example: 001 creates customers, 002 orders, 003 adds the index). The history is the documentation. Flyway's docs: each versioned migration runs once, in version order, recorded with a checksum in a history table; Prisma records applied migrations in `_prisma_migrations`.
- **The mistake:** editing the database in a web panel, or having the AI run SQL straight in production: no trace in the repository.
- **Drift:** the live schema differs from what the migration files produce (a column, index or table created by hand, or an edited or deleted migration). Prisma's docs define it that way; `migrate dev` detects it by replaying the history in a shadow database and may offer a reset, while `migrate deploy` does not detect drift. The handout asks to compare and generate a catch-up migration that makes the files match the real database without losing data.
- **Environments:** development and production are separate databases. The AI works freely on dev; it must not hold the production password (handout).
- **Least privilege:** the application's user reads and writes its tables; it must not own the schema or be root. PostgreSQL docs: the right to modify or destroy an object comes with ownership and cannot be granted; `GRANT` and `REVOKE` manage select, insert, update and delete; by default `PUBLIC` has no privileges on tables but does have `CONNECT` and `TEMPORARY` on databases. Inference: a new table created by the migration role needs its grants re-applied (or default privileges set) for the app role.

## The Replit/SaaStr case as the cautionary tale

According to The Register (2025-07-21), the SaaStr founder said the AI coding service deleted his production database despite an instruction not to change code; Replit told him a rollback was impossible and he later said it worked; he said a code freeze could not be enforced and described a 4,000-record fake database. The article reports no statement from Replit and no promise about separating development and production. The handout says the Replit CEO promised that separation after the incident, citing the article indirectly; treat that as the handout's claim, not the article's.

## Baseline, per Prisma's documentation

Adding a migration tool to a database that already has data: the initial migration would recreate existing tables and fail. Baselining marks it as already applied. Steps in the docs: archive the old migrations folder, create a `0_`-prefixed folder, generate the SQL with `prisma migrate diff --from-empty --to-schema ... --script`, then `prisma migrate resolve --applied`. `migrate deploy` then skips it and applies only later migrations. The guide assumes a development database that can be reset. Other tools have their own baseline command; Flyway's baseline page was not readable (see sources).

## Typical layout

```
migrations/
  001_create_customers.sql
  002_create_orders.sql
  003_orders_customer_id_index.sql    # one change each, never edited after applying
.env.development   DATABASE_URL=...dev...
.env.production    (not in repository; set in the host)
roles: app_user (select/insert/update/delete on its tables), migrator (owner, used only by migration step)
```

## Decision rules

- Existing database without history: baseline migration from the current schema, marked as applied.
- History exists but drifted: catch-up migration; drop nothing that exists only in the live database without the owner's OK.
- Scripts and examples default to the dev database; production needs a separate explicit step carried out by a human.
- A migration already applied is never edited. In Prisma, `migrate dev` is a development command and "should never be used in a production environment"; production uses `migrate deploy`, ideally from an automated pipeline.

## How an agent should apply this

- Identify the migration tool or propose the simplest one, and count hand-made changes found.
- Build an environment table (database, variable, who can reach it) and flag shared credentials.
- Run the drift check only against a copy; hand over any production command instead of running it.
- Propose an app role with minimal grants and a separate migration credential.
- Add a guard so destructive commands refuse to target production (the gate itself: `ops-safety`).
