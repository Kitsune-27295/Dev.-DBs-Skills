# Ports and Adapters: Conceptual Model

Sources: https://alistair.cockburn.us/hexagonal-architecture/ · https://jmgarridopaz.github.io/content/hexagonalarchitecture.html · https://engsoftmoderna.info/artigos/arquitetura-hexagonal.html · Last verified 2026-11-27

## Origin and intent

Cockburn's technical report (HaT 2005.02, dated 2005-09-04, marked version 0.9) states the intent: let users, programs, automated tests or batch scripts drive the application equally, and develop and test it apart from its eventual databases and devices. His central claim is that the useful asymmetry is inside versus outside, not left versus right or top versus bottom. He argues that stacked layer drawings invite business logic to leak across boundaries and cannot show an application with more than two ports. The hexagon exists to leave room for more ports; the number six has no meaning.

## Vocabulary

- **Actor**: anything outside that interacts with the application. Classify by who starts the conversation: actor starts = **driver** (primary); application starts = **driven** (secondary).
- **Driven actors split in two** (Garrido): *repository* (the application sends and reads back) and *recipient* (the application only sends).
- **Port**: a purposeful conversation expressed as an API, owned by the hexagon. Name it for its purpose in the "for ...ing" style, never for a technology.
- **Adapter**: a technology-specific component that plugs into a port and translates. Examples from Cockburn: GUI, test harness, batch driver, HTTP interface on the driving side; SQL, flat file, in-memory mock database on the driven side.
- **Composition root**: startup code that knows everything: configure the environment, pick and build a driven adapter per driven port, build the application with them, then pick a driver adapter per driver port, hand it the application and run it.

## Dependency direction

Both adapter kinds depend on the hexagon, which depends on no technology. The direction is asymmetric in use: on the driven side the application must be handed a concrete adapter (it starts the dialogue), so construction is wiring work for the composition root; on the driver side the application never knows who calls.

## Wording of other authors

Valente calls driver ports "inbound" (services the system offers) and driven ports "outbound" (services it requires), both inside the inner hexagon, with adapters in the outer one. He draws two concentric hexagons; Garrido stresses the pattern prescribes no layers. Treat rings as a drawing choice, not a rule.

## Port granularity (a design choice)

| Choice | Effect |
|---|---|
| One driver port grouping many use cases | fewer types, weaker single responsibility |
| One port per use case | easy to test one rule; different drivers see different subsets |
| Separate command and query ports | CQRS-shaped |

## Failure modes

- Reading the pattern as "three layers: domain, ports, adapters".
- Drawing the port outside the adapter.
- Port methods named after the technology or table.
- Only one adapter per port and no test adapter.

## Example: naming by intent (own sketch)

```
interface ForAssigningTasks  { assign(taskId, employeeId) }        // driver port
interface ForStoringTasks    { save(task); byId(id) }              // driven, repository
interface ForNotifyingPeople { taskAssigned(employee, task) }      // driven, recipient
```

## How an agent should apply this

- Classify each new dependency (driver, repository, recipient) before naming anything.
- Name ports by purpose; keep adapter construction in the composition root.
- Give every driven port a real adapter and an in-memory one; every driver port a real driver and a test driver.
- Do not impose layers inside the hexagon unless domain complexity asks for them (`clean-architecture` owns layer rules).
