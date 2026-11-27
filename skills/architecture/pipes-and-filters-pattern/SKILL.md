---
name: pipes-and-filters-pattern
description: Split a multi-step processing job into single-purpose filters joined by pipes, and decide whether the pipes stay in-process or become queues: filter contracts, safe reordering, throughput limits, backpressure, ordering, payload size (claim check), per-filter permissions, and what to do with a failing item. Use when designing, reviewing or refactoring an ETL, document or RAG indexing, media, message-transformation or request-middleware flow into a pipeline, or when asked whether stages deserve their own queue. Not for the queue worker itself (use `background-worker-job-scheduler`), duplicate-safe handlers (`idempotency-fix`), or cross-service transactions (`saga-transactional-outbox-pattern`).
---

# Pipes and Filters (Pipeline) Pattern

One idea: break a processing task into filters that each do one thing, connect them with pipes, and keep each filter ignorant of its neighbors so steps can be reused, replaced, scaled and (when the rules allow) reordered. Sources and what was not adopted: [references/sources.md](references/sources.md).

## 1. Vocabulary

| Term | Meaning |
|---|---|
| Filter | one processing step: reads from an input pipe, transforms, validates or drops, writes to an output pipe; normally stateless |
| Pipe | the connector between filters: a stream or channel in one process, a Unix pipe, or a message queue between hosts |
| Pipeline / composition | filters joined through defined input and output interfaces |
| Contract | the data a filter accepts and produces plus its effects on other systems; matching schemas alone do not make two steps interchangeable |
| Claim check | store the payload elsewhere and pass a reference through the pipe |
| Pump / sink | our names for the source and the final consumer; Azure's page does not use them |

## 2. Core rules

1. **One responsibility per filter, no knowledge of neighbors.** A filter binds to its input and output contract only, never calls another filter, and passes through fields it does not use unchanged.
2. **Reorder only when data dependencies and business rules allow it.** Example from the Azure page: publishing before validating exposes invalid data.
3. **Stateless by default.** Give each filter the context it needs; if it loads external state, every filter pays that cost, so measure it.
4. **Start in-process; separate hosts need a named reason:** independent scaling, specialized hardware, failure or permission isolation. Separate hosts add connections and deployments, and a dead filter still starves later steps. Filters that scale together can share a process.
5. **Throughput is capped by the slowest filter, pipe or shared resource.** More instances help only if the work is shareable and downstream systems can take the load. A queue absorbs bursts only; if arrival stays above capacity it grows without bound, so limit per-filter concurrency and call rate and make producers slow down (backpressure).
6. **Ordering is not free.** Parallel instances and retries reorder messages. Prefer order-insensitive filters; otherwise group by a business key and preserve order at every stage.
7. **Large payloads: claim check.** Check pipe size limits; storing data separately adds storage, retrieval and cleanup duties.
8. **Least privilege per filter.** Filters in one process or function app share a security boundary; use separate hosting and identities when permissions differ.
9. **Failure handling is part of the design.** Retry transient faults with delay and a cap (`circuit-breaker-retry-telemetry`); park invalid or exhausted items visibly (`background-worker-job-scheduler`); a failed late step that must undo earlier business effects needs compensating transactions that record completed steps, not a pipeline rollback; give every item a tracking id logged by every filter. A filter may emit its result and crash before acknowledging, so each must be idempotent (`idempotency-fix`).

## 3. Building order

1. Write each filter's contract: input, output, side effects, idempotency approach, what happens to a bad item.
2. Build and unit-test each filter alone with valid, boundary and malformed input.
3. Compose in-process with per-stage metrics (latency, drop rate) and a tracking id.
4. Promote a pipe to a queue only after measuring a bottleneck or isolation need; then add backpressure, a failure destination and ordering rules.

## 4. Testing strategy

| Target | Test |
|---|---|
| Single filter | unit test, including malformed input |
| Contract between neighbors | schema or type check that output fits the next input |
| Composed pipeline | integration test from source to sink; bad items end in the failure destination |
| Retry and overload | fault injection: slow or fail one filter, check buffering, no duplicates, no loss |

## 5. When it earns its keep

- Worth it: steps with separate responsibilities and clear contracts, stages that scale or need different hardware, a need to add, replace or reorder steps, containing one step's failure. Typical fits: ETL, document or RAG indexing (parse, chunk, embed, index), media processing, message transformation, request middleware (our examples; the Azure page uses image processing).
- Not worth it: synchronous request-response, one atomic transaction across filters, or per-step hand-off or state reload costing more than the benefit.

## 6. Mistakes to catch

- **Hidden coupling through shared mutable state:** filter 2 relies on a half-written row from filter 1. Pass state in the message or a claim check.
- **A queue between trivial steps:** distributed pipes add latency and operations for no scaling gain.
- **No backpressure:** unbounded buffers or an ever-growing queue.
- **Schema-compatible but unsafe reordering.**
- **No failure destination:** one bad item blocks everything behind it.
- **Retry without idempotency:** the Azure demo itself is not retry-safe (a retry can re-watermark or hit a deleted source).

## Quick Decision Checklist

- [ ] Does each filter have one responsibility and a written contract (data, side effects)?
- [ ] Is any reordering checked against data dependencies and business rules?
- [ ] In-process by default, with a named reason for each queue or separate host?
- [ ] Backpressure and concurrency limits set; ordering rule stated?
- [ ] Claim check for large payloads; least privilege per filter?
- [ ] Idempotent filters, capped retries, a visible failure destination, a tracking id?
- [ ] Does the work really fit a progressive transformation?

## Deep references

- [Distributed pipeline design issues](references/distributed-pipeline-design-issues.md) — when splitting filters across hosts or queues
- [Pipeline style and reliability companions](references/pipeline-style-and-reliability-companions.md) — which reliability patterns to pair with a pipeline
- [Trigger evals](references/trigger-evals.md) — when tuning the description
- [Sources](references/sources.md) — verification status and claims not adopted
