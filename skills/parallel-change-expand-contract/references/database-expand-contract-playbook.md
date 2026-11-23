# Database Expand and Contract: Seven-Step Playbook and Migration-Tool Guide

Sources: https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern · https://www.prisma.io/docs/guides/database/data-migration · Last verified 2026-11-23

## Seven steps (Prisma Data Guide)
1. **Deploy new schema** next to the old (new columns/tables; nullable or defaulted so current clients keep working).
2. **Expand the client**: still read the old structure, write to both.
3. **Migrate existing data**: copy and transform history; verify transformations preserve meaning (edge cases such as splitting a name break naive logic).
4. **Test the new interface** while prod still reads old; use a replica/standby where possible; add indexes if slow.
5. **Cut reads over** in stages; writes still go to both.
6. **Stop writing** to the old structure.
7. **Remove** old columns/tables once no client uses them.
Steps 2 and 3 can swap order by design.

## Worked example: table split
`equipment` held `city`, `park`, `playground`; a new `playground` table (also holding `sq_ft`) was created. The client dual-wrote under Redis feature flags (one for write targets, one for read source), a script backfilled history (park sizes from an external source), reads switched, writes to old stopped, legacy columns dropped.

## Dual-write and rollback facts
- Dual writes keep the new structure current with the old as fallback.
- Data only in the new design (e.g. `sq_ft`) is lost on rollback. Rollback is easy before step 5 and costly after.
- Constraints on new columns break old clients unless nullable/defaulted.
- The guide has no SQL, no trigger discussion and no dedicated column-rename walkthrough; do not attribute those to it.

## Tool-managed variant (Prisma migration guide, boolean to enum)
- The expand migration adds a `status` enum column defaulting to `Draft` and keeps `published`; a `dataTransform` backfills `status = 'Published'` where `published = true`. A later contract migration drops `published` with a destructive-operation warning.
- `check` must return rows (not an aggregate) so the step can be skipped when already done; the runner prechecks and postchecks it.
- On PostgreSQL schema change plus backfill run in one transaction; failed runs retry safely; rollback is another planned migration, not an undo.
- Gotcha: old code writes only `published`, so a post published after the backfill gets `Draft`; pause writes until new code is live (or dual-write).
- Do not use a schema-sync command that skips data operations; do not hand-edit generated migration artifacts (hash mismatch errors).
- Apply the expand step alone first (`--to`) and preview the route (`--show`). Production runs plain data ops, not application code.
- Limits: the guide backfills in a single UPDATE and says nothing about batching, throttling or progress monitoring. The existing `sources.md` credits it with throttled backfill and zero-query monitoring, which the fetched page does not support; design those yourself (inference).

## Sketch (rename column, generic SQL)
```
-- expand
ALTER TABLE users ADD COLUMN given_name text NULL;
-- app: write both columns; backfill in batches with a pause between them
UPDATE users SET given_name = first_name WHERE given_name IS NULL AND id BETWEEN :a AND :b;
-- cut reads over, stop writing first_name, watch for reads of first_name == 0
-- contract
ALTER TABLE users DROP COLUMN first_name;
```

## How an agent should apply this
- Ship schema expand, app dual-write, backfill, read cutover, write stop and drop as separate deployments.
- Make new columns nullable/defaulted; add NOT NULL only after backfill and cutover.
- Batch and throttle large backfills yourself and label this as your own design.
- Decide the rollback point (before read cutover) and state what data is lost after it.
- Require evidence of no readers of the old column before the destructive drop.
