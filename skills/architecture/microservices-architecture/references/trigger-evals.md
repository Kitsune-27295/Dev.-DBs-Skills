# Trigger Evals

Last verified 2026-11-27. Expected skill per prompt.

Should trigger `microservices-architecture`:
1. "We have 12 services but they all write to one Postgres schema and deploy together. Is this microservices?"
2. "Three teams are blocked by shared releases; should we split the order domain out, and what must be in place first?"
3. "How do I keep an order and a payment service consistent without distributed transactions?" (here: pointer to `saga-transactional-outbox-pattern` for the mechanics)

Near-misses:
1. "Compare our ESB-based SOA with microservices" -> `soa-vs-microservices-architecture`
2. "Structure our single deployable app into bounded-context modules" -> `modular-monolith-architecture`
3. "Our Lambda cold starts are slow" -> `serverless-architecture`
