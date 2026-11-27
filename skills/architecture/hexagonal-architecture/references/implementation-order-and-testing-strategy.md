# Implementation Order and Testing Strategy

Sources: https://jmgarridopaz.github.io/content/hexagonalarchitecture.html · https://alistair.cockburn.us/hexagonal-architecture/ · https://docs.aws.amazon.com/pt_br/prescriptive-guidance/latest/cloud-design-patterns/hexagonal-architecture.html · https://github.com/emedina/hexagonal-spring-ref-app · https://github.com/jmgarridopaz/bluezone · Last verified 2026-11-27

## The four-step build order (Garrido de Paz)

Start from the application as a black box with driver and driven ports sketched; driven ports may be incomplete and surface while you work.

| Step | Drivers | Driven | Outcome |
|---|---|---|---|
| 1 | Test driver | Mock or in-memory adapters | Hexagon complete, testable in isolation |
| 2 | Real drivers (web, REST) | Mocks kept | New drivers tested without infrastructure |
| 3 | Test driver from step 1 | Real adapters (database, email) | Each real adapter checked against the real device |
| 4 | Real drivers | Real adapters | End to end; any combination configurable |

Rationale: business rules are verified before technology exists and each later step changes one side. Cockburn's report shows the same idea: acceptance tests against a mock database before the GUI or real database exists, then test databases in integration runs.

## Test taxonomy (Nat Pryce, as quoted by Garrido)

- **Unit**: single objects inside the hexagon.
- **Integration**: adapters, checking the translation between port and outside world.
- **Acceptance**: driver port plus isolated hexagon, against acceptance criteria.
- **System**: whole system including deployment and startup.

How many of each is a shape decision owned by `testing-pyramid-and-shapes`; no source here measures the right ratio.

## Shapes seen in the sources

- **AWS sample (Python, Lambda and DynamoDB)**: a domain class with no outward knowledge; an input-port class that receives output ports through its constructor and orchestrates load, domain call, save; a factory that builds the DynamoDB adapters; a handler that parses the event, calls the factory and returns a status. Domain unit tests exercise the pure class with fixtures. The page is a machine translation; its English original prevails.
- **BlueZone (Java, Garrido)**: driver adapters Web UI and CLI; driven ports rate repository, ticket repository, payment service. The README says: build once, edit a properties file to pick the adapter per port, then run. (GPL-3.0 licensed: ideas only here.)
- **Medina reference app (Spring, MIT)**: modules application-core (domain, use-case handlers, ports), api-adapter, in-memory-repositories, an external adapter, shared-kernel and an assembly module. ArchUnit Hexagonal 1.0.0 tests cover: shared kernel limited to allowed libraries, domain free of infrastructure and frameworks, ports are interfaces, naming and structure of commands, queries and handlers, adapters depend only on allowed packages; allowed dependencies per layer are configured in a test resource file.

## Enforcing the rules mechanically

Prose rules decay. Add an architecture test that fails when the hexagon imports a framework, when one adapter imports another, or when a driver imports a concrete adapter. ArchUnit is the JVM example; for other languages an import-graph test (own suggestion) does the same. Run it in CI.

## Contract test shared by adapters (own sketch)

```
for adapter in [InMemoryTasks(), SqlTasks(testDb)]:
    t = Task(id=1); adapter.save(t)
    assert adapter.byId(1) == t
    assert adapter.byId(99) is None
```

## Anti-patterns

- Integration tests only: slow, and rule bugs hide behind infrastructure failures.
- Mocking domain objects in domain tests (mock only driven ports).
- A fake that diverges from the real adapter; share one contract test across both.

## How an agent should apply this

- Build and test the hexagon with a test driver and in-memory driven adapters before any real adapter.
- Run one contract test against every adapter of a driven port, the in-memory one included.
- Add or keep an architecture test for the dependency direction; run it before reporting structural work done.
- Pick the test level by target: unit for rules, acceptance for use cases, integration for adapters, one system test for wiring.
