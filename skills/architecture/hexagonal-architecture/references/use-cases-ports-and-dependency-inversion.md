# Use Cases, Command Objects and Dependency Inversion

Sources: https://reflectoring.io/spring-hexagonal/ · https://docs.aws.amazon.com/pt_br/prescriptive-guidance/latest/cloud-design-patterns/hexagonal-architecture.html · https://github.com/emedina/hexagonal-spring-ref-app · https://github.com/cod3rcursos/arq-hexagonal-simplificada · Last verified 2026-11-27

## Shape of the core (Hombergs, BuckPal example)

- **Domain objects** hold state and behavior together; `Account` enforces its own withdrawal rules.
- **Use cases** are first-class classes, one per user action (`SendMoneyService`): load domain objects, call behavior, save, and depend on nothing outside the hexagon. The example also locks accounts and releases the locks around the transfer.
- **Input port**: the interface a use case implements and outside callers invoke (`SendMoneyUseCase`).
- **Command object**: bundles the input parameters and validates itself in its constructor, keeping validation noise out of the use case.
- **Output ports**: interfaces the use case needs (load or save accounts), shaped by the use case, not by the database. This is Dependency Inversion: the use case owns the abstraction, the adapter implements it. Mechanics: `dependency-inversion-composition-root`.

## Variants of where logic lives

| Variant | Source | Note |
|---|---|---|
| Use case implements the input port | Hombergs | Kept as the default |
| Input-port class orchestrates domain model and output ports | AWS sample | Same idea, other names |
| Command and query handlers per use case | Medina | Per-use-case ports; ArchUnit rules on naming |
| Two folders: `core` (use cases) and `adapters` (input and output ports plus technology adapters) | Cod3r README | Small TypeScript start; the README places the ports inside the adapters module, which differs from the "ports belong to the hexagon" reading, so keep ports in the core when you copy the shape. Licence unconfirmed, ideas only |

## Mapping cost

Separate web, domain and persistence models isolate best and multiply classes; a shared model is cheaper but leaks. Hombergs names mapping as a cost of the pattern. Which strategy to use is not settled by these sources: choose full mapping only where that boundary is likely to change independently (own inference).

## Example: use case owning its output ports (own sketch)

```
interface LoadNotePort { load(id) -> Note }   // owned by the hexagon
interface SaveNotePort { save(note) }
class PublishNote implements PublishNoteUseCase {
  constructor(load: LoadNotePort, save: SaveNotePort) {}
  run(cmd: PublishNoteCommand) {    // cmd validated at construction
    const n = this.load.load(cmd.id)
    n.publish(cmd.actor)            // rule lives in the domain object
    this.save.save(n)
  }
}
```

## Failure modes

- Anemic domain: the use case holds every rule and domain objects are bags of fields; the hexagon then adds ceremony without isolation.
- Output port shaped like the ORM instead of the use-case need.
- Validation repeated per transport instead of in the command or domain.
- One god input port for the whole application.

## How an agent should apply this

- One use case per user action, taking a self-validating command and returning a plain result.
- Define output ports in the core, named by need; implement them in adapters.
- Put invariants in domain objects; controllers only parse, call and format.
- Keep mappers in adapters; decide per boundary whether separate models are worth it.
