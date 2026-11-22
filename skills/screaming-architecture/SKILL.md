---
name: screaming-architecture
description: Use when designing or auditing a repository's top-level directory structure, package names, and use-case organization according to Robert C. Martin's (Uncle Bob's) Screaming Architecture principle — making the codebase scream its business domain and use cases ("Healthcare System", "Accounting Ledger", "Second Brain Vault") rather than its frameworks ("Rails", "Spring/Hibernate", "Next.js/Prisma").
---

# Screaming Architecture

One idea: just as the blueprints of a library scream **"Library"** (reading rooms, check-in desks, book galleries) and the blueprints of a house scream **"House"** (living room, kitchen, bedrooms) rather than **"Bricks and Mortar"**, the top-level directory structure and primary types of a software repository must **scream the business domain and use cases of the system** — never the web framework, ORM, or delivery mechanism. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Robert C. Martin & Ivar Jacobson)

| Term | Meaning | Test sentence |
|---|---|---|
| Screaming Architecture | a top-level codebase layout whose folder and module names immediately tell a new engineer what business problem the system solves and what use cases it supports | "looking at `src/`, do I see `claims/`, `underwriting/`, `policies/` — or do I see `controllers/`, `prisma/`, `redux/`?" |
| Use-Case Driven Structure | Ivar Jacobson's principle (*Object-Oriented Software Engineering*): software architecture exists to support the **use cases** of the system, independent of delivery details | "can a newcomer read all the use cases of the system without knowing whether it ships over HTTP, CLI, or MCP?" |
| Delivery Mechanism | the transport channel through which use cases are invoked (Web/HTTP, Console/CLI, thick client, MCP tool server, background queue) | "the Web is a delivery detail, not an architecture" |
| Framework at Arm's Length | treating frameworks (Spring, Rails, Next.js, ASP.NET, EF Core, Prisma) as peripheral tools plugged into outer adapters rather than letting them dictate the core folder tree and base classes | "use the framework; don't marry it or let it take over your domain model" |

## Core architectural rules and invariants

1. **The First-Impression Litmus Test:** When a new developer opens the top-level source directory (`src/` or module root), their immediate reaction must be: *"Oh, this is a `<Business Domain>` system (e.g., Health-Care System, Order Fulfillment Engine, Knowledge Vault)"* — **never** *"Oh, this is a Rails / Spring Boot / Next.js / Laravel app."*
2. **Name top-level packages and types after Domain Concepts and Use Cases:**
   - **Bad (Framework-Screaming):** `src/controllers/`, `src/models/`, `src/views/`, `src/helpers/`, `src/middlewares/`, `src/repositories/`
   - **Good (Domain & Use-Case Screaming):** `src/enrolment/` (`EnrollStudentUseCase`, `CancelEnrollmentUseCase`), `src/grading/`, `src/tuition-billing/`, `src/course-catalog/` (or inside `src/domain/` and `src/application/` organized by business capability).
3. **Defer and isolate framework, database, and web decisions:** A good architecture centers on use cases so decisions about web servers, databases, and frameworks can be deferred, swapped, or tested without touching the core. Never inherit domain entities from framework base classes (`ActiveRecord::Base`, `Model`, `Entity`) or litter use cases with HTTP/ORM annotations.
4. **The Web is a delivery mechanism, not the architecture:** Whether a use case is triggered by a REST endpoint, a GraphQL mutation, a CLI command, or an AI agent MCP tool call is an outer delivery detail (`hexagonal-architecture`, `clean-architecture`). The use case input/output contract must be transport-agnostic.
5. **All use cases must be unit-testable in-situ without booting the framework:** You must be able to run the entire suite of domain and use-case tests **without** starting the web server, **without** connecting to a live database engine, and **without** booting a heavy framework container.

## How to Audit and Refactor a Codebase to Scream its Domain

1. **Run the `ls src/` / Directory Tree Audit:**
   - List the top 2 levels of source directories.
   - Count how many folder names are **Domain Nouns / Use-Case Verbs** vs. **Technical / Framework Stereotypes** (`controllers`, `services`, `utils`, `orm`, `dto`, `adapters`).
2. **Extract explicit Use-Case classes/functions named in the Ubiquitous Language:**
   - Replace generic CRUD methods (`UserService.update(id, data)`) with explicit business use cases (`ApproveLoanApplication`, `SealVaultSource`, `TransferFunds`, `DischargePatient`).
3. **Push Framework Conventions to the Outermost Edge:**
   - If a framework demands a special directory (e.g., Next.js `app/` routes or framework CLI folders), keep that directory as a **wafer-thin driver layer** that only parses the transport request and immediately calls into the domain-screaming core (`src/core/<domain-capability>/` or `packages/<bounded-context>/`).
4. **Combine with `package-by-feature-component` and `clean-architecture` / `hexagonal-architecture`:**
   - Organize the core by domain capability / feature slice so the directory tree serves as a living map of what the business does.

## Verification checklist

| Check | Question | Pass Condition |
|---|---|---|
| Top-level directory check | If you hide `package.json` / `pom.xml` / `go.mod` and show `tree -L 2 src/` to a stranger, can they guess what industry and product this codebase is for? | Yes — domain nouns and use cases dominate the tree |
| Delivery ignorance check | Can a reader locate every business use case in the repository and understand its inputs, outputs, and rules before finding out where the views, HTTP controllers, or SQL tables live? | Yes — views, controllers, and DB gateways are isolated details |
| Framework-free test check | Do the use-case tests run in milliseconds using plain objects without booting the web framework or database? | Yes — zero framework startup in domain/use-case specs |

## When it earns its keep

- **Worth it:** Every product with domain logic, business workflows, or multiple delivery channels where long-term maintainability, fast developer onboarding, and architectural clarity matter.
- **Not worth it:** Pure technical infrastructure libraries whose actual domain *is* the technical mechanism itself (e.g., if you are authoring an HTTP router library, its domain naturally screams `routes/`, `headers/`, `middleware/`).

## Mistakes to catch

- **Letting the Framework Generator dictate the entire application architecture:** Running `rails new`, `nest new`, or `create-next-app` and stuffing all business rules directly inside the framework's generated `controllers/` or `app/api/` route files for the next 5 years.
- **Generic CRUD naming (`OrderManager`, `DataHelper`, `ProcessService`):** Using vague technical nouns instead of the exact business use-case verbs spoken by domain experts.
- **Confusing "Screaming Architecture" with ignoring Clean/Hexagonal boundaries:** Screaming Architecture does not mean dumping SQL and HTML into a folder just because the folder is named `billing/`. It means the top-level organization screams `billing/`, while keeping delivery (HTTP/UI) and persistence (DB) decoupled from the `billing` use cases and entities.
