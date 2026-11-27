# Trigger Evals

Last verified 2026-11-27. Prompts checked by reading against the description.

## Should trigger (value-objects-type-invariants)

1. "Our invoice split divides by 3 and rounds each share, and the total is off by a cent."
2. "This `User` has `isVerified`, `verifiedAt?` and `token?`; can the type prevent bad combinations?"
3. "Make `DateRange` immutable with proper equality so it works in a Set."

## Near misses (belong elsewhere)

1. "Parse the request body into typed values at the boundary." -> `defensive-domain-modeling`
2. "Make the DB reject negative amounts and null currencies." -> `schema-and-constraints`
3. "Model the order lifecycle with guards and transitions." -> `state-machine-workflow-engine`
