---
name: hexagonal-architecture
description: "Keep business logic independent of technology with Ports & Adapters (hexagonal architecture, Cockburn 2005): classify actors as driver or driven, shape ports by purpose, put adapters outside, wire everything in one composition root, build and test the core first against in-memory fakes, and guard the dependency direction with a test. Use when adding a use case, a driver adapter (CLI, HTTP, agent tool), a driven adapter (database, file system, network, model provider) or a port, when a dependency points the wrong way (a use case importing a driver or SQL), or before deciding whether a module needs ports at all. Not for ring-by-ring layering rules (use clean-architecture), the injection mechanics (use dependency-inversion-composition-root) or slicing by feature (use vertical-slice-architecture)."
---

# Hexagonal architecture (Ports & Adapters)

One idea: **the application is a closed area that names no technology; everything outside it (people, tests, other programs, databases, mail servers) talks to it through ports, and adapters translate.** Dependencies point inward only. Sources, retrieved statuses and unadopted claims: [references/sources.md](references/sources.md).

## 1. Vocabulary

| Term | Meaning | Test sentence |
|---|---|---|
| Hexagon | the application: business logic plus its ports | "no technology is named in here" |
| Driver (primary) actor | starts the conversation: user, test, scheduler, another system | "who starts it? the actor" |
| Driven (secondary) actor | contacted by the application: a *repository* (read and write) or a *recipient* (send only) | "who starts it? the application" |
| Driver port | the application's API, its use-case boundary | named for a purpose: "for ...ing" |
| Driven port | what the application requires from outside | shaped by the need, not by the tool |
| Adapter | translates one technology to or from a port; one port can have many | CLI parser, HTTP handler, SQL repository, in-memory fake |
| Composition root | the one startup place that knows everything and wires it | `main`, bootstrap |

Ports belong to the hexagon, not to the adapter. The flow is `actor -> adapter -> port -> hexagon`, never `actor -> port -> adapter`.

## 2. Dependency rules (check on every change)

1. The hexagon depends on nothing but the language runtime: no database driver, HTTP, file system API, framework or vendor SDK.
2. Driver adapters call a driver port. Driven adapters implement a driven port. Both depend on the hexagon, never the reverse.
3. No adapter imports another adapter. Shared need: move it into the hexagon or a port.
4. Only the composition root names concrete adapters, and only to hand them to the hexagon.
5. The pattern prescribes no layers inside the hexagon (Cockburn criticizes layer drawings; Garrido lists "three layers" as a misreading). Choose internal structure freely, keep rule 1 true. Ring-by-ring layer rules: `clean-architecture`.
6. Map at the adapter boundary; keep ORM or transport annotations off domain objects when you can afford the mapping.

Asymmetry: a driver adapter knows the application; the application knows its driven ports but never the adapter behind them. Injection mechanics: `dependency-inversion-composition-root`.

## 3. Ports: classify, then name

1. Ask who starts the conversation. Actor starts: driver port. Application starts: driven port; then repository or recipient.
2. Name by purpose (`ForStoringTasks`, `ForNotifyingPeople`), never by technology or table.
3. Granularity is your choice: one driver port per use case (easy to test, different drivers see different subsets), or a grouped port for a small app. Cockburn expects most applications to need only two to four ports.
4. Reject a port with one implementation, one caller and no need for a test double.

Detail and a naming example: [references/ports-and-adapters-conceptual-model.md](references/ports-and-adapters-conceptual-model.md).

## 4. Build order (Garrido de Paz)

1. Test driver adapter plus mock or in-memory driven adapters: the hexagon is complete and testable alone. Driven ports surface while you write this; add them then.
2. Real driver adapters (web, CLI, agent tool), mocks kept.
3. Real driven adapters (database, email), driven by the step-1 test driver.
4. Real drivers with real driven adapters, wired in the composition root; any combination is configurable.

## 5. Tests per layer

| Layer | Test (Pryce terms) | Uses |
|---|---|---|
| Domain objects | unit | nothing |
| Use cases through the driver port | acceptance, bulk of the suite | in-memory fakes of driven ports |
| Adapter | integration | the real technology plus a contract check that it honors the port |
| Whole system | system, few | everything real |

Guard rule direction with an architecture test (an import-graph scan or a tool such as ArchUnit) so a wrong-way import fails the build. Test-shape economics: `testing-pyramid-and-shapes`; test-first loop: `tdd`.

## 6. Does it pay off?

Garrido: small projects may not justify the complexity; medium and large long-lived ones usually do, and mock adapters help dev and test even when production technology never changes. Hombergs: rich business rules pay off, plain CRUD is probably overhead. AWS: adapters are justified when inputs or outputs vary. All costs (complexity, indirection, mapping, build time) are argued, not measured. State the case in one sentence naming a concrete variation before adding a port. Cost of speculative structure: `yagni-evolutionary-architecture`. Detail: [references/when-hexagonal-pays-off-costs-and-tradeoffs.md](references/when-hexagonal-pays-off-costs-and-tradeoffs.md).

## 7. Mistakes to catch

- A port shaped like the database (`findWithJoins`) instead of the need.
- A use case that builds SQL, opens a file or calls the network.
- Business rules (validation, permissions) inside a driver adapter: every other driver then lacks them.
- Two adapters importing each other, or an adapter importing the composition root.
- A global that lets any code fetch a concrete adapter.
- One adapter per port and no fake: the testability payoff is never collected.
- Keeping the ceremony while rules live in adapters: cost paid, benefit lost.

## Quick Decision Checklist

- [ ] Does the hexagon import nothing but the language runtime?
- [ ] Was each port classified (driver, driven repository, driven recipient) and named by purpose?
- [ ] Are business rules in the hexagon, not in a driver adapter?
- [ ] Do adapters avoid importing each other, with only the composition root wiring concrete ones?
- [ ] Is each use case tested against in-memory fakes before a real adapter exists?
- [ ] Does an architecture test fail the build on a wrong-way import?
- [ ] Can I name the concrete variation (second client, planned swap, need for a fake) that justifies each port?

## Deep references

- [references/ports-and-adapters-conceptual-model.md](references/ports-and-adapters-conceptual-model.md): read when classifying actors, naming ports or settling granularity and composition-root duties.
- [references/implementation-order-and-testing-strategy.md](references/implementation-order-and-testing-strategy.md): read when planning the build sequence, contract tests or architecture tests.
- [references/use-cases-ports-and-dependency-inversion.md](references/use-cases-ports-and-dependency-inversion.md): read when writing a use case, its command object and output ports.
- [references/when-hexagonal-pays-off-costs-and-tradeoffs.md](references/when-hexagonal-pays-off-costs-and-tradeoffs.md): read when deciding whether a module needs ports.
- [references/trigger-evals.md](references/trigger-evals.md): read when tuning this skill's description.
- [references/sources.md](references/sources.md): URL statuses, reading limits, claims not adopted.
