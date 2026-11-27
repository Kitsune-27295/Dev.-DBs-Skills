# Trigger Evals: ssot-and-dry

Last verified 2026-11-27 (paper test against the description; not run on a host).

## Should trigger

1. "The discount tiers are hard-coded in the service, an OpenAPI enum and the UI dropdown. How do I keep one source?" -> `ssot-and-dry`
2. "Reviewer says validate_age and validate_quantity are duplicates because the bodies match. Merge them?" -> `ssot-and-dry` (coincidence test)
3. "Should Sales and Support share one Customer class to avoid duplication?" -> `ssot-and-dry` (Bounded Context limit)

## Near misses

1. "Add a new payment provider without editing checkout." -> `open-closed-principle`
2. "This class is edited by finance and ops for unrelated tickets; split it." -> `single-responsibility-cohesion`
3. "Is it worth abstracting after only two copies?" -> `kiss-yagni-aha`
