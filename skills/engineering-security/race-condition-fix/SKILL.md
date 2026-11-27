---
name: race-condition-fix
description: "Find and fix race conditions in code that reads a value, decides, then writes it back (stock, coupons, balances, credits, seats, invites, counters, any limited resource), so two simultaneous requests cannot both win: negative stock, a coupon used twice, overbooked seats, duplicate orders. Fixes in the database, in a fixed order of preference, and proves each fix with a simultaneous-request test. Use when concurrent requests break a limit or counter. Not for the same event or retry delivered several times (use idempotency-fix) or a half-finished multi-table write (use transaction-fix)."
---

# Race-condition fix

Two requests read the same value, both decide on it, both write over it. One loaf of bread, two customers, both told "yes". The fix belongs where the write lands: the database you already run. Run the shared safety rules of `fundamentals-audit` first. When one action writes to several tables and a failure mid-way leaves half-done data, that is `transaction-fix`, not a race.

## Signs

Duplicate orders, negative stock, a coupon or invite redeemed more than once, a balance that does not add up. A table with a negative quantity is enough to suspect the whole write path.

## Steps

1. **Find every read-decide-write path.** Scan for the pattern "read, check, then write" on any limited resource: order creation, stock decrement, coupon use, balance, credits, seats or slots, invites, counters. Done when each hit has `file:line` and the resource it guards; a scheduling system counts as much as stock.
2. **State the consequence per hit** in one sentence: what happens if two identical requests arrive in the same millisecond (duplicate order, stock below zero, coupon twice).
3. **Choose the simplest database fix, in this order:**
   1. **Unique constraint** (unique index) that makes the duplicate record impossible.
   2. **Atomic operation** in one statement, then check affected rows: `UPDATE stock SET qty = qty - 1 WHERE id = ? AND qty > 0`; zero rows affected means the resource is gone.
   3. **Transaction with a row lock** (`SELECT ... FOR UPDATE`, or the engine's equivalent) when the rule is too complex for one statement.
4. **Client side:** disable the submit button while the request runs, as UX comfort. The protection is the server and the database.
5. **Prove each fix:** one test that fires 2 requests simultaneously (`Promise.all` or the stack's equivalent) and asserts that exactly one has effect. The test fails before the fix and passes after; see `integration-tests` for the shape.

## Rules

- No Redis, queue, in-memory lock or cache read when the database solves it. Each adds a system to operate, and a cache has a window in which it is wrong; a longer window does not fix it. If the database truly is not enough, explain why before proposing anything else.
- Show the full list and the plan before touching a file. Every new migration is reviewed by a human before it runs.
- Existing duplicate rows that block a unique constraint: report them and propose a cleanup. Delete nothing on your own.

## Source

Martin Kleppmann, "How to do distributed locking", read through `references/locks-vs-database-guards-kleppmann.md`; the unique key, conditional UPDATE and row lock are this skill's own application (from the handout).

## Quick Decision Checklist

- [ ] Did I find every read-check-write path on a limited resource, each with file:line?
- [ ] Did I state per hit what happens if two identical requests arrive in the same millisecond?
- [ ] Am I trying the fixes in order: unique constraint, atomic conditional statement, then row-lock transaction?
- [ ] After an atomic UPDATE, am I checking affected rows to detect that the resource is gone?
- [ ] Is the database enough, with no Redis, queue, in-memory lock or cache added?
- [ ] Is there a test firing two simultaneous requests that asserts exactly one has effect?
- [ ] Have I shown the list and plan first, with migrations reviewed by a human?
- [ ] Am I reporting existing duplicates and proposing cleanup instead of deleting them?

## Deep references

- [Sources](references/sources.md) — provenance and caveats, including the Kleppmann wording discrepancy
- [Race scenarios and database guards](references/race-scenarios-and-database-guards.md) — when choosing between unique index, atomic update and row lock
- [Locks versus database guards](references/locks-vs-database-guards-kleppmann.md) — when someone proposes Redis or another external lock
