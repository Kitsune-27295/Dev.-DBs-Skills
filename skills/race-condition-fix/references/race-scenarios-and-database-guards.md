# Race scenarios and database guards

Sources: video chapter "Evitando o caos com Race Condition" (2:51-7:11, https://www.youtube.com/watch?v=G8SeOH0qerk); handout section "1. Race condition" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-24

## The shape of the bug

A race here is a check-then-act window: request A reads "1 in stock", request B reads the same "1", A writes 0, B writes -1 (or a second order row). The video tells it with one loaf and two customers; the handout widens it to every read-decide-write on a limited resource: stock, coupons, balances, credits, seats, invites. The video adds that it is not only stock: a barbershop booking system that reads a slot and later writes it has the same window.

Observable symptoms (handout): duplicate orders, negative stock, a coupon used more than once. The video's author says a negative stock column is the first thing he looks for when auditing an inherited system (his claim).

## The three guards, cheapest to heaviest

| Guard | What closes the window | Fits when |
|---|---|---|
| Unique constraint / unique index | The database refuses the second insert | "This record may exist once" (one order per cart, one redemption per coupon and user) |
| Atomic single statement | Check and write happen as one operation; the affected-row count says who won | A counter or quantity changes under a condition |
| Transaction with row lock | The second transaction waits for the first to commit | The rule spans several reads or tables and cannot be one statement |

Own example of the atomic form (pseudo-SQL):

```sql
UPDATE coupons SET uses_left = uses_left - 1
WHERE code = :code AND uses_left > 0;
-- rows affected = 1: granted; 0: sold out, reply "unavailable"
```

The caller must read the affected-row count; ignoring it recreates the bug while looking fixed (my inference, a common failure mode).

## Why the video rejects extra infrastructure

The video argues each added system (Redis, a queue) is one more thing to operate, that a cache has an expiry window so "making the window longer" does not help, and that the existing database already solves it. The handout turns this into a prompt rule: propose new infrastructure only after explaining why the database is insufficient. These are the author's engineering opinions; the trade-off changes when the contended state does not live in one database (see `locks-vs-database-guards-kleppmann.md`).

## What the prompt asks the AI to do

1. List every read-decide-write path. 2. Describe the two-simultaneous-requests outcome in one sentence each. 3. Propose the fix in the order above. 4. Treat the disabled submit button as UX only. 5. Write a test firing two simultaneous requests proving one effect. Constraints: plan before edits, human review of new migrations, report existing duplicates that block a unique index instead of deleting them.

## How an agent should apply this

- Search for read-then-write on limited resources, not just stock; include scheduling and invites.
- Prefer the first guard that expresses the rule; fall to a row lock only when needed.
- Always check affected rows or the unique-violation error and map it to a clean "unavailable" response.
- Write the two-concurrent-requests test first so it fails before the fix.
- Before adding a unique index, query for existing duplicates and report them.
