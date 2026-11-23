# Wide Refactors, Blocking Edges and the Frontier: Worked Example
Sources: https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md · Last verified 2026-11-23

The upstream page defines tickets as tracer-bullet vertical slices with explicit "blocked by" edges, and carves out one exception: wide refactors. SKILL.md states the rules; this file shows how they play out in a concrete decomposition. Examples are the author's own illustrations of the upstream rules (marked as inference where they go beyond the page).

## Definitions (from the upstream page)
- **Tracer-bullet slice:** a narrow but complete path through every layer, demoable or verifiable alone, small enough for one fresh context window.
- **Blocking edge:** a ticket that must finish before another can start. No blockers means it can start now.
- **Frontier:** every ticket whose blockers are all done. A linear chain has a frontier of one.
- **Wide refactor:** one mechanical change whose blast radius spans the codebase, so one edit breaks many call sites at once and no slice can land green.
- **Expand-contract:** expand (new form beside old), migrate (batched call-site moves), contract (delete old form).

## Is it a slice or a wide refactor? (decision rule, inference)
| Question | Slice | Wide refactor |
|---|---|---|
| Can one ticket change behaviour end to end and pass CI? | yes | no, a single edit breaks many sites |
| Does the change touch a shared symbol/column/contract used everywhere? | no | yes |
| Is the work mechanical rather than behavioural? | rarely | usually |

## Example A: normal feature (frontier in action)
```
01 Schema + repository for saved searches          blocked by: none
02 Create a saved search (API + UI + tests)        blocked by: 01
03 List saved searches (API + UI + tests)          blocked by: 01
04 Delete a saved search                           blocked by: 02
```
Frontier at start: {01}. After 01: {02, 03} (parallelisable). After 02: 04 joins. Each ticket delivers observable behaviour; 01 is a prefactor/foundation and is placed first because prefactoring goes first in the page's rules. Note that 01 alone is thin; if it is not independently verifiable, fold it into 02 (inference).

## Example B: wide refactor (retype `userId` from number to string)
```
01 Expand: add UserId string type + converters beside number   blocked by: none
02 Migrate package billing/                                    blocked by: 01
03 Migrate package auth/                                       blocked by: 01
04 Migrate package reports/                                    blocked by: 01
05 Contract: remove number form, tighten types                 blocked by: 02, 03, 04
```
CI stays green after every migrate batch because the old form still exists. Batches are sized by blast radius (per package or per directory), not by arbitrary file counts. The contract ticket is blocked by every migrate batch, so it cannot start while any caller remains.

If batches cannot stay green individually, keep the same sequence but put them on a shared integration branch that all block a final integrate-and-verify ticket; green is only promised there.

## Failure modes
- **Horizontal slicing:** all-DB-changes or all-UI-changes tickets. Nothing is demoable until the last one lands.
- **Phantom edges:** declaring blockers that do not genuinely gate the ticket, which serialises work and shrinks the frontier. The quiz step asks the user to check exactly this.
- **Forcing a wide refactor into a tracer bullet:** produces an unlandable red-CI ticket.
- **Stale detail:** file paths and code snippets in tickets rot; only inline a snippet when a prototype produced it and it encodes a decision (state machine, schema, type shape).
- **Combined local file:** local mode needs one file per ticket (`.scratch/<feature-slug>/issues/<NN>-<slug>.md`), numbered in dependency order.

## How an agent should apply this
- Before drafting, test each candidate change against the slice-or-wide-refactor table; do not default everything to slices.
- Write blocking edges as real identifiers/numbers, blockers first in publication order, so edges can reference them.
- After drafting, compute the frontier explicitly and report it; if it is always size one, ask whether edges are phantom.
- For expand-contract, always create the contract ticket last and blocked by all migrate batches.
- Keep ticket bodies behavioural (what works end to end), with acceptance criteria as checkboxes.
