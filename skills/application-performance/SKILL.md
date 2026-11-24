---
name: application-performance
description: "Make an application faster with evidence, end to end: name the user-visible journeys and a target, measure first at every layer (backend timings, browser Core Web Vitals, profiler, realistic benchmarks), keep network and model/third-party latency out of code blame, find the single dominant cost (USE method, Amdahl's law, flame graphs), decide between one slow thing and many fast things, triage in order (query, N+1, index, payload, cache, rendering, bundle), apply one small targeted fix, re-measure with a negative control, and turn the result into a benchmark or budget gate in CI. Use when a screen, endpoint, job, build or interaction is slow, before optimizing anything, when someone says 'make it faster', or when adding performance gates to CI."
---

# Application Performance — Measure, Find the Dominant Cost, Fix Small, Re-measure

One idea: **speed is a property of a user-visible journey, and every change must be justified by a measurement of that journey, not by a suspicion about the code.** Optimize only the part that dominates the time, prove the effect with the same measurement that exposed it, and keep the proof as a gate so the gain does not erode. Sources and claims not adopted: [references/sources.md](references/sources.md).

Boundaries (one owner per rule): SQL plans, indexes and query rewrites belong to `query-performance`; cache design, invalidation and HTTP caching belong to `caching-strategies`; a wrong or stale value (not a slow one) is `cross-layer-value-trace`; the general debugging loop is `diagnosing-bugs`; completion evidence is `verification-loop`; accessibility regressions from speed work are `a11y-audit`. This skill owns the **method and the end-to-end triage order** that decides which of those to open.

---

## 1. Define the journey and the target first

"The app is slow" is not measurable. Write down, before touching code:

| Field | Decide |
|---|---|
| **Journey** | The exact user action and the observable end ("open the orders list until rows are usable", "submit the form until confirmation", "nightly import finishes"). |
| **Workload** | Data size, concurrency, device/network class, cold vs warm state. Include a typical case and a tail case; do not invent a matrix with no decision value. |
| **Target** | A number with a percentile ("p95 under 800 ms", "LCP at p75 under 2.5 s"), or "no worse than today" for a refactor. Without a target there is no stopping rule. |
| **Allowed differences** | What behavior must stay identical (output, ordering, errors, auth). Speed bought by dropping correctness is a regression. |

If the user cannot give a target, propose one, label it an assumption, and continue. Ask only when the answer changes the approach.

## 2. Measure first, at the layer that can answer

Different layers answer different questions; one number never covers all of them.

| Layer | Measure | Typical tool |
|---|---|---|
| Browser, real users (field) | LCP, INP, CLS at the 75th percentile, split by mobile and desktop | RUM, CrUX, `web-vitals` library |
| Browser, controlled (lab) | Trace of one journey, long tasks, layout/paint cost; Total Blocking Time as the INP proxy | DevTools Performance panel, Lighthouse |
| Network edge | Time to first byte, payload bytes, request count, waterfall | DevTools Network, HAR |
| Backend request | Time per phase (parse, auth, query, serialize), query count per request | structured timings, `Server-Timing`, tracing |
| Process | CPU samples, event-loop stalls, allocations, GC | Node `--prof`/inspector, Python `cProfile`, flame graph |
| Resource | Utilization, saturation, errors per CPU, memory, disk, network, pool, queue | USE method checklist |
| Regression | Fixed workload, raw samples, aggregate, budget | benchmark in CI |

Rules:
- **Field beats lab for "is it bad", lab beats field for "why".** Confirm the problem with real-user or realistic data, then reproduce it in a lab trace.
- Record the **raw samples**, runtime, revision, workload and command, not only the mean. Averages hide tails; look at percentiles.
- Measure **cold and warm separately**; never let setup warm a cold scenario.
- **Backend and browser are separate measurements.** A fast API does not prove fast paint, scrolling or input response.
- Run the unoptimized workload **before** changing production code and save it. A "before" taken after the edit is worthless.

Details and the measurement card: [references/measurement-and-evidence.md](references/measurement-and-evidence.md).

## 3. Keep what code cannot change out of the blame

Split the journey's time into **owned** and **not owned** before ranking anything.

- Not owned by the code under test: network round trips, a remote model or third-party API, the user's device, the shared database host under someone else's load.
- Measure local overhead with the external boundary **stubbed or timed separately** (record the external call duration as its own phase). State the exclusion in the result: "local overhead, excluding model latency", never "end-to-end latency".
- A slow external call is still a finding, but its fixes differ: fewer calls, parallel calls, caching, timeouts and streaming, not micro-optimizing local loops. Failure-path latency (timeouts, retries) is measured on its own: a slow error is a different problem from a slow success.

## 4. Find the dominant cost

1. **Many fast things or one slow thing?** Per-request timeline: one span consuming most of the time (a slow query, a blocking call) vs hundreds of small spans (N+1, per-item calls, per-node re-renders). They have opposite fixes; many fast things is never solved by tuning one of them.
2. **Amdahl check.** Speeding up a part that is 10% of the time cannot yield more than about 11% overall, however clever the change. Compute `p` (the share of time) before investing; skip candidates whose share is small.
3. **Resource check (USE).** For each resource ask for utilization, saturation (queued work) and errors; a saturated pool or a queue explains latency no profiler line will show. Little's law (`concurrency = throughput x time in system`) tells you how much concurrency a latency implies, so a pool of 10 with 200 ms calls caps near 50 requests per second.
4. **Profile, do not guess.** Use a sampling profiler or flame graph and read the wide plateaus at the top; width is share of samples, not time order. Note what a CPU profile cannot show (blocking and waiting).
5. **Name each candidate** with: the production code path that runs it, the repeated work, the share `p`, the smallest falsifiable change, and the behavior that must not change. A suspicious loop, an unused cache or a large file is not evidence by itself.

