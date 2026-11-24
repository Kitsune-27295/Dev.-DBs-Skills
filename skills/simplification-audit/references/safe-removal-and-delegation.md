# Safe Removal and Delegation

Sources: https://martinfowler.com/bliki/ParallelChange.html · https://martinfowler.com/bliki/BranchByAbstraction.html · https://abseil.io/resources/swe-book/html/ch15.html · https://refactoring.com/ · https://martinfowler.com/bliki/Yagni.html · Last verified 2026-11-24

## Choosing the removal route

| Situation | Route |
|---|---|
| Private, unreachable, evidence complete | Delete in small steps with the suite after each; no migration needed |
| Behavior with consumers you control, signature or contract change | Parallel Change: expand, migrate, contract |
| Consumers you cannot edit (published API, other teams, stored data) | Deprecation plan first, then Parallel Change |
| Replacing a whole dependency or subsystem gradually | Branch by Abstraction: put an interface in front, route clients through it, build the replacement behind it, switch, delete the old one, optionally remove the abstraction |
| Candidate buried in an oversized file | Split with `layered-refactor` first, then remove |

## Parallel Change in brief

Fowler's three phases: **expand** (add the new alongside the old so existing clients keep working), **migrate** (move clients incrementally; the long phase, and for external clients it depends on their cooperation), **contract** (remove the old once no client uses it). The article warns that skipping the contract step leaves a codebase worse than it started, so the transition needs discipline: mark the old version with a deprecation note or TODO, and track migration to its end. Full recipe: `parallel-change-expand-contract`.

## Deprecation practice

From the deprecation chapter of the Google software-engineering book:
- **Advisory deprecation** has no deadline or enforcement; it can work when the replacement is clearly better but rarely finishes migration alone.
- **Compulsory deprecation** has a deadline and enforcement; it works best with a staffed team that owns migrations and the authority to break non-compliant users after adequate warning. Without staffing it feels like an unfunded mandate and can stall on the last critical user.
- **Warnings** should be actionable (the user can take a concrete step) and relevant (shown when the user is doing the affected thing); too many warnings cause fatigue.
- **Owners** whose primary goal is removal are required; progress is tracked through visible milestones.
- **Decide** by weighing ongoing maintenance against removal cost and the diffuse cost of two systems side by side; gather concrete usage evidence.
- Prevent **backsliding** with review-time static checks that flag new uses of the deprecated thing.

## Delegating discovery by domain

A brief for each domain agent (own template):

```text
Domain: <bounded area, listed paths or packages>
Task: find removable obligations of these kinds: <categories>
Protected (do not propose): <decisions and twins to keep>
Evidence rule: for each candidate give producers, consumers, search forms used,
  places searched and not searched, runtime evidence if any.
Record: candidate, owner, disappears/remains, capability loss, strongest reason
  to keep, alternatives rejected, classification.
Limits: at most <N> candidates, ranked; read-only; do not edit files.
Return: the records only, no recommendation to implement.
```

Guidelines:
- Give each agent an independent domain; avoid overlapping search areas so evidence is not duplicated.
- Ask for rejected alternatives; an agent that cannot say why not to remove something has not looked.
- The coordinating agent merges, dedupes, and re-checks candidates that cross domains (a symbol "unused" in one domain may be consumed in another).
- Do not accept a reply that lists only counts or opinions.
- When you need an independent read of the proposals, give the code and records to a fresh reviewer without your conclusion.

## The proposal skeleton

For a substantial proposal use: **Problem** (the maintained obligation and who pays for it), **Proposal** (what goes, what stays), **Alternatives considered** (smaller changes and why not), **Acceptance criteria** (observable conditions, tests that must pass, usage that must read zero), **Risks** (capability loss, consumers not searched, rollback). Include concrete consumer evidence and the removed maintenance cost. Small local cleanups belong inline as a comment or a ticket, not a design document. Update an existing decision record rather than creating a duplicate; check whether a new record supersedes an old one.

## Folding another branch's simplifications

Compare its independent diff against the current base, port only supported, non-overlapping proposals, and consolidate overlapping rationale. Re-verify evidence on the current base; a stale inventory is not evidence.

## After the removal

- Run the narrow owning tests and the broader suite; update docs, catalogs, schemas, snapshots and generated files with the change.
- Re-run the consumer search after the change lands and again after one full business cycle.
- Keep a short record of what was removed and why, so a later session does not reintroduce it.
- Report commands actually run and the coverage gaps; do not describe an unverified search as exhaustive.

## How an agent should apply this

- Pick the route from the situation table; use Parallel Change whenever any consumer is outside your control.
- Brief domain agents with the template; require evidence and rejected alternatives in every record.
- Write proposals in the skeleton and wait for approval before implementing unless asked to implement.
- Plan the contract step up front so the old path does not linger.
- Record what you did not search and what would raise confidence.
