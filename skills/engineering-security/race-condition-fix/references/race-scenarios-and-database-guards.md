# Race scenarios and database guards

Sources: PostgreSQL docs, Transaction isolation (https://www.postgresql.org/docs/current/transaction-iso.html), Explicit locking (https://www.postgresql.org/docs/current/explicit-locking.html), INSERT (https://www.postgresql.org/docs/current/sql-insert.html); handout section "1. Race condition" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software); the video chapter at https://www.youtube.com/watch?v=G8SeOH0qerk (page text not readable; chapter times unverified) · Last verified 2026-11-27

## The shape of the bug

A check-then-act window: request A reads "1 in stock", request B reads the same "1", A writes 0, B writes -1 (or a second order row). The handout widens it to every read-decide-write on a limited resource: stock, coupons, balances, credits, seats, invites. A booking system that reads a slot and later writes it has the same window. Symptoms: duplicate orders, negative stock, a coupon used more than once.

## The three guards, cheapest to heaviest

| Guard | What closes the window | Fits when |
|---|---|---|
| Unique constraint / unique index | The database refuses the second insert | "This record may exist once" (one order per cart, one redemption per coupon and user) |
| Atomic single statement | Check and write are one operation; the affected-row count says who won | A counter or quantity changes under a condition |
| Transaction with row lock | The second transaction waits for the first to end | The rule spans several reads or tables and cannot be one statement |

Atomic form (PostgreSQL-flavored pseudo-SQL):

```sql
UPDATE coupons SET uses_left = uses_left - 1
WHERE code = :code AND uses_left > 0;
-- rows affected = 1: granted; 0: sold out, reply "unavailable"
```

Why it works in PostgreSQL's default Read Committed: if a concurrent transaction changed the row first, the second command waits, and when the first commits it re-evaluates the `WHERE` clause on the updated row; a row that no longer matches is skipped. The same docs warn this re-evaluation can surprise multi-row statements, so keep the guarded update to the one row you mean. The caller must read the affected-row count; ignoring it recreates the bug while looking fixed.

Unique guard, insert form:

```sql
INSERT INTO redemptions (coupon_id, user_id) VALUES (:c, :u)
ON CONFLICT (coupon_id, user_id) DO NOTHING;
-- inserted count 0: already redeemed
```

`ON CONFLICT` needs a unique index or non-deferrable constraint to act on; the omitted-target form of `DO NOTHING` covers all of them. Without one, no conflict is ever detected. (For `DO UPDATE` the docs state an atomic insert-or-update outcome even under high concurrency; the page gives no such sentence for `DO NOTHING`, so lean on the unique index itself for the guarantee.)

Row lock: `SELECT ... FOR UPDATE` locks the rows returned until the transaction ends; other updaters, deleters and lockers wait, plain `SELECT` is not blocked, and a waiting `SELECT FOR UPDATE` returns the current row version (or no row if it was deleted). Waiting has no limit except deadlock detection, so keep it short. At Repeatable Read or Serializable, a conflicting row change raises an error (SQLSTATE `40001` for Serializable) and the application must retry the whole transaction.

## Why not extra infrastructure

The handout's stance: each added system (Redis, a queue) is one more thing to operate, a cache has an expiry window, and the existing database already solves it; propose new infrastructure only after explaining why the database is insufficient. That is the author's engineering opinion. The trade-off changes when the contended state does not live in one database (see `locks-vs-database-guards-kleppmann.md`).

## How an agent should apply this

- Search for read-then-write on limited resources, not just stock; include scheduling and invites.
- Prefer the first guard that expresses the rule; fall to a row lock only when needed.
- Always check the affected-row count or the unique-violation error and map it to a clean "unavailable" response.
- Write the two-concurrent-requests test first so it fails before the fix.
- Before adding a unique index, query for existing duplicates and report them; delete nothing.
- Name the engine and isolation level you assumed in the report.
