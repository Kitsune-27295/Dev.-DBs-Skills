# Sources - Repository & Unit of Work

Re-fetched with WebFetch on 2026-11-27 (Firecrawl had no credits). WebFetch returns a model-produced digest, not raw text.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://martinfowler.com/eaaCatalog/repository.html | 200 OK, 2026-11-27 | Definition, collection-like interface, declarative queries, one-way dependency; no explicit when-to-use section |
| https://martinfowler.com/eaaCatalog/unitOfWork.html | 200 OK, 2026-11-27 | Definition and problem statement; mechanics are in PoEAA ch. 11 (not read) |
| https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design | 200 OK, 2026-11-27 (page dated 2018, updated 2023) | One repository per aggregate root, IAggregateRoot bound, interface placement, testing, DAL comparison, DbContext as UoW, CQRS query bypass, repositories not mandatory |

## Reading limits
- UoW mechanics (change set ordering, identity map, optimistic checks) and ORM-session equivalence beyond EF are general knowledge, not read from a source.
- The contract-test recipe and in-memory fakes are our recommendation; Microsoft only describes mock repositories and unit-versus-integration tests.

## Claims not adopted
- That SQLAlchemy or Hibernate sessions are full UoW implementations: not read; stated only as a general-knowledge aside.
- Fowler's "when to use" for Repository: implied by the page, not stated.
