# Sources: Modular Monolith Architecture

Every URL below was re-fetched on 2026-11-27 with WebFetch (Firecrawl had no credits). Rows record what was actually read.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://github.com/kgrzybek/modular-monolith-with-ddd | 200 OK; README read to section 3.19, last ~4 KB truncated; MIT shown in the sidebar, license text not read | Module list, composition root per module, schema per module, in-memory event bus, outbox/inbox with a background worker, IntegrationEvents-only visibility, CQRS, event sourcing in Payments, NetArchTest, module API operations |
| https://docs.spring.io/spring-modulith/reference/fundamentals.html | 200 OK, version 2.2.0 stable (2.3.0 snapshot listed) | Module detection, nested modules (1.3), `allowedDependencies`, named interfaces, OPEN type, `@Modulithic`, detection strategy |
| https://docs.spring.io/spring-modulith/reference/events.html | 200 OK, version 2.2.0 | Publication lifecycle and statuses (ABANDONED added in 2.2), completion modes, abandon default, staleness monitor, `@Externalized`, brokers, outbox starters (2.1), persistence starters |
| https://docs.spring.io/spring-modulith/reference/testing.html | 200 OK, version 2.2.0 | Bootstrap modes, `@MockitoBean`, `@ModuleSlicing`, Scenario API and its transaction behavior, `spring-modulith-junit` (1.3) |
| https://martinfowler.com/bliki/MonolithFirst.html | 200 OK; dated 3 June 2015 | Modular APIs and storage make a later split simple; few reported cases |

## Reading limits

- The Spring Modulith verification page was not fetched; the exact `verify()` rule list is not adopted beyond what the fundamentals page states.
- The "order :: **" notation was garbled in the fetched text; it is marked as inferred.
- The tail of the Grzybek README (about 4 KB) was not read; the license text was not read.
- No code in this skill or its references was executed.

## Claims not adopted as fact

- Cycle detection by every named tool: only the Spring Modulith and general ArchUnit-style use is in the sources; the skill says to check the chosen tool.
- `dependency-cruiser` as a boundary checker (earlier draft): not read in any source.
- C4 diagrams and an architecture decision log in the Grzybek repository (earlier draft): not re-confirmed.
- `PublishedEvents` / `AssertablePublishedEvents` (earlier draft): absent from the 2.2.0 testing page.
- Order preservation under resubmission with serialized externalization (earlier draft): not found on the events page.
- "Slice test boots the module's schema against a real test DB" (earlier draft): not stated by the testing page.
- Asynchronous events as the universal rule between modules: the skill's default only; sources differ (see rule 3 of the skill).

Fowler's page is a blog post and states no data on how often the path works.
