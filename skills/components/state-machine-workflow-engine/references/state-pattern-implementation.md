# State Pattern Implementation

Sources: https://refactoring.guru/design-patterns/state · Last verified 2026-11-23

## Intent

Let an object change behavior when its internal state changes, so it appears to change class. It is the object-oriented way to implement a finite-state machine: each state a class, transitions by swapping the state object.

## Problem it removes

A `Document` can be Draft, Moderation or Published; `publish()` behaves differently in each (draft goes to moderation, moderated publishes only for an admin, published does nothing). Implemented with `if/switch` on a state field, every method accumulates large conditionals, changing transition rules touches many methods, and since states are hard to predict upfront the code bloats over time.

## Structure

1. **Context:** holds the current state object, delegates state-specific work, exposes a way to replace it.
2. **State interface:** only the methods that vary by state.
3. **Concrete states:** state-specific behavior; shared code may go in abstract intermediates; may hold a back-reference to the context to read data or trigger transitions.
4. **Transitions:** set by the context or by the states themselves.

## Implementation steps (source)

1. Pick the context (existing class or a new one if state logic is spread across classes).
2. Define the state interface with only the varying methods.
3. One concrete class per state; move that state's code in. If it needs context privates: make them public, add public helper methods, or nest the states in the context.
4. Add a state field (interface type) and public setter to the context.
5. Replace conditionals with delegation to the state object.
6. Create state instances and trigger transitions (context, states or client); that code depends on concrete state classes.

## State vs Strategy

Both delegate to helper objects. Strategy keeps the helpers independent and unaware of each other. State allows concrete states to know each other and change the context's state. The page also lists Bridge, State, Strategy and Adapter as structurally similar composition patterns that solve different problems.

## Pros and cons

Pros: Single Responsibility (one class per state), Open/Closed (new state without touching existing states or the context), simpler context. Con: overkill for few states or rarely changing ones.

## Example (TypeScript, our illustration)

```ts
interface DocState { publish(d: Doc, user: User): void }
class Draft implements DocState { publish(d: Doc) { d.setState(new Moderation()); } }
class Moderation implements DocState {
  publish(d: Doc, u: User) { if (u.isAdmin) d.setState(new Published()); }
}
class Published implements DocState { publish() { /* no-op */ } }
class Doc { private state: DocState = new Draft();
  setState(s: DocState) { this.state = s; }
  publish(u: User) { this.state.publish(this, u); } }
```

## When to prefer a table or a library instead (our judgment)

- State classes persist poorly: you need to store a **state name** and rebuild the object; keep a registry mapping name to state.
- Business entities with 4-8 states and mostly data-driven rules are often clearer as a transition table or XState definition, which can also be diagrammed.
- Use the State pattern when behavior (not just permission) differs substantially per state and the set of operations is stable.

## Failure modes

State classes reaching into context internals (leaky encapsulation); states that create each other, coupling them all together; transitions scattered so nobody can draw the machine; state objects holding per-instance data making them non-shareable; persisting the object instead of the state name.

## How an agent should apply this

- Refactor conditionals one method at a time: extract interface, move the branch per state, keep tests green.
- Keep the interface minimal: only state-varying operations.
- Centralize transition knowledge (in the states or one table) and produce a diagram from it.
- Persist the state identifier and rehydrate through a registry.
- Skip the pattern for two or three stable states; use an enum plus a transition table.
