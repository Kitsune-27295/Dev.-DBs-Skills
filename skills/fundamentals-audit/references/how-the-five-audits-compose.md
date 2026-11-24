# How the five fundamentals compose, and why this order

Sources: video, run-order summary at about 30:07-31:16 (https://www.youtube.com/watch?v=G8SeOH0qerk); handout sections "Antes de colar qualquer prompt" and "A ordem que eu rodaria" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-24

## The five and what each protects

| Fundamental | Protects against | Fix skill |
|---|---|---|
| Integration tests | Silent regressions from AI edits | `integration-tests` |
| Never trust the client | Tampered prices, leaked keys, loose policies | `never-trust-the-client` |
| Race condition | Double-spend of limited resources | `race-condition-fix` |
| Idempotency | Repeated deliveries causing repeated effects | `idempotency-fix` |
| Separation of responsibilities | Tangled files where every edit has side effects | `layered-refactor` |

## The recommended order and the reasoning given

1. Integration tests first: they lock current behavior so later changes cannot break the whole app unnoticed (video and handout).
2. Client trust second: the handout calls it the open door; the video says leaving a door or a key exposed is the next priority.
3. Race conditions and idempotency third: the handout says "that is money"; in the video race is third and idempotency fourth, with the remark that it matters most when money or bookings are involved.
4. Separation last: the tests are already working, so the restructuring is safe (the video says doing it by hand used to hurt; with AI and tests it is quick).

My inference on how they chain: the concurrency tests asked for by race and idempotency fixes are written in the style set up in step 1; the unique constraint behind a processed-events table is the same mechanism as the race guard; characterization tests in the refactor reuse the integration setup. So skipping step 1 makes steps 3 to 5 each reinvent test setup.

## Shared process rules (both sources)

- Separate branch, never commit directly to main.
- Each prompt shows its plan first; read it before accepting.
- New migrations are reviewed before they run; production is not touched unseen.
- Do not run a prompt whose effect you do not understand ("watch first, then run").
- No magic prompt: the video says each one hands over the rod, not the fish; read the report, fix item by item.
- Do not run two processes on the same area at once (stated in the refactor chapter, generalized in SKILL.md).

## How an agent should apply this

- Offer the audit before any fix; run fixes in the stated order unless the report shows a high-risk finding that justifies reordering, and say why.
- Run one fix skill per branch and finish it before starting the next.
- When a fix skill needs tests, point back to `integration-tests` rather than inventing a test setup.
- Treat the owner's approval of each plan as a gate, not a formality.
