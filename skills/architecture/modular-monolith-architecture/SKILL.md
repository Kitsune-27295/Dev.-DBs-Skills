---
name: modular-monolith-architecture
description: Structure one deployable application as autonomous domain modules (DDD bounded contexts) with hidden internals, a separate schema per module, explicit public contracts or in-process events, and an architecture test that fails the build on boundary leaks. Covers module boundary rules, data isolation, inter-module communication, slice testing and the Spring Modulith and .NET reference designs. Not for independently deployed services (see microservices-architecture), layers inside one module (layered-n-tier-architecture) or outbox mechanics (saga-transactional-outbox-pattern). Use when designing, reviewing or refactoring a modular monolith, stopping modules from reaching into each other's code or tables, or preparing a monolith for later extraction.
---

# Modular Monolith Architecture

One idea: deploy a **single runtime unit**, but partition its code and data into **autonomous vertical modules (bounded contexts)** with compile-time or test-time encapsulation, a schema per module, and explicit public contracts or integration events. Sources, retrieved statuses and claims not adopted: [references/sources.md](references/sources.md).

## Vocabulary

| Term | Meaning | Test sentence |
|---|---|---|
| Application module | a vertical slice for one bounded context (for example `Meetings`, `Payments`), owning its domain, application logic and persistence | "high cohesion inside, minimal coupling outside" |
| Public API / named interface | the thin contract (facade, command/query interface, or published integration events) a module exposes | "the only types another module may import" |
| Internal types | entities, repositories, handlers and tables hidden inside the module | "invisible to every other module" |
| Integration event | an immutable fact one module publishes so others can react | "decouples modules in time inside the same process" |
| Logical data isolation | each module owns its schema and never joins or queries another module's tables | "one database server, separate schema per module" |
| Module composition root | per-module registration block so a module cannot resolve another module's internals | rule owner: `dependency-inversion-composition-root` |

## 1. Module boundary and dependency rules

1. **Hide internals by default.** Entities, value objects, repositories and mappings are package-private or `internal`; only the public facade or an integration-events contract is visible. In the .NET reference only the IntegrationEvents assembly may be referenced by other modules; in Spring Modulith the base package is the API and sub-packages are internal.
2. **No cross-module joins, shared tables or foreign keys.** Give each module its own schema and enforce ownership. The .NET reference forbids shared data and cross-module transactions.
3. **Prefer asynchronous in-process events over synchronous calls** for reactions between modules. This is the skill's default, not a universal rule: Spring Modulith also allows calls across declared dependencies, while the .NET reference prohibits direct calls between modules. Use a synchronous contract call only when an immediate answer is required. Event reliability (outbox, inbox, idempotent handlers): `saga-transactional-outbox-pattern`.
4. **Cross the boundary with primitives and contract DTOs**, never a domain or ORM entity.
5. **Each module picks its own internal complexity** (inference from the reference, where only some modules use CQRS and one uses event sourcing): a core module may use rich DDD, a supporting one plain CRUD. Layering inside a module: `layered-n-tier-architecture`, `clean-architecture`.
6. **Verify boundaries in CI.** Spring Modulith `ApplicationModules.of(...).verify()`, NetArchTest (.NET) or ArchUnit (Java) fail the build on illegal access; check cycle support in the tool you pick. Add the check with the first module.

## 2. Building order

1. **Discover bounded contexts** (event storming, domain mapping) and create `modules/<context>` instead of global horizontal layers.
2. **Isolate persistence:** own schema, migration history and ORM context per module.
3. **Define the public API and the module's registration block;** keep the rest internal.
4. **Wire reliable messaging** only where an event must survive a crash: an outbox/inbox per module, or the framework's publication registry (Spring Modulith). Mechanics: `saga-transactional-outbox-pattern`.
5. **Lock boundaries** with the architecture test on every commit.

## 3. Tests per level

| Level | Test | Uses |
|---|---|---|
| Module domain and use cases | unit or module acceptance test | the public facade with in-memory fakes |
| Module slice (`@ApplicationModuleTest`) | integration test | boots only that module (default mode STANDALONE); mock missing beans, and treat many mocks as a coupling smell |
| Architecture verification | static check | no illegal access, no cycles where the tool supports it |
| Cross-module scenario | integration test | module A publishes, module B's listener reacts (Scenario API or a polling probe) |

General test-shape guidance: `testing-pyramid-and-shapes`.

## 4. When it earns its keep

- **Worth it:** several bounded contexts, growing teams that want module ownership without the operational cost of services, and a monolith that may later extract a module. Fowler's "Monolith First" says a monolith modular at both API boundaries and storage makes a later split fairly simple, and adds that few cases of this path are reported.
- **Not worth it:** a single-context CRUD app, or a system that needs independent runtimes, languages or release cycles now (`microservices-architecture`).

## Mistakes to catch

- **Cheating at the database:** separate packages but `JOIN`s across module tables in a shared schema. It kills autonomy and later extraction.
- **A global `shared/domain` dump** (`User`, `Account`) imported by every module. Each context owns its representation; share only technical building blocks.
- **One DI container with no module scope**, so any handler can inject another module's repository.
- **Fire-and-forget in-memory events after commit** with no persisted record: a crash loses them.
- **`OPEN` modules left permanent** in Spring Modulith; the docs read heavy use as a sign of weak modularization.

## Quick Decision Checklist

- [ ] Are modules vertical bounded contexts with internals hidden behind a thin public contract?
- [ ] Does each module own its schema, with no cross-module joins, shared tables or foreign keys?
- [ ] Do modules exchange only primitives and contract DTOs?
- [ ] Are events that must not be lost persisted in the publishing transaction?
- [ ] Is there no shared global domain folder?
- [ ] Does CI run an architecture test for illegal access (and cycles, if supported)?
- [ ] Is one deployable really enough, or does a driver need microservices?

## Deep references

- [references/modular-monolith-ddd-reference-implementation.md](references/modular-monolith-ddd-reference-implementation.md): the .NET reference design, module rules, outbox/inbox, testing. Read when you need a concrete full-autonomy example.
- [references/spring-modulith-structure-and-verification.md](references/spring-modulith-structure-and-verification.md): module detection, named interfaces, `verify()`. Read when the stack is Spring Boot.
- [references/spring-modulith-events-and-testing.md](references/spring-modulith-events-and-testing.md): publication registry, externalization, module tests. Read when wiring or testing events in Spring Modulith.
- [references/trigger-evals.md](references/trigger-evals.md): should-trigger and near-miss prompts. Read when tuning the description.
- [references/sources.md](references/sources.md): URLs, retrieved statuses, reading limits, claims not adopted.
