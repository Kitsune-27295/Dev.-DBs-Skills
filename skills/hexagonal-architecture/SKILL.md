---
name: hexagonal-architecture
description: Use when designing, reviewing or changing code in a Ports & Adapters (hexagonal) codebase - adding a use case, a driving adapter (CLI, MCP, HTTP), a driven adapter (database, filesystem, network, model provider), a port, or the composition root - or when a dependency points the wrong way (a use case importing a driver, SQL or node:fs outside an adapter). Gives the dependency rules, the order to build things in, a test per layer, and the common mistakes. Also use before splitting a layered module into hexagon plus adapters.
---

# Hexagonal architecture (Ports & Adapters)

One idea: the application is a closed area with no knowledge of technology. Everything outside it (people, tests, other programs, databases, mail servers) talks to it through **ports** and is translated by **adapters**. Dependencies point inward only. Sources and their claims: `references/sources.md`.

## Vocabulary (use these words, they stop arguments)

| Term | Meaning | Test sentence |
|---|---|---|
| Hexagon | the application: domain plus use cases plus its ports | "no technology is named in here" |
| Driver (primary) actor | triggers the conversation: user, test, cron, another system | "who starts it? the actor" |
| Driven (secondary) actor | provides what the app needs: repository (read and write) or recipient (send and forget) | "who starts it? the application" |
| Driver port (inbound) | the API the hexagon offers; boundary of the use cases | "this port is for ...ing something" |
| Driven port (outbound) | the SPI the hexagon requires; shaped by what the use case needs, never by the technology | named for purpose, not for tool |
| Driver adapter | turns a technology request into a call on a driver port | CLI parser, HTTP handler, MCP tool, test case |
| Driven adapter | implements a driven port with one technology | SQLite repository, filesystem, fake in memory |
| Composition root | the only place that picks adapters and wires them | `main`, bootstrap |

Ports belong to the hexagon, not to the adapter. Draw it `actor -> adapter -> (port) hexagon`, never `actor -> port -> adapter`.

## Dependency rules (what to check on every change)

1. The hexagon depends on nothing but the language runtime. No database driver, no HTTP, no `node:fs`, no framework, no vendor SDK.
2. Driver adapters depend on a driver port (or the use case that implements it). They never reach into the domain's internals or into a driven adapter.
3. Driven adapters depend on the hexagon (they implement its port). They never import another adapter; if two adapters need the same thing, it belongs in the hexagon or a port.
4. Only the composition root imports concrete adapters, and only to hand them to the hexagon.
5. Layers inside the hexagon (domain, use cases) are your choice; the pattern says nothing about them. Keep rule 1 true for all of them.
6. Never put technology annotations or ORM types on a domain object. Map at the adapter boundary and accept the small cost.

Asymmetry to remember: the driver adapter knows the application (it calls it); the application knows the driven port (it calls it) but never which adapter sits behind it. This is Configurable Dependency (dependency injection through a constructor argument or a registry).

## Building order (from the canonical article)

1. Define the ports around the application as a black box. Expect to refine driven ports while writing use cases; add them when a use case needs them.
2. Implement each driver port **test-first**, driven by a test adapter, with in-memory fakes behind the driven ports. The hexagon is now complete and testable in isolation.
3. Add the real driver adapters (CLI, HTTP, MCP), still on the fakes.
4. Add the real driven adapters (database, filesystem, network), still driven by the tests.
5. Wire real with real in the composition root and run end to end.

## Tests per layer

| Layer | Test | Uses |
|---|---|---|
| Domain objects | unit | nothing |
| Use cases (driver port) | acceptance, most of the suite | in-memory fakes of the driven ports |
| Driven adapter | integration, few | the real technology plus a contract check that it honors the port |
| Driver adapter | integration, few | a real or recorded request against a fake hexagon |
| Whole system | system, one success and one failure per flow | everything real |

Guard the rules with an architecture test (import graph scan) so a wrong-way import fails the build; do not rely on review.

## When it earns its keep

Worth it: long-lived system, several kinds of client (CLI, web, agent tools), technology that will change, rich business rules. Not worth it: a small CRUD with fixed technology (the adapter layer becomes a cost with no payoff). Say which case you are in before adding ports.

## Mistakes to catch

- Reading "three layers: domain, ports, adapters" into the pattern. The pattern prescribes none.
- A port shaped like the database ("findByJoinedTable") instead of the need ("find notes the reader may see").
- A use case that builds an SQL string, opens a file or calls `fetch`. Move it behind a driven port.
- A driver adapter that holds business rules (validation, permission, sensitivity ceilings). Rules live in the hexagon so every driver gets them; a rule missing in one transport is a security bug.
- Two adapters importing each other, or an adapter importing the composition root.
- A global that lets any code fetch a concrete adapter. Resolve ports through the one locator that the composition root fills.
- Inventing a port for something that will never vary and has one caller.

## In this repository

Map the six areas to the rules above and follow `AGENTS.md`: `src/domain` (pure), `src/ports` (inbound and outbound interfaces plus the runtime locator), `src/application` (use cases), `src/adapters` (driven, one family per folder, no cross-family imports), `src/drivers` (CLI, MCP, HTTP; never import `src/adapters`), `src/bootstrap` (the only wiring root). The strict check lives in the architecture test; run it before finishing any structural change.

## Deep references

- [Ports and Adapters: conceptual model](references/ports-and-adapters-conceptual-model.md) — read when classifying actors, naming ports, or settling port granularity and composition-root duties.
- [Implementation order and testing strategy](references/implementation-order-and-testing-strategy.md) — read when planning the build sequence, test levels, contract tests or architecture tests.
- [Use cases, command objects and dependency inversion](references/use-cases-ports-and-dependency-inversion.md) — read when writing a use case, its input and output ports, or deciding where logic lives.
- [When hexagonal pays off: costs and trade-offs](references/when-hexagonal-pays-off-costs-and-tradeoffs.md) — read when deciding whether a module needs ports at all.
