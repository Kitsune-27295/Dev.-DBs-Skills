---
name: vertical-slice-architecture
description: Use when designing, reviewing, or refactoring a codebase around Vertical Slice Architecture (organizing code by feature/request slice instead of horizontal technical layers), eliminating pass-through Service/Repository ceremony, deciding where shared domain logic lives, or combining vertical slices with CQRS and MediatR/REPR endpoints. Gives Jimmy Bogard's coupling axis rule, per-slice pattern freedom, refactoring triggers, testing strategy, and common mistakes.
---

# Vertical Slice Architecture

One idea: stop coupling code horizontally across technical layers (`Controllers/`, `Services/`, `Repositories/`) where a single feature change forces edits across five folders; instead, **organize around the axis of change — the distinct request or feature slice** — encapsulating the endpoint, request/response contract, validation, and data access together so you **minimize coupling between slices and maximize cohesion inside a slice**. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Bogard & Jovanović)

| Term | Meaning | Test sentence |
|---|---|---|
| Vertical Slice | a self-contained feature folder or file encapsulating one distinct request (Command or Query) from UI/HTTP entry down to database access | "adding or changing a feature touches one slice folder, not five horizontal layers" |
| Axis of Change | the principle that things that change together should live together (`Features/Orders/PlaceOrder.cs` rather than `Controllers/`, `Services/`, `Repositories/`) | "couple vertically along the request, never horizontally across unrelated features" |
| Per-Slice Pattern Freedom | each slice chooses the simplest domain/data pattern that fits its complexity (raw SQL projection, Transaction Script, Active Record, or rich DDD Aggregate) | "a simple GET slice does not pay the abstraction tax of a complex POST slice" |
| REPR (Request-Endpoint-Response) | structuring each HTTP slice around three cohesive pieces: the Request DTO/Command, the Endpoint/Handler, and the Response DTO | "replaces bloated 20-action CRUD Controllers with single-purpose endpoints" |
| Cross-Cutting Pipeline Behavior | middleware or mediator decorator handling truly universal technical concerns (logging, validation execution, auth, transaction wrapping) across all slices | "keeps plumbing out of slices without coupling business rules together" |
| Domain Core Extraction (Refactoring Trigger) | pushing complex business invariants out of a slice handler into a rich Domain Entity/Method only when code smells (duplication of the *exact same business rule* or handler bloat) appear | "refactor to domain models from observed smells, not speculative upfront interfaces" |

## Core architectural rules and invariants

1. **Minimize coupling between slices, maximize coupling inside a slice:** A slice (`PlaceOrder`) must never call another slice's handler (`ReserveInventoryHandler`) or import another slice's private request/response DTOs. Each slice is an independent use case.
2. **Eliminate mandatory pass-through abstractions:** Do not create `IOrderService` or `IOrderRepository` interfaces that have only one implementation and exist solely to satisfy a layer rule. Let the slice handler talk directly to the ORM `DbContext`, query builder, or raw SQL connection unless an external boundary genuinely needs mocking.
3. **Choose the domain pattern per slice, not system-wide:**
   - **Query slices (`GET`):** Project directly from the database (`DbContext` / Dapper / SQL) into the slice's Response DTO (`cqrs-pattern`). Never load rich domain entities or map through 3 layers just to render a screen.
   - **Simple Command slices (`POST`/`PUT`):** Start with a clean Transaction Script inside the handler.
   - **Complex Command slices:** When a handler accumulates complex branching or shares a true domain invariant with another command, push that behavior down into a rich Domain Entity method (`order.Cancel(reason, clock)`).
4. **Duplication is better than the wrong shared abstraction ("Code sharing is coupling"):** Even if `CreateStudent` and `EditTutor` have similar-looking validation today, do not merge them into a shared `PersonValidator` unless they represent the **exact same business rule** that must always change together. If two screens can diverge, keep their validators and DTOs separate inside their respective slices.
5. **Handle cross-cutting technical plumbing via Pipeline Behaviors / Middleware:** Use a mediator pipeline or HTTP middleware for request validation (`IValidator<T>`), structured logging, authorization checks, and unit-of-work transaction commits so slice handlers contain only feature logic.

## Building order

1. **Create the feature folder (`Features/<FeatureGroup>/<SliceName>`):** Put the Endpoint/Route, Request record, Validator, Handler, and Response record in one file or one cohesive folder.
2. **Start with the simplest implementation inside the slice:** Write the query or command directly against the database context / driver.
3. **Write a slice integration test against a real test database:** Test the slice from Request to Response (or HTTP Endpoint) through the full pipeline (validation + handler + real DB).
4. **Refactor to rich Domain Objects only when smells emerge:** When a command handler grows complex business rules, extract a pure domain method onto the Entity and add fast unit tests for that domain object.

## Testing strategy

| Target | Test | Uses |
|---|---|---|
| Pure Domain Entity methods (extracted from complex slices) | unit test (fast, zero mocks) | plain domain objects in memory |
| Slice Validator | unit test | passes valid/invalid Request DTOs directly to the slice's validator |
| Vertical Slice Handler / Endpoint | vertical integration test (majority of suite) | sends Request/HTTP call through the real pipeline against a real Testcontainers database — **zero repository mocks** |

## When it earns its keep

- **Worth it:** Feature-driven web applications, APIs, and modular monoliths where most changes add or modify discrete user requests/screens, and teams want high feature velocity without mock-heavy layered ceremony.
- **Not worth it:** Teams that lack refactoring discipline and dump 1,500 lines of duplicated domain rules into procedural handlers without ever pushing invariants into domain entities, or tiny libraries with no request/use-case boundaries.

## Mistakes to catch

- **Slice-calls-Slice coupling:** Having `CreateOrderHandler` invoke `SendConfirmationEmailHandler` or `UpdateInventoryHandler` directly. Either publish an in-process domain event or extract a shared domain service/entity method.
- **Recreating horizontal repositories inside VSA:** Adding `IUserRepository` and `IUserService` layers underneath vertical slice handlers — combining the folder structure of VSA with all the ceremony and coupling of N-Layer.
- **Sharing DTOs or Validators across distinct slices:** Reusing `OrderDto` across `CreateOrder`, `UpdateOrder`, and `GetOrderDetails`, so a field added for one screen breaks or exposes data on another (`never-trust-the-client`).
- **Procedural God Handlers (skipping the refactoring step):** Bogard explicitly warns that VSA requires recognizing code smells — when business rules get tangled inside a handler, push them into rich Domain Entities instead of leaving procedural spaghetti.

## Quick Decision Checklist

- [ ] Does each feature live in one slice, with coupling kept inside the slice?
- [ ] Do slices avoid calling other slices' handlers or importing their DTOs?
- [ ] Am I avoiding pass-through interfaces that exist only to satisfy a layer rule?
- [ ] Did I pick the pattern per slice: direct projection for queries, transaction script for simple commands?
- [ ] Am I accepting some duplication instead of a wrong shared abstraction?
- [ ] Is cross-cutting plumbing in pipeline behaviors or middleware?
- [ ] Did I push tangled business rules into domain entities instead of a God handler?

## Deep references

- [Bogard's slice principles and trade-offs](references/bogard-slice-principles-and-tradeoffs.md) — when justifying slices over layers or checking team fit
- [Slice practice: cross-cutting, testing, literature](references/slice-practice-cross-cutting-testing-and-literature.md) — when placing shared logic, plumbing and tests, or finding further reading
