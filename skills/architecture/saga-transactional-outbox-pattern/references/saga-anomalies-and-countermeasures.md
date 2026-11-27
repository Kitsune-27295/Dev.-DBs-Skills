# Saga Transaction Classes, Isolation Anomalies and Countermeasures

Sources: https://microservices.io/patterns/data/saga.html · https://learn.microsoft.com/en-us/azure/architecture/patterns/saga · Last verified 2026-11-27

## Why sagas exist
With Database per Service, a rule that spans two services (Richardson's example: an order must not exceed a customer's credit limit, with Orders and Customers owned by different services) cannot be enforced in one local ACID transaction, and 2PC is ruled out. A saga is a reliably coordinated sequence of local transactions; on a business-rule failure, compensating transactions undo what earlier steps committed. You get consistency but lose two things: automatic rollback (you write the undo logic) and the "I" in ACID (isolation).

## Step classes (Microsoft's vocabulary)
| Class | Meaning | Design consequence |
|---|---|---|
| Compensable | Can be undone by an opposite-effect transaction | Needs a written, idempotent compensation |
| Pivot | Point of no return; either the last compensable step or the first retryable one; may itself be non-compensable | Place it after every step that can fail for business reasons (design advice, not from the page) |
| Retryable | After the pivot; idempotent, must eventually succeed | Retry with backoff; never compensate |

Ordering rule (derived from the above): compensable steps first, pivot next, retryable steps last. Anything that can fail for business reasons belongs before or at the pivot.

## Anomalies caused by missing isolation
- Lost update: one saga overwrites changes another saga made without seeing them.
- Dirty read: reading data another saga has modified but may still compensate.
- Fuzzy (non-repeatable) read: two steps of one saga see different data because another saga updated it in between.

## Countermeasures
| Countermeasure | Mechanism | Use when |
|---|---|---|
| Semantic lock | Compensable step sets an app-level flag (e.g. `PENDING`) that other transactions must respect or wait on | Records mutated by a saga must not be treated as final by others |
| Commutative updates | Make operations order-independent (debit/credit instead of set-balance) | Updates can be expressed as deltas |
| Pessimistic view | Reorder steps so data updates happen in retryable steps, removing dirty reads | You control step order |
| Reread value | Re-read before write; if changed, abort step and restart saga | Cheap optimistic check, low contention |
| Version file | Log operations per record and apply in correct order | Out-of-order arrival (e.g. cancel before create) |
| By value (risk-based) | Pick concurrency mechanism by business risk: saga for low-value, distributed transaction for high-value | Mixed-risk workloads |

Richardson's page does not list the anomalies, countermeasures or step classes (re-checked 2026-11-27); it says countermeasures are needed and points to chapter 4.3 of *Microservices Patterns*. The lists above come from the Azure page. Azure adds that compensations might not always succeed.

## Failure modes
- Compensations that can themselves fail: they must be retryable and idempotent; park in a dead-letter or manual queue after bounded retries.
- Semantic lock never released because the saga died: needs saga timeouts and a recovery job (inference).
- Treating a pivot as compensable and "canceling" after the point of no return.

## Reporting the outcome to the client
Three options from Richardson: (1) block until the saga ends; (2) return an id immediately and let the client poll (`GET /orders/{id}`); (3) return an id and push the result (WebSocket/webhook). Option 2 or 3 is the sensible default for sagas that cross more than two services (inference).

## Example: semantic lock in an order saga
```
Order: PENDING --(credit reserved)--> APPROVED
                 \--(credit rejected)--> REJECTED
# Other flows see PENDING and refuse "ship" or "cancel", or queue behind it.
```

## How an agent should apply this
- Label every saga step compensable, pivot or retryable in the design before coding it.
- Push anything that can fail on a business rule ahead of the pivot.
- For each shared record, name the anomaly it can suffer and choose one countermeasure explicitly; default to semantic lock plus reread value.
- Require idempotency keys on forward and compensating handlers and a timeout plus recovery path for every lock.
- Define how the client learns the result (poll or push) before implementing the endpoint.
