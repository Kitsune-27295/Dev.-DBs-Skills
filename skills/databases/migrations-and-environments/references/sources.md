# Sources — Migrations and environments

Every URL below was re-fetched on 2026-11-27 (summarizing WebFetch tool; Firecrawl unavailable).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, section "6. Migrations e ambientes" | 200 | The prompt: detect the tool, align migrations with the real schema without losing data, separate dev and prod config (agent defaults to dev), least-privilege user with GRANTs, delete nothing live-only without asking, nothing run in production |
| The Register, 2025-07-21, https://www.theregister.com/2025/07/21/replit_saastr_vibe_coding_incident/ | 200 | The founder's account of the deletion, rollback reversal, code-freeze claim, 4,000-record fake data; no Replit statement; no CEO promise |
| https://www.prisma.io/docs/orm/prisma-migrate/workflows/baselining | 200 | Baseline steps (`migrate diff`, `migrate resolve --applied`), dev-database assumption |
| https://www.prisma.io/docs/orm/prisma-migrate/workflows/development-and-production | 200 | `migrate dev` vs `migrate deploy`, shadow database, drift definition, `migrate reset` behavior |
| https://www.prisma.io/docs/orm/prisma-migrate/workflows/prototyping-your-schema | 200 | `db push`: no history, data-loss flag, prototyping only |
| https://www.prisma.io/docs/orm/prisma-migrate/workflows/customizing-migrations | 200 | `--create-only` draft edits (rename, expand and contract, 1-1 direction) |
| https://www.prisma.io/docs/orm/prisma-schema/data-model/unsupported-database-features | 200 | views unsupported, `Unsupported()`, `dbgenerated`, partial indexes via `where`; CHECK not mentioned |
| https://documentation.red-gate.com/flyway/flyway-concepts/migrations/versioned-migrations | 200 | applied once, in order, checksum history table, do not change migrations in permanent environments |
| https://documentation.red-gate.com/fd/baseline-migrations-273875979.html | 404 | nothing; Flyway baseline claims not adopted |
| https://www.postgresql.org/docs/current/ddl-priv.html | 200 | ownership not grantable, GRANT/REVOKE privileges, PUBLIC defaults |
| https://www.postgresql.org/docs/current/catalog-pg-constraint.html | 200 | `contype` codes (including `n`, `t`), `convalidated`, `pg_get_constraintdef()` |
| https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-indexes-transact-sql | 200 | `has_filter`, `filter_definition` |
| https://learn.microsoft.com/en-us/sql/relational-databases/indexes/create-filtered-indexes | 200 | what a filtered index is; no filter on PK or unique constraints |
| Video "Banco de Dados \| Fundamentos para Vibe Coders #EP2", https://www.youtube.com/watch?v=TL4T9ZESamI | 200, text truncated to the title | Nothing re-verified; the 001/002/003 example and "grandmother's recipe" analogy are the video's, unconfirmed |
| Internal project skill, read earlier for method only; no text, names or figures reused | read locally | the two ORM lessons |

## Reading limits

Pages were read through a summarizing tool. Scripts, SQL and data files: the SQL snippets in the references are the skill's own examples and were not run. Prisma pages describe the tool as served on 2026-11-27; behavior of older versions was not checked.

## Claims not adopted as fact

- Replit CEO promised dev/prod separation: only the handout says so, indirectly; the article does not.
- "`migrate reset` causes total data loss": not on the pages read; replaced by the documented behavior.
- Flyway or other tools' baseline commands (`baselineOnMigrate` and similar): the page was a 404 and the versioned-migrations page does not mention them.
- That Prisma cannot express CHECK constraints: not stated on the pages; the reference says to test the tool and version.
- Catalog views for check constraints and DENY permissions on SQL Server: not read.
- Re-applying grants on tables the migration role creates: inference, not on the privileges page.
- What Flyway does when an applied migration's checksum changes: the page does not say.
