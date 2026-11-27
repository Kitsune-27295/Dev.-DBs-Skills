# Sources for the pipes-and-filters-pattern skill

Last verified 2026-11-27. All pages re-fetched with WebFetch on that date; summaries are in our own words.

| # | Source | Status | What the skill takes from it |
|---|---|---|---|
| 1 | Microsoft Azure Architecture Center, "Pipes and Filters pattern", https://learn.microsoft.com/en-us/azure/architecture/patterns/pipes-and-filters | Read, 200 OK; page date 2026-11-16 | Filters, pipes, composition, contract; reordering limits; throughput and latency; streaming; compensating transactions; the issues list (boundaries, complexity, backpressure, ordering, payload size, access control, reliability, idempotency, context, message tolerance, error handling); when to use or avoid; the queue-based image example and its retry-safety warning; Bash pipe example. |
| 2 | Microsoft Azure Well-Architected Framework, "Architecture design patterns that support reliability", https://learn.microsoft.com/en-us/azure/well-architected/reliability/design-patterns | Read, 200 OK; ms.date 2024-10-10, live copy updated 2026-08-17 | One-line reliability roles of Pipes and Filters, Claim Check, Competing Consumers, Queue-Based Load Leveling, Idempotent Consumer, Retry, Circuit Breaker, Compensating Transaction, Saga, Sequential Convoy, Rate Limiting, Throttling. |
| 3 | Software Architecture Guild, "Architecture Styles", pipeline section, https://software-architecture-guild.com/guide/architecture/fundamentals/architecture-styles/#pipeline-architecture | Read, 200 OK | Short overview only: ordered stages, suits media streaming and batch processing, scaling named as the challenge. |

## Reading limits

- The Azure GitHub demo and the Spring Integration and Apache Camel samples linked from source 1 were not opened. The C# snippet is not reproduced.

## Claims not adopted

- Pump, filter, pipe, sink as a four-component taxonomy, and fit for compilers, Unix shells and ETL attributed to source 3: the section does not say this. The Azure page does show a Bash pipe. The terms pump and sink survive in the skill only as our labels.
- `maxDeliveryCount` and "DLQ" wording: Service Bus and dead-letter details are not on the pattern page, which says to set aside failed messages visibly. Dead-letter mechanics belong to `background-worker-job-scheduler`.
- Illustrative numbers from the old text (1 ms vs 150 ms, a stage 100 times slower, 10 GB buffers): invented, removed.
- "Pairing with Competing Consumers" as stated on the pattern page: it appears in the reliability list only; the old text over-attributed it.

## Nuances

- Source 3 presents the pipeline as a monolithic style, while source 1 spreads the same idea across queues; the skill's answer is to start in-process and separate on a named reason.
