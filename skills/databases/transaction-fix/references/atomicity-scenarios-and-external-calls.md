# Atomicity scenarios and the external-call boundary

Sources: PostgreSQL docs, Transactions tutorial (https://www.postgresql.org/docs/current/tutorial-transactions.html); microservices.io Transactional Outbox (https://microservices.io/patterns/data/transactional-outbox.html); the handout section "2. Transação" (https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe); the video of the same series, chapter 03 (https://www.youtube.com/watch?v=TL4T9ZESamI, page text not readable, chapters unverified) · Last verified 2026-11-27

## What a transaction promises

Several steps become one unit: from other transactions' point of view it happens completely or not at all, and if an error prevents completion none of the steps take effect. Changes stay invisible to others until commit, then appear together. Commit is durable once acknowledged. `ROLLBACK` cancels everything since `BEGIN`. The classic story: move 100 from account A to B; if the server dies after the debit and before the credit, the money vanishes unless both writes sit in one transaction.

An error inside a PostgreSQL transaction block puts it in an aborted state; only `ROLLBACK` (or `COMMIT`, which also rolls back) or `ROLLBACK TO` a savepoint recovers it. Other engines differ; check the one in use.

## Scenarios worth hunting for

| Scenario | What breaks without a transaction |
|---|---|
| Checkout: create order, take stock, record payment | Order with no stock change, or payment without an order |
| Balance transfer | Money disappears or duplicates |
| Cancellation or refund | Status changed but ledger entry missing |
| Signup writing several tables | User without profile or settings |
| Sale with installments and address | A sale with half its parts, hard to detect later |

Backend-as-a-service warning (handout claim, consistent with the PostgreSQL rule that each statement commits alone): three separate API calls (debit, credit, status) are three independent operations. Bundle them in a database function or a server endpoint that opens one transaction; check the provider's documentation for the mechanism.

ORMs usually support transactions but will not use them unless the code asks; name the operations explicitly.

## The external-call boundary

Handout rule: email, payment gateway and webhooks stay outside the transaction. Reasons: a rollback cannot recall an email already sent, and a transaction open over a slow call keeps row locks and connections busy (PostgreSQL's locking docs discourage long-open transactions). Shapes (this skill's own practice):

```
# commit first, then call
tx: insert order, items; commit
then: send confirmation email   # on failure retry; the order is already correct

# record intent, act afterwards
tx: insert order, insert outbox(send_email)   # atomic together
worker: read outbox, send, mark done
```

Commit-then-call can lose the call if the process dies right after commit; the outbox shape avoids that but delivers at least once, so the receiver must tolerate duplicates (owner: `saga-transactional-outbox-pattern`; dedupe: `idempotency-fix`). A payment taken at a provider cannot be rolled back by the database; name the compensation (refund, reversal).

## Forced-failure test

```
make the second write throw
expect: the first write is absent
expect: the caller receives the error
```

It must fail on the original code; that failure is the evidence the fix matters.

## How an agent should apply this

- List multi-write operations with order of writes and `file:line` before editing.
- Write the one-sentence invariant and the failing forced-error test first.
- Wrap only existing writes; keep decision reads inside; never change business rules.
- Do not catch and continue inside the transaction; let the error reach the caller after rollback.
- Keep email, payment and webhook calls outside; say how failures are retried or compensated.
- If the steps are separate client calls, propose one endpoint or function.
