# Slices in Practice: Cross-Cutting Concerns, Testing and the Literature Map

Sources: https://milanjovanovic.tech/blog/vertical-slice-architecture-dotnet ; https://github.com/drveillard/software-architecture/blob/main/docs/vertical-slice-architecture.md · Last verified 2026-11-23

Caveat: the Jovanovic URL returned a hub page with summaries and links to sub-articles, not the full article, so code patterns (REPR specifics, Carter) were not read; only the hub's statements are used. The Veillard page is a link list with no prose of its own; its entries are titles, not verified claims.

## Hub statements (Jovanovic)

- Feature-based organization: endpoint, handler, validation and data access together; adding a feature adds a slice and should not disturb unrelated features.
- Commands and queries are already separate, so each in its own slice can be optimized independently.
- Cross-cutting policy shared across slices lives in pipeline behaviors, decorators, endpoint filters or middleware; feature-specific validation and decisions stay in the slice.
- Warning: a shared service layer becomes a new coupling point.
- Criticism noted: duplication across slices; the answer is handling cross-cutting concerns without breaking isolation.
- Compatibility: slices fit modular monoliths and combine with Clean Architecture, where Clean governs dependency direction and slices organize behavior. Do not force simple slices through identical layers.
- Testing: test through the public boundary (usually HTTP) against a real database; unit-test extracted domain logic only when decision complexity justifies it; architecture tests can enforce structure.

## Veillard reading list: what categories exist

Comparisons with Clean/Onion (Headspring articles, "Slices vs. Layers"); foundations (Bogard, Simon Brown on package by component and architecturally aligned testing, Feature Folders); ASP.NET implementations (MediatR endpoints, thin controllers on a diet, Razor Pages); strategy and tests ("how to slice effectively", modular monolith primer, vertical slice testing, avoiding premature abstractions); samples (ContosoUniversity, eShopOnWeb, event-sourcing examples, minimal API examples); a Packt design patterns book chapter. Mostly .NET, some Java; many entries date 2013-2021 and some links may be stale. It includes both advocacy and critiques.

## Decision table

| Situation | Choice |
|---|---|
| CRUD-ish feature, one request one screen | single handler file, direct data access |
| rule used identically in 3+ slices | extract domain method/value object, not a service layer |
| auth, logging, validation plumbing | pipeline behavior or middleware |
| rich invariants | slice at application layer plus shared Domain core |

## How an agent should apply this

- Put plumbing in pipeline/middleware, never in a shared "BaseService".
- Test slices over real HTTP plus real database; reserve unit tests for domain logic.
- Add an architecture test (folder/namespace rule) so slices cannot reference each other.
- Treat duplication across slices as acceptable until the same domain concept appears repeatedly.
- Read the linked sub-articles before quoting REPR/Carter details; this file does not cover them.
