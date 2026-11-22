---
name: layered-refactor
description: Use to split an oversized file or module that mixes screen code, business rules and data or external-service access into separate layers without changing behavior, when every edit to it breaks something else or nobody dares open it. Maps the file, writes characterization tests, then moves one small piece per step with tests after each step.
---

# Layered refactor

Give each concern its own drawer. Three are enough; this is not a mandate for a heavy architecture, just a way to stop one edit rippling through everything.

| Drawer | Holds |
|---|---|
| UI | what appears on screen and captures user events |
| Business rules | calculations, validations, decisions |
| Data and services | database, external APIs, payment gateway, email, anything outside the process |

Why it matters: a disorganized file confuses the agent as it confuses a person. The source's analogy: productivity sags in the middle of a project, where code has grown tangled (echoing the "Lost in the Middle" study, which concerns model recall in long contexts, not projects). An organized codebase keeps the agent effective for longer: better odds, not a guarantee. Start with the shared safety rules in `fundamentals-audit`.

## Steps (completion criteria in brackets)

1. **Map the file:** every function, component and block, each classified into one drawer. [every block has a drawer]
2. **Name the obstacles:** cross dependencies, duplicated code, global state that block separation. [each has `file:line`]
3. **Propose the target structure** following the project's existing pattern. No new framework or library. Show it and wait for approval. [owner's OK]
4. **Check test cover.** If the current behavior is not covered, write **characterization tests**: tests that record what the code does today, even when it looks wrong, for the main flows of this file. They run against the real code and pass before step 5. [suite green on the untouched file]
5. **Plan small steps:** each step moves one piece, keeps public names, leaves the app working. [list of steps approved]
6. **Execute one step at a time and run the tests at the end of each.** [green after every step; red means undo that step, not edit the test]

## Rules

- **Behavior does not change.** A bug found on the way is written on a **separate list** and handled after the refactor. Never fix it in flight, and never run another branch fixing bugs in the same area meanwhile: two simultaneous processes on one area are the usual cause of failure.
- No renaming of routes, public props or database columns.
- Order of work in a larger cleanup: tests first, so the separation is protected; separation last. See `fundamentals-audit` for the full order.
- Integration-level characterization is preferred over unit tests with mocks; see `integration-tests`.
