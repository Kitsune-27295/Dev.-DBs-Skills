# When Hexagonal Architecture Pays Off: Costs and Trade-offs

Sources: https://jmgarridopaz.github.io/content/hexagonalarchitecture.html · https://docs.aws.amazon.com/pt_br/prescriptive-guidance/latest/cloud-design-patterns/hexagonal-architecture.html · https://reflectoring.io/spring-hexagonal/ · Last verified 2026-11-27

Netflix and Baeldung articles returned HTTP 403 again on 2026-11-27 (WebFetch and curl), so nothing here relies on them.

## Benefits claimed (read in sources)

- **Testability**: test drivers and mocks let the application be tested alone; fits BDD (Garrido). AWS agrees: abstractions on inputs and outputs make isolated unit tests easier.
- **Maintainability and flexibility**: change technology by changing an adapter; adapters can be chosen by configuration; new adapters need no change to existing code (Garrido).
- **Delayed technology decisions**: build business logic first (Garrido).
- **Independent evolution**: several client types share one domain; database and UI technology can be refreshed without touching logic (AWS).
- **DDD fit**: each application component can map to a subdomain (AWS).
- **Fakes even with stable technology**: mock adapters help in dev, test and production environments that differ (Garrido).

## Costs (argued, none measured)

- **Complexity**: many modules with explicit dependency rules, more if the language cannot expose only ports (Garrido).
- **Build time** in large projects with many adapters (Garrido).
- **Indirection and mapping**: extra calls and object translation (Garrido, Hombergs).
- **Maintenance overhead**: adapter code is justified only when inputs or outputs vary or storage must change over time (AWS).
- **Latency**: AWS lists it as a concern; in-process it is likely small (own inference).

## Decision matrix (own synthesis)

| Situation | Verdict |
|---|---|
| Small CRUD, fixed technology, one client | Skip ports; plain layered module (`layered-n-tier-architecture`) |
| Rich business rules, long-lived, several clients | Adopt use cases, ports and adapters |
| Stable technology, unreliable or unavailable external service | Adopt for that one port; a fake stands in |
| Serverless function with one database | Light version: pure domain class plus one repository port (the AWS sample shape) |
| Unsure | One port at the most volatile boundary; add others on demand (`yagni-evolutionary-architecture`) |

## Failure modes

- Adopting it for a CRUD app and drowning in pass-through classes.
- Ports invented for things that never vary and have one caller.
- Keeping the ceremony while rules live in adapters.

## How an agent should apply this

- State the case in one sentence, naming a concrete variation (second client, planned swap, need for a fake), before adding a port.
- For borderline modules, introduce ports lazily where volatility or test pain already shows.
- Report costs honestly (mapping, indirection); promise no speedups, none are measured.
- Reject an adapter with one implementation, one caller and no test-double need.
