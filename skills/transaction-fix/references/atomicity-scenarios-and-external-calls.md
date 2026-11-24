# Atomicity scenarios and the external-call boundary

Sources: video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 03 11:46-15:50; handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe section "2. Transação" · Last verified 2026-11-24

## What a transaction promises

Several writes become one unit: all land (commit) or none do (rollback). The lesson's story: move 100 from João to Maria; if the server dies after the debit and before the credit, the money vanishes. With a transaction the database undoes the partial work. The video ties this to the "A" in ACID (atomicity).

## Scenarios worth hunting for

| Scenario | What breaks without a transaction |
|---|---|
| Checkout: create order, decrement stock, record payment | Order exists with no stock change, or payment recorded without an order |
| Balance transfer | Money disappears or duplicates |
| Cancellation or refund | Status changed but ledger entry missing |
| Signup writing several tables | User without profile or settings |
| ERP-style sale (video example): sale, installments, delivery address, payment | A sale with half its parts, hard to detect later |

The video's backend-as-a-service warning: three separate API calls (debit, credit, status change) are three independent operations. If one fails, the others stay. The remedy it names is to send them as one package: in practice a database function or a server endpoint that opens the transaction (the video says these services offer ways to bundle calls; specific mechanisms are not named, so check the provider's documentation).

## ORMs

The video notes most ORMs support transactions but the AI will not use them unless told the problem exists. This is why the prompt names the operations explicitly.

## The external-call boundary (handout rule)

Email, payment gateway and webhooks stay outside the transaction. Reasons (partly inference): a rollback cannot recall an email already sent, and holding a transaction open over a slow network call keeps locks and connections busy. Typical shapes:

```
# commit first, then call
tx: insert order, items; commit
then: send confirmation email   # if this fails, retry; the order is already correct

# record intent, act afterwards
tx: insert order, insert outbox(row: send_email)   # atomic together
worker: read outbox, send, mark done
```

A payment taken at a provider cannot be rolled back by the database; name the compensation (refund, reversal) in the report.

## Forced-failure test (the proof)

```
test: make the second write throw
expect: first write is absent (nothing stored)
expect: caller receives the error
```

The test must fail on the original code; that failure is the evidence that the fix matters.

## How an agent should apply this

- List every operation that writes in more than one place, with order of writes and `file:line`, before editing.
- Write the one-sentence invariant and a failing forced-error test first.
- Wrap only existing writes; do not change business rules or values.
- Keep email, payment and webhook calls outside the transaction and describe how failures are retried or compensated.
- If the steps are separate client calls, propose one endpoint or database function instead of piecemeal calls.
