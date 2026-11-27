---
name: repository-unit-of-work
description: "Decide how the domain loads and saves aggregates and where a transaction starts and ends: one Repository per aggregate root (not per table) with a domain-owned collection-like interface, one Unit of Work commit per use case issued by the application layer, ORM contexts as built-in UoW, reads served by query services, in-memory fakes proven by contract tests. Use when adding or reviewing repositories, DbContext or session scoping, transaction boundaries, generic-repository debates, or persistence details leaking into domain code; not for SQL tuning (query-performance), schema design (schema-and-constraints) or debugging a failing transaction (transaction-fix)."
---

# Repository & Unit of Work

One idea: **the domain talks to a collection-like abstraction of aggregates, and one Unit of Work decides when that in-memory work becomes a single transaction.** Everything else (SQL dialect, ORM, caching) is an adapter detail. Sources, statuses and claims not adopted: [references/sources.md](references/sources.md).

Boundary: this skill owns the persistence abstraction and transaction scope. SQL tuning is `query-performance`; schema and constraints are `schema-and-constraints`; diagnosing a broken transaction is `transaction-fix`; boundary data shapes and model translation are `dto-mapper-anti-corruption-layer`; command/query split itself is `cqrs-pattern`; port/adapter structure is `hexagonal-architecture` and `clean-architecture`.

---

## 1. What the Two Patterns Are

| Pattern | Fowler's definition | Practical meaning |
|---|---|---|
| Repository | Mediates between domain and data mapping using a collection-like interface | `get/add/find_x` on aggregates; query logic lives in one place |
| Unit of Work | Tracks what changed during a business transaction and writes it out, handling concurrency | One `commit` per use case; batched writes; one DB transaction |

Microsoft's guide states that EF's `DbContext` already implements both patterns (`SaveChanges` is the commit); other ORM sessions play a similar role (our general knowledge, not read here). Wrap only for a real reason.

## 2. Repository Rules

1. **One repository per aggregate root, never per table or per entity.** Children are reached through the root. Enforce with a generic bound to an aggregate-root marker type.
2. **Interface belongs to the domain/application side**; implementation in infrastructure. Dependency points inward.
3. **Collection semantics:** `get`, `add`, `remove`, intent-named finders. No `save_all_columns`, no raw SQL handles, no lazily evaluated query objects leaking out.
4. **Load whole aggregates**; the root enforces invariants after loading.
5. **No business rules, no commits, no DTO returns** inside a repository.
6. Cross-cutting (cache, log, retry) via decorators on the interface, not inside queries (`caching-strategies`).
7. Repositories are **optional**: skip them for thin CRUD or when the ORM is the accepted abstraction; they earn their place with a rich domain model and heavy or duplicated querying.

## 3. Unit of Work Rules

| Rule | Reason |
|---|---|
| One unit per command/use case, opened and committed by the application layer | Domain must not own transaction boundaries |
| Repositories never commit | Single commit point |
| Modify one aggregate per transaction by default | Aggregate = consistency boundary; cross-aggregate effects go through domain events (`saga-transactional-outbox-pattern`) |
| Write outbox rows/events in the same unit | Atomic state + message |
| Never hold a unit across user think time or remote calls | Locks and stale data |
| Retry the whole unit on transient/optimistic conflicts, idempotently | `idempotency-fix` |
| Use version/concurrency tokens for contested aggregates | Lost-update protection |

```
with uow:                      # begin
    o = uow.orders.get(cmd.id)
    o.confirm()
    uow.outbox.add(OrderConfirmed(o.id))
    uow.commit()               # single transaction
```

## 4. Reads Do Not Need Repositories

Queries change no state, so use query services or read models (plain SQL, projections) returning view-shaped data; repositories are for loading aggregates to change them. This avoids bending aggregate repositories into reporting engines. See [persistence-testing-and-cqrs-reads.md](references/persistence-testing-and-cqrs-reads.md) and `cqrs-pattern`.

## 5. Testing

- Domain and use-case tests: in-memory fake repositories, no database.
- Adapters: a shared contract test run against both the fake and the real engine, so fakes cannot drift.
- Few integration tests against the real database; many fast unit tests (`testing-pyramid-and-shapes`, `integration-tests`).
- A mock-only strategy is rejected; the mapping and transaction behavior need real-engine verification.

## 6. Placement in Microservices

- Each service owns its database; repositories exist only for that service's aggregates (`microservices-architecture`, `soa-vs-microservices-architecture`).
- Never a repository over another service's tables; call its API through an adapter that translates models (`dto-mapper-anti-corruption-layer`).
- Domain entities are not API payloads; translate at the boundary.

## Reject on Sight

- `GenericRepository<T>` with `GetAll()`, `Update(entity)` for every table.
- Repository per table/child entity.
- `SaveChanges()` / `commit()` called inside repository methods or domain entities.
- Controllers talking to `DbContext` while the domain is also expected to be persistence-ignorant (pick one deliberately).
- Repository returning `IQueryable`/query builder to the application layer.
- Multi-aggregate transactions justified by "it is simpler".

## Quick Decision Checklist

- [ ] Is each repository tied to exactly one aggregate root?
- [ ] Does the interface live inward of the infrastructure implementation?
- [ ] Is there one commit per use case, issued by the application layer?
- [ ] Are events/outbox rows written in the same unit as state?
- [ ] Are reads served by query services, not aggregate repositories?
- [ ] Do fakes pass the same contract tests as the real adapter?
- [ ] Did I check whether a repository is warranted at all?

## Deep references

- [Trigger evals](references/trigger-evals.md) — when checking that this description fires on persistence-boundary work and not on its neighbors

- [Repository pattern and aggregates](references/repository-pattern-and-aggregates.md) — definition, one-per-root rule, interface shape, repository vs DAL, trade-offs.
- [Unit of Work and transaction scope](references/unit-of-work-and-transaction-scope.md) — what is tracked, commit mechanics, scope rules, failure modes.
- [Persistence testing and CQRS reads](references/persistence-testing-and-cqrs-reads.md) — query bypass, fakes, contract tests, decorators.
