# Trigger Evals

Last verified 2026-11-27

Should trigger `ddd-domain-heuristics-debiasing`:
1. "We have eight modules. Which are core and which should we buy instead of build?"
2. "Do we really need aggregates and repositories for this admin CRUD module?"
3. "Before we approve this microservice split, run a bias check on the decision."

Near misses (expected skill):
1. "Write the ADR file with status, context and consequences." -> `adr-architecture`
2. "Model Order as an aggregate that protects its invariants." -> `defensive-domain-modeling`
3. "Design the event store and snapshots for this aggregate." -> `event-sourcing-pattern`
