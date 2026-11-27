---
name: saga-transactional-outbox-pattern
description: "Keep data consistent across services without two-phase commit: Sagas (local transactions plus compensations, choreography versus orchestration, compensable, pivot and retryable steps, isolation anomalies and countermeasures) and the Transactional Outbox with idempotent consumers (polling publisher versus log tailing or change feed) that removes the database-plus-broker dual write. Gives step-ordering and compensation rules and the mistakes to catch. Not for method-level atomicity inside one database (`transaction-fix`) or broker topology (`event-driven-architecture`). Use when designing, reviewing or debugging cross-service workflows, lost or duplicated events, or saga rollbacks."
---

# Saga & Transactional Outbox Patterns

One idea: when a business transaction spans multiple databases or a database plus a message broker, **Two-Phase Commit (2PC) is not an option** — replace distributed locks with a **Saga** (a sequence of local ACID transactions that undo failures via **Compensating Transactions**), and eliminate dual-write bugs inside every step by persisting state changes and outbound messages atomically in a **Transactional Outbox**. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Chris Richardson & Azure Architecture Center)

| Term | Meaning | Test sentence |
|---|---|---|
| Saga | a sequence of local transactions $T_1, T_2, \dots, T_n$ across services where each step commits locally and failures trigger compensating transactions $C_{k-1}, \dots, C_1$ in reverse order | "ACID minus Isolation: other transactions can see intermediate state" |
| Compensatable Transaction | a local transaction that can potentially be rolled back later by a subsequent failure in the Saga | "must have a matching idempotent Compensating Transaction ($C_i$)" |
| Pivot Transaction | the go/no-go decision point of a Saga: if the Pivot Transaction commits, the Saga is guaranteed to run to completion | "steps before the Pivot are compensable; steps after it are retryable (Azure)" |
| Retryable Transaction | a step after the Pivot Transaction that is idempotent and retried until it succeeds | "only transient failures remain after the pivot" |
| Choreography vs. Orchestration | **Choreography**: decentralized — each service publishes domain events that trigger the next service; **Orchestration**: centralized — a dedicated Saga Orchestrator state machine sends commands to participants and handles replies | "Choreography suits few participants and simple flows; Orchestration suits complex flows (Azure); a 4+ participants cut-off is only this skill's rule of thumb" |
| Transactional Outbox | a table (or document collection in the same logical partition) where outbound messages/events are inserted as part of the **exact same local ACID transaction** that mutates the domain entity | "eliminates the dual-write bug between the database and the message broker" |
| Message Relay | the background process that reads committed rows from the Outbox (via **Polling Publisher** or **Transaction Log Tailing / Change Feed**) and publishes them to the broker | "delivers at-least-once, in the order the application sent the messages (Richardson)" |

## Core architectural rules and invariants

1. **Never dual-write directly to a Database and a Message Broker:** Writing `await db.save(order); await broker.publish(event);` is broken: if the process crashes after `db.save()`, the event is lost forever; if you publish before `db.save()` and the DB commit fails, consumers act on a phantom event. **Always** insert the outbound event into an `OUTBOX` table (or same-partition document batch) inside the same local ACID transaction.
2. **Pair every Outbox with an Idempotent Consumer (Inbox):** Because the Message Relay can crash after publishing to the broker but before marking the Outbox row as published, the broker will receive duplicate messages (*at-least-once* delivery). Every downstream Saga participant and event consumer must track processed `messageId`s in an `INBOX` / `processed_events` table (`idempotency-fix`) or be naturally idempotent.
3. **Classify every Saga step around the Pivot Transaction (Azure vocabulary):** Order your Saga steps intentionally:
   1. **Compensatable steps first** (e.g., `CreateOrder(PENDING)`, `ReserveCredit`), each with a tested compensating action (`RejectOrder`, `ReleaseCredit`).
   2. **Pivot step** (e.g., `AuthorizeCharge`).
   3. **Retryable steps last** (e.g., `ApproveOrder`, `CreateShipment`), which are retried until they succeed.
