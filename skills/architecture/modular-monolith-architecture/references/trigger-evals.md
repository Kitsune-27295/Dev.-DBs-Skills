# Trigger evals: modular-monolith-architecture

Last verified 2026-11-27. Starting-point prompts, not a measured trigger rate.

## Should trigger

1. "Our billing code imports tables from the orders package and joins them. How do we make these proper modules inside one app?"
2. "Set up Spring Modulith verification so a module can't touch another module's internals."
3. "We want module-per-bounded-context in a single deployable and each module with its own schema; review my layout."

## Near misses (expected skill)

1. "Split the checkout module into its own service with its own pipeline." -> `microservices-architecture`
2. "How should I design the outbox table and retry for my event publisher?" -> `saga-transactional-outbox-pattern`
3. "Organize controllers, services and repositories inside one module into layers." -> `layered-n-tier-architecture`
