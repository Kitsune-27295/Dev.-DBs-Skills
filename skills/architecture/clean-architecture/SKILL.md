---
name: clean-architecture
description: Use when designing, reviewing, or refactoring a Clean Architecture codebase (Entities/Domain, Use Cases/Application, Interface Adapters, Frameworks & Drivers), enforcing Uncle Bob's Dependency Rule, or crossing circle boundaries with Dependency Inversion and simple DTOs. Gives the four concentric circles, the Dependency Rule, boundary-crossing mechanics, test strategy per circle, and common mistakes.
---

# Clean Architecture

One idea: organize software into concentric circles — **Entities** (enterprise business rules) at the center, then **Use Cases** (application business rules), **Interface Adapters** (controllers, presenters, gateways), and **Frameworks & Drivers** (DB, Web, UI, devices) on the outside — governed by one non-negotiable invariant: **The Dependency Rule** (source code dependencies can only point **inward**). Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (the four concentric circles)

| Circle (inner -> outer) | Meaning | Test sentence |
|---|---|---|
| 1. Entities (Domain) | enterprise-wide business objects and invariants; the least likely to change when external details change | "would this rule still exist if we did the business with paper and pencil?" |
| 2. Use Cases (Application) | application-specific business rules that orchestrate the flow of data to and from Entities | "describes one automated operation of this specific application" |
| 3. Interface Adapters | converts data from the format convenient for Use Cases/Entities to the format convenient for the DB, Web, or UI (Controllers, Presenters, Gateways/Repositories) | "translates between the inner circles and external technology" |
| 4. Frameworks & Drivers | outermost details: web framework, database engine, ORM, UI, external APIs, wiring/bootstrap | "glue code and external tools kept at arm's length" |
| Input / Output Port | interfaces owned by the Use Case circle: Input Port is implemented by the Use Case Interactor; Output Port is called by the Interactor and implemented by an outer Adapter (Presenter or Gateway) | "how control crosses a circle boundary against the flow of execution" |

## The Dependency Rule (what to check on every change)

1. **Inward-only source dependencies:** Nothing in an inner circle can know anything at all about something in an outer circle. No name declared in an outer circle (functions, classes, variables, ORM annotations, framework types) may be mentioned by the code in an inner circle.
2. **Invert control across boundaries:** When a Use Case (inner) needs to call a Presenter or Database Gateway (outer), the Use Case defines an **interface (Output Port)** inside the Use Case circle, and the outer Adapter implements it (Dependency Inversion Principle).
3. **Pass simple, isolated data structures across boundaries:** Never pass ORM rows, database records, or raw HTTP request objects inward. Data crossing a boundary must always be simple data structures (DTOs, Request/Response models, value structs) in the form most convenient for the **inner** circle.
4. **Frameworks are details, not the architecture:** Keep web frameworks, ORMs, and vendor SDKs in the outermost ring. Do not let framework base classes or annotations infect Entities or Use Cases.
5. **Four circles are a schematic, not a hard limit:** You may have more than four circles if needed, provided the Dependency Rule holds: dependencies always point toward higher-level policy (inward).

## Building order

1. **Entities first:** Model core domain entities, value objects, and enterprise invariants with zero external dependencies and pure unit tests.
2. **Use Cases and Ports second:** Write each Use Case (Interactor) along with its Request/Response DTOs and required Gateway/Presenter interfaces inside the Application circle. Test every use case against in-memory fakes.
3. **Interface Adapters third:** Implement Controllers, Presenters, and persistence Gateways/Repositories that adapt external requests and databases to the Use Case interfaces.
4. **Frameworks, Drivers, and Composition Root last:** Wire dependency injection, web server routes, and database connections in the outermost startup/infrastructure ring.

## Tests per circle

| Circle | Test | Uses |
|---|---|---|
| Entities (Domain) | unit test | nothing external; pure language runtime |
| Use Cases (Application) | unit / acceptance test | in-memory fakes for Gateways/Output Ports; no DB, no web server |
| Interface Adapters (Controllers, Gateways) | integration test | real test DB for Gateways; mock/fake Use Cases for Controllers/Presenters |
| Frameworks & Drivers (Web/App Host) | end-to-end / functional test | full wired application on critical user journeys |

Automate the Dependency Rule with an architecture test (e.g., `NetArchTest`, `ArchUnit`, `dependency-cruiser`) that fails CI if `Domain` imports `Application`/`Infrastructure` or if `Application` imports `Infrastructure`/`Web`.

## When it earns its keep

- **Worth it:** Medium-to-large systems with rich domain rules, long expected lifespan, multiple delivery mechanisms (Web, CLI, background jobs, mobile API), or storage/framework choices that may evolve over time.
- **Not worth it:** Simple CRUD utilities, throwaway prototypes, or thin data-proxy services where mapping across 3-4 circles adds boilerplate with zero business policy to protect.

## Mistakes to catch

- **Violating the Dependency Rule for convenience:** Importing an ORM `DbContext`, Prisma client, or HTTP exception class directly inside a Use Case or Entity.
- **Passing outer data structures inward:** Returning database entity rows or taking framework `HttpRequest` objects as Use Case arguments, forcing inner circles to violate rule 3.
- **Leaking Entity internals directly to the external API:** Returning rich domain Entities directly as JSON responses from Controllers without a Presenter or Response DTO, coupling database/domain shape to public API clients.
- **Anemic Use Cases + Smart Controllers:** Putting orchestration and business validation inside the Web Controller while the Use Case only delegates to a Repository.
- **Over-abstracting trivial internal helpers:** Creating a Port/Adapter boundary for deterministic in-memory helpers (like date math or string formatting) that are not external agencies.

## Quick Decision Checklist

- [ ] Do all source dependencies point inward, with no outer name used in an inner circle?
- [ ] Does the Use Case own the port interface that the outer adapter implements?
- [ ] Do only simple DTOs cross boundaries, never ORM rows or raw HTTP request objects?
- [ ] Are web frameworks, ORMs and vendor SDKs confined to the outermost ring?
- [ ] Is business validation in the Use Case, not in the Controller?
- [ ] Do controllers return Response DTOs or Presenters, not raw domain entities?
- [ ] Does an architecture test fail CI when an inner circle imports an outer one?
- [ ] Does this system have enough business policy to be worth the circles, and is the new port a real external agency?

## Deep references

- [The Dependency Rule and Boundary Crossing](references/dependency-rule-and-boundary-crossing.md) — read when enforcing the rule or designing ports and presenters.
- [Layers, Stability and Inversion of Control](references/layers-and-inversion-of-control.md) — read for the layer-by-layer rationale and how to place port interfaces.
- [.NET Project Layout and the Composition Root](references/dotnet-layout-and-composition-root.md) — read when mapping the circles to .NET projects and wiring DI.
