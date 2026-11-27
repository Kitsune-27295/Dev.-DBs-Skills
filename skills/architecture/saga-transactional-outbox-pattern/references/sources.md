# Sources — Saga and Transactional Outbox Patterns

Every URL below was re-fetched on 2026-11-27 (rebuild pass; first authoring pass was 2026-11-22).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Chris Richardson, "Pattern: Saga", https://microservices.io/patterns/data/saga.html | 200 | Problem (2PC not an option), choreography versus orchestration, compensating transactions, lack of isolation, outbox or event sourcing for atomic update plus messaging, client outcome. It does NOT name anomalies, countermeasures or compensable/pivot/retriable (confirmed with curl) |
| Microsoft Azure Architecture Center, "Saga distributed transactions pattern", https://learn.microsoft.com/en-us/azure/architecture/patterns/saga | 200, page date 2025-02-25 | Compensable, pivot and retryable steps, choreography and orchestration trade-offs, anomalies (lost update, dirty read, fuzzy read), six countermeasures, idempotence, compensations may fail, use/avoid lists |
| Chris Richardson, "Pattern: Transactional outbox", https://microservices.io/patterns/data/transactional-outbox.html | 200 | Dual-write problem, outbox table or NoSQL attribute, message relay, ordered sending, polling publisher and log tailing named, at-least-once and idempotent consumers |
| Microsoft Azure Architecture Center, "Implement the Transactional Outbox pattern by using Azure Cosmos DB", https://learn.microsoft.com/en-us/azure/architecture/databases/guide/transactional-out-box-cosmos | 200, page date 2026-02-23 | Transactional batch in one logical partition, change feed relay, Service Bus dedup and sessions, restart on error, TTL cleanup (about 10 days), sample not production-ready, NServiceBus and MassTransit outbox |

## Reading limits
- The relay pros/cons table, the orchestrator skeleton and the SQL sketch are this skill's own illustration, not source text.
- The Richardson pages were read through a summarizer plus a keyword check with curl; step counts of his Create Order example were not verified.
- No scripts or data files in this skill.

## Claims not adopted as fact
- Richardson as the source of the anomaly list, countermeasures and compensable/pivot/retriable classes: they are Azure (and his book, not read).
- "ACD" as a term: not on either page; replaced by "ACID minus Isolation".
- "Choreography for 2-3 steps, orchestration for 4+": number cut-offs are a rule of thumb; sources say few versus complex.
- Debezium and WAL tailing as examples of log tailing: not on the pages read.
- The out-of-order compensate tombstone: own design, not in the sources.
