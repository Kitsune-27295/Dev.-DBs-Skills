# Triage Order and Fix Patterns

Sources: https://sre.google/sre-book/monitoring-distributed-systems/ · https://nodejs.org/en/learn/getting-started/profiling · https://www.brendangregg.com/usemethod.html · Last verified 2026-11-27

This file is mostly the skill's own synthesis, built on the measurement and profiling pages above and on a method abstracted from skills read for ideas only (see `sources.md`). The ordering is a frequency-and-cost heuristic, not a published standard: it comes from experience and is justified here only as "check cheap, common causes first". Where a step restates general engineering knowledge not read from a source, it is labeled so.

## Why an order at all

Most slow screens are explained by a small number of causes, and the cheapest to confirm are server-side data access. Checking them first avoids spending a day in the browser on a problem that is one missing index. The order is a default; if a trace already shows the time is in the browser, start there.

## The order, with evidence and the smallest fix

| # | Suspect | How to confirm | Smallest fix | Owner of detail |
|---|---|---|---|---|
| 1 | One slow query | One span dominates; plan shows scan, sort or spill | Rewrite or index that query only | `query-performance` |
| 2 | N+1 | Query or call count scales with rows; per-request count at size N vs 10N | One set-based query or one batched call keyed by id | `query-performance` |
| 3 | Missing/unusable index | Seek expected, scan observed; function wrapped around the column; foreign key unindexed | Targeted index, one at a time, measured | `query-performance` |
| 4 | Payload and serialization | Response bytes, hydration time, unused fields | Select only needed fields, paginate, compress, stream | this file |
| 5 | Cache misuse | Repeated identical work, near-zero hit rate, stale reads | Cache the expensive pure result with bounded size and invalidation | `caching-strategies` |
| 6 | Rendering | Long tasks, layout thrash, large DOM | Do less per frame, virtualize, defer | [frontend-and-browser-cost.md](frontend-and-browser-cost.md) |
| 7 | Bundle/loading | Large scripts, blocking resources | Split, defer, preload the critical resource | [frontend-and-browser-cost.md](frontend-and-browser-cost.md) |

Fan-out calls to external services follow the same pattern as N+1: one call per item instead of one call with a list. They are doubly costly because the external system takes the load too.

## Fix patterns that remove work

Prefer, in this order: do not do it; do it once; do it in a batch; do it later; do it in parallel; make it faster.

- **Batch instead of loop.** Replace per-item queries or calls with one request carrying the set of ids; join in memory by key. Verify the count dropped, not just the time.
- **Select less.** Fields nobody reads, rows beyond the first page, or whole documents when an aggregate was needed. Cursor pagination replaces deep offset pagination (details in `query-performance`).
- **Stream instead of buffering.** Transform and send in chunks to bound memory and cut time to first byte; keep validation and ownership rules intact.
- **Move blocking work off the hot path.** The Node profiling guide's example is a synchronous hashing call that blocked the event loop; switching to the asynchronous form raised throughput about 3.7x in that one test (5.33 to 19.46 requests per second). General rule: never run long synchronous CPU work on the thread that serves interactive requests.
- **Parallelize independent awaits.** Calls that do not depend on each other should start together; bound the concurrency and check the downstream capacity (Little's law in [finding-the-dominant-cost.md](finding-the-dominant-cost.md)).
- **Compute once, reuse.** Memoize pure results; cache expensive reads with a defined invalidation (`caching-strategies`). A cache that makes a benchmark repeat fast but not the first request is not a fix.
- **Defer, do not delete.** Postpone work for hidden or collapsed views; measure the first activation too.
- **Right data structure.** Replace repeated scanning or shifting with a map, set or index; measure the whole consumer path, not only the isolated container.

Pseudo-example (N+1 repair, own illustration):

```text
before: for order in orders: customer = get_customer(order.customer_id)   # 1 + N calls
after:  ids = unique(o.customer_id for o in orders)
        customers = get_customers(ids)                                    # 1 call
        by_id = index(customers, "id"); attach by key
measure: calls per request 51 -> 2 at N=50; same output for missing ids
```

## Things to leave alone

- A path that is a small share of the journey (check `p` first).
- Code that is slow but cold (nightly, rare admin screens) unless it threatens a window or a limit.
- Correctness-bearing work (authorization checks, validation at trust boundaries, idempotency guards): measure it, but do not remove it to gain speed. Tune the predicate or move it, and prove behavior is unchanged.

## Test the exclusions

If the journey includes a model call or another remote service, the local overhead and the remote latency are different budgets. Time the remote call as its own phase, put the stub in the benchmark, and report both numbers.

## How an agent should apply this

- Walk the table top to bottom with the trace in hand; stop at the first layer that explains most of the time.
- Prefer the fix that removes work and confirm with a count (queries, calls, bytes) as well as a time.
- Open the neighbor skill for SQL and cache specifics instead of re-deriving them here.
- Run the owning functional tests after each fix; never ship a speedup that changed output.
- Record the suspects you checked and ruled out so the next session does not repeat them.
