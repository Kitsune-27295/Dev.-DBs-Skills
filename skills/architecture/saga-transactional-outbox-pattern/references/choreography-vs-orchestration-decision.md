# Choreography vs Orchestration: Decision Guide

Sources: https://microservices.io/patterns/data/saga.html · https://learn.microsoft.com/en-us/azure/architecture/patterns/saga · Last verified 2026-11-27 (Azure page dated 2025-02-25)

## The two styles
- Choreography: no controller. Each local transaction publishes a domain event that triggers the next participant. Richardson's Create Order example (order may not exceed credit limit) runs on domain events: the order starts as `PENDING`, the customer side reserves credit, and the order is approved or rejected from the outcome event.
- Orchestration: an orchestrator object holds saga state and sends commands (`Reserve Credit`) to participants, receiving replies. In the same example the orchestrator creates the order, sends the reserve-credit command, reads the reply, then approves or rejects. (Step counts in the original page were not verified.)

Terminology (Microsoft): an event is a state change that already happened; a command encapsulates what is needed to perform an action. Choreography runs on events, orchestration on commands plus replies.

## Trade-offs
| Aspect | Choreography | Orchestration |
|---|---|---|
| Fit | Few participants, simple flow | Complex flows, new services joining often |
| Coordination logic | Spread across services | One place (state machine) |
| Single point of failure | None | Orchestrator (make it durable and highly available) |
| Cyclic dependencies | Real risk: participants consume each other's messages | Avoided; orchestrator owns the flow |
| Visibility | Hard to see which participant reacts to what as steps grow | Easy: state is stored and interpretable |
| Integration testing | All services must run to simulate a transaction | Orchestrator testable with stubbed participants (inference) |
| Timeouts and compensation | Each participant must handle them | Centralized |

## Decision rules
- Use choreography when: few participants (Azure; "2-3" is this skill's rule of thumb), linear flow, rarely changing, no desire for a shared coordinator.
- Use orchestration when: 4+ participants (a rule of thumb, not from the sources), branching or parallel steps, timeouts, or a need to answer "where is order 123 stuck?".
- Avoid the saga pattern when: all data sits in one database (use a local transaction). Microsoft lists tight coupling, compensations in earlier participants, and cyclic dependencies as poor fits.
- Hybrid (inference): orchestrate the core business saga, let peripheral consumers (analytics, email) subscribe by choreography.

## Operational concerns (both)
Debugging gets harder as participants grow; monitor and track every saga instance; handle transient failures with idempotent consumers (Microsoft links its Idempotent Consumer pattern); local commits cannot be rolled back, only compensated; compensations can fail.

## Orchestrator skeleton (pseudo-code)
```
on Start(order):      state=CREATING;   send CreateOrder
on OrderCreated:      state=RESERVING;  send ReserveCredit
on CreditReserved:    state=APPROVING;  send ApproveOrder
on CreditRejected:    state=COMPENSATING; send RejectOrder
on timeout(state):    retry or compensate per step class
persist state after every transition, in the same tx as the outgoing command (outbox)
```

## How an agent should apply this
- Count participants and branches first; many participants or any branching means orchestration.
- Persist orchestrator state and outgoing commands in the same local transaction (outbox) so the orchestrator is crash-safe.
- With choreography, draw the event graph and reject any cycle.
- Add a saga id/correlation id to every message and expose a "saga status" query for operators.
- Test every failure branch, not only the happy path.