4. **Mitigate the lack of Isolation (Lost Updates, Dirty Reads, Fuzzy Reads):** Because each Saga step commits to its local database immediately, other transactions can see intermediate state before the Saga finishes. Countermeasures (named by Azure; Richardson's page only points to his book for them):
   - **Semantic Lock:** Have compensatable steps set an explicit pending flag on the record (`status = 'APPROVAL_PENDING'` or `credit_reserved`) that blocks or warns concurrent operations until the Saga clears it.
   - **Commutative Updates:** Design updates so order does not matter (e.g., `balance += delta` rather than `balance = X`).
   - **Pessimistic View:** Reorder Saga steps so data updates happen in retryable steps, which removes dirty reads of values a compensation might roll back.
   - **Reread Value:** Confirm the data is unchanged before updating; if it changed, stop the step and restart the saga.
   - Also named by Azure: **Version File** (log operations per record, apply in order) and **By Value** (pick saga or distributed transaction by business risk).
5. **Compensating transactions are semantic undos, never physical deletions of history:** A compensation (`RefundPayment`, `CancelOrder`) is a new forward local transaction that reverses the business effect of an earlier step and must itself be idempotent and retried until it completes.
6. **Handle Concurrent Compensation & Action Races (own design, with Azure's Version File as the nearest named countermeasure):** If a Saga times out and sends `Compensate` while the original `DoAction` is delayed, the participant may receive `Compensate` first. Record a tombstone/canceled state on `Compensate` so a late `DoAction` is rejected as a no-op. Also remember compensations can fail (Azure): retry them and alert on exhaustion.

## Building order

1. **Build the Transactional Outbox & Inbox foundation first:** Create the `outbox_messages` and `inbox_messages` tables (or Cosmos DB transactional batch + Change Feed processor) and the Message Relay worker.
2. **Map the Saga State Machine and Pivot Point:** List every step, its failure mode, its semantic lock state (`*_PENDING`), and its exact compensating transaction.
3. **Choose Orchestration vs. Choreography:** If the flow has many participants (this skill's rule of thumb: more than 3), branching rollbacks, or timeout management, build an explicit **Saga Orchestrator** persisted as a state machine (`current_step`, `saga_state`, `payload`) rather than scattering choreography listeners across 5 repos.
4. **Implement and test the unhappy rollback paths first:** Write the compensating handlers and verify that a failure at Step $k$ cleanly compensates Steps $k-1 \dots 1$.

## Testing strategy

| Component | Test | Uses |
|---|---|---|
| Transactional Outbox Atomicity | database integration test (`transaction-fix`) | forces an exception before commit and verifies neither the entity nor the Outbox row exists; on commit, verifies both exist atomically |
| Message Relay & Idempotent Consumer | integration test (`idempotency-fix`) | simulates relay crash after publish (delivers same Outbox message twice) and verifies consumer executes the business side effect exactly once |
| Saga Happy Path & Every Rollback Branch | component / state-machine test | tests success ($T_1 \to T_2 \to T_3$) **plus** failure at $T_2$ ($T_1 \to T_2\text{ fails} \to C_1$) and failure at $T_3$ ($T_1 \to T_2 \to T_3\text{ fails} \to C_2 \to C_1$) |
| Out-of-Order Command / Compensation Race | concurrency / ordering test | delivers `Compensate(T_2)` before `Execute(T_2)` and verifies final state remains compensated |

## When it earns its keep

- **Worth it:** Any microservice (`microservices-architecture`), modular monolith (`modular-monolith-architecture`), or event-driven system (`event-driven-architecture`) that updates a database and publishes events/commands, or executes multi-service business workflows without 2PC.
- **Not worth it:** Single-database operations inside a monolith where a standard local ACID database transaction (`BEGIN ... COMMIT`, see `transaction-fix`) can update all tables atomically without distributed Saga overhead.

## Mistakes to catch

- **Using a Saga for tables that live in the same database and schema:** Replacing a 5-line ACID SQL transaction with a 500-line asynchronous Saga when both tables belong to the same service.
- **Publishing events in memory inside an ORM `afterCommit` hook without an Outbox row:** If the process dies 1 millisecond after `COMMIT` and before the in-memory hook finishes the network call to Kafka/RabbitMQ, the event is permanently lost.
- **Choreography spaghetti as participants grow:** Chaining many services via point-to-point events where no single place tracks whether the overall business transaction is stuck, timed out, or partially compensated. Switch to an Orchestrator.
- **Forgetting Semantic Locks (Dirty Reads):** Letting a user cancel or withdraw funds that were temporarily credited by Step 1 of an in-flight Saga that later rolls back at Step 3.
- **Unbounded Outbox table growth:** Never archiving or deleting published Outbox rows, so the polling query slows down. Azure's Cosmos sample expires events by TTL (it suggests about 10 days in production so a downed relay can catch up).
- **Hiding the saga outcome from the client:** A synchronous request that starts a saga needs a way to learn the result (wait, poll or notification; Richardson).

## Quick Decision Checklist

- [ ] Do the writes span services or a broker, rather than one database that a local ACID transaction covers?
- [ ] Are outbound events inserted into an Outbox in the same local transaction, with no dual write?
- [ ] Does every consumer track processed message IDs, or is it naturally idempotent?
- [ ] Are Saga steps ordered as compensatable first, then the Pivot, then retriable steps?
- [ ] Does every compensatable step have a tested, idempotent compensating transaction?
- [ ] Are Semantic Locks or other countermeasures in place for the lack of isolation?
- [ ] Do I use Orchestration for 4+ services, branching rollbacks or timeouts?
- [ ] Does the participant handle Compensate arriving before DoAction, and is the Outbox cleaned up?

## Deep references

- [Saga anomalies and countermeasures](references/saga-anomalies-and-countermeasures.md) — read when classifying saga steps (compensable/pivot/retryable) or choosing isolation countermeasures.
- [Choreography vs orchestration decision guide](references/choreography-vs-orchestration-decision.md) — read when choosing or reviewing a saga coordination style.
- [Outbox relay mechanics and Cosmos DB implementation](references/outbox-relay-and-cosmos-implementation.md) — read when designing the outbox relay, ordering, dedup and cleanup.
- [Trigger evals](references/trigger-evals.md) — sample prompts that should and should not load this skill.
- [Sources](references/sources.md) — retrieved statuses, reading limits, claims not adopted.
