# Transactional Outbox: Relay Mechanics and the Cosmos DB Implementation

Sources: https://microservices.io/patterns/data/transactional-outbox.html · https://learn.microsoft.com/en-us/azure/architecture/databases/guide/transactional-out-box-cosmos · Last verified 2026-11-23

## The problem in one line
Updating the database and publishing to a broker are two writes to two systems. Publishing mid-transaction may precede a rollback; publishing after commit may never happen if the process crashes. Order across service instances must also hold (E1 before E2 for the same aggregate).

## Solution parts (Richardson)
Sender service, database (business tables plus outbox), outbox (a table in SQL; an outbox attribute on the record in NoSQL), and a message relay. Messages are sent if and only if the transaction commits, and in application order. Drawbacks: easy to forget the outbox write; the relay can publish twice (crash after publish, before marking done), so consumers must be idempotent (e.g. track processed message ids). Relay options: Polling Publisher, Transaction Log Tailing.

## Cosmos DB variant (Microsoft)
- Atomicity comes from a transactional batch, which works only within one logical partition of one container. Business object and event documents therefore share the partition key and container; a `type` field (`contact` vs `domainEvent`) tells them apart.
- The domain entity keeps a private list of events raised by its methods (private setters; methods like `SetName` raise `ContactNameUpdated`). Events are turned into outbox documents just before save (the sample uses a mediator, MediatR) and written in the same batch as the entity, with ETags for optimistic concurrency.
- Relay = Change Feed Processor (or an Azure Function trigger). Order is guaranteed within a logical partition. The processor tracks progress in a leases container, so no `Processed` flag is needed. It batches messages per partition key and sends to a Service Bus topic with `MessageId` = event doc id and `SessionId` = partition key, so sessions preserve FIFO and duplicate detection drops replays.
- On error the processor restarts from the last successfully processed batch; resulting duplicates are absorbed by Service Bus duplicate detection.
- Cleanup via document TTL (events carry a `ttl`; business docs use -1). TTL deletion uses leftover request units. Production advice: keep TTL long (the article suggests about 10 days) so a downed worker or bus can catch up.
- Alternative: embed events inside the business document; cleanup then needs document updates and costs more RUs.
- The article says its sample is not production-ready (multithreading limits) and points to NServiceBus or MassTransit built-in outbox support.

## Relay choice
| Relay | Pros | Cons |
|---|---|---|
| Polling publisher | Works on any DB; simple | Polling load, latency, ordering care with multiple workers |
| Log tailing / CDC / change feed | Low latency, no polling | Extra infrastructure or engine-specific |

## Sketch: SQL outbox
```sql
BEGIN;
UPDATE orders SET status = 'PAID' WHERE id = :id;
INSERT INTO outbox (id, aggregate_id, type, payload)
  VALUES (:uuid, :id, 'OrderPaid', :json);
COMMIT;
-- relay: SELECT ... WHERE published_at IS NULL ORDER BY seq LIMIT 100
-- keep one relay per aggregate key to preserve order
```

## How an agent should apply this
- Never publish directly from request handlers; write an outbox row in the same transaction.
- Use the outbox row id as the broker message id, and make every consumer idempotent.
- Preserve per-aggregate order: partition key or session id equals aggregate id.
- On Cosmos, keep entity and events in one container and partition; set TTL generously.
- Prefer a maintained library (NServiceBus, MassTransit) when one fits instead of hand-rolling.
