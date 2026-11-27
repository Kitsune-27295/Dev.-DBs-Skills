# Operational Considerations: Versioning, Concurrency, GDPR and Fit

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing · https://microservices.io/patterns/data/event-sourcing.html · Last verified 2026-11-27 (Azure page dated 2026-03-27)

## Framing
Microsoft's page opens with a warning: event sourcing is complex, costly to adopt or leave, and constrains later design in the parts that use it; for most systems and most parts of a system, traditional data management is enough. Adopt it selectively (a payment ledger or order pipeline), keep CRUD for profile or configuration data.

Richardson frames it as a fix for atomically updating state and publishing events: saving one event is a single atomic operation, and the event store doubles as a broker. Drawbacks he lists: unfamiliar model, and hard queries that usually force CQRS with eventually consistent read data. His page does not cover idempotent consumers, GDPR or schema evolution (re-checked 2026-11-27; it mentions snapshots only as a loading optimization); Microsoft does.

## Considerations (Microsoft)
| Topic | Guidance |
|---|---|
| Event design | Capture intent ("two seats reserved"), not just resulting state ("remaining = 42"); state-only events reduce the store to a meaningless change log |
| Versioning | Never mutate stored events. Strategies: tolerant deserialization (ignore unknown, default missing), explicit version in envelope or type name, chained upcasters at read time, in-place rewrite only as a last resort because it breaks the audit trail |
| Bad events | A bug's events persist; fix with compensating events or upcasters |
| Ordering and concurrency | Per-stream incrementing sequence plus optimistic concurrency: the store rejects an append if the stream changed since read; handler reloads, re-evaluates, retries |
| Querying | Only "stream by entity id"; everything else needs projections or materialized views |
| Event store vs broker | Kafka-style brokers lack per-entity stream reads and optimistic concurrency; use them to distribute events, not as the store |
| Rehydration cost | Snapshot every N events; snapshots are an optimization, the stream remains the truth |
| Cross-entity conflicts | OCC covers one stream; reconcile others by business means (back order, notify customer) |
| Idempotency | At-least-once delivery means duplicates; track last processed sequence per consumer or make mutations repeat-safe (inbox mechanics are owned by `saga-transactional-outbox-pattern`) |
| Circular logic | Event handlers that raise events that trigger the same handlers can loop |
| Testing | Given past events, when command, then new events; plus integration tests for projections, idempotency and schema evolution |
| Personal data | Store personal data outside the stream and reference by id; if inseparable, crypto-shred: encrypt per subject and delete the key (costs encryption on every read and write plus key management) |
| Internal vs public events | Microsoft: storage events are low level, so specific integration events may be needed; the boundary rule is in `streams-aggregation-and-practitioner-guide.md` |

## Use when / avoid when
Use when intent and history matter, replay or rollback is valuable, you need decoupled consumers, or you already use CQRS and accept eventual consistency. Avoid for plain CRUD, prototypes and MVPs or short-lived systems, mostly-static reference data, strict real-time consistency of views, or teams new to event-driven systems (Microsoft).

## Example: optimistic append
```ts
const { events, version } = await store.read(streamId);
const state = events.reduce(evolve, initial);
const newEvents = decide(state, command);          // pure
await store.append(streamId, newEvents, { expectedVersion: version }); // throws on conflict
```

## How an agent should apply this
- Confine event sourcing to the aggregates that need audit or replay; say so explicitly.
- Write intent-named events and decide the versioning strategy (upcasters) before the first event ships.
- Use expected-version appends and retry loops; never share a broker as the store.
- Make projections idempotent with a stored last-processed position.
- Plan personal data handling (external storage or crypto-shredding) at design time.
