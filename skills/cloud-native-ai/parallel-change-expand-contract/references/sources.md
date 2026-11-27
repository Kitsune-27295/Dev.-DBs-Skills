# Sources — Parallel Change (Expand and Contract)

Every URL below was checked during skill authoring (2026-11-27), read with WebFetch.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Danilo Sato, "Parallel Change" on Martin Fowler's site](https://martinfowler.com/bliki/ParallelChange.html) | 200 OK, dated 13 May 2014 | Three phases (expand, migrate, contract), Kerievsky credit (2006, talk 2010), Grid example, applications (refactoring, database, deployments, remote APIs), feature flag and branch by abstraction companions, caveats. |
| [Prisma Data Guide, The Expand and Contract Pattern](https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern) | 200 OK, no publication date on the page | Seven steps, table-split example, dual writes, rollback limits, nullable or defaulted new columns. |
| [Prisma docs, expand-and-contract migrations](https://www.prisma.io/docs/guides/database/data-migration) | 200 OK; the page targets Prisma ORM 8, labeled a release candidate, and links an ORM 7 version | Boolean-to-enum example, `check` and `dataTransform` semantics, transaction and retry behavior, the write gap between expand and contract, tool warnings. |
| [PostgreSQL docs, ALTER TABLE](https://www.postgresql.org/docs/current/sql-altertable.html) (added 2026-11-27) | 200 OK, "current" version | ADD COLUMN default and rewrite rules, SET NOT NULL scan and CHECK shortcut, NOT VALID and VALIDATE CONSTRAINT locks, DROP COLUMN behavior. |

## Reading limits
- The previous text said it was retrieved on 2026-11-22; it was re-read in full on 2026-11-27 and corrected as listed below.
- The Prisma pages were read as summaries from WebFetch, not word for word; Prisma command names are version-specific.
- PostgreSQL behavior is quoted for "current"; the page names no release for the rewrite rules, so older servers were not checked. MySQL, SQL Server and other engines were not read.
- No scripts or SQL files exist in this skill to re-verify; the two SQL sketches are the author's own illustrations and were not executed.

## Claims not adopted as fact
- "Origin of the pattern (Danilo Sato)": Sato wrote the article; the page credits Kerievsky with the technique.
- "Dual-writing guarantees rollback": the Prisma guide says rollback can lose data after reads cut over.
- "Prisma docs describe throttled backfill, avoiding table locks and zero-query monitoring": neither Prisma page covers batching, throttling, locks or monitoring; these are this skill's design (inference).
- "Database triggers vs application dual-writes": the Data Guide does not mention triggers.
- "Kafka or RabbitMQ event payload changes": no source read; kept only as a labeled inference.
- "500 rows per batch": an example number with no source; removed.
- Whether the Prisma Data Guide is still current: it carries no date.
