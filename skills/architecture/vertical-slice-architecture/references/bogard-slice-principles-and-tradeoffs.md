# Bogard's Vertical Slice Principles and Trade-offs

Sources: https://www.jimmybogard.com/vertical-slice-architecture/ ; https://github.com/jbogard/contosoUniversityDotNetCore-Pages · Last verified 2026-11-23

## Origin

Bogard's team began a long project with onion architecture; within a couple of months its problems showed, so they moved to command/query separation (not yet called CQRS) and vertical slices, and had used it for about seven to eight years at the time of writing (2018).

## Argument against layers

Layered, onion and clean architectures fit only a minority of requests. They are mock-heavy and impose rigid dependency rules that manufacture abstractions: "controller must call a service that must use a repository."

## The model

- Each request is a use case; group its concerns front to back.
- Couple along the axis of change. Guiding rule (his words): "Minimize coupling between slices, and maximize coupling in a slice."
- Commands and queries map to CQRS and to GET versus POST/PUT/DELETE.
- Shared repositories, services and controllers mostly disappear; frameworks may force some (controllers, ORM unit of work), but keep cross-slice sharing minimal.
- Each slice picks its own approach: start with a transaction script, refactor to domain patterns when smells appear in business logic.

## Benefits and costs

| Benefit | Cost / precondition |
|---|---|
| new features mostly add code instead of changing shared code, lowering side-effect risk | team must recognize smells and refactor (Fowler, Kerievsky techniques) |
| less abstraction overhead | without that skill, handlers bloat and logic never reaches the domain |
| scales past layered designs with a skilled team | complex logic must be moved into domain objects deliberately |

## Reference implementation

`ContosoUniversityDotNetCore-Pages` (README: "the way I would write it") targets ASP.NET Core on .NET 10 with Razor Pages, and names CQRS with MediatR, AutoMapper, FluentValidation, HtmlTags and EF Core, with an Aspire app host and an `IntegrationTests` project plus CI. The fetched README did not show the folder layout or test strategy, so claims about Testcontainers or layout in the parent sources.md were not re-confirmed this pass.

## Not verified

The "code sharing is coupling" Q&A cited in sources.md did not appear on the fetched page (no comments were returned); treat it as unverified here.

## How an agent should apply this

- Organize by request: one folder per use case holding request, handler, validator and response.
- Inject the data context straight into handlers; do not add repository or service layers just for symmetry.
- When a handler grows tangled business rules, move them into domain entity methods before adding more code.
- Share across slices only for identical domain concepts, not similar-looking code.
- Warn the user if the team lacks refactoring discipline: VSA is a poor fit then.
