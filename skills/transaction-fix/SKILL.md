---
name: transaction-fix
description: Use when one user action writes to more than one table or step (create an order and take stock, charge and grant access, transfer between accounts) and a failure in the middle can leave half-done data. Finds each multi-write operation, wraps it in a database transaction so it is all or nothing, keeps external calls outside the transaction, and proves it with a forced-failure test.
---

# Transaction fix (all or nothing)

A transaction makes several writes behave as one: either every write lands or none does. Without it, a crash between two writes leaves an order with no items or a payment with no access. Two requests racing on the same row are a different problem: `race-condition-fix`. Same event delivered twice: `idempotency-fix`. Shared database rules and safety steps: `database-audit`, `fundamentals-audit`.

## Steps

1. **Find every operation that writes to more than one table, more than one row, or makes separate calls** to the database for one user action. List each with `file:line` and the order of its writes. Done when the list is complete or the search method is stated.
2. **For each, state in one sentence** what must be true afterwards ("the order exists if and only if its items and the stock change exist"). That sentence is the business rule the test will check.
3. **Write the failing test first:** force an error after the first write (a stub that throws, a violated constraint) and assert that **nothing was written**. It must fail on the current code.
4. **Wrap the writes in one transaction** in the server or a database function, using the stack's own mechanism, with rollback on any error. If the steps are separate calls from the client today, propose moving them into one endpoint or function. Keep reads that decide the outcome inside it.
5. **Move every external call outside the transaction:** an email, a payment provider call, a webhook. Hold the transaction open on a slow network call and locks pile up. Pattern: commit first, then call; or record the intent inside the transaction and send afterwards.
6. **Run the test again** and the neighboring tests; show the output.

## Rules

- One operation per change; do not rewrite unrelated code. Do not change business rules or values: only group the writes that already exist.
- Never swallow the error to make a test pass: the failure must reach the caller after rollback.
- A step that cannot be undone by rollback (money moved at a provider) is named in the report with how it is compensated.
- Tests run against a real test database that is not production; see `integration-tests`.
- Show the list from step 1 before editing anything.

Source: the handout of the second database lesson of mano deyvin (prompt "the half-saved order").

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were verified and which are the lesson's own
- [Atomicity scenarios and external calls](references/atomicity-scenarios-and-external-calls.md) — when you hunt multi-write operations or decide where an email or payment call goes
