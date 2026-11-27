# Trigger Evals

Last verified 2026-11-27. Three prompts that should load this skill and three near-misses that belong elsewhere.

## Should trigger

1. "Set up arc42 docs for our new service and tell me which sections to write first." Expected: `arc42-api-contracts-architecture`.
2. "We expose a WebSocket feed. Should it be OpenAPI or AsyncAPI, and what must the docs add beyond the generated reference?" Expected: `arc42-api-contracts-architecture`.
3. "Add CI that validates openapi.yaml and fails on breaking changes." Expected: `arc42-api-contracts-architecture`.

## Near-miss (should not trigger)

1. "Draw a C4 container diagram for this system." Expected: `c4-model-architecture`.
2. "Write an ADR for choosing Kafka over RabbitMQ." Expected: `adr-architecture`.
3. "Split our docs into tutorial, how-to, reference and explanation pages." Expected: `diataxis-documentation-architecture`.
