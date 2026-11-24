# Report and Plan Templates

Sources: author's workflow (see `sources.md`); field choices follow the REPORT and FCLASS rules in `ssot-rule-registry.md` · Last reviewed 2026-11-24

The only home for the copyable templates the skill uses. `SKILL.md` links here and never repeats a template. Fill every field or write "none" or "not verified"; delete nothing silently.

## 1. Test plan table (Plan mode and Phase 3)

| ID | Objective | Priority | Level | Preconditions | Steps | Expected result |
|---|---|---|---|---|---|---|
| CART-01 | Guest adds an item and sees the count | P1 | UI | Empty cart, seeded product | 1. Open product page 2. Click Add to cart | Cart badge shows 1; item listed in the cart |
| CART-02 | Quantity of zero is rejected | P2 | API | Logged-in user | POST item with quantity 0 | 400 with a validation message; cart unchanged |

Rules for the table: one objective per row; priority P1 (revenue, security, core journey), P2 (common), P3 (rare); level per LEVEL; each expected result is observable (text, state, status code), never "works". Add a "Risks and gaps" line under the table for areas intentionally not covered.

## 2. Execution report (Phase 6)

```
# QA report: <feature or PR>
Mode: Plan | Test | Test & Fix      Date: <date>      Target: <local | staging URL name>
Playwright version: <installed>      Docs facts re-verified: yes | no | not needed

## Scope run
| Command | Result (counts, exit code) | Evidence read |
|---|---|---|
| <targeted command> | <passed/failed/flaky counts> | <trace / log path> |
| <full suite command, once> | <counts> | <report path> |

## Summary
Passed: <n>   Failed: <n>   Flaky: <n>   Skipped or annotated: <n>   Not run: <n>

## Failures by class
| Test | Class (A-E names) | Root cause (one sentence + evidence) | Action taken | Attempts used (max 3) |
|---|---|---|---|---|

## Changes
Files changed: <paths>            Application source touched: no | yes (Test & Fix only)
Annotated items (INTEG exception only): <test, defect reference, evidence>

## Not verified
<what was not run, assumptions, unknowns, blockers>

## Next steps
<escalations, decisions needed from a human>
```

## 3. Failure-analysis record (one per failing test, Phase 5)

```
Test: <file:title>        Command: <narrowest repro>        Reproduced: yes | no | intermittent
Error (first lines): <message, expected vs received>
Evidence: trace <path> | console <finding> | network <request, status, timing> | snapshot <finding>
Class: A Test Bug | B Application Bug | C Environment Bug | D Flaky | E Specification Issue
Hypothesis: <X is the cause because evidence Y>
Attempt n/3: <one change> -> <re-run command> -> <result>
Decision: fixed | reported | escalated   Reason: <why>
```

## 4. Flaky-test ticket

```
Title: Flaky: <test title> (<project>)
Observed: failed <n> of <m> runs; passed on retry <n> times; environment: <local | CI job>
Class: D Flaky (or C Environment Bug)    Suspected cause: <evidence, not a guess>
Evidence: <trace path, failing step, request timing>
Reproduction: <narrowest command, workers setting>
Fix proposal: <condition wait, data isolation, fixture change>   Owner: <name or unassigned>
Status of the test meanwhile: running and reported as flaky (never silently skipped)
```

## How an agent should apply this

- Paste the template, fill it from commands you actually ran, and keep "not verified" honest.
- Use the plan table before writing code in Test mode; in Plan mode it is the deliverable.
- Keep one failure-analysis record per failing test; the report's failure table summarizes them.
- Open a flaky-test ticket (or write the block into the report) only for class D or C findings with evidence.
- Do not store these templates anywhere else in the skill; link here.
