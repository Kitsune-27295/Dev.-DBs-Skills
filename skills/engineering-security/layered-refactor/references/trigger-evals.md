# Trigger Evals

Last verified 2026-11-27. Starting-point set (3 + 3), not a scored run.

| Prompt | Expected skill |
|---|---|
| "orders.py is 2,000 lines: SQL, Stripe calls and discount logic all inline. Split it without changing behavior." | `layered-refactor` |
| "Nobody dares touch checkout.tsx; each fix breaks another screen. How do I untangle it safely?" | `layered-refactor` |
| "Separate UI, rules and data access in this one component, small steps, tests after each." | `layered-refactor` |
| "Should our new service use strict or relaxed layers, and one tier or three?" | `layered-n-tier-architecture` |
| "Deepen this shallow module so its interface is small." | `codebase-design` |
| "Write integration tests for the checkout flow before we touch it." | `integration-tests` |
