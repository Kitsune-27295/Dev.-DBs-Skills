# Microkernel Principles, Partitioning and Extensions

Sources: https://csse6400.uqcloud.net/handouts/microkernel.pdf · https://github.com/ahmedhammad97/Software-Architecture-Patterns-Notes · https://software-architecture-guild.com/guide/architecture/fundamentals/architecture-styles/ · Last verified 2026-11-27

## Four elements (UQ CSSE6400, R. Thomas; PDF dated 9 March 2026, last updated 2023-03-04)
Core system (base functionality or a general processing path), plug-ins (independent specialized behavior), plug-in interface (how core and plug-ins interact), registry (which plug-ins exist and how to reach them). Examples cited: browsers, Eclipse, Jenkins. Worked example: a payroll core (identify employee, calculate pay, pay) with one plug-in per pay adjustment (bonuses, penalty rates, deductions), all behind one `adjustPay(employee, periodDetails, conditions, basePay)` interface returning a signed monetary amount. In the monolith case the registry can be a plain name-to-object map.

## Four principles (UQ definitions 2 to 4, plus the plug-in data rule from section 5.3)
1. Independent Plug-in: plug-ins depend only on the core through the interface, never on each other, nor on core internals or the core datastore. Plug-in-to-plug-in dependencies create coupling and a "big ball of mud".
2. Standard Interface: one interface for the core's use of plug-ins, so two plug-ins or two thousand add no extra core complexity.
3. Domain Standard Interface: when the core is domain-partitioned, give each domain its own plug-in interface so each business process is customized independently (domains may share one when they truly coincide).
4. Plug-in data: the core passes data in; a plug-in that needs persistence owns its own database rather than asking the core to manage it.

## Technical vs domain partitioning of the core
| | Technical (layers) | Domain (business workflows) |
|---|---|---|
| Strength | Matches how developers see code; cohesive per technical capability | Mirrors the business; a story lands in one domain; easier to split into distributed containers and databases |
| Weakness | Business flows cut across all layers; higher data coupling | Boundary code (UI, persistence, queues) is repeated in every domain |

The microkernel core may follow either. Inference: choose domain partitioning when plug-in sets differ per business process.

## Extensions
- Distributed microkernel: core partitions on different tiers (frontend, backend, database server); front and back ends may each have plug-ins, the database usually none.
- Alternative contracts: in-process code modules (JAR/DLL) use a compiled interface; external plug-in services use RMI or, more commonly, REST. Then the registry must also hold the endpoint URL and the request/response data shapes.
- Plug-in databases: each sophisticated plug-in keeps its own store.
- Non-standard interfaces: for third-party services with their own API, write an adapter plug-in so the core still sees one standard interface.

## Positioning from the secondary sources
- The Software Architecture Guild groups microkernel under monolithic styles (with layered, modular, pipeline), names highly customizable product platforms as an ideal use, and warns that managing plug-in dependencies and integration can get hard.
- The Hammad notes (a personal notes repository, secondary) say the core must hold a plug-in registry, plug-ins should communicate minimally, and some plug-ins may depend on others (a concern). Contact options: OSGi, message passing, web services, point-to-point binding, always with a well-defined contract. Its ratings were an image, so no ratings are adopted.

## Sketch: registry plus standard interface
```ts
interface PayAdjustment { adjust(ctx: PayContext): Money }
const registry = new Map<string, PayAdjustment>();
registry.set("overtime", new OvertimePlugin());
const total = [...registry.values()].reduce((s, p) => s.add(p.adjust(ctx)), base);
// core never imports OvertimePlugin directly except at composition root
```

## How an agent should apply this
- Reject any plug-in import of another plug-in; route shared logic through the core interface or a shared library.
- Keep exactly one interface per extension domain and put all data a plug-in needs in its arguments.
- Make the registry richer when plug-ins go out of process (endpoint, schema, version).
- Wrap third-party APIs in adapter plug-ins instead of widening the core interface.
- Give plug-ins that need state their own storage; never let them read the core database.
