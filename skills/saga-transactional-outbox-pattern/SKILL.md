---
name: saga-transactional-outbox-pattern
description: Use when designing, reviewing, or debugging distributed transactions and reliable event publishing across microservices or modular monoliths — implementing Sagas (Choreography vs Orchestration, Compensating Transactions, ACD semantic locks/countermeasures) and the Transactional Outbox + Idempotent Consumer pattern (Polling Publisher vs Transaction Log Tailing / Change Feed). Gives atomic dual-write elimination, compensation rules, and common mistakes.
---

# Saga & Transactional Outbox Patterns

One idea: when a business transaction spans multiple databases or a database plus a message broker, **Two-Phase Commit (2PC) is not an option** — replace distributed locks with a **Saga** (a sequence of local ACID transactions that undo failures via **Compensating Transactions**), and eliminate dual-write bugs inside every step by persisting state changes and outbound messages atomically in a **Transactional Outbox**. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Chris Richardson & Azure Architecture Center)

| Term | Meaning | Test sentence |
|---|---|---|
| Saga | a sequence of local transactions $T_1, T_2, \dots, T_n$ across services where each step commits locally and failures trigger compensating transactions $C_{k-1}, \dots, C_1$ in reverse order | "gives ACD (Atomicity, Consistency, Durability) without the Isolation of a single DB lock" |
| Compensatable Transaction | a local transaction that can potentially be rolled back later by a subsequent failure in the Saga | "must have a matching idempotent Compensating Transaction ($C_i$)" |
| Pivot Transaction | the go/no-go decision point of a Saga: if the Pivot Transaction commits, the Saga is guaranteed to run to completion | "transactions before the Pivot are compensatable; transactions after it are retriable" |
| Retriable Transaction | a step after the Pivot Transaction that is guaranteed to succeed eventually via idempotent retries | "cannot fail permanently for business reasons" |
| Choreography vs. Orchestration | **Choreography**: decentralized — each service publishes domain events that trigger the next service; **Orchestration**: centralized — a dedicated Saga Orchestrator state machine sends commands to participants and handles replies | "use Choreography for 2-3 simple steps; use Orchestration for 4+ steps or cyclic dependencies" |
| Transactional Outbox | a table (or document collection in the same logical partition) where outbound messages/events are inserted as part of the **exact same local ACID transaction** that mutates the domain entity | "eliminates the dual-write bug between the database and the message broker" |
| Message Relay | the background process that reads committed rows from the Outbox (via **Polling Publisher** or **Transaction Log Tailing / Change Feed**) and publishes them to the broker | "delivers at-least-once in commit order" |

## Core architectural rules and invariants

1. **Never dual-write directly to a Database and a Message Broker:** Writing `await db.save(order); await broker.publish(event);` is broken: if the process crashes after `db.save()`, the event is lost forever; if you publish before `db.save()` and the DB commit fails, consumers act on a phantom event. **Always** insert the outbound event into an `OUTBOX` table (or same-partition document batch) inside the same local ACID transaction.
2. **Pair every Outbox with an Idempotent Consumer (Inbox):** Because the Message Relay can crash after publishing to the broker but before marking the Outbox row as published, the broker will receive duplicate messages (*at-least-once* delivery). Every downstream Saga participant and event consumer must track processed `messageId`s in an `INBOX` / `processed_events` table (`idempotency-fix`) or be naturally idempotent.
3. **Classify every Saga step around the Pivot Transaction:** Order your Saga steps intentionally:
   1. **Compensatable steps first** (e.g., `CreateOrder(PENDING)`, `ReserveCredit`), each with a tested compensating action (`RejectOrder`, `ReleaseCredit`).
   2. **Pivot step** (e.g., `AuthorizeCharge`).
   3. **Retriable steps last** (e.g., `ApproveOrder`, `CreateShipment`), which are retried until they succeed.
4. **Mitigate the lack of Isolation (ACD Anomalies: Lost Updates, Dirty Reads, Fuzzy Reads):** Because each Saga step commits to its local database immediately, other transactions can see intermediate state before the Saga finishes. Use Richardson's countermeasures:
   - **Semantic Lock:** Have compensatable steps set an explicit pending flag on the record (`status = 'APPROVAL_PENDING'` or `credit_reserved`) that blocks or warns concurrent operations until the Saga clears it.
   - **Commutative Updates:** Design updates so order does not matter (e.g., `balance += delta` rather than `balance = X`).
   - **Pessimistic View:** Reorder Saga steps so high-risk business checks happen early, minimizing the window where dirty reads occur.
   - **Reread Value:** Verify the record version hasn't changed before overwriting.
5. **Compensating transactions are semantic undos, never physical deletions of history:** A compensation (`RefundPayment`, `CancelOrder`) is a new forward local transaction that reverses the business effect of an earlier step and must itself be idempotent and retried until it completes.
6. **Handle Concurrent Compensation & Action Races:** If a Saga times out and sends a `Cancel/Compensate` command while the original `DoAction` command is delayed on the network, the participant might receive `Compensate` *before* `DoAction`. Make the participant record a tombstone/cancelled state on `Compensate` so a late-arriving `DoAction` is rejected as a no-op!

## Building order

1. **Build the Transactional Outbox & Inbox foundation first:** Create the `outbox_messages` and `inbox_messages` tables (or Cosmos DB transactional batch + Change Feed processor) and the Message Relay worker.
2. **Map the Saga State Machine and Pivot Point:** List every step, its failure mode, its semantic lock state (`*_PENDING`), and its exact compensating transaction.
3. **Choose Orchestration vs. Choreography:** If the flow has >3 services, branching rollbacks, or timeout management, build an explicit **Saga Orchestrator** persisted as a state machine (`current_step`, `saga_state`, `payload`) rather than scattering choreography listeners across 5 repos.
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
- **Choreography spaghetti across 6+ services:** Chaining 6 services via point-to-point events where no single place tracks whether the overall business transaction is stuck, timed out, or partially compensated. Switch to an Orchestrator.
- **Forgetting Semantic Locks (Dirty Reads):** Letting a user cancel or withdraw funds that were temporarily credited by Step 1 of an in-flight Saga that later rolls back at Step 3.
- **Unbounded Outbox table growth:** Never archiving or deleting published Outbox rows (`published_at IS NOT NULL`), causing the Outbox polling query to slow down as the table hits tens of millions of rows.
