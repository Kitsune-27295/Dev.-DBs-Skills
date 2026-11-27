# The drawers metaphor and incremental layering

Sources: video chapter "Organizando seu código em gavetas" (20:32-24:07, https://www.youtube.com/watch?v=G8SeOH0qerk); handout section "4. Separação de responsabilidades" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-24

## The metaphor

The video starts from one `checkout` file that contains the screen, a payment-gateway integration, a database call, a price lookup, email input handling and validation, all together. The fix is to give each concern a drawer, and to stop at three: screen (only what the user clicks and sees), business rules (calculation, validation, decision), data (database, external APIs, gateway, anything outside the process). The speaker explicitly declines Clean Architecture because it costs time for a simple problem and says no pile of layers is needed.

Why he says it matters: when code is tangled, the AI loses its way just as a person would, so keeping drawers tidy helps the agent as well as the human (his argument; the mid-project productivity dip is described anecdotally).

## Handout steps, mapped

| Handout step | Purpose |
|---|---|
| 1. Map the file by layer (UI, rules, data/services) | Know what is where before moving anything |
| 2. Flag cross dependencies, duplication, global state | These block clean cuts |
| 3. Propose folder structure following the project's existing pattern, no new library | Avoid architecture drift |
| 4. Plan small steps; each moves one piece, keeps public names, app still works | Always shippable |
| 5. Check existing tests; if absent write characterization tests of current behavior, even when it looks wrong | A safety net first |
| 6. One step at a time, run tests after each | Catch regressions at the step that caused them |

Rules: no bug fixes or business changes during the refactor (note bugs in a separate list); do not rename routes, public props or database columns; show the plan and wait for approval.

## Why the order puts this last

The author's overall order places separation after integration tests because the tests already running make the restructuring low-risk; he adds that doing it by hand was painful before AI. Work on a separate branch and avoid two parallel efforts on the same area: his example of a bug-fix branch and a refactor branch touching the same code is the failure to avoid.

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
- Get characterization tests green on the untouched file before step 1.
- Keep each step to one piece and run the suite at its end.
- Record bugs found in a separate list; do not fix them in the same change.
