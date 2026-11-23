# .NET Project Layout and the Composition Root

Sources: https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures · https://github.com/jasontaylordev/cleanarchitecture · Last verified 2026-11-23

(The skill's sources.md lists the pt-pt URL of the Microsoft page; the en-us canonical was fetched and used.)

## Microsoft guide: from N-Layer to Clean
- Traditional N-Layer (UI, BLL, DAL): compile-time dependencies run top to bottom, so the business layer depends on data-access details and often a database; testing it needs a test database. Dependency inversion fixes this.
- Layers are logical; tiers are physical deployment targets. An N-Layer app is commonly deployed to one tier.
- The guide treats Hexagonal, Ports-and-Adapters, Onion and Clean as the same family reached by applying DIP plus DDD, and uses "Clean Architecture" as the name.
- **Application Core** holds entities, aggregates, interfaces, domain services, specifications, custom exceptions and guard clauses, domain events and handlers; interfaces for data/file/network access live here; non-entity data crossing in may be simple DTOs. It has no dependency on other layers.
- **Infrastructure**: EF Core `DbContext`/migrations, repositories, services such as file logger or SMTP notifier; references the Application Core and implements its interfaces.
- **UI**: controllers, filters, middleware, views, view models, startup; references the Core and talks to infrastructure only through Core interfaces; no direct instantiation or static calls to Infrastructure types.
- **Composition root**: `Startup`/`Program.cs` wires implementations to interfaces. The solid arrows in the guide's diagram are compile-time dependencies, the dashed one is runtime-only. UI may need a project reference to Infrastructure just for wiring; limit real references to the composition root (or use a DI container that loads assemblies).
- Testing: Core is unit-tested in isolation; Infrastructure is integration-tested against real dependencies.
- The guide calls this the most appropriate way to structure non-trivial monoliths, and notes simple all-in-one (folder-based) projects drift into spaghetti as they grow. Microservices add complexity; a monolith with clean internal layers is often the better option.

## Jason Taylor template (repo page)
The fetched GitHub page lists the top-level contents but not the contents of `src/` or `tests/`, so the project-by-project mapping (Domain, Application, Infrastructure, Web) in `sources.md` is not re-verified here. What the page does show:
- Template for ASP.NET Core with Aspire; ASP.NET Core 10 or 11, EF Core, Angular 22 or React 19 (or none), MediatR, AutoMapper, FluentValidation, Scalar.
- Tests: NUnit, Shouldly, Moq, Respawn. Database: SQLite (default), PostgreSQL or SQL Server.
- Also: `docs/decisions/` (ADRs), a `ca-use-case` scaffold template, Dev Container, `AGENTS.md`.
- Scaffold: `dotnet new install Clean.Architecture.Solution.Template`, then `dotnet new ca-sln -cf none -db sqlite -o MyApp`; run with `aspire run`.

## Failure modes
- Leaving the "UI references Infrastructure" convenience open so controllers new up repositories.
- Putting `DbContext` in the Core because "it is just a class".
- Treating the template's MediatR/AutoMapper stack as part of the architecture; they are choices, the rule is the inward direction.

## How an agent should apply this
- Map a new .NET solution to Core / Infrastructure / UI (or Domain / Application / Infrastructure / Web) with references pointing at the Core only.
- Restrict the UI-to-Infrastructure reference to the composition root; enforce with an architecture test.
- Put repository interfaces and domain exceptions in the Core; EF types and external clients in Infrastructure.
- Use the template as a starting point, then trim unneeded features (frontend, Aspire) rather than keeping dead scaffolding.
- Choose a folder-organised single project for small apps; adopt the split when business rules and change pressure justify it.
