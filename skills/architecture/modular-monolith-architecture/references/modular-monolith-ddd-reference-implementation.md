# Reference Implementation: Modular Monolith with DDD (Grzybek)

Sources: https://github.com/kgrzybek/modular-monolith-with-ddd (README read up to section 3.17; last ~4 KB unread) · Last verified 2026-11-23

## Shape
A .NET app for a Meetup-like domain. A thin API (authenticates, authorizes, forwards commands/queries, no logic) fronts the modules: User Access, Registrations, Meetings, Administration, Payments. Each module has its own composition root and IoC container, initialized by a static method from the host. Layout per module: Application, Domain, Infrastructure and IntegrationEvents assemblies; only IntegrationEvents is visible to others; everything else internal.

## Isolation rules
- Modules talk only through asynchronous integration events on an in-memory event bus; direct method calls between modules are prohibited.
- The API reaches a module through three operations: command with result, command without, query.
- Each module owns a separate schema; no shared data, no transaction across modules; modules could move to separate databases later.
- Reliability: Outbox/Inbox tables per module plus a Quartz.NET worker give at-least-once delivery and processing. Internal commands reuse the mechanism so state changes happen only via commands, in a separate transaction.

## Inside a module
CQRS: commands go through a write model (aggregates, repositories); queries are raw SQL over views. Handlers are wrapped by decorators: logging, validation, unit of work (commit once, dispatch domain events). Authorization is permission-based RBAC checked at the controller. Payments uses event sourcing. The README notes that the mediator hides which handler runs.

## Testing
Unit tests through the public domain API only (no InternalsVisibleTo, no test-only constructors); architecture tests (NetArchTest) for layering, dependencies and encapsulation; integration tests per use case on a real SQL Server, mocking only external services; system tests poll asynchronous flows with probes and timeouts. Docs: C4 levels 1-4, event storming, an architecture decision log.

## Cost
This is a maximal-autonomy design: rich modules plus outbox, event sourcing and CQRS. Treat it as a ceiling, not a default; simple modules need none of it (inference).

## How an agent should apply this
- Copy the boundary rules first (one public contract assembly, own schema, no cross-module calls), the machinery later.
- Add outbox/inbox only when an event must not be lost across a transaction boundary.
- Give each module its own composition root so it can be extracted.
- Add architecture tests in the first module, not after violations appear.
- Choose CQRS or event sourcing per module on need.
