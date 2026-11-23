# Implementation Order and Testing Strategy for Hexagonal Apps

Sources: https://jmgarridopaz.github.io/content/hexagonalarchitecture.html · https://docs.aws.amazon.com/pt_br/prescriptive-guidance/latest/cloud-design-patterns/hexagonal-architecture.html · https://github.com/jmgarridopaz/bluezone · https://github.com/emedina/hexagonal-spring-ref-app · Last verified 2026-11-23

## The four-step build order (Garrido de Paz)

Start from the app as a black box with driver and driven port interfaces sketched (driven ports may be incomplete; they surface while implementing drivers).

| Step | Drivers | Driven | Outcome |
|---|---|---|---|
| 1 | Test driver adapter (optionally BDD Given-When-Then) | Mock/in-memory adapters | Hexagon complete and testable in isolation |
| 2 | Real driver adapters (web, REST) | Mocks kept | New drivers tested without infrastructure |
| 3 | Test driver from step 1 | Real adapters (DB, email) | Each real adapter tested against the real device |
| 4 | Real drivers | Real adapters | End-to-end; any combination can be configured |

Why this order works: business rules are verified before any technology exists, and each later step changes exactly one side.

## Test taxonomy (Nat Pryce, as used by Garrido)

- **Unit**: single objects inside the hexagon.
- **Integration**: adapters, proving the translation between port and outside world.
- **Acceptance**: driver port plus isolated hexagon, checking each use case's acceptance criteria.
- **System**: whole system including adapters, deployment, startup.

## Concrete shapes seen in the sources

- **AWS sample (Python, Lambda + DynamoDB)**: the domain class `Recipient` knows nothing about DynamoDB; an input-port class receives output ports through its constructor and orchestrates load, domain call, save; a factory function wires the DynamoDB adapters; the Lambda handler only parses the event, calls the factory and returns a status. Domain unit tests need no mocks because the logic lives in the pure class (refuse a third slot, refuse two slots on one date).
- **BlueZone (Java, Garrido)**: driver adapters Web UI and CLI; driven ports rate repository, ticket repository, payment service; which adapter serves each port is read from a properties file at startup, so a run can swap in mocks without recompiling. Its README states the rules (ticket end time from amount and rate; valid if now is between start and end).
- **Medina reference app (Spring)**: modules application-core, api-adapter, in-memory-repositories, an external adapter, shared-kernel, assembly. In-memory repositories are first-class adapters. ArchUnit-based tests enforce: domain has no framework dependencies, ports are interfaces, adapters depend only on allowed packages; allowed dependencies live in a test resource config. Errors travel as `Either` values rather than exceptions (the project's own choice). The page did not show the actual rule definitions.

## Enforcing the rules mechanically

Prose rules decay. Add an architecture test (ArchUnit on the JVM; for JS/TS an import-graph test or a dependency-cruiser style rule, my suggestion) that fails when the domain imports a framework, when one adapter family imports another, or when a driver imports an adapter. Run it in CI.

## Anti-patterns

- Integration tests only: slow, and business-rule bugs hide behind infrastructure failures.
- Mocking the domain in domain tests (inference: mock only driven ports).
- Mocks that diverge from real adapters; share one contract test across both.

## Example: contract test shared by two adapters (my sketch)

```
for adapter in [InMemoryTasks(), SqlTasks(testDb)]:
    t = Task(id=1); adapter.save(t)
    assert adapter.byId(1) == t
    assert adapter.byId(99) is None
```

## How an agent should apply this

- Build and test the hexagon with a test driver plus in-memory driven adapters before writing any real adapter.
- Add a contract test run against every adapter of a driven port, the in-memory one included.
- Add or keep an architecture test enforcing the dependency direction; run it before reporting structural work done.
- Pick the test level by target: unit for rules, integration for adapters, acceptance for use cases, one system test for wiring.
