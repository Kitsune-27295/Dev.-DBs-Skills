# How the five fundamentals compose, and why this order

Sources: author handout, sections on safety rules, run order and the combined read-only audit prompt (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software); Kleppmann on locks (https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html) · Last verified 2026-11-27

## The five and what each protects

| Fundamental | Protects against | Fix skill |
|---|---|---|
| Integration tests | Silent regressions from AI edits | `integration-tests` |
| Never trust the client | Tampered prices, leaked keys, loose policies | `never-trust-the-client` |
| Race condition | Double-spend of limited resources | `race-condition-fix` |
| Idempotency | Repeated deliveries causing repeated effects | `idempotency-fix` |
| Separation of responsibilities | Tangled files where every edit has side effects | `layered-refactor` |

## The recommended order and the reasoning given

1. Integration tests first: they lock current behavior so later changes cannot break the app unnoticed.
2. Client trust second: the handout calls it the open door.
3. Race conditions and idempotency third, because they involve money. The handout groups them as one step; SKILL.md lists the two audit steps separately.
4. Separation last: tests already protect the behavior, so restructuring is safe.

My inference on how they chain: the concurrency tests asked for by the race and idempotency fixes reuse the setup from step 1; the unique constraint behind a processed-events table is the same mechanism as the race guard; characterization tests in the refactor reuse the integration setup. Skipping step 1 makes steps 3 to 5 each reinvent test setup.

## How the audit relates to the fix prompts

The handout's combined prompt has a role, a hard read-only constraint, five ordered steps and a report file; steps and report shape live in SKILL.md ("The audit", "Deliverable"). Each step is the detection half of a fix skill: step 3 mirrors the race fix's "list every read-decide-write", step 4 the inventory of webhooks and payment calls, step 2 the secret classification and policy review, step 5 the file mapping. The audit omits fixing, testing and plan approval.

My addition: step 3 also asks whether the database alone would suffice where a lock or cache is found. A lease-based lock can expire while its holder is paused and still write; the safe fixes are fencing tokens or a database constraint (see the Kleppmann essay).

Branch, plan-first, migration review and one-process-at-a-time rules live in SKILL.md ("Pre-run safety rules"). The handout's stance, mirrored there: no prompt is magic, so read the report and fix item by item.

## How an agent should apply this

- Offer the audit before any fix; run fixes in the stated order unless the report shows a high-risk finding that justifies reordering, and say why.
- If a check would need a write (a migration, an install), mark it "not verified". Rank the top five by exploitability and money impact. Do not start a fix in the same run.
- Run one fix skill per branch and finish it before starting the next.
- When a fix skill needs tests, point back to `integration-tests` rather than inventing a setup.
- Treat the owner's approval of each plan as a gate, not a formality.
