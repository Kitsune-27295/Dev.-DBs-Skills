---
name: layered-refactor
description: "Behavior-preserving split of one oversized file or module that mixes screen code, business rules and data or external-service access (database, payment gateway, email) into three layers, with characterization tests first and one small piece moved per step. Not for choosing a layered architecture (layered-n-tier-architecture), redesigning module interfaces (codebase-design) or writing the safety-net tests themselves (integration-tests). Use when every edit to a file breaks something else, nobody dares open it, or a tangled file must be cleaned up without changing behavior."
---

# Layered refactor

Give each concern its own drawer. Three are enough; this is not a mandate for a heavy architecture, just a way to stop one edit rippling through everything. Sources and what they cover: [references/sources.md](references/sources.md).

| Drawer | Holds |
|---|---|
| UI | what appears on screen and captures user events |
| Business rules | calculations, validations, decisions |
| Data and services | database, external APIs, payment gateway, email, anything outside the process |

Warning sign: a file you dread opening, where every change has side effects. The safe path is small steps that do not change behavior, backed by tests that record how the file behaves today. Safety rules shared with the other audits, and the order of work, live in `fundamentals-audit`.

## Steps (completion criteria in brackets)

1. **Map the file:** every function, component and block, each classified into one drawer. [every block has a drawer]
2. **Name the obstacles:** cross dependencies, duplicated code, global state that block separation. [each has `file:line`]
3. **Propose the target structure** following the project's existing pattern. No new framework or library. Show it and wait for approval. [owner's OK]
4. **Check test cover.** If the current behavior is not covered, write **characterization tests** for the main flows of this file: tests that record what the code does today, even when it looks wrong. They pass against the untouched code before step 6. [suite green on the untouched file]
5. **Plan small steps:** each moves one piece, keeps public names, leaves the app working. [list of steps approved]
6. **Execute one step at a time and run the tests at the end of each.** [green after every step; red means undo that step, not edit the test]

## Rules

- **Behavior does not change.** A bug found on the way goes on a **separate list** and is handled after the refactor, never fixed in flight.
- No renaming of routes, public props or database columns.
- Work on a separate branch, not on main. Avoid a second branch changing the same area meanwhile (this pack's process advice, not from the handout).
- Order in a larger cleanup: tests first, separation last (the handout's order: separation after integration tests, with the tests already protecting you); see `fundamentals-audit`. Characterization at integration level is preferred over mock-heavy unit tests; see `integration-tests`.
- For deepening a module's interface after it is split, see `codebase-design`; for what the layers may depend on, see `layered-n-tier-architecture`.

## Quick Decision Checklist

- [ ] Is every block of the file mapped to one drawer: UI, business rules, or data and services?
- [ ] Does the target structure follow the project's existing pattern, with no new framework or library, and the owner's OK?
- [ ] Do characterization tests for the main flows pass on the untouched file before I move anything?
- [ ] Is each step small, keeping public names and leaving the app working?
- [ ] Do I run the tests after every step, undoing the step (not editing the test) when red?
- [ ] Is any bug I find going on a separate list instead of being fixed in flight?
- [ ] Am I leaving routes, public props and database columns un-renamed?

## Deep references

- [Sources](references/sources.md) - provenance, reading limits and claims not adopted
- [Drawers and incremental steps](references/drawers-and-incremental-steps.md) - when planning the step sequence of a refactor
- [Trigger evals](references/trigger-evals.md) - should-trigger and near-miss prompts for this skill's description
