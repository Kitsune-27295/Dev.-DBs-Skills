---
name: parallel-change-expand-contract
description: "Plan or review a breaking change to a live schema, API field or endpoint, event payload or public interface so old and new consumers keep working throughout the rollout: expand (add the new beside the old), migrate (dual-write, backfill, move readers, stop writing the old), contract (remove the old only on evidence that nothing uses it), each phase its own release. Covers where rollback stops being cheap and where PostgreSQL locks or rewrites hide in the expand and contract steps. Not for choosing a migration tool or environment setup (use `migrations-and-environments`) or for deciding what to delete (use `simplification-audit`). Use when renaming or splitting a column or table, changing a type, reshaping an API contract, or refactoring a public interface without downtime."
---

# Parallel Change (Expand and Contract)

One idea: **never ship a breaking change in one step; add the new beside the old, move every consumer across, then remove the old, as separate releases so old and new code can run at the same time.** Sources, retrieved statuses and claims not adopted: [references/sources.md](references/sources.md).

Origin: Danilo Sato's 2014 article on Martin Fowler's site names three phases (expand, migrate, contract) and credits Joshua Kerievsky with documenting the technique in 2006. The seven-step database form comes from the Prisma Data Guide; batching, throttling and zero-use monitoring are not in either page and are this skill's own design.

## 1. The three phases

| Phase | What ships | Exit test |
|---|---|---|
| **Expand** | New column, table, field or endpoint beside the old; nothing existing changes; new database columns are nullable or defaulted | Old code and old clients still pass unchanged |
| **Migrate** | Writers write both; data backfilled; readers cut over in stages; then writers stop writing the old | Every reader and writer uses the new form, evidence in hand |
| **Contract** | Old structure removed | The old form had zero use for an agreed window |

Prisma's seven steps map as: deploy schema (expand); write to both; backfill (steps 2 and 3 may swap); test the new interface; cut reads over; stop writing the old (migrate); remove the old (contract). Write the contract step and its exit metric into the ticket before starting expand.

## 2. Rules that prevent the usual outages

1. **Expand is additive only.** A new `NOT NULL` column with no default breaks every writer that does not know it yet. Add `NOT NULL` after backfill and cutover.
2. **Know what the engine does to the table.** In PostgreSQL, adding a column with a non-volatile default does not rewrite the table; a volatile default, stored generated column, identity column or constrained domain type does. `SET NOT NULL` scans the whole table unless a valid `CHECK` constraint already proves no nulls; `ADD CONSTRAINT ... NOT VALID` then `VALIDATE CONSTRAINT` avoids the long exclusive lock. Other engines differ: check yours. Detail: [database playbook](references/database-expand-contract-playbook.md).
3. **Dual-write, but do not call it a rollback guarantee.** Rollback is easy at most points, but once reads move to the new structure, data that exists only there is lost on rollback. Name the rollback point and what it costs.
4. **Close the window between expand and cutover.** Old code writes only the old column; rows written after the backfill miss the new one. Dual-write, or pause writes until new code is live.
5. **Backfill in small throttled batches** (the batch size is yours to tune; one bulk transaction on a large table risks long locks and timeouts). Make the backfill idempotent so a failed run can retry.
6. **Contract on evidence, not on a calendar.** Show no reads or writes of the old form, then remove it. The drop is destructive: apply the gate in `ops-safety`.
7. **Never skip contract.** Fowler's article warns that two permanent paths leave you worse off than before. Give migration an owner and a visible end; mark the old form deprecated.
8. **Release after each phase.** Never combine expand and contract in one deploy; during rolling deployments, old instances still query the old form until the last one is replaced.

## 3. Choosing the shape

- **Schema:** the seven-step form above, one release per step.
- **Code or class interface:** add the new method beside the old, make the old delegate to the new, move callers, delete. Many internal callers: use branch by abstraction.
- **Remote API:** widen the payload on the same endpoint or add a new endpoint instead of a new version; track which consumers still use the old field.
- **Events (inference, not in the sources):** consumers of stored or queued messages see old and new payloads for as long as old messages exist; for event-sourced streams see the versioning notes in `event-sourcing-pattern`.

Phases, variants and caveats: [references/parallel-change-phases-and-variants.md](references/parallel-change-phases-and-variants.md).

## Quick Decision Checklist

- [ ] Is the change split into expand, migrate and contract as separate releases, with the contract exit metric written down first?
- [ ] Is every new column or field nullable or defaulted in expand?
- [ ] Do I know whether this engine rewrites or locks the table for each DDL statement?
- [ ] Do writers write both forms, and is the gap before cutover closed?
- [ ] Is the backfill batched, throttled and safe to retry?
- [ ] Is the rollback point named, with the data lost after it?
- [ ] Is there evidence of zero use of the old form, and did the destructive gate run, before the drop?
- [ ] Does the migration have an owner and an end date?

## Deep references

- [Parallel change phases and variants](references/parallel-change-phases-and-variants.md) — read for code or API refactoring, feature flags, branch by abstraction, caveats.
- [Database expand/contract playbook](references/database-expand-contract-playbook.md) — read for the seven-step schema migration, a tool-managed example, PostgreSQL lock and rewrite facts, rollback limits.
- [Trigger evals](references/trigger-evals.md) — read when tuning the description.
- [Sources](references/sources.md) — retrieved statuses, reading limits, claims not adopted.
