# Trigger evals: transaction-fix

Last verified 2026-11-27. Manual cases, not yet run as a scored eval.

## Should trigger

1. "Checkout creates the order, then decrements stock; if stock fails we keep an order with no items. Fix it." Expected: `transaction-fix`.
2. "A money transfer debits one account and credits another in two calls. Make it all or nothing." Expected: `transaction-fix`.
3. "Signup writes users, profiles and settings; sometimes only the user row exists." Expected: `transaction-fix`.

## Near-miss (should not trigger)

1. "Two users bought the last item at the same time and stock went negative." Expected: `race-condition-fix`.
2. "The payment webhook ran twice and credited the account twice." Expected: `idempotency-fix`.
3. "Order service and payment service must stay consistent; design the compensation flow." Expected: `saga-transactional-outbox-pattern`.
