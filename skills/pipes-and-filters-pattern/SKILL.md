---
name: pipes-and-filters-pattern
description: Use when designing, reviewing, or refactoring a sequential data, media, document, or event processing workflow into the Pipes and Filters (Pipeline) pattern — decomposing monolithic processing into stateless, reusable Filter stages connected by buffered or synchronous Pipes. Gives filter invariants, backpressure, idempotency, poison-message routing, and common mistakes.
---

# Pipes and Filters (Pipeline) Pattern

One idea: decompose a complex, multi-step data-processing task into a sequence of **independent, stateless, single-purpose processing stages (Filters)** connected by **conduits (Pipes)** that pass standardized data payloads from one stage's output to the next stage's input — enabling easy reordering, composition, reuse, and independent scaling of bottleneck stages. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Azure Architecture Center & Architecture Guild)

| Term | Meaning | Test sentence |
|---|---|---|
| Filter | a modular, self-contained processing step that reads from an input pipe, transforms/enriches/validates/filters the payload, and writes to an output pipe | "knows its input and output contract, never which filter ran before it or comes after it" |
| Pipe | the connector carrying data between adjacent filters (in-memory stream/channel, Unix pipe, or distributed message queue/event stream) | "buffers and transports payloads without mutating business content" |
| Data Source (Pump) | the origin that injects raw payloads into the first pipe (file reader, webhook ingress, IoT stream, database change feed) | "starts the pipeline flow" |
| Data Sink | the final consumer at the end of the pipeline (database writer, search index, object storage, downstream API) | "terminates the pipeline and persists or delivers the final result" |
| Stateless Filter | a filter whose output depends exclusively on the current input payload, holding zero in-memory state from prior messages | "can be parallelized across $N$ worker instances safely" |
| Dead-Letter / Poison Pipe | a side channel where malformed or repeatedly failing payloads are routed so they do not stall the pipeline | "isolates bad payloads without dropping valid traffic" |

## Core architectural rules and invariants

1. **Filters must be ignorant of their neighbors:** Filter $B$ must never call Filter $A$ or Filter $C$ directly, nor assume a specific upstream/downstream implementation. It binds strictly to its Input Envelope and Output Envelope so filters can be reordered, inserted, bypassed, or reused in a different pipeline.
2. **Keep Filters stateless and idempotent:** Never rely on in-memory state left behind by a previous message in the same filter process. When pipes are backed by asynchronous queues or streams (at-least-once delivery), a filter may receive the same message twice after a crash — make every filter with external side effects idempotent (`idempotency-fix`).
3. **Standardize the Pipe Envelope (or use the Claim-Check pattern for large payloads):** Agree on an explicit, versioned message contract across pipes. If payloads are large (e.g., PDFs, images, multi-megabyte JSON), store the blob in object storage and pass only a lightweight reference URI + metadata through the pipe (**Claim-Check pattern**) so pipes/queues do not choke on serialization overhead.
4. **Choose In-Process vs. Distributed Pipes deliberately:**
   - **In-process pipes (iterators, streams, channels, middleware chains):** Use when all steps run fast on the same CPU/memory footprint and need low latency with zero network serialization.
   - **Distributed pipes (queues / event streams between worker services/FaaS):** Use only when one filter is a heavy bottleneck (e.g., OCR, LLM inference, video transcoding) that requires independent horizontal scaling, specialized hardware (GPUs), or fault isolation via durable queue buffering.
5. **Enforce Backpressure and Poison-Message isolation:** Bound the capacity of in-memory pipes (bounded channels) or scale queue consumers based on queue depth so a fast producer cannot OOM a slow filter. Route any message that fails validation or exceeds max retries (`maxDeliveryCount`) to a **Dead-Letter Queue (DLQ)** with full diagnostic context (which filter failed, error message, correlation ID).

## Building order

1. **Define the canonical Pipe Envelope and Stage Interfaces:** Specify the typed input/output contracts (`Filter<TIn, TOut>`) and correlation/trace metadata.
2. **Implement each Filter as a pure, isolated unit test-first:** Build and unit-test each filter (`Validate`, `Decrypt`, `Transform`, `Enrich`, `Deduplicate`) in complete isolation with sample input payloads.
3. **Wire the Pipeline Composer (in-process first):** Connect the filters in a declarative pipeline runner with error handling, metrics per stage (latency, drop rate), and dead-letter routing.
4. **Promote bottleneck Pipes to durable queues only where needed:** Measure stage throughput; if Stage 3 takes 100x longer than Stages 1-2, insert a queue pipe before Stage 3 and scale Stage 3 workers horizontally (**Competing Consumers**).

## Testing strategy

| Scope | Test | Uses |
|---|---|---|
| Individual Filter | unit test (fast, exhaustive edge cases) | feeds valid, boundary, and malformed input envelopes directly to the single filter function/class |
| Contract Compatibility | type / schema test | verifies `Filter[i].OutputSchema` satisfies `Filter[i+1].InputSchema` |
| Composed Pipeline | integration test | feeds representative payloads into the Pump and asserts the final state at the Sink + verifies poison payloads land in the Dead-Letter Sink |
| Backpressure & Retry | fault-injection test | slows or fails one downstream filter and verifies upstream buffering, idempotency on retry, and zero data loss |

## When it earns its keep

- **Worth it:** ETL/ELT data ingestion, compiler/AST passes, document/RAG indexing pipelines (parse -> chunk -> enrich -> embed -> index), media processing, EDI/financial message validation and transformation, and HTTP/RPC request middleware chains.
- **Not worth it:** Interactive request-response workflows requiring bidirectional conversation between steps, or tightly coupled transactional updates where steps cannot be expressed as a progressive data transformation flow.

## Mistakes to catch

- **Hidden coupling via shared mutable database state between filters:** Having Filter 1 write half a row to a shared DB table and passing only an ID to Filter 2, which mutates the same table and expects Filter 1's undocumented side effects. Pass the state in the pipe envelope (or an immutable Claim-Check blob).
- **Distributed queues between trivial 1ms filters:** Putting 6 Kafka topics or SQS queues between 6 tiny JSON-mapping steps that take 0.2ms each — turning a 1ms in-process pipeline into a 150ms distributed operational nightmare.
- **Unbounded in-memory pipes (No Backpressure):** Reading 10 GB of source records into an unbounded in-memory array/channel before a slow downstream filter can drain it, crashing the process with an Out-Of-Memory error.
- **Blocking the entire pipe on one malformed record:** Throwing an unhandled exception on a bad record without a Dead-Letter Pipe, causing the queue consumer to retry the same poison message infinitely and halt all subsequent data.
