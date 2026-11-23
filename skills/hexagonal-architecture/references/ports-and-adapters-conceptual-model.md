# Ports and Adapters: Conceptual Model in Depth

Sources: https://jmgarridopaz.github.io/content/hexagonalarchitecture.html · https://engsoftmoderna.info/artigos/arquitetura-hexagonal.html · Last verified 2026-11-23

## Core vocabulary

- **Hexagon**: the closed boundary around business-only logic. No framework, device or technology references inside. The pattern puts no constraint on the internal structure (layers, feature modules, DDD tactics, or one CRUD module all fit). The number of sides means nothing; Cockburn picked six for drawing room and to suggest inside versus outside.
- **Actor**: anything outside that interacts with the app (humans, other apps, devices). Classify by *who starts the conversation*: the actor starts it = **driver** (primary); the app starts it = **driven** (secondary).
- **Driven actors split in two**: *repository* (app sends and reads back: database, file store) and *recipient* (app only sends: SMTP server, event bus).
- **Port**: a purpose-grouped boundary interface owned by the hexagon. Named for intent, in the "for ...ing" style (for adding items to a cart, for obtaining orders, for sending notifications), never for technology. Ports belong to the hexagon, not to the adapter side.
- **Driver port** = the application's API / use-case boundary. **Driven port** = the SPI, the "required interface".
- **Adapter**: an outside component translating one technology to or from a port. The GoF Adapter applied to a port. One port can have many adapters.
- **Composition root** (Main component): the only startup code that knows everything.

## Port granularity (a design choice, not a rule)

| Choice | Effect |
|---|---|
| One driver port grouping many use cases | Fewer types, weaker SRP |
| One port per use case (handler per command, often with a command bus) | SRP, easy to test one rule |
| Separate command port and query port | CQRS shape |

Inference: pick one-port-per-use-case when several drivers need different subsets; pick a grouped port for small apps.

## Dependency direction and the symmetry trap

- Driver adapters depend on the hexagon; driven adapters depend on the hexagon; the hexagon depends on nothing but language utilities. This is the whole mechanism (Configurable Dependency: an object receives an interface in its constructor, a concrete is supplied at runtime).
- **Symmetric**: all adapters on both sides depend inward. **Asymmetric**: on the driven side the app must be handed a concrete adapter (it starts the dialogue); on the driver side the app never knows which driver is calling.
- Corollary: construction of driven adapters is wiring work (composition root); a driver only needs a reference to the driver port.

## Composition root, step by step

1. Configure the environment (database connections, servers).
2. For each driven port pick an adapter and instantiate it.
3. Build the application, injecting those adapters through its constructor.
4. For each driver port pick a driver adapter, hand it the application instance, run it.

## Inbound / outbound wording (Valente)

Valente says inbound ports declare the services the system *offers*, outbound ports declare the services it *requires*; both sit in the inner hexagon. His library example: web, mobile and an external system each enter through an inbound adapter to one inbound port (search catalog, loan, register user); persistence goes out through one outbound port implemented by a relational adapter. Note a tension: he draws two concentric hexagons (domain inside, adapters outside), while Garrido stresses the pattern prescribes no layers. Treat concentric rings as a drawing choice.

## Failure modes

- Treating the pattern as "three layers: domain, ports, adapters" and importing that layering rule.
- Drawing the port outside the adapter (actor -> port -> adapter -> app). The correct flow is actor -> adapter -> port (the hexagon's skin).
- Port methods named after the technology or the table.
- Only one adapter per port, with no test adapter or mock: the testability payoff is never collected.

## Example: naming by intent (my sketch)

```
// driver port (what the app offers)
interface ForAssigningTasks { assign(taskId, employeeId) }
// driven ports (what the app needs)
interface ForStoringTasks    { save(task); byId(id) }          // repository
interface ForNotifyingPeople { taskAssigned(employee, task) }  // recipient
```

## How an agent should apply this

- Classify each new dependency as driver, driven repository or driven recipient before naming anything.
- Name ports for the purpose ("for ...ing"), not the technology.
- Make sure every driven port has a real adapter and an in-memory or fake one; every driver port gets a real driver and a test driver.
- Keep adapter construction in the composition root only.
- Do not impose layers inside the hexagon unless the domain complexity calls for them.
