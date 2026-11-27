# The drawers metaphor and incremental layering

Sources: handout section "4. Separacao de responsabilidades" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-27

## The metaphor

The handout's phrase is "each thing in its own drawer". A file that holds the screen, a payment-gateway call, a database call, price rules and input validation together is the case. The fix names three drawers: UI (what appears and captures events), business rules (calculations, validations, decisions) and data and services (database, third-party APIs). The handout names no heavier architecture; stopping at three keeps the change cheap.

## Handout steps, mapped

| Handout step | Purpose |
|---|---|
| 1. Map the file by layer (UI, rules, data/services) | Know what is where before moving anything |
| 2. Flag cross dependencies, duplication, global state | These block clean cuts |
| 3. Propose folder structure following the project's existing pattern, no new library | Avoid architecture drift |
| 4. Plan small steps; each moves one piece, keeps public names, app still works | Always shippable |
| 5. Before step 1, check existing tests; if absent write characterization tests of current behavior, even when it looks wrong | A safety net first |
| 6. One step at a time, run tests after each | Catch regressions at the step that caused them |

Rules in the handout: no bug fixes or business changes during the refactor (note bugs in a separate list); do not rename routes, public props or database columns; show the plan and wait for approval.

## Where it sits in the order

The handout's suggested order puts integration tests first and separation of responsibilities last, "with the tests already protecting you"; it also says to work on a separate branch rather than main. The order of the whole audit chain is owned by `fundamentals-audit`.

## Own example of one small step

```text
Before: checkout.tsx computes total = price * qty - coupon(...) inline
Step 1: move the calculation to rules/checkoutTotal; checkout.tsx imports it
Test:   characterization test pins total for 3 inputs; green before and after
```

If a test goes red after a step, undo that step rather than editing the test.

## How an agent should apply this

- Classify every block into the three drawers and list obstacles with `file:line` before proposing structure.
- Follow the existing folder conventions; introduce no framework.
- Get characterization tests green on the untouched file before the first move.
- Keep each step to one piece and run the suite at its end.
- Record bugs found in a separate list; do not fix them in the same change.
