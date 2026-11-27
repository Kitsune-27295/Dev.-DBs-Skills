# Repository Pattern and Aggregates

Sources: https://martinfowler.com/eaaCatalog/repository.html · https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design · Last verified 2026-11-27

## Definition
Fowler (Hieatt and Mee, PoEAA 2003): a Repository mediates between the domain and data-mapping layers using a collection-like interface for domain objects. Clients build queries declaratively and the repository returns matching objects; query construction lives in one place and the dependency runs one way, from persistence toward the domain. It sits on top of a mapping layer such as Data Mapper.

Microsoft's DDD guidance restates it: repository interfaces are defined in the domain model, implemented as persistence-specific adapters in infrastructure, so the domain stays free of persistence concerns.

## Mechanics
1. Domain or application code asks for an aggregate by identity or specification: `orders.get(order_id)`.
2. The repository loads the whole aggregate (root plus its children) into memory.
3. Behavior runs on the in-memory aggregate; invariants are enforced by the root.
4. The caller adds/updates through the repository, and persistence is committed by the unit of work (see `unit-of-work-and-transaction-scope.md`).

## One repository per aggregate root, never per table
- The aggregate root guards invariants and transactional consistency, so the repository boundary is the aggregate boundary. A repository per table lets callers mutate children behind the root's back.
- Enforce it in types: a generic `Repository<T extends AggregateRoot>` (Microsoft uses an `IAggregateRoot` marker).
- The only write path into the transactional store goes through repositories; read-only queries may bypass them (see `persistence-testing-and-cqrs-reads.md`).

## Interface shape (language-neutral)
```
interface OrderRepository {      // lives in the domain / application port
  get(id: OrderId): Order | null
  add(order: Order): void
  find_open_for(customer: CustomerId): Order[]   // intent-revealing query
}
```
Prefer intent-named finders or a small specification object over a generic `query(sql)`; avoid returning `IQueryable`-style leaky handles.

## Repository vs DAL
A classic DAL class works per table/row, is tightly coupled to callers, and often lacks transactions. A repository hides persistence details behind an abstraction, enabling decorators/proxies for caching, logging and error handling, and multiple adapters per environment.

## Forces and trade-offs
- Benefits: testable domain logic, one place for query logic, swappable storage, enforced aggregate boundary.
- Costs: indirection; hides persistence power (Bogard's critique quoted by Microsoft: it hides important details of the persistence mechanism, and with CQRS repositories may be unnecessary). Microsoft states repositories are optional, unlike aggregates and a rich domain model.
- Fowler's page has no explicit when-to-use section; its text implies value with a complex domain model, many domain classes or heavy querying (our reading).

## Anti-patterns
Generic CRUD repository per entity; repository methods returning DTOs or view models (that is a query service); business rules inside the repository; leaking ORM entities or lazy-loaded proxies upward; one repository holding unrelated aggregates ("god repository").
