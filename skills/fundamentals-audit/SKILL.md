---
name: fundamentals-audit
description: Use to audit an application, especially AI-built, against five engineering fundamentals at once (integration tests, client trust, race conditions, idempotency, separation of responsibilities) without changing anything, and to decide which fix to run first. Also holds the run order and the safety rules every fix skill follows before it touches code.
---

# Fundamentals audit and run order

Read-only: change no project file, run no migration, install nothing. Read code, run read-only commands, write one report. Fixes are the skills named below, run one at a time. This file is the single home of the run order and the pre-run rules; they cite it.

## Pre-run safety rules (apply before any fix skill)

- Work on a **separate branch**; nothing goes straight to the main branch.
- Every skill shows its **plan first**; read it before accepting. Do not run a prompt or skill whose effect you do not understand.
- **Every new migration is reviewed by a human before it runs.** A production database is never touched without the owner looking.
- **One process at a time** on a codebase: no two branches, tabs or agents working the same area.
- Never delete, skip or loosen a test to get green (`integration-tests`).
- No magic prompt exists: read the report, fix one thing at a time, approve each.

## Run order of the fixes

1. `integration-tests`: lock current behavior first, so nothing that follows breaks silently.
2. `never-trust-the-client`: the open door (leaked keys, rules in the browser, loose policies); `security-audit` finds more of it.
3. `race-condition-fix` and `idempotency-fix`: money and scarce resources.
4. `layered-refactor`: last, with tests already protecting the behavior.

The database has its own audit and run order (exposure, backups, usage cost, transactions, schema, migrations, performance): `database-audit`. Run it beside this one when the application owns a database.

## The audit (steps in order; note findings before moving on)

1. **Integration tests.** Is a test tool configured? Is the test database separate from production? What is the command to run everything? Run it only if it cannot touch production, then give passes and failures. List the critical flows (signup, login, checkout, subscription, webhooks): which have a route-level test, which only a unit test with mocks, which nothing.
2. **Client trust.** Price, discount, permission, admin-role or plan-limit rules that live only in the front end. Keys and tokens in client code or client-exposed variables (prefixes such as `NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`), classed public by design or secret. For a database exposed by API, apply `database-exposure` (tables, policies, grants, open port). Depth: `security-audit`.
3. **Race conditions.** Every read-decide-write over a limited resource (stock, coupon, balance, credit, seat, invite): what happens if two identical requests arrive together, and whether a unique constraint, atomic operation or row lock protects it. Flag protections that rely on an in-memory lock, an expiring cache lock or a cached read, and say whether the database alone would do.
4. **Idempotency.** Inbound webhooks: signature verified on the raw body? A processed-events record with a unique id? What if the same event arrives twice? Calls to the payment gateway: do they send an idempotency key?
5. **Separation of responsibilities.** The longest files; in each, whether screen, business rules and data or service access are mixed. Name candidate number 1 to refactor.

## Deliverable

`AUDIT.md` at the project root: one table per step (finding, risk high/medium/low, file and line, suggested fix) and, at the top, the **five highest risks** in order. Anything not verifiable says "not verified" and why, never a guess. End with which of the five fix skills to run first and why.
