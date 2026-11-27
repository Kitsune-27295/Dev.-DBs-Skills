# Pipeline Style Taxonomy and Reliability Companion Patterns

Sources: https://software-architecture-guild.com/guide/architecture/fundamentals/architecture-styles/#pipeline-architecture · https://learn.microsoft.com/en-us/azure/well-architected/reliability/design-patterns (page ms.date 2024-10-10, live copy updated 2026-08-17) · Last verified 2026-11-27

## Pipeline as an architecture style
- The Guild page gives only a short overview: data flows through a sequence of stages, each doing one operation before passing output on. It suits strictly sequential work such as media streaming or batch data processing, and names hard-to-scale as the main drawback. It groups pipeline with layered and microkernel as monolithic styles (Richards and Ford). Re-read 2026-11-27: the page does not list component types (pump, filter, pipe, sink), does not mention Unix shells, compilers or ETL, and gives no per-style ratings; the only drawback it names is efficient scaling. Those extras are not sourced here.
- Reading: the style is decomposition inside a deployable; the Azure pattern stretches the same idea across queues. Both agree on one-responsibility stages.

## Reliability companions (Azure Well-Architected summaries)
| Pattern | Role next to a pipeline |
|---|---|
| Pipes and Filters | Single-responsibility stages let you plan failure handling per stage and avoid commingled processing. |
| Claim Check | Message buses lack the durability and DR of data stores; keep data in a store, send a reference; queue recovery after disaster gets easier. |
| Competing Consumers | Treat consumers as replicas; one instance dying does not stop the queue draining. |
| Queue-Based Load Leveling | Buffer spikes between stages; isolates processing malfunctions from intake. |
| Idempotent Consumer | Same effect whether a message is processed once or several times; at-least-once delivery can duplicate messages, so retries need it (`idempotency-fix`). |
| Retry | Controlled retries for transient faults. |
| Circuit Breaker | Stop hammering a failing dependency; enables graceful degradation. |
| Compensating Transaction / Saga | Reverse earlier effects when a later stage fails; no cross-stage atomic transaction. |
| Sequential Convoy | Keep ingress concurrent but process related messages in order. |
| Rate Limiting / Throttling | Bound call rates to dependencies and protect stages. |

## Decision rules
- Retry plus idempotency is a pair; retries without idempotent filters create duplicates.
- A queue between stages without backpressure just moves the failure into the queue.
- Ordering requirement present: use a business-key convoy; do not rely on single-consumer luck.

## How an agent should apply this
- When asked to make a pipeline reliable, walk the table and pick only rows with a named failure scenario.
- Say explicitly when you rely on outside knowledge (pump and sink naming) rather than the cited page.
- Pair every Retry with an idempotency mechanism and a dead-letter destination.
- Treat Claim Check as a reliability tool for payloads, not just a size workaround.
