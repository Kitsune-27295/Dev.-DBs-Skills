---
name: event-driven-architecture
description: Use when designing, reviewing, or debugging an Event-Driven Architecture (producers, event brokers/channels, consumers, Pub/Sub vs Event Streaming), or untangling Martin Fowler's patterns (Event Notification, Event-Carried State Transfer, Event Sourcing, CQRS) and passive-aggressive command traps. Gives pattern boundaries, delivery guarantees, consumer idempotency rules, and common mistakes.
---

# Event-Driven Architecture (EDA)

One idea: decouple **event producers** from **event consumers** through asynchronous **event channels** (pub/sub brokers or durable event streams) so producers announce facts that happened without knowing who listens — **provided** you never confuse the four distinct patterns commonly lumped under "Event-Driven": **Event Notification**, **Event-Carried State Transfer**, **Event Sourcing**, and **CQRS**. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Fowler's four distinct patterns & Azure topology)

| Term | Meaning | Test sentence |
|---|---|---|
| Event Producer | detects or executes a domain change and publishes an immutable event fact | "does not know which consumers exist or what they will do" |
| Event Channel / Broker | ingests and routes events via **Pub/Sub** (push to subscribers, ephemeral) or **Event Streaming** (append-only durable log like Kafka/Event Hubs where consumers track offsets) | "transports events without holding domain business logic" |
| 1. Event Notification | producer sends a thin message ("something changed, here is the ID") with no expectation of a specific response | "low coupling, but hides multi-step workflow control flow if overused" |
| 2. Event-Carried State Transfer (ECST) | event carries the full changed data payload so consumers update their own local read cache and never need to query the producer at runtime | "trades data duplication for higher availability and zero runtime RPC back-calls" |
| 3. Event Sourcing | every state change is persisted as an immutable sequence of events as the system of record; rebuilding state replays the event log | "see `event-sourcing-pattern` — an internal persistence model, not just pub/sub" |
| 4. CQRS | separating the write model (commands) from one or more read models (queries) | "see `cqrs-pattern` — often paired with events, but distinct" |
| Passive-Aggressive Command | an anti-pattern where a producer expects a specific recipient to perform a mandatory action, but disguises the command as an event | "named `OrderPlaced` when it really means `BillCustomerNow` and fails if ignored" |

## Core architectural rules and invariants

1. **Name and choose which pattern you are building:** Before adding a topic or queue, state whether the message is an **Event Notification** (thin fact), **Event-Carried State Transfer** (fat state snapshot for local caching), or an explicit **Command** (directed request to an owner).
2. **Events are immutable past-tense facts (`OrderPaid`), never commands:** An event records something that has already happened inside the producer's boundary. If Producer A requires Service B to do something and cares about the outcome, use a Command or an orchestrated Saga, not a passive-aggressive event notification.
3. **Choose Pub/Sub vs. Event Streaming deliberately:**
   - Use **Publish-Subscribe** (e.g., Event Grid, SNS/SQS, RabbitMQ) when current subscribers need near-real-time push notifications and processed events do not need historical replay.
   - Use **Event Streaming** (e.g., Kafka, Event Hubs) when events must be retained in an ordered, durable log for high-volume stream processing, temporal windowing, or onboarding new consumers that replay history.
   - Do not confuse Pub/Sub (every subscriber gets every event) with **Competing Consumers** on a queue (each work item is processed by only one worker instance).
4. **Publish reliably (Transactional Outbox) and consume idempotently:** Never dual-write to a database and an event broker in raw application code. Persist the event in a local Transactional Outbox within the same DB transaction, and make every consumer idempotent (`idempotency-fix`) because brokers guarantee *at-least-once* delivery, not *exactly-once*.
5. **Make hidden control flows observable:** Event Notification scatters multi-step business flows across decoupled listeners, making the overall process invisible in source code. Propagate a **Correlation ID** and **Causation ID** on every event envelope and enforce distributed tracing.
6. **Plan for out-of-order arrival and poison events:** Network partitions and retries reorder events. Include a monotonic version/sequence number or timestamp per aggregate on every event, and configure a Dead-Letter Queue (DLQ) so malformed or failing events do not block the partition/subscription forever.

## Building order

1. **Map the domain events and ownership:** Identify the producer of each fact, whether consumers need thin notifications or Event-Carried State Transfer, and whether a multi-step flow requires a Saga orchestrator instead of pure choreography.
2. **Define a versioned event schema envelope:** Standardize metadata (`eventId`, `eventType`, `schemaVersion`, `occurredAt`, `aggregateId`, `aggregateVersion`, `correlationId`, `causationId`) plus the payload.
3. **Wire the Producer with a Transactional Outbox:** Commit domain state and the outbox row atomically; let a relay publish to the broker.
4. **Build Idempotent Consumers with DLQs:** Record processed `eventId`s (or check `aggregateVersion`) inside the consumer's transaction, and route permanent failures to a monitored DLQ.

## Testing strategy

| Component | Test | Uses |
|---|---|---|
| Event Producer & Outbox | unit / integration test | verifies domain action emits the exact expected event schema into the Outbox |
| Event Schema Contract | schema / contract test | verifies producer payload matches every consumer's expected JSON/Avro/Protobuf schema (backward compatibility) |
| Event Consumer | integration test | sends the same event twice (idempotency), out-of-order events, and a malformed event (DLQ routing) against a real test DB |
| Choreographed Workflow | trace / scenario test | verifies an end-to-end event chain using correlation IDs across involved consumers |

## When it earns its keep

- **Worth it:** Systems where multiple independent subsystems must react to the same business fact without modifying the producer, high-volume IoT/telemetry ingestion, cross-context data replication for high availability (ECST), and asynchronous workflows with bursty load.
- **Not worth it:** Simple synchronous request-response CRUD flows where the caller immediately needs the result of the write, or workflows with complex multi-step error compensation where pure event choreography turns into an un-debuggable pinball machine.

## Mistakes to catch

- **The Passive-Aggressive Command Trap (Fowler):** Using Event Notification when the sender implicitly depends on a specific receiver executing a side effect. When that flow spans 5 event hops, nobody can read the code and tell what happens on failure.
- **Dual-write without Outbox:** Publishing to Kafka/RabbitMQ before or after `db.commit()` without an Outbox — losing events or emitting phantom events on rollback.
- **Non-idempotent consumers:** Processing a redelivered `PaymentSucceeded` event twice and double-crediting an account (`idempotency-fix`).
- **Breaking event schemas in place:** Renaming or deleting fields in a published event payload without versioning or upcasting, crashing downstream consumers.
- **Unbounded callback storms on thin Event Notifications:** Emitting a thin notification to 20 subscribers who all immediately fire synchronous HTTP `GET` requests back to the producer at the exact same millisecond (fix with Event-Carried State Transfer).
