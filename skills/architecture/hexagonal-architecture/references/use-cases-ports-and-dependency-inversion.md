# Use Cases, Command Objects and Dependency Inversion

Sources: https://reflectoring.io/spring-hexagonal/ · https://github.com/cod3rcursos/arq-hexagonal-simplificada · https://github.com/emedina/hexagonal-spring-ref-app · https://docs.aws.amazon.com/pt_br/prescriptive-guidance/latest/cloud-design-patterns/hexagonal-architecture.html · Last verified 2026-11-23

## Shape of the core (Hombergs, BuckPal example)

- **Domain objects** hold state and behavior together, plain code with no outward dependency. The `Account` example enforces withdrawal rules itself. They change only when business rules change.
- **Use cases** are first-class classes, one per user action (`SendMoneyService`). They load domain objects, call behavior, save results, and depend on nothing outside the hexagon.
- **Input port** = interface the outside calls (`SendMoneyUseCase`), implemented by the use case. Callers are driving adapters.
- **Command object** bundles the parameters and validates itself in its constructor, so the use case stays free of validation noise and cannot receive an invalid command.
- **Output ports** (`LoadAccountPort`, `UpdateAccountStatePort`) are shaped by what the use case needs. This is Dependency Inversion: the use case owns an abstraction; the persistence adapter implements it. Ports can be shared across use cases.
- **Driving adapter**: a REST controller reads path/body, builds the command, calls the input port; authentication and JSON mapping live here. **Driven adapter**: a persistence adapter implements the output ports and maps domain objects to ORM entities through a mapper.
- Framework annotations (`@Component`, `@Transactional`) appear on services and adapters for wiring. Hombergs accepts that on use-case services; domain objects stay clean.

## Variants of where logic lives

| Variant | Source | Note |
|---|---|---|
| Use case implements the driver port directly | Hombergs, Garrido | The skill's stricter reading, kept |
| Input-port class orchestrates domain model and output ports | AWS sample | Same idea, different naming |
| Command and query handlers behind a bus | Medina | Per-use-case ports; handlers return a result type |
| Two-folder split: `core` (use cases) and `adapters` (port implementations) | Cod3r README (code not readable via the fetch tool; only the README description was seen) | Good starting size for small TypeScript/Deno projects |

## Mapping strategies (inference from the cost discussion)

Full mapping (separate web, domain and persistence models) maximizes isolation but multiplies classes. A shared model across adapters is cheaper but leaks. Use full mapping only where that boundary is likely to change independently. Hombergs defers mapping strategies to his book; the article does not detail them.

## Example: use case owning its output port (my sketch)

```
interface LoadNotePort { load(id) -> Note }     // owned by the hexagon
interface SaveNotePort { save(note) }
class PublishNote implements PublishNoteUseCase {
  constructor(load: LoadNotePort, save: SaveNotePort) {}
  run(cmd: PublishNoteCommand) {      // cmd validated at construction
    const n = this.load.load(cmd.id)
    n.publish(cmd.actor)              // rule lives in the domain object
    this.save.save(n)
  }
}
```

## Failure modes

- Anemic domain: the use case holds all rules and domain objects are bags of fields; the hexagon then adds ceremony without isolation payoff.
- Output port shaped like the ORM (`findWithJoins`) instead of the use-case need.
- Validation duplicated per transport instead of living in the command or domain.
- One god input port for the whole app.

## How an agent should apply this

- Write one use case per user action, taking a self-validating command and returning a plain result.
- Define output ports inside the application core, named by need, then implement them in adapters.
- Put invariants in domain objects; keep controllers to parse, call, format.
- Keep mappers in adapters; decide per boundary whether separate models are worth the cost.
- Annotate only wiring classes; keep domain objects framework-free.
