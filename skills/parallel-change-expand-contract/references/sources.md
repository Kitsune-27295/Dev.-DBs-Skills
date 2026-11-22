# Sources for the parallel-change-expand-contract skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Martin Fowler, "Parallel Change" (2014), https://martinfowler.com/bliki/ParallelChange.html | Origin of the pattern (Danilo Sato): three-phase lifecycle (**Expand**, **Migrate/Transition**, **Contract**); applying parallel change to database schemas, APIs, and refactoring large classes; enabling continuous delivery by avoiding synchronized cross-team deployments. |
| 2 | Prisma Data Guide, "The Expand and Contract Pattern" (2023), https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern | Relational database implementation: handling column renames, type conversions, table splits, and relationship migrations without downtime; rules for dual-writing, database triggers vs. application dual-writes, and safety checks before dropping columns. |
| 3 | Prisma Documentation, "Data Migration in Zero-Downtime Deployments", https://www.prisma.io/docs/guides/database/data-migration | Throttled background backfilling techniques; avoiding table locks on massive tables; monitoring zero-query windows prior to contract deployment; rollback procedures for rolling releases. |
