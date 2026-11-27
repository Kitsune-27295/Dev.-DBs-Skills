---
name: integration-tests
description: "Put tests on the flows that must not break (signup, login, checkout, payment webhooks, anything touching money, permissions or another user's data) as route-level integration tests against a real test database, from behavior sentences the human approves before any code. Also owns the test golden rule: never delete, skip or loosen a test to make it pass. Not for red-green-refactor on a new feature (`tdd`), browser suites (`playwright-qa-orchestrator`), flaky CI (`ci-test-reliability`) or choosing the suite mix (`testing-pyramid-and-shapes`). Use when an app has no tests on critical flows, an AI change broke something far away, or you must pick which flows to cover."
---

# Integration tests

An integration test calls the real route with a real test database and fakes only what is external (payment gateway, email, third-party APIs). It is the one test type that guards the whole path without a swamp of tests.

| Type | Why not as the main net |
|---|---|
| Unit | Mocks the data, so an agent loves it: it passes without testing the wiring |
| End-to-end (Playwright, Cypress) | Clicks the screen; slow and breaks for unrelated reasons |
| **Integration** | Hits the route under the UI with the real database, rules and policies running |

Without them an agent changes one place, breaks another far away, and the customer finds out ("it stopped on its own": it never does).

## Steps

1. **List critical flows** by reading the project: signup, login, checkout, payment webhooks, any route touching money, permissions or another user's data. [each flow named]
2. **Write behavior sentences** in `describe` / `it` form ("when ..., then ...") for each flow, covering: the happy path; expected errors (payment declined, invalid field, no permission); repetition (double click, duplicate webhook, two requests at once); limits (zero stock, expired plan, zero or negative amount); improper access (user A reading or changing user B's data). [five groups per flow]
3. **Stop and show the sentences.** The human is the source of truth for expected behavior: they read, correct and approve. You write the sentences; they do not have to write code, only agree with the `it` line. [explicit approval]
4. **Set up the environment** with the project's existing tool; if none exists, suggest the simplest for the stack and wait for approval. The test database is **separate**: local container, local backend-as-a-service, or a dedicated test project, with the same engine as production (an in-memory stand-in of another engine can hide real differences). [config points at no production data]
5. **Write the tests against the routes** (API routes, server actions, edge functions). Mock only external services; the database, business rules and policies run for real. Fire concurrent cases at the same instant (`Promise.all` or equivalent). Illustrative shape (Vitest-style `describe`/`it`; adapt to your runner):

   ```ts
   describe('payment webhook', () => {
     it('when the same event arrives twice, enables the plan once', async () => {
       await post(webhook, paidEvent)
       await post(webhook, paidEvent)
       expect(await subscriptions(user)).toBe(1)
     })
     it('when both copies arrive together, enables the plan once', async () => {
       await Promise.all([post(webhook, paidEvent), post(webhook, paidEvent)])
       expect(await subscriptions(user)).toBe(1)
     })
   })
   ```
6. **Run everything and report** passes and failures. A test failing because of a real bug **stays failing** and enters a bug list. [list delivered]
7. **Optional, only if approved:** one E2E smoke test for the signup-to-checkout path.
8. **Deliver the single command** that runs all tests, to run after every AI-made change.

## Golden rule

Never delete, skip, or loosen a test to make it pass. If a test looks wrong, stop and ask. Business rules do not bend to turn a run green. Avoid rewriting passing tests while refactoring: a test that already covers a rule is the cheapest guard you have. Never mock the database or the rule under test. Add a negative cross-tenant test (user B asks for user A's object and gets nothing); if a calculation needs the database to be tested, the logic is in the wrong layer (see the tenant-isolation reference). **Never connect tests to a production database**; RLS and policy tests are only valid against a real database, run under the application's own database role. Duplicate and simultaneous cases are written here; fixing the code they expose belongs to `idempotency-fix` and `race-condition-fix`.

When an agent changes code, run the test command; green means carry on, red means read the failure and fix the code.

## Quick Decision Checklist

- [ ] Did I list the critical flows by reading the project?
- [ ] Do the sentences cover happy path, errors, repetition, limits and improper access?
- [ ] Did I show the sentences and get the human's approval before writing tests?
- [ ] Is the test database separate from production, with only external services mocked?
- [ ] Are concurrent cases fired at the same instant, with a cross-tenant negative test?
- [ ] Does a test that fails on a real bug stay failing and go to the bug list?
- [ ] Am I avoiding deleting, skipping or loosening any test to get green?

## Deep references

- [Sources](references/sources.md) — provenance, fetch statuses, claims not adopted
- [Trigger evals](references/trigger-evals.md) — should-trigger and near-miss prompts for the description
- [What to test and real database](references/what-to-test-and-real-database.md) — when deciding test scope, database setup or tooling
- [Tenant-isolation negative test and logic layer](references/tenant-isolation-and-logic-layer.md) — when a route reads tenant data, or a test needs the database only for arithmetic
