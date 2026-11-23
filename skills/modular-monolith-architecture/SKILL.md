---
name: modular-monolith-architecture
description: Use when designing, reviewing, or refactoring a Modular Monolith (DDD Bounded Contexts packaged as independent vertical modules inside a single deployable unit), enforcing module encapsulation and database schema isolation, or setting up in-process contract/event communication between modules. Gives module boundary rules, data isolation levels, inter-module communication patterns, slice testing, and common mistakes.
---

# Modular Monolith Architecture

One idea: deploy the application as a **single runtime unit**, but partition its code and data into **autonomous, domain-driven vertical modules (Bounded Contexts)** with strict compile-time encapsulation, isolated database schemas/tables, and explicit public contracts or integration events. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary

| Term | Meaning | Test sentence |
|---|---|---|
| Application Module | a vertical slice corresponding to one DDD Bounded Context (e.g., `Meetings`, `Payments`, `UserAccess`, `Administration`), owning its domain, application logic, and persistence | "high cohesion inside, minimal coupling outside" |
| Public API / Named Interface | the thin, explicit contract (facade, command/query interface, or published integration events) a module exposes to other modules | "the only types another module is allowed to import" |
| Internal Module Types | domain entities, repositories, handlers, and DB tables hidden inside the module (`internal` / package-private) | "invisible to every other module at compile time" |
| Integration Event (In-Process / Outbox) | an immutable fact published by one module via an in-process event bus (backed by a transactional Outbox/Inbox) to notify other modules | "decouples modules temporally and logically inside the same process" |
| Logical Data Isolation | every module owns its own database schema (e.g., `payments.subscriptions`, `meetings.meetings`) and never joins or queries another module's tables directly | "one database server, strictly separate schemas per module" |
| Module Composition Root | per-module DI container or registration block that prevents accidental cross-module service injection | "a module cannot accidentally resolve another module's internal repository" |

## Module boundary and dependency rules

1. **Encapsulate module internals by default:** Make all domain entities, value objects, repositories, and database mappings package-private / `internal`. Only the module's public facade or `IntegrationEvents` contract package is visible to the outside world.
2. **No cross-module database joins or shared tables:** Module A must never query, join, or hold a foreign key to a table owned by Module B. Place each module's tables in its own database schema (e.g., `schema_a.*`, `schema_b.*`) and enforce schema ownership.
3. **Prefer asynchronous in-process Integration Events over synchronous calls:** When Module A completes a business action that Module B cares about, publish an `IntegrationEvent` via the transactional Outbox (`ApplicationEventListener` / Outbox processor) rather than coupling Module A's transaction to Module B's internal logic.
4. **Communicate only with primitive/DTO contracts:** Never pass a Domain Entity or ORM entity from one module to another. Any synchronous module-to-module call or integration event payload must contain only immutable primitives and contract DTOs.
5. **Each module chooses its own internal complexity:** A core domain module can use rich DDD + Clean/Hexagonal architecture, while a simple supporting module inside the same monolith can use simple CRUD.
6. **Verify boundaries automatically in CI:** Use architecture verification tools (Spring Modulith `ApplicationModules.of(...).verify()`, `NetArchTest`, `ArchUnit`, or `dependency-cruiser`) to fail the build on any cyclic dependency or unauthorized import of a module's internal packages.

## Building order

1. **Discover Bounded Contexts (Event Storming / Domain Mapping):** Group business capabilities into autonomous vertical modules (`modules/<context-name>`) rather than global horizontal layers (`controllers/`, `services/`, `models/`).
2. **Isolate module persistence:** Give each module its own schema (`<module_name>`), migration history, and repository/ORM context.
3. **Define the module's public API and internal composition root:** Expose only a thin contract (commands/queries/events) and keep the rest internal.
4. **Wire reliable inter-module messaging:** Add an Outbox + Inbox table per module (or framework-managed persistent event publication register like Spring Modulith's event publication log) so cross-module event handlers are idempotent and crash-safe.
5. **Lock boundaries with an architecture test:** Run module verification on every commit.

## Tests per level

| Level | Test | Uses |
|---|---|---|
| Module Domain & Use Cases | unit / module acceptance test | tests the module through its public facade with in-memory fakes |
| Standalone Module Slice (`@ApplicationModuleTest`) | isolated module integration test | boots **only** that module's configuration and schema against a real test DB, mocking or publishing events at the boundary |
| Architecture Verification | static / bytecode dependency check | verifies zero circular module dependencies and zero leaks of internal types |
| Cross-Module Scenario | system / integration test | verifies an end-to-end flow where Module A publishes an event and Module B's listener processes it |

## When it earns its keep

- **Worth it:** Complex business domains with multiple Bounded Contexts, growing engineering teams that want clear module ownership without the operational tax of Kubernetes/microservices, and legacy monoliths preparing a safe strangler path toward selective microservice extraction.
- **Not worth it:** Single-context CRUD apps where there is only one logical domain module, or systems where modules genuinely need independent hardware runtimes, polyglot languages, or independent deployment cycles right now (use `microservices-architecture`).

## Mistakes to catch

- **Cheating at the database layer:** Enforcing code separation in modules while still writing SQL `JOIN`s across module tables in a shared `dbo`/`public` schema. That destroys module autonomy and prevents future extraction.
- **Sharing a "Common Domain" dump:** Putting shared business entities (`User`, `Account`, `Product`) into a global `shared/domain` folder imported by all modules. Each Bounded Context must own its own local representation; share only technical building blocks (UUIDs, Outbox primitives, Clock).
- **Sharing a single global DI container without module scopes:** Allowing any developer to `@Autowired` / inject `PaymentsRepository` directly inside `MeetingsHandler`.
- **In-memory fire-and-forget events without an Outbox:** Publishing cross-module events in memory after a DB commit without persisting them in the same transaction — losing events if the process crashes mid-flight.

## Deep references

- [DDD reference implementation](references/modular-monolith-ddd-reference-implementation.md) — full-autonomy module rules, outbox/inbox, testing
- [Spring Modulith structure and verification](references/spring-modulith-structure-and-verification.md) — module detection, named interfaces, verify()
- [Spring Modulith events and testing](references/spring-modulith-events-and-testing.md) — publication registry, externalization, module tests
