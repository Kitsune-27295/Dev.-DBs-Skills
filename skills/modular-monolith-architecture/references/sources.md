# Sources for the modular-monolith-architecture skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Kamil Grzybek, `modular-monolith-with-ddd` (GitHub repository & Architecture Decision Records), https://github.com/kgrzybek/modular-monolith-with-ddd | Full production reference of a DDD Modular Monolith split into autonomous modules (`Meetings`, `Administration`, `Payments`, `UserAccess`, `Registrations`); maximum autonomy per module; separate DI IoC container per module; separate database schema per module with zero cross-schema joins; communication exclusively via an in-memory Event Bus backed by transactional Outbox and Inbox patterns; C4 model diagrams, Clean Architecture + CQRS inside rich modules, and automated ArchUnit/NetArchTest boundary checks. |
| 2 | Spring Team (Oliver Drotbohm et al.), *Spring Modulith Reference Documentation* (v2.2), https://docs.spring.io/spring-modulith/reference/index.html | Functional structuring of Spring Boot applications into logical domain modules; compile-time and test-time architectural verification (`ApplicationModules.verify()`); named interfaces and package encapsulation; transactional event publication log for decoupled inter-module integration; isolated module slice testing (`@ApplicationModuleTest`). |
| 3 | Martin Fowler, "Monolith First" (2015), https://martinfowler.com/bliki/MonolithFirst.html | Designing a monolith with strict modularity at both API boundaries and data storage so that boundaries can be refactored cheaply in-process and, if ever needed, extracted to microservices later. |

## Notes on disagreements and nuances across sources

- **Synchronous Facade calls vs. Pure Event-Driven inter-module communication:** Grzybek (Source 1) favors maximum autonomy through asynchronous integration events (with local data replication via Event-Carried State Transfer when Module A needs a piece of Module B's data), allowing synchronous module-to-module client calls only when an immediate response is strictly required. Spring Modulith (Source 2) supports both public Spring bean dependency injection across allowed module dependencies and transactional `@ApplicationModuleListener` events. This skill recommends asynchronous Outbox-backed events by default to prevent temporal coupling, with explicit public-contract calls allowed when synchronous reads are unavoidable.
