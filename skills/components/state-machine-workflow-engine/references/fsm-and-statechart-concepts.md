# FSM and Statechart Concepts

Sources: https://statecharts.dev/what-is-a-state-machine.html · https://statecharts.dev/what-is-a-statechart.html · Last verified 2026-11-27

## Finite-state machine

An FSM can be in exactly one of a finite number of states at a time and changes state in response to external inputs; each change is a transition. It is specified by its states, its initial state and the conditions for each transition. The statecharts.dev example is an on/off switch: states `on` and `off`, a `flick` event toggling them, entering `on` turning a light on (entry action) and exiting turning it off (exit action).

## Why: state explosion in variables

Program state is the set of variables and values at a moment. Five independent booleans give 32 combinations, many invalid. A machine models only valid states and the allowed next state from each; it replaces the variables by one thing that can only be in valid states. (The page makes the 32-combination point; the phrase "state explosion" is ours.)

## Definition vs execution

The abstract machine (diagram or code) is like a class; a running machine is like an object. Components:
- **Initial state** entered automatically at start.
- **Entry/exit actions** run when a state is entered or left, typically side effects.
- **Events** each state defines transitions for.
- **Transitions** exit one state and enter another on an event.
- **Transition actions** run when a transition fires.

Execution loop: enter initial state; pass events as they occur; check each against the current state's transitions; if one matches it fires (exit, transition action, enter, entry actions); now in the new state, ready for the next event.

## Statechart extensions

| Feature | Semantics |
|---|---|
| **Hierarchy** | A state can contain a nested machine (substates). Atomic = no substates; compound = has substates. Entering a compound state enters its initial substate; exiting exits substates. A parent's transitions apply to every child, avoiding duplicates |
| **Orthogonal regions / parallel state** | Compound state split into independent regions, all active at once; entering enters every region |
| **Guarded transitions** | Fire only if the condition is true; if false the event is effectively ignored for that transition |
| **Multiple transitions per event** | Several guarded transitions respond to the same event; the true guard wins at runtime. Order and exhaustiveness matter (our note: make guards mutually exclusive or define precedence, and add a fallback) |
| **Automatic (transient) transitions** | Fire immediately on entering a state; combined with guards they act as decision nodes |
| **Delayed transitions** | Fire after the machine has been in a state for a set time (timeouts) |
| **History states** | A transition to a history state returns to the substate last active |
| **Entry/exit actions** | Side effects tied to entering/leaving |

## Example: hierarchy plus parallel (our illustration, model of Stately's dog example)

```
walk (parallel)
 ├─ movement: walking ⇄ running
 └─ tail:     notWagging ⇄ wagging     (initial: notWagging)
```
Four flat states (walking+wagging, walking+notWagging, ...) collapse into 2+2 states.

## Trade-offs

Pros: explicit legal transitions, visualizable, finite review surface. Cons: diagram sprawl if hierarchy unused; guarded multi-target transitions need careful ordering; timers and parallelism need an execution runtime; flat tables do not scale to hierarchy.

## Failure modes

Missing initial state in a region; overlapping guards giving non-deterministic choice; side effects in guards; delayed transitions that survive restarts without persistence; entry actions that assume a previous state.
