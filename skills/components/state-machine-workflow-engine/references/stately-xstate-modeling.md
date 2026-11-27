# Stately and XState Modeling

Sources: https://stately.ai/docs/state-machines-and-statecharts · https://statecharts.dev/what-is-a-statechart.html · Last verified 2026-11-23

The Stately page is an introduction; it says guards, actions, history and actors are not covered there. Anything beyond that below is marked "general knowledge, not read from source".

## Definitions on the page

- **State machine:** model of how a process changes between states in response to events; helps find impossible states and undesirable transitions. A flat machine has one active state.
- **Statechart:** visual extension (boxes and arrows) adding hierarchy, concurrency and communication (linked to the actor model). In Stately Studio both terms are the same thing, called state machines.
- **FSM:** a state machine with finitely many states.

## Elements

| Element | Notes from the page |
|---|---|
| State | Status or mode (Asleep, Awake); rounded rectangle in Studio |
| Initial state | Entered at start; one top-level initial state |
| Atomic state | No child states |
| Final state | Process completed; double border |
| Event | Occurrence triggering a transition ("wakes up") |
| Transition | Source to target on an event; arrows labeled with events; each state/event pair leads to exactly one next state |
| Self-transition | Leaves and returns to the same state |
| Parent (compound) state | Children active only while parent active; must name an initial child |
| Parallel state | All child regions active at once, divided by dashed lines; each region needs an initial state |

## XState basics from the page

`createMachine` takes an `id`, an `initial` state and a `states` object; each state's `on` maps event names to targets.

```ts
const dogMachine = createMachine({
  id: "dog", initial: "asleep",
  states: {
    asleep: { on: { "wakes up": "awake" } },
    awake:  { on: { "falls asleep": "asleep" } },
  },
});
```

## General knowledge, not read from source (verify against current XState docs)

- Guards are named conditions on transitions; actions are named side effects supplied via the machine's implementation options; `actor`s run machines (`createActor`) and receive events with `send`.
- Machine definitions are plain data: they can be serialized, visualized in Stately Studio and tested without running side effects (pure transition function).
- Prefer named guards/actions so definitions stay serializable and diagrammable.

## Modeling workflow (our recommendation)

1. List the verbs people use ("submit", "approve", "expire") as events; the nouns/phases as states.
2. Draw the flat machine; look for repeated transitions (hierarchy) and independent concerns (parallel).
3. Add guards for business rules, actions for effects.
4. Encode in a library or table; export a diagram into docs (`mermaid`).
5. Review the diagram with domain experts; the picture is the specification.

## Trade-offs

Pros: shared visual language with non-developers, impossible states found at design time, serializable definitions. Cons: runtime dependency; learning curve for hierarchy/actors; machines can be overused for trivial flows; storing and migrating persisted machine state across definition versions needs a plan (our inference).

## Failure modes

Modeling UI events instead of domain events; mixing domain lifecycle and presentation animations in one machine; unnamed inline guards/actions that cannot be inspected; changing state names without migrating persisted instances.

## How an agent should apply this

- Define the machine as data with named guards/actions; keep implementations in a separate map.
- Name events as domain facts (`PAYMENT_CAPTURED`), states as phases.
- Mark initial states for every compound and parallel region.
- Version persisted machine snapshots and write a migration when renaming states.
- Verify API details against current XState docs before coding; this skill did not read them.