Method details and worked examples: [references/finding-the-dominant-cost.md](references/finding-the-dominant-cost.md).

## 5. Triage order for a slow screen or endpoint

Check in this order; it follows frequency and cost to fix. Stop at the first layer that explains most of the time, fix it, and re-measure before moving on.

| # | Suspect | Evidence that confirms it | Hand off to |
|---|---|---|---|
| 1 | One slow query | A single span dominates; plan shows scan, sort or huge row counts | `query-performance` |
| 2 | N+1 (queries or API calls) | Query/call count grows with row count; many near-identical spans | batch or join (see `query-performance`), then re-count |
| 3 | Missing or unusable index | Plan scans where a seek is expected, filter wrapped in a function, FK without index | `query-performance` |
| 4 | Payload size and serialization | Large response bytes, slow JSON/ORM hydration, fields nobody reads | field selection, pagination, compression |
| 5 | Cache missing or misconfigured | Same work recomputed, hit rate near zero, or stale reads after a "fix" | `caching-strategies` |
| 6 | Rendering and main-thread work | Long tasks, layout thrash, huge DOM, INP phases dominated by processing or presentation | [references/frontend-and-browser-cost.md](references/frontend-and-browser-cost.md) |
| 7 | Bundle and loading | Large scripts, render-blocking resources, late LCP resource | same reference |

N+1 hides in single-request profiles: count the queries or calls per request and compare at two data sizes. Pooling, queues and locks (a resource, not a line of code) are checked with the USE view in section 4.

## 6. Fix small, one cause at a time

- **One causal change per measurement.** Two changes at once make the result unattributable.
- Prefer removing work to making work faster: do it less, do it once, do it later, do it in a batch, or do not do it.
- Defer, do not delete, inactive or collapsed work, and measure first activation of what was deferred.
- Parallelize only independent work, bound concurrency, and check the downstream system can take it.
- A cache is a last-mile tool: bound it, define invalidation, and confirm the speedup is real on a cold path (`caching-strategies`).
- If a fix needs a behavior change, state it, get agreement, and verify it; never trade correctness silently for a number.

## 7. Re-measure and prove

- Re-run the **same** measurement; compare raw samples, not a single run. Report before and after with the workload and revision.
- **Negative control:** the tightened assertion or budget must fail on the original implementation (or a controlled reintroduction of the cost). A threshold the regression passes gives no protection; one tighter than the noise floor flakes.
- Run the owning functional tests for output, ordering, errors and cancellation: speed evidence does not replace correctness evidence (`verification-loop`).
- Check what moved: time often shifts into another phase; if the end-to-end figure did not improve, the change was not a win, whatever the micro-benchmark says.
- Watch retained memory as well as time; a faster path with unbounded retention is not an automatic win.
- If it did not help, revert it and record the finding. A negative result is a result.

## 8. Keep the gain: benchmarks and budgets as CI gates

- Add a benchmark for the **journey**, using the production code path and a fixed, generated workload (no private data, no ambient network).
- Gate on **budgets stored as source constants** with headroom above measured noise; calibrate on the actual CI runner and repeat runs. Do not let an environment variable widen a budget to make a build green.
- Prefer ratios and counts (query count, bytes, allocations) for hard gates; wall-clock budgets need repeated samples and a noisy-runner policy.
- Keep real-user monitoring after launch: lab gates catch regressions, field data confirms the benefit.

## 9. Reject these

- Optimizing without a "before" number, or after changing the code.
- Averages as the only statistic.
- Micro-optimizing a path that is a few percent of the journey.
- Calling local overhead "end-to-end latency" while excluding network or model time without saying so.
- A cache added to hide a slow query nobody examined.
- Changing behavior (truncating results, skipping validation) to reach the number.
- A benchmark that reimplements the algorithm instead of running production code.

---

## Quick Decision Checklist

1. Journey, workload, target percentile and allowed differences written down?
2. "Before" measured on the unoptimized code, raw samples and revision saved?
3. External latency (network, model, third party) separated and stated?
4. Dominant cost found by trace/profile/USE, with its share of total time?
5. One slow thing or many fast things decided from per-request span or call counts?
6. Triage order followed and the right neighbor skill opened for SQL, cache or browser work?
7. One change per measurement; behavior preserved and tests run?
8. Same measurement repeated; negative control done; memory checked?
9. Benchmark or budget added with noise headroom, or a reason recorded for not adding one?
10. Result reported with before/after numbers, exclusions and what was not covered?

## Deep references

- [Measurement and evidence](references/measurement-and-evidence.md) — when you design the measurement: journeys, measurement card, lab vs field, percentiles, benchmarks and CI budgets
- [Finding the dominant cost](references/finding-the-dominant-cost.md) — when you must rank candidates: USE method, Amdahl and Little, profilers, flame graphs, one slow vs many fast
- [Triage order and fix patterns](references/triage-order-and-fix-patterns.md) — when you have a slow screen or endpoint and need the order of suspects and the smallest fix for each
- [Frontend and browser cost](references/frontend-and-browser-cost.md) — when the slow part is in the browser: Core Web Vitals, LCP subparts, INP phases, DevTools, bundles
- [Sources and claims not adopted](references/sources.md) — when you must check what was read and which figures are not facts
