# Trigger evals: race-condition-fix

Last verified 2026-11-27. Manual cases, not yet run as a scored eval.

## Should trigger

1. "We sometimes sell more tickets than seats; two buyers get the last seat." Expected: `race-condition-fix`.
2. "A coupon with one use was redeemed twice when users double-clicked at the same moment." Expected: `race-condition-fix`.
3. "Should I add a Redis lock around the stock decrement?" Expected: `race-condition-fix`.

## Near-miss (should not trigger)

1. "The payment webhook was delivered three times and credited the account three times." Expected: `idempotency-fix`.
2. "If the server dies after creating the order but before the items, we keep an empty order." Expected: `transaction-fix`.
3. "Design a distributed lock service with leader election across regions." Expected: `background-worker-job-scheduler` or an architecture skill, not this one.
