# Persistence Testing and CQRS Reads

Sources: https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design · https://martinfowler.com/eaaCatalog/repository.html · Last verified 2026-11-27

## Writes through repositories, reads around them
Microsoft's guidance: in a DDD microservice the only channel that updates the database is the repositories (one per aggregate root), because the root controls invariants. Queries change nothing, so they may use other channels. With CQS/CQRS, side queries run outside the domain model using plain SQL (their example uses Dapper), joining any tables the screen needs, unconstrained by aggregates. A command handler then loads aggregates through repositories, mutates them in memory, and persists in a transaction.

| Concern | Path |
|---|---|
| Command (state change) | handler -> repository -> aggregate -> unit of work |
| Query (screen/report) | query service -> SQL/read model -> view DTO |
Related: `cqrs-pattern`. Shape of the read result is `dto-mapper-anti-corruption-layer` territory; SQL tuning is `query-performance`.

## Testing consequences
- Repository interfaces in the domain/application layer plus dependency injection allow fake or in-memory repositories, so unit tests cover domain logic without a database. Database tests are integration tests: fewer, slower, less parallel-friendly.
- Unit tests assume the repository delivers aggregates and stores them correctly; the repository itself is verified by integration tests against the real engine.
- Counterpoint from the Microsoft article (quoting Bogard): mocking repositories still needs a real integration test; with CQRS he saw no need for repositories. Practical reading (my inference): use fakes for domain/use-case tests, but never rely only on them.

## Contract test for adapters
Write one shared test suite that every adapter (SQL, in-memory fake) must pass: add then get returns equal aggregate; missing id returns null; concurrent update raises conflict; removed aggregate is gone. This keeps the fake honest.
```
for repo_factory in (InMemoryOrders, SqlOrders):
    repo = repo_factory()
    repo.add(order); assert repo.get(order.id) == order
```

## Cross-cutting concerns via decorators
Because the repository is an abstraction, caching, logging and retry can wrap it (decorator/proxy) instead of living inside data-access code (`caching-strategies`).

## Anti-patterns
Mock-only persistence testing; fakes that diverge from SQL semantics (ordering, null handling, uniqueness); running hundreds of DB tests in unit stage; query methods growing parameters until the repository is a query engine.
