# Trigger evals for vertical-slice-architecture

Last verified 2026-11-27. Starting set, not a scored eval.

Should trigger (expected: this skill)
1. "Every feature touches Controllers, Services, Repositories and DTOs. How do I organize by feature instead?"
2. "My IOrderService just forwards to IOrderRepository. Do I need them?"
3. "Two handlers have similar validators. Share them or keep them in each feature folder?"

Near-miss (expected: neighbor)
1. "Enforce the dependency rule between domain, application and infrastructure circles" -> `clean-architecture`
2. "Split the read model from the write model with separate stores" -> `cqrs-pattern`
3. "Isolate the core behind ports and adapters with fakes" -> `hexagonal-architecture`
