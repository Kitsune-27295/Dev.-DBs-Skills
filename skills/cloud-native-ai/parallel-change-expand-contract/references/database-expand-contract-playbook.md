# Database Expand and Contract: Seven-Step Playbook, Tool Example and PostgreSQL Facts

Sources: https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern · https://www.prisma.io/docs/guides/database/data-migration · https://www.postgresql.org/docs/current/sql-altertable.html · Last verified 2026-11-27

## Seven steps (Prisma Data Guide)
1. **Build and deploy the new schema** beside the old (nullable columns or defaults so current clients keep working).
2. **Expand the interface**: clients still read the old structure and write to both.
3. **Migrate existing data**: copy and transform history. Steps 2 and 3 can run in either order.
4. **Test the new interface** (functionality and performance), possibly on a standby or replica.
5. **Cut reads over** to the new structure; clients keep writing to both.
6. **Stop writing** to the old structure.
7. **Remove** the old structure.

## Worked example: table split
`equipment` held city, park and playground columns. A new `playground` table (with a size column) was created. Clients dual-wrote under Redis-stored feature flags (one flag for write targets, one for the read source); a script backfilled history, taking park sizes from an external source; reads switched; writes to `equipment` stopped; the legacy location columns were dropped.

## Dual-write and rollback facts
- Dual writes validate the new interface and keep new data landing in the new structure while the old one stays as fallback.
- The guide says rollback is easy at most points, but after reads cut over (step 5) it can lose data that exists only in the new design (the per-playground size).
- The page is not dated; it has no SQL, no trigger discussion, no batching or throttling, and no column-rename walkthrough (its example is a split of a name column, advising new columns over altering old ones). Do not attribute those to it.

## Tool-managed variant (Prisma boolean to enum guide)
This guide targets Prisma ORM 8, which it labels a release candidate, and links to a version for ORM 7; the commands below are version-specific. The method is general; the command names are not.
- Expand migration: add a `status` enum column defaulting to `Draft`, keep `published`; the planner emits the column with a default and a `CHECK` constraint and no backfill. A `dataTransform` in the migration sets `status = 'Published'` where `published` is true. Contract: a later migration removes `published`, with a destructive-change warning.
- `check` must return rows while work remains (not an aggregate): it becomes an `EXISTS` precheck that decides whether the step runs and a `NOT EXISTS` postcheck. An aggregate always returns one row, so the step would never be skipped and the postcheck would always fail.
- On PostgreSQL the schema change and backfill run in one transaction ("together or not at all"); a failed run is safe to retry; a rollback is one more planned migration, not an undo.
- Gotcha: between expand and contract, old code writes only `published`, so a post published after the backfill keeps `Draft`; pause writes until new code is live (or dual-write).
- Do not use the schema-sync command (`db update`) for this change: it carries no data operations. Never hand-edit the generated `ops.json`; edit the migration source and recompile, or the hash check refuses to run.
- Apply the expand migration alone first with `--to`, preview a route with `--show`, deploy the new code, then apply the drop. Production runs the compiled operations, not application code.
- Limits: the example backfill is one `UPDATE` over all matching rows; the guide covers PostgreSQL only and says nothing about batching, locks or large-table performance.

## PostgreSQL facts that decide expand and contract steps (ALTER TABLE page)
- **ADD COLUMN with a default:** a non-volatile default is evaluated once and stored in metadata, with no table rewrite, even on large tables. A volatile default (for example `clock_timestamp()`), a stored generated column, an identity column or a domain-typed column with constraints rewrites the table and its indexes. The page ties none of this to a release number.
- **SET NOT NULL:** normally scans the whole table; skipped when a valid `CHECK` constraint proves no nulls exist (and is not dropped in the same command). The page names no lock for this form, so the general rule applies: `ACCESS EXCLUSIVE` unless noted.
- **Large-table pattern:** `ADD CONSTRAINT ... NOT VALID` skips the scan of existing rows (new writes are checked at once); `VALIDATE CONSTRAINT` later takes only `SHARE UPDATE EXCLUSIVE`. Allowed for foreign key, `CHECK` and not-null constraints. `ADD FOREIGN KEY` needs `SHARE ROW EXCLUSIVE` rather than `ACCESS EXCLUSIVE`.
- **DROP COLUMN:** the column is only made invisible; space is not reclaimed until rows are rewritten, and indexes and constraints on it go with it. `CASCADE` is needed if views or foreign keys outside the table depend on it. The page names no lock, so assume `ACCESS EXCLUSIVE`.
- Other engines (MySQL, SQL Server) behave differently and were not checked; read their docs before applying these rules.

## Sketch (rename column, generic SQL; my own design, not from the pages)
```
-- expand
ALTER TABLE users ADD COLUMN given_name text NULL;
-- app: write both columns; backfill in small batches with a pause between them
UPDATE users SET given_name = first_name WHERE given_name IS NULL AND id BETWEEN :a AND :b;
-- cut reads over, stop writing first_name, watch until reads of first_name == 0
-- contract
ALTER TABLE users DROP COLUMN first_name;
```

## How an agent should apply this
- Ship schema expand, app dual-write, backfill, read cutover, write stop and drop as separate releases.
- Make new columns nullable or defaulted with a non-volatile default; add `NOT NULL` through a validated `CHECK` after backfill and cutover.
- Batch and throttle large backfills and label that as your own design.
- Decide the rollback point (before read cutover) and state what data is lost after it.
- Require evidence of no readers of the old column before the destructive drop, and run the `ops-safety` gate.
