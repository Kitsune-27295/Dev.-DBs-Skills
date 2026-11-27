# Trigger Evals

Last verified 2026-11-27. Starting points for a description check, not a measured result.

## Should trigger (this skill)
1. "Our Order has status plus isPaid, isShipped, isCancelled and bugs from impossible combos. Model the lifecycle."
2. "Refunds are allowed only after shipping and never twice; where do those rules live?"
3. "Table, State pattern or XState for an approval flow with a timeout and parallel review tracks?"

## Near-misses (other skill)
1. "Coordinate payment, stock and shipping services with compensation on failure." -> `saga-transactional-outbox-pattern`
2. "Store every status change as an immutable event and rebuild state by replay." -> `event-sourcing-pattern`
3. "Make illegal states unrepresentable with sum types in the domain model." -> `defensive-domain-modeling`
