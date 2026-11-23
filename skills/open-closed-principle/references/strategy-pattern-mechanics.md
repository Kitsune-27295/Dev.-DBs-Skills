# Strategy Pattern Mechanics

Sources: https://refactoring.guru/design-patterns/strategy · Last verified 2026-11-23

## Intent and problem

Strategy is a behavioral pattern: define a family of algorithms, put each in its own class, make them interchangeable. The source's motivating case is a navigation app that keeps adding route types (car, walking, public transport, cycling, tourist sights). Each addition enlarges the navigator class, changes to one algorithm risk breaking others, and teammates collide in merge conflicts. Real-world analogy: getting to the airport by bus, cab or bicycle depending on budget and time.

## Structure

| Participant | Role |
|---|---|
| Context | Holds a reference to one strategy; talks to it only through the interface |
| Strategy | Common interface declaring the method the context calls |
| Concrete Strategy | One algorithm variant |
| Client | Creates a concrete strategy, passes it to the context, may replace it at run time via a setter |

Pseudocode in the source: `Strategy.execute(a, b)` with Add/Subtract/Multiply; context's `executeStrategy` delegates; the client picks by user input and calls `setStrategy`.

## Implementation steps (from the source)

1. Find the frequently changing algorithm or the big conditional choosing among variants.
2. Declare the strategy interface.
3. Move each variant to its own class implementing it.
4. Give the context a strategy field (and setter) and use only the interface.
5. Have clients pair a context with a suitable strategy.

## Applicability

Swap algorithm variants at run time; merge near-identical classes that differ in one behavior; isolate business logic from algorithm details; replace a large conditional over variants.

## Pros and cons

- Pros: run-time swapping, isolation of details, composition over inheritance, supports OCP (new strategy, context untouched).
- Cons: with few, stable algorithms the extra types are needless complexity; the client must understand differences between strategies to choose; in languages with function values an anonymous function often suffices.

## Relations (how to pick the neighbor)

| Pattern | Difference from Strategy |
|---|---|
| State | An extension of Strategy; states may know about and trigger each other, strategies are mutually independent |
| Template Method | Inheritance, class-level, static; Strategy is composition, object-level, switchable at run time |
| Decorator | Changes an object's outer behavior; Strategy changes its "guts" |
| Command | Turns an operation into an object (queue, log, undo); Strategy = different ways of the same task |
| Bridge, Adapter | Similar composition structure, different problems |

## Design choices (partly inference)

- **Stateless strategies** can be shared singletons; stateful ones need per-use instances.
- **Data in, result out:** pass needed data as parameters; avoid handing the context itself (couples both ways).
- **Function vs class:** one-method strategy + first-class functions = pass a function; use a class when the strategy has config or several collaborating methods.
- **Selection:** map from key to strategy built at the composition root; unknown key fails fast at startup, not mid-request.
- **Defaults:** supply a default strategy at construction so callers need no knowledge in the common case (mitigates "client must understand strategies").

```ts
type Pricing = (order: Order) => number;          // function strategy
const strategies: Record<string, Pricing> = { standard, member, bulk };
const price = (o: Order, p: Pricing = standard) => p(o);
```

## Failure modes

- Strategy per trivial branch (class explosion).
- Interface grows methods only some strategies use (ISP/Liskov breach: `pragmatic-solid-and-ssot`).
- Context still switches on type before delegating.
- Strategies share mutable context state, hiding coupling.

## Use when / avoid when

Use when 3+ real variants or run-time choice exist and the conditional is a change hotspot. Avoid for two stable branches or pure data differences (use a table).

## How an agent should apply this

- Check the participants: can you point to Context, interface, 2+ concrete strategies and the client that chooses?
- Prefer a function type when the signature has one method.
- Keep selection outside the context; keep the interface minimal.
- If strategies need to switch each other, you want State; say so in the review.
- Test each strategy in isolation and the context with a fake strategy (`testing-pyramid-and-shapes`).
