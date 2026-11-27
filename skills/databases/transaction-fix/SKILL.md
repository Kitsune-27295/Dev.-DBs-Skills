---
name: transaction-fix
description: "Make one user action that writes in several places (create an order and take stock, charge and grant access, move money between accounts, signup across tables) all-or-nothing, so a crash or error between writes cannot leave half-done data. Lists each multi-write operation, wraps the writes in one database transaction, keeps email, payment and webhook calls outside it and proves it with a forced-failure test. Use when a failure midway leaves partial rows. Not for two requests racing on one value (use race-condition-fix), the same event arriving twice (use idempotency-fix) or consistency across services (use saga-transactional-outbox-pattern)."
---

# Transaction fix (all or nothing)

One idea: **a transaction makes several writes behave as one, so group the writes that already exist and prove the group fails whole.** Without it, a crash between two writes leaves an order with no items or a payment with no access. Verified facts and claims not adopted: [references/sources.md](references/sources.md). Other problems have owners: two requests racing on one row is `race-condition-fix`; one event delivered twice is `idempotency-fix`; consistency across services (outbox, saga) is `saga-transactional-outbox-pattern`. Shared database rules and safety steps: `database-audit`, `fundamentals-audit`.

## 1. Find every multi-write operation

List each operation that writes to more than one table or row, or issues separate calls to the database for one user action, with `file:line` and the order of its writes. Done when the list is complete or the search method is stated. Show the list before editing anything.

Why separate calls are the bug: with no explicit `BEGIN`, a database such as PostgreSQL wraps each statement in its own tiny transaction, so three separate statements or API calls are three independent commits. Some client libraries open and commit transactions for you; check what yours does.

## 2. State the rule, then write the failing test

For each operation write one sentence of what must hold afterwards ("the order exists if and only if its items and the stock change exist"). Then write the test first: force an error after the first write (a stub that throws, a violated constraint) and assert that **nothing was written** and that the caller received the error. It must fail on the current code. Tests run against a real non-production database (`integration-tests`).

## 3. Wrap the writes

Put the writes, and the reads that decide the outcome, in one transaction on the server or in a database function, using the stack's own mechanism, rolling back on any error. If the steps are separate client calls today, propose one endpoint or function. Do not change business rules or values; only group what exists.

- Let the error propagate after rollback. In PostgreSQL an error inside a transaction block leaves it aborted: every command except `ROLLBACK` or `COMMIT` is refused until you roll back, so catching the error and carrying on does not work. To recover part of a transaction, use a savepoint deliberately.
- Keep the transaction short. A transaction holds its row locks until it ends, and other writers wait; never hold one open across user input or a slow network call.
- A transaction alone does not stop two concurrent requests from both passing a check. If that is the symptom, go to `race-condition-fix`.

## 4. Keep external calls outside

Email, payment-provider calls and webhooks go outside the transaction: a rollback cannot recall a sent email, and a slow call holds locks. Two shapes, both this skill's own practice: **commit, then call** (if the call fails, retry; the data is already correct), or **record the intent inside the transaction and send afterwards** (an outbox row; the pattern, its relay and the duplicate-delivery caveat belong to `saga-transactional-outbox-pattern`). A step the database cannot undo (money moved at a provider) is named in the report with how it is compensated, for example a refund.

## 5. Re-run

Run the forced-failure test and the neighboring tests; show the output. One operation per change; no unrelated rewrites.

## Quick Decision Checklist

- [ ] Have I listed every multi-write operation with file:line and write order before editing anything?
- [ ] Have I stated the business rule that must hold afterwards, in one sentence?
- [ ] Is there a failing test that forces an error after the first write and asserts nothing was written?
- [ ] Are all the writes, plus the reads that decide the outcome, inside one transaction with rollback?
- [ ] Are external calls (email, payment, webhook) outside the transaction, and is the transaction short?
- [ ] Does the error still reach the caller after rollback, rather than being swallowed?
- [ ] Is any step rollback cannot undo named with how it is compensated, and is this really not a race or a duplicate event?

## Deep references

- [references/atomicity-scenarios-and-external-calls.md](references/atomicity-scenarios-and-external-calls.md): read when hunting multi-write operations or deciding where an email or payment call goes.
- [references/trigger-evals.md](references/trigger-evals.md): read when tuning the description or checking the boundary with neighbors.
- [references/sources.md](references/sources.md): read to see what was verified on 2026-11-27, reading limits and claims not adopted.
