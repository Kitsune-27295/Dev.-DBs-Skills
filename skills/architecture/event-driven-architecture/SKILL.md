---
name: event-driven-architecture
description: Name which "event-driven" pattern you mean and design the channel around it: Event Notification, Event-Carried State Transfer, pub/sub vs event streaming vs queue, broker vs mediator topology, payload (thin vs fat), ordering, schema evolution, and the passive-aggressive command trap (a command disguised as an event). Use when designing, reviewing or debugging a system where producers announce facts to consumers through a broker, or when someone says "make it event-driven". Not for the persistence and replay model (use `event-sourcing-pattern`), read/write split (`cqrs-pattern`), distributed transactions and outbox (`saga-transactional-outbox-pattern`), or one-queue job workers (`background-worker-job-scheduler`).
---

# Event-Driven Architecture (EDA)

One idea: producers announce facts through event channels without knowing who listens, but "event-driven" covers four different patterns (Fowler), so name the one you are building before designing anything. Sources and what was not adopted: [references/sources.md](references/sources.md).

## 1. Vocabulary

| Term | Meaning | Owner of the details |
|---|---|---|
| Producer / channel / consumer | the producer does not know the consumers; consumers are decoupled from each other | this skill |
| Event Notification | thin event, sender expects no meaningful reply; flow becomes hard to see | this skill |
| Event-Carried State Transfer (ECST) | event carries the data so receivers keep their own copy and stop calling the source | this skill |
| Event Sourcing | the event log is the system of record | `event-sourcing-pattern` |
| CQRS | separate read and write models; not itself about events | `cqrs-pattern` |
| Passive-aggressive command | the sender needs a specific receiver to act, but sends an "event" | this skill |

## 2. Core rules

1. **Name the pattern first.** If the request says "event-driven", state which of the four it is; choose each independently, since adopting one does not imply the others.
2. **An event is a past-tense fact; a command is a request to an owner.** If removing one subscriber silently breaks the sender's outcome, it is a command: send a command message, call directly, or orchestrate (`saga-transactional-outbox-pattern`).
3. **Pick the channel by who must receive.** Each work item handled once by one worker is a queue (Competing Consumers; see `background-worker-job-scheduler`). Every interested party gets a copy is pub/sub (no history for new subscribers). Need ordered, durable history, replay or late joiners is event streaming (consumers track their own position; order holds within a partition). See [queues vs pub/sub](references/queues-vs-publish-subscribe.md).
4. **Pick the payload per consumer.** Full attributes spare callbacks but grow messages, create several systems of record and complicate versioning. Keys only keep one source of truth and small contracts but make consumers query the source. Mixing per consumer is allowed when you control them.
5. **Pick the topology by flow.** Broker (broadcast) fits simple flows but nobody owns a multistep transaction, so restart and replay are not built in. Mediator holds state, errors and restarts and dispatches commands, at the price of coupling and a possible bottleneck.
6. **Plan the failure path with the happy path.** Persist in-transit events and acknowledge after handoff; tolerate duplicates, reordering and stale reads; give every event a correlation ID from day one; decide schema versioning early and let consumers tolerate unknown versions; park unrecoverable events visibly. Mechanics: `saga-transactional-outbox-pattern` (outbox, idempotent consumer), `idempotency-fix`, `background-worker-job-scheduler` (poison messages).
7. **Keep sensitive data out of events.** Events are visible to many components (assume breach).

## 3. Building order

1. List each fact, its producer, and whether consumers need a notification, state, or a command.
2. Choose channel type, payload style and topology (rules 3 to 5).
3. Define the envelope: id, type, schema version, occurred-at, entity id plus a version or sequence if order matters, correlation and causation ids (own convention).
4. Wire reliable publishing and consuming; specify retry, error handler and dead-letter path.
5. Document multi-hop flows in a sequence diagram; the code will not show them.

## 4. Testing strategy

| Target | Test |
|---|---|
| Producer emits the right event | integration test on the emitted event |
| Schema compatibility | contract test per consumer |
| Consumer | same event twice, out of order, malformed, against a real test store |
| Choreographed flow | scenario test following one correlation ID end to end (needs deliberate design; async chains are harder to verify than call stacks) |

## 5. When it earns its keep

- Worth it: several subsystems react to the same event, near-real-time reaction, time-window patterns, high-volume ingestion (IoT), independent scaling of producers and consumers.
- Not worth it: plain request-response where synchronous calls meet latency needs, strong consistency across services, or a team without experience operating asynchronous distributed systems.
- A producer that must wait for an answer can use request-response over a request queue plus a reply queue; ask first whether a direct call is simpler.

## 6. Mistakes to catch

- **Passive-aggressive command** (Fowler): imperative event names (`SendInvoice`) or flows that only work if a named subscriber acts.
- **Callback storm:** a thin notification makes every subscriber query the source at once; consider ECST or a smaller subscriber set.
- **Hidden flow:** a notification chain with no diagram or correlation ID.
- **Too many or too few events:** publish by consequence (for example only `compliant` and `noncompliant`) so each consumer sees relevant events.
- **Breaking schemas in place** without a version strategy.
- **Bundling Event Sourcing and CQRS** into "event-driven" without separate justification.

## Quick Decision Checklist

- [ ] Did I name the pattern (Notification, ECST, Sourcing, CQRS) and justify each separately?
- [ ] Is each message a fact, or an explicit command routed to its owner?
- [ ] Queue, pub/sub or streaming chosen by who must receive and whether replay is needed?
- [ ] Payload style (thin or fat) and topology (broker or mediator) chosen on purpose?
- [ ] Failure path specified: retry, error handler, dead-letter, compensation?
- [ ] Correlation ID, schema version and an idempotent consumer in the contract?
- [ ] Is EDA justified over a synchronous call?

## Deep references

- [Fowler four event patterns](references/fowler-four-event-patterns.md) — before naming or choosing an event-driven pattern
- [Azure EDA topologies and challenges](references/azure-eda-topologies-and-challenges.md) — when choosing channel, payload, topology, error handling
- [Queues vs publish/subscribe](references/queues-vs-publish-subscribe.md) — when choosing between a queue and a topic
- [Trigger evals](references/trigger-evals.md) — when tuning the description
- [Sources](references/sources.md) — verification status and claims not adopted
