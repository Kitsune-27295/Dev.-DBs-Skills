---
name: state-machine-workflow-engine
description: "Model entity lifecycles and workflows as explicit finite state machines and statecharts: State pattern (one class per state, context delegation), states/events/transitions, entry/exit and transition actions, guards, hierarchy (compound states), parallel regions, history, delayed transitions, and Stately/XState-style definitions. Use when an entity has a status field with scattered if/switch logic, when order/payment/document/approval workflows need legal-transition rules, or when choosing between a transition table, State pattern and an XState machine."
---

# State Machine & Workflow Engine

One idea: replace a bag of status flags and scattered conditionals with **one explicit model of which states exist and which events may move between them**; the machine can only occupy valid states, every transition is named, guarded and observable, and side effects hang off entry, exit and transition actions. Sources and claims: [references/sources.md](references/sources.md).

Boundary with neighbors: cross-service orchestration, compensation and the outbox belong to `saga-transactional-outbox-pattern` (the state machine owns the **local** transition model of one entity or process); storing transitions as an immutable event log is `event-sourcing-pattern`; type-level "illegal states unrepresentable" and sum types are `defensive-domain-modeling`; adding states without editing old ones echoes `open-closed-principle`; background execution of delayed or retried transitions is `background-worker-job-scheduler`; message-driven reactions are `event-driven-architecture`; avoid building a framework before need (`yagni-evolutionary-architecture`); draw diagrams with `mermaid`; test shapes in `testing-pyramid-and-shapes`.

---

## 1. When You Need One

| Symptom | Verdict |
|---|---|
| `status` field plus `if (status == ...)` in many methods | Strong candidate |
| Booleans that combine into impossible states (`isPaid && isCancelled`) | Strong: five booleans = 32 combinations, most invalid |
| Rules like "refund only after shipped, never twice" | Guards on transitions |
| Lifecycle needs audit, timeouts, retries | Machine with delayed transitions and actions |
| Two states, one flag, no growth | Plain enum; machine is overkill |

Reject introducing a machine for a two-state toggle or a one-off script.

## 2. Vocabulary (statecharts.dev and Stately)

| Term | Meaning |
|---|---|
| **State** | Mode of the entity; exactly one active at a time in a flat machine |
| **Initial / Final state** | Entered at start / marks completion |
| **Event** | Occurrence that may trigger a transition |
| **Transition** | Source state + event (+ guard) to target state; deterministic per state/event pair |
| **Guard** | Boolean condition that can block a transition |
| **Action** | Side effect on entry, exit or transition |
| **Self-transition** | Leaves and re-enters a state (does something without changing state) |
| **Compound / atomic** | State with child states / without |
| **Parallel (orthogonal) state** | Child regions all active at once, each with its own initial state |
| **History state** | Re-enter the last active substate |
| **Delayed / automatic transition** | Fires after a time in state / immediately on entry (usually guarded) |

Definition vs run-time: the machine definition is like a class; a running instance is like an object. Execution: enter initial state, feed events, match current state's transitions, evaluate guards, exit/enter states, run actions. Details: [references/fsm-and-statechart-concepts.md](references/fsm-and-statechart-concepts.md).

## 3. Choose the Implementation

| Option | Use when | Avoid when |
|---|---|---|
| **Transition table** (map of `state -> event -> {guard, target, action}`) | Flat, <10 states, single language; most business entities | Hierarchy or parallelism needed |
| **State pattern** (class per state; context delegates) | Behavior per state differs a lot and grows; want Open/Closed | Few states that rarely change (the pattern itself calls this overkill) |
| **Statechart library (XState / Stately)** | Hierarchy, parallel regions, history, visual editing, shared diagram with non-developers | Tiny flat flows; serialization/storage requirements not met |
| **Workflow engine (external)** | Long-running, human tasks, cross-service | Single-entity rules |

Details on the State pattern: [references/state-pattern-implementation.md](references/state-pattern-implementation.md).

## 4. Design Rules

1. **Enumerate states first, then events, then the transition matrix.** Mark every blank cell as "rejected" deliberately.
2. **Reject illegal events explicitly:** returning an error or ignoring (decided per event) beats silent state corruption.
3. **Guards must be pure** (no side effects); put effects in actions.
4. **Entry/exit actions for effects tied to being in a state;** transition actions for effects tied to one edge.
5. **Persist the current state value** (plus context data), not derived booleans; persistence and the transition must be atomic (`transaction-fix` territory, outbox for emitting events).
6. **Idempotent transitions:** the same event delivered twice must not double-apply (`idempotency-fix`).
7. **One owner:** only the machine changes the state; no direct `entity.status = ...` writes elsewhere.
8. **Use hierarchy to share handlers** (a parent handles `cancel` for all children) instead of copying transitions; use **parallel regions** instead of multiplying states (4 x 3 combos).

## 5. Minimal Example

```ts
const orderMachine = createMachine({
  id: "order", initial: "draft",
  states: {
    draft:   { on: { SUBMIT: { target: "paid", guard: "hasItems" } } },
    paid:    { entry: "emitPaid", on: { SHIP: "shipped", CANCEL: "cancelled" } },
    shipped: { on: { DELIVER: "delivered" } },   // no CANCEL: illegal by omission
    delivered: { type: "final" }, cancelled: { type: "final" },
  },
});
```
Same model as a transition table in any language: `TABLE[state][event] -> {guard, target, action}`; the executor looks up, checks the guard, exits, runs the action, enters.

## 6. Testing

- Test the **definition**: every state/event cell either transitions to the expected target or is rejected.
- Test guards as pure functions.
- Walk key paths (happy, cancel, retry, timeout) as event sequences asserting final state and emitted effects.
- Property idea (our inference): from any reachable state, a random event sequence never yields a state outside the enumerated set.

## 7. Anti-Patterns

| Smell | Fix |
|---|---|
| State as free-form string edited anywhere | Single machine owns it |
| Boolean flags mimic states | Enumerated states |
| Guards that call services or mutate | Pure guards; effects in actions |
| State explosion from combining independent concerns | Parallel regions or separate machines |
| Duplicating transitions across siblings | Parent state handler |
| Giant machine mixing unrelated workflows | Split per aggregate; coordinate with events/`saga-transactional-outbox-pattern` |
| Switch on state in many methods (the original smell) | State pattern or table |

## Quick Decision Checklist

- [ ] States, events, transition matrix written down; blanks deliberately rejected?
- [ ] Implementation matches complexity (table, State pattern, statechart)?
- [ ] Guards pure; effects in entry/exit/transition actions?
- [ ] Only the machine mutates state; persistence atomic with transition?
- [ ] Transitions idempotent for redelivered events?
- [ ] Hierarchy/parallel used instead of duplicated transitions or state explosion?
- [ ] Tests cover every cell, guards and main paths?
- [ ] Diagram kept beside the code (`mermaid`)?

## Deep references

- [FSM and Statechart Concepts](references/fsm-and-statechart-concepts.md) — when you need precise semantics: execution steps, hierarchy, parallel, history, delayed, guards
- [State Pattern Implementation](references/state-pattern-implementation.md) — when refactoring conditionals into state classes or comparing with Strategy
- [Stately and XState Modeling](references/stately-xstate-modeling.md) — when defining machines in XState/Stately and reading their diagrams
