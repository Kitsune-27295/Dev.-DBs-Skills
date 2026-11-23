# When Hexagonal Architecture Pays Off: Costs and Trade-offs

Sources: https://jmgarridopaz.github.io/content/hexagonalarchitecture.html · https://docs.aws.amazon.com/pt_br/prescriptive-guidance/latest/cloud-design-patterns/hexagonal-architecture.html · https://reflectoring.io/spring-hexagonal/ · Netflix and Baeldung pages: unreachable (see note) · Last verified 2026-11-23

Note: https://netflixtechblog.com/ready-for-changes-with-hexagonal-architecture-b315ec967749 and https://www.baeldung.com/hexagonal-architecture-ddd-spring returned HTTP 403 to every fetch method available here (Firecrawl also had no credits). Points about them below come only from the existing `sources.md` summary, not from reading the pages.

## Benefits claimed (read in sources)

- **Testability**: each driver port gets a test driver, each driven port a mock, so the app is testable alone; fits BDD acceptance scenarios (Garrido).
- **Maintainability and flexibility**: switch technology by choosing another adapter, possibly from a properties file with no recompile; add adapters without touching existing code (Garrido).
- **Delayed technology decisions**: build business logic first (Garrido).
- **Independent evolution**: UI and database can be modernised without touching business logic; several clients share one domain (AWS).
- **DDD fit**: each application component can map to a subdomain (AWS).

## Costs (all argued, none measured)

- **Complexity**: many modules with explicit dependency rules (hexagon depends on nothing, adapters on the hexagon, startup on all); if the language cannot expose only ports, the hexagon splits further (Garrido).
- **Build time** in large projects with many adapters (Garrido).
- **Indirection and mapping**: extra calls and object translation (Garrido, Hombergs).
- **Maintenance overhead**: adapter code is justified only when inputs or outputs actually vary; otherwise it is one more layer (AWS).
- **Latency**: an extra layer can add some (AWS). In-process this is small; my inference.

## Decision matrix

| Situation | Verdict |
|---|---|
| Small CRUD, fixed technology, one client | Skip ports; a plain layered or MVC module is enough |
| Rich business rules, long-lived, several clients (CLI, web, agent tools) | Adopt: use cases, ports, adapters |
| Stable technology but an unreliable or unavailable external service | Adopt for that one port only (a mock stands in) |
| Serverless function with one DB | Light version: pure domain class plus one repository port |
| Unsure | One port at the most volatile boundary; add others on demand |

## Netflix evidence (from sources.md, not re-read)

Claimed: a data-source swap done by configuration, and a three-layer test split (many interactor tests, few data-source tests, one success and one failure integration test per action). These are the authors' own numbers; treat as an anecdote, not evidence.

## Failure modes

- Adopting it for a CRUD app and drowning in pass-through classes.
- Ports invented for things that never vary and have one caller.
- Keeping the ceremony but putting rules in adapters, so the cost is paid and the benefit lost.

## How an agent should apply this

- State the case (worth it or not) in one sentence before adding any port, naming a concrete variation (second client, planned swap, need for a fake).
- For borderline modules, introduce ports lazily at boundaries that already show volatility or test pain.
- Report costs honestly (mapping, indirection); do not promise speedups, none are measured.
- Reject adapters that have exactly one implementation, one caller and no test-double need.
