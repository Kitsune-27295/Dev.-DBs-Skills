---
name: race-condition-fix
description: "Find and fix race conditions in code that reads a value, decides, then writes it back (stock, coupons, balances, credits, seats, invites, counters, any limited resource), so two simultaneous requests cannot both win: negative stock, a coupon used twice, overbooked seats, duplicate orders. Fixes in the database in a fixed order of preference (unique constraint, conditional atomic UPDATE, row lock) and proves each with a simultaneous-request test. Use when concurrent requests break a limit or counter. Not for the same event or retry delivered several times (use idempotency-fix) or a half-finished multi-table write (use transaction-fix)."
---

# Race-condition fix

One idea: **let the store that holds the data arbitrate, in the cheapest form that expresses the rule.** Two requests read the same value, both decide on it, both write over it: one loaf of bread, two customers, both told "yes". Verified facts and claims not adopted: [references/sources.md](references/sources.md). Run the shared safety rules of `fundamentals-audit` first. One action writing to several tables with a failure midway is `transaction-fix`; the same event arriving twice is `idempotency-fix`.

## 1. Spot the signs

Duplicate orders, negative stock, a coupon or invite redeemed more than once, a balance that does not add up. A negative quantity in a table is enough to suspect the whole write path.

## 2. Find every read-decide-write path

Scan for "read, check, then write" on any limited resource: order creation, stock decrement, coupon use, balance, credits, seats or slots, invites, counters. Done when each hit has `file:line` and the resource it guards; a scheduling system counts as much as stock. State per hit, in one sentence, what happens if two identical requests arrive in the same millisecond. Show the list and the plan before touching a file.

## 3. Choose the simplest database fix, in this order

1. **Unique constraint** (unique index) that makes the duplicate record impossible. In PostgreSQL, `INSERT ... ON CONFLICT DO NOTHING` turns the loser into "zero rows inserted" instead of an error; without a unique index or constraint there is nothing to conflict on.
2. **Atomic conditional statement**, then check affected rows: `UPDATE stock SET qty = qty - 1 WHERE id = ? AND qty > 0`; zero rows means the resource is gone. Under PostgreSQL's default Read Committed level, a second updater waits for the first, then re-evaluates the `WHERE` on the new row version, which is why this form is safe there. Another engine or isolation level: confirm its behavior before relying on it.
3. **Transaction with a row lock** (`SELECT ... FOR UPDATE`, or the engine's equivalent) when the rule is too complex for one statement. Other writers wait until the lock holder ends, so keep the transaction short. Under Repeatable Read or Serializable, a conflict raises an error (serialization failure) and the whole transaction must be retried.

Client side: disable the submit button while the request runs, as UX comfort only. The protection is the server and the database.

## 4. Prove each fix

One test that fires 2 requests simultaneously (`Promise.all` or the stack's equivalent) and asserts that exactly one has effect, and that the loser gets a clean "unavailable" response. It fails before the fix and passes after; shape in `integration-tests`.

## 5. Guardrails

- No Redis, queue, in-memory lock or cache read when the database solves it. Each adds a system to operate, and a cache has a window in which it is wrong; a longer window does not fix it. If the database truly is not enough, explain why first; lock theory is in [references/locks-vs-database-guards-kleppmann.md](references/locks-vs-database-guards-kleppmann.md).
- Every new migration is reviewed by a human before it runs.
- Existing duplicate rows that block a unique constraint: report them and propose a cleanup. Delete nothing on your own.

## Quick Decision Checklist

- [ ] Did I find every read-check-write path on a limited resource, each with file:line?
- [ ] Did I state per hit what happens if two identical requests arrive in the same millisecond?
- [ ] Am I trying the fixes in order: unique constraint, atomic conditional statement, then row-lock transaction?
- [ ] After an atomic UPDATE or ON CONFLICT insert, am I checking the affected-row count?
- [ ] Is the database enough, with no Redis, queue, in-memory lock or cache added?
- [ ] Is there a test firing two simultaneous requests that asserts exactly one has effect?
- [ ] Have I shown the list and plan first, with migrations reviewed by a human?
- [ ] Am I reporting existing duplicates and proposing cleanup instead of deleting them?

## Deep references

- [references/race-scenarios-and-database-guards.md](references/race-scenarios-and-database-guards.md): read when choosing between unique index, atomic update and row lock.
- [references/locks-vs-database-guards-kleppmann.md](references/locks-vs-database-guards-kleppmann.md): read when someone proposes Redis or another external lock.
- [references/trigger-evals.md](references/trigger-evals.md): read when tuning the description or checking the boundary with neighbors.
- [references/sources.md](references/sources.md): read to see what was verified on 2026-11-27, reading limits and claims not adopted.
