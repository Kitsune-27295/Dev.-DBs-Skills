# Azure EDA Style: Topologies, Payloads and Challenge Catalog

Sources: https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/event-driven (the PT-PT page is the same article, not re-read) · Last verified 2026-11-23

## Building blocks

Producers emit events, channels (brokers or ingestion services) carry them, consumers react. Producers do not know who listens; consumers are decoupled from each other; in pub/sub each consumer sees every event.

**Pub/sub vs event streaming**
- Pub/sub: the infrastructure tracks subscriptions and pushes each event to each subscriber; the event is not kept in a durable log, so new subscribers miss history.
- Streaming: events go to a durable log, strictly ordered within a partition; clients do not subscribe, they read from any position and advance their own offset. This enables replay for recovery, late-joining consumers and reprocessing after a bug fix.
- Competing Consumers (queue) is different: each message is processed once by one consumer.

## Consumer variations

Simple event processing (event triggers an action), basic correlation (correlate by id, persist earlier events, i.e. sagas), complex event processing (patterns over time windows), event stream processing (pipeline into stream processors, typical for IoT).

## Payload strategy

| Style | Pro | Con |
|---|---|---|
| All attributes in payload | Consumers need no callback | Bigger messages, multiple systems of record, harder versioning |
| Keys only | Single system of record, small stable contracts | Consumers query the source often, slower |

Per-consumer mixing is allowed when you control the consumers.

## Topologies

- **Broker**: components broadcast, others react or ignore. Highly decoupled, scalable; nobody owns the state of a multistep transaction, so there is no built-in restart or replay and inconsistency risk is real.
- **Mediator**: a mediator holds state, handles errors and restarts, and dispatches commands (usually onto queues) instead of broadcasting. More control and consistency; more coupling and a possible bottleneck/reliability point.

## Challenge catalog (and the stated mitigation)

| Challenge | Mitigation from the page |
|---|---|
| Guaranteed delivery | Persist in-transit events; acknowledge only after handoff (client acknowledge mode) |
| Eventual consistency | Design consumers and reads to tolerate stale data |
| Ordering / exactly-once with multiple instances | Idempotent consumers; minimize coordination |
| Cross-service coordination | Choreography or saga orchestration; compensating transactions |
| Error handling | Error-handler processor, resubmit to the channel (out of order), then dead-letter queue |
| Observability | Correlation ID in every event, planned from the start |
| Request-response need | Request queue plus reply queue with session id / reply-to |
| Too many or too few events | Publish by consequence, e.g. only `compliant` / `noncompliant` |
| Schema evolution | Versioning strategy early; consumers tolerate unknown versions |

Security note from the page: events are visible to many components, so avoid leaking sensitive data into them ("assume breach").

## When to use / avoid

Use: several subsystems need the same events, near-real-time reaction, time-window pattern matching, high volume (IoT), independent scaling of producers and consumers. Avoid: simple request-response is enough; strong cross-service consistency is required; the team has not operated async distributed systems.

## Example: DLQ flow (pseudo-code)

```
on_event(e):
  try: handle(e)            # idempotent by e.id
  except Transient: send(error_handler, e)
error_handler(e):
  if retry_ok(e): resubmit(channel, e)   # may reorder
  else: send(dead_letter_queue, e)       # human inspection
```

## How an agent should apply this

- Pick broker topology for simple fan-out and mediator/orchestrator for multistep transactions needing restart.
- Require a correlation ID, an event version field, and an idempotency key in every event contract you design.
- Specify the failure path (retry, DLQ, compensation) alongside the happy path.
- Choose streaming over pub/sub only when replay or late consumers are real requirements.
- Reject EDA for plain synchronous interactions; say why (operational overhead, eventual consistency).
