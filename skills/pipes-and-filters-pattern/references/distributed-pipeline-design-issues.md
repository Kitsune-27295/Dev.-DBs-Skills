# Pipes and Filters: Design Issues When Filters Are Hosted Separately

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/pipes-and-filters · Last verified 2026-11-23

## Core mechanics
- A **filter** does one task; a **pipe** moves data between filters; a chain of both is a **pipeline**. Filters are normally stateless and joined by defined input/output contracts (composition).
- A filter's **contract** covers the data it accepts and produces and any side effects on other systems. Matching schemas alone do not make two steps interchangeable: reordering must keep data dependencies and business rules (page's example: publishing before validating exposes invalid data).
- Throughput = items completed per unit time, capped by the slowest filter, pipe or shared resource. Latency = processing time per step + waiting between steps + transfer time. Parallel instances of a filter raise throughput only if the work is shareable and downstream systems can take the extra load.
- Streaming: a later filter can start on partial output while the earlier one still runs.
- If a late failure must undo business effects of earlier steps, use compensating transactions (record which steps finished and how to undo each); this is not a rollback of the whole pipeline.

## Issue checklist
| Concern | Rule |
|---|---|
| Deployment/failure boundary | Same process = shared resources and shared failure. Separate hosts isolate failure, but a dead filter still starves later steps. |
| Complexity | Each separately hosted filter adds connections and deployments. |
| Throughput/backpressure | A queue absorbs bursts only; if arrival exceeds capacity it grows forever. Cap per-filter concurrency and the total call rate to downstream systems; make producers slow down. |
| Ordering | Parallel instances and retries reorder messages. Prefer order-insensitive filters; else group by a business key and preserve order at every stage. |
| Payload size | Pipes have size limits; use Claim Check (store payload, pass a reference), accepting storage, retrieval and cleanup duties. |
| Access control | Least privilege per filter; filters in one process or function app share one security boundary, so use separate hosts and managed identities when permissions must differ. |
| Idempotency | A filter may emit its result and crash before acknowledging, so retries duplicate output. Reprocessing must equal processing once (watermarking twice is the page's example). Broker duplicate detection helps but does not replace this. |
| Context/state | Each filter runs in isolation; give it the context it needs. Reloading external state in every filter is costly. |
| Message tolerance | Act on relevant fields, pass unknown fields through unchanged. |
| Error handling | Retry transient faults with delay and a cap; park invalid or exhausted messages visibly; attach a tracking id to every item and log it in every filter. |

## When to use / avoid
- Use: steps with separate responsibilities and clear contracts; stages that scale or need different hardware; need to add/replace/reorder steps; need to contain one step's failure. Co-locate filters that scale together (Compute Resource Consolidation).
- Avoid: synchronous request-response flows; a single atomic transaction across filters; per-step data hand-off or state reload costing more than the benefit.

## Example shape (queue pipes with claim check, pseudo-code)
```
onMessage(queue="resize-in", ref):
    if alreadyDone(ref, step="resize"): return forward(ref)   # idempotency guard
    img = blob.get(ref); out = resize(img)
    blob.put(ref, out)                                          # same key => safe retry
    queue("watermark-in").send(ref)
```
The Microsoft demo itself warns it is not retry-safe: a retry can re-watermark or fail because a later filter deleted the source.

## How an agent should apply this
- Start in-process; before adding a queue between two stages, name the concrete scaling, isolation or hardware reason.
- For every filter write down: input contract, output contract, side effects, idempotency key, and what happens to a poison message.
- Pass references (claim check) once payloads approach pipe limits; never grow messages silently.
- Add a tracking id and per-stage logs before the second distributed stage exists.
- Reject reorderings that only look schema-compatible; check business rules.
