# Trigger evals: idempotency-fix

Last verified 2026-11-27. Manual cases, not yet run as a scored eval.

## Should trigger

1. "Our payment webhook sometimes runs twice and customers get two welcome emails." Expected: `idempotency-fix`.
2. "How do I make my POST /orders endpoint safe if the client retries after a timeout?" Expected: `idempotency-fix`.
3. "Audit our Stripe webhook handler: signature check, duplicates, retries." Expected: `idempotency-fix`.

## Near-miss (should not trigger)

1. "Two customers bought the last item at the same instant and stock went negative." Expected: `race-condition-fix`.
2. "A crash between inserting the order and its items leaves an order with no items." Expected: `transaction-fix`.
3. "Design reliable event publishing between services with an outbox and saga." Expected: `saga-transactional-outbox-pattern`.
