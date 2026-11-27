---
name: vertical-slice-architecture
description: Organize an application by feature or request (a vertical slice holding endpoint, request, validation, handler and data access together) instead of by technical layer, and decide per slice how much domain structure it needs. Use when a change touches Controllers, Services and Repositories at once, when pass-through service or repository interfaces add ceremony, when asking where shared logic and cross-cutting plumbing live, or when moving a layered .NET-style codebase to slices with CQRS handlers. Not for dependency-direction rules between circles (use `clean-architecture`), ports and adapters (`hexagonal-architecture`), or the read/write model split itself (`cqrs-pattern`).
---

# Vertical Slice Architecture

One idea (Bogard): couple along the axis of change. Group everything one request needs, from entry point to data access, and keep slices loosely coupled: "minimize coupling between slices, and maximize coupling in a slice". Sources and what was not adopted: [references/sources.md](references/sources.md).

## 1. Vocabulary

| Term | Meaning |
|---|---|
| Vertical slice | one use case (a command or a query) with all its concerns in one place |
| Axis of change | things that change together live together |
| Per-slice pattern freedom | each slice picks its own domain-logic approach; start with Transaction Script and refactor as smells appear (Bogard, citing Fowler's patterns) |
| Cross-cutting behavior | policy shared by slices (validation execution, logging, authorization, transactions) in pipeline behaviors, decorators, endpoint filters or middleware |
| REPR (request, endpoint, response) | a common endpoint shape; named by Jovanovic, details not read here (see sources) |

## 2. Core rules

1. **Organize by request, not by layer.** Endpoint, request and response types, validation, handler and data access sit together; adding a feature adds a slice and should not disturb unrelated features.
2. **Keep slices loosely coupled (our rule).** A slice does not call another slice's handler or reuse its private request and response types; if two slices need the same behavior, extract a domain method or publish an in-process event.
3. **Drop pass-through abstractions.** Layered designs force "controller calls service calls repository" (Bogard's complaint). A handler may use the data context directly unless a real external boundary needs substitution. Frameworks may still force some sharing (controllers, ORM unit of work); keep it minimal.
4. **Choose the domain pattern per slice.** Queries: project straight into the response type (`cqrs-pattern`). Simple commands: Transaction Script in the handler. When rules tangle or the same domain concept recurs, move behavior into a domain entity or value object. Complex domains may keep a shared Domain core under feature slices; Clean Architecture governs dependency direction, slices organize behavior (Jovanovic).
5. **Share only the same domain concept (our heuristic).** Similar-looking validators or DTOs that can diverge stay separate; shared code is a coupling point. Duplication is the known criticism, so answer it with rule 6 rather than a shared service layer.
6. **Put cross-cutting policy in pipeline or middleware**; feature-specific validation and decisions stay in the slice.
7. **Test through the public boundary against a real database** (usually HTTP); unit-test extracted domain logic only when decision complexity justifies it. Consider an architecture test that forbids slice-to-slice references (our suggestion).

## 3. Building order

1. Create the feature folder and put the endpoint, request, validator, handler and response in one file or folder.
2. Implement the simplest thing against the data context.
3. Write a slice test through the real pipeline and database.
4. When a handler grows tangled rules or a rule repeats, extract a domain method and add fast unit tests for it.

## 4. Testing strategy

| Target | Test |
|---|---|
| Extracted domain methods | fast unit tests, no mocks |
| Slice validator | unit test with valid and invalid requests |
| Slice end to end | integration test through the real pipeline and a real database (the bulk of the suite) |
| Slice boundaries | optional architecture test on folder or namespace references |

## 5. When it earns its keep

- Worth it: feature-driven web apps, APIs and modular monoliths where most changes add or alter discrete requests.
- Not worth it: a team that cannot recognize smells and refactor (Bogard says it may not suit them), since handlers then bloat and logic never reaches the domain; tiny libraries with no request boundary.

## 6. Mistakes to catch

- **Slice calls slice:** one handler invoking another; use a domain method or an event.
- **Layers rebuilt inside slices:** adding `IUserRepository` and `IUserService` beneath handlers keeps the old ceremony.
- **One DTO for several slices:** a field added for one screen leaks into or breaks another (`never-trust-the-client`).
- **God handler:** procedural handlers that never push rules into the domain.
- **Shared base service** for plumbing instead of pipeline behaviors.

## Quick Decision Checklist

- [ ] Does each feature live in one slice, with slices loosely coupled?
- [ ] Any pass-through interface that exists only to satisfy a layer rule?
- [ ] Domain pattern chosen per slice (projection, Transaction Script, domain entity)?
- [ ] Shared code limited to the same domain concept?
- [ ] Cross-cutting policy in pipeline behaviors or middleware?
- [ ] Slice tests run against a real database; rules refactored into the domain when smells appear?
- [ ] Does the team have the refactoring discipline this needs?

## Deep references

- [Bogard's slice principles and trade-offs](references/bogard-slice-principles-and-tradeoffs.md) — when justifying slices over layers or checking team fit
- [Slice practice: cross-cutting, testing, literature](references/slice-practice-cross-cutting-testing-and-literature.md) — when placing shared logic, plumbing and tests, or finding further reading
- [Trigger evals](references/trigger-evals.md) — when tuning the description
- [Sources](references/sources.md) — verification status and claims not adopted
