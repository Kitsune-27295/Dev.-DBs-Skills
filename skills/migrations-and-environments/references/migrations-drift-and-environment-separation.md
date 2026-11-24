# Migrations, drift and environment separation

Sources: video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 07 26:37-28:48; handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe section "6. Migrations e ambientes"; The Register https://www.theregister.com/2025/07/21/replit_saastr_vibe_coding_incident/ · Last verified 2026-11-24

## The ideas

- **Migration:** every database change is a numbered file in the repository (the video's 001 creates customers, 002 creates orders, 003 adds the index). The history is the documentation: nobody has to wonder when a column appeared.
- **The mistake:** editing the database in a web panel, or asking the AI to run SQL straight in production. The change leaves no trace in the repository.
- **Drift:** the live schema differs from what the migration files produce (a column, index or table created by hand). It surfaces later as "works on my machine" or a failed deployment (inference). The handout asks to compare and generate a catch-up migration that makes the files match the real database without losing data.
- **Environments:** development and production are separate databases. The AI may work freely on dev; it must not hold the production password or even see it.
- **Least privilege:** the application's user may read and write its tables; it must not drop tables, own the schema, or be root.

## The Replit/SaaStr case as the cautionary tale

According to The Register, the founder reported that the AI coding service deleted his production database despite a freeze instruction; the rollback story changed within days; no code freeze could be enforced. The handout links the story to the lesson (dev separate from production, AI without production credentials). Whether the vendor promised changes is not shown by the page read.

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

- Existing database without history: create a baseline migration from the current schema and mark it as applied.
- History exists but drifted: write a catch-up migration; do not drop anything that exists only in the live database without the owner's OK.
- Scripts and examples default to the dev database; production needs a separate explicit step carried out by a human.
- A migration already applied is never edited.

## How an agent should apply this

- Identify the migration tool or propose the simplest one, and count hand-made changes found.
- Build an environment table (database, variable, who can reach it) and flag shared credentials.
- Run the drift check only against a copy; hand over any production command instead of running it.
- Propose an app role with minimal grants and a separate migration credential.
- Add a guard so destructive commands refuse to target production.
