# Measurement and Evidence

Sources: https://web.dev/articles/vitals · https://web.dev/articles/performance-budgets-101 · https://sre.google/sre-book/monitoring-distributed-systems/ · https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Server-Timing · Last verified 2026-11-24

## Why measurement comes first

A performance change is a hypothesis about where time goes. Without a measurement of the journey a user actually runs, the hypothesis is untested and the change may not matter. Three ideas from the sources carry most of the weight: measure the user-visible outcome (not an internal function), look at the distribution (not the mean), and keep field and lab data apart because they answer different questions.

## Field data and lab data

Core Web Vitals are mainly field metrics: they come from real users on real devices and networks, and the web.dev article says only field measurement captures that variation. Lab data comes from a controlled run, is best for catching regressions before release and for explaining a cause, and cannot measure Interaction to Next Paint (INP) because a lab run has no real user input. Total Blocking Time is the usual lab proxy for INP.

Practical reading:
- Use field data (real-user monitoring, CrUX, PageSpeed Insights) to answer "is this bad, for whom, on which page type".
- Use a lab trace (DevTools, Lighthouse) to answer "what exactly takes the time".
- Do not call a lab number a user outcome; do not use a field number to debug a function.

The published thresholds for a "good" experience are LCP within 2.5 s, INP at or under 200 ms and CLS at or under 0.1, judged at the 75th percentile of page loads, split by mobile and desktop. Treat these as the starting target for browser work and write your own percentile target for backend journeys.

## Distributions, not averages

The SRE monitoring chapter makes the same point for services. A 100 ms mean can coexist with a small share of requests taking seconds, and in a system where a page depends on several backends, one backend's slow tail can become the typical frontend response. Rules that follow:
- Report percentiles (p50, p95, p99) or a histogram with roughly exponential buckets, never the mean alone.
- Keep latency of successful and failed requests separate. A fast error can pull the overall number down; a slow error is worse than a fast one and must not be dropped. Both are real findings.
- The four golden signals (latency, traffic, errors, saturation) are a compact checklist for a service dashboard. Saturation is the signal that explains latency rising before a resource reaches 100%.

## The measurement card

Fill one card per journey before implementing anything. It forces the decisions that make a result reproducible.

| Field | Decision |
|---|---|
| User operation | The action and its observable completion condition |
| Workload | Dimensions, distribution, construction seed or constants, and why they exercise ordinary and tail use |
| Entry path | The production code path and built artifacts; which external boundaries are stubbed |
| Clock | Setup included or not, cold or warm, start and end marks, excluded costs |
| Memory | What stays reachable at the end, baseline, GC policy |
| Verdict | Raw samples, the aggregate that decides, the budget, and the negative control |
| Behavior | The functional tests or snapshots that must still pass |

Example, a backend journey: "GET orders list for a tenant with 50,000 orders, page size 50, warm connection pool, database on the same host, model/network calls stubbed. Clock starts at request receipt and ends at last response byte. Report p50 and p95 over 30 runs after 5 warm-up runs. Query count per request is recorded as a separate figure."

## Getting backend time to the browser

The `Server-Timing` response header carries named durations from the server into DevTools and, through `PerformanceServerTiming`, into scripts. An example is `db;dur=53, app;dur=47.2`. It lets one trace show which phase of a response was server time. Two cautions from the specification page: the header can expose application and infrastructure detail, so decide which metrics to send and to whom (for example, only to authenticated users), and cross-origin scripts can read it only if `Timing-Allow-Origin` allows it.

## Benchmarks as CI gates

A performance budget is a limit on a metric that affects speed. The web.dev budget article distinguishes quantity-based budgets (asset sizes and counts), milestone timings (for example FCP, TTI), and rule-based scores (Lighthouse). It recommends combining quantity and user-centric measures, setting a separate budget per page type, enforcing budgets in the build (bundle-size checks, Lighthouse CI) and continuing to measure real users after launch. Its default numbers (for example TTI under 5 s and under 170 KB of critical-path resources) assume baseline devices and slow networks; treat them as a starting point, not a standard for your audience.

Rules for gates that stay useful (the first four are this skill's synthesis; the budget-type list above is from the source):
1. Run the production code path on a fixed generated workload; do not copy the algorithm into the benchmark.
2. Store budgets as source constants; do not let an environment variable relax them.
3. Calibrate on the runner that will enforce the gate and repeat runs; set the limit above the measured noise.
4. Add a negative control: the gate must fail against the original slow implementation.
5. Prefer hard gates on counts and sizes (queries per request, bytes, allocations) and softer, repeated-sample gates on wall-clock time.
6. Serialize measured work against other CPU-heavy jobs so neighbors do not distort the sample.

## How an agent should apply this

- Write the measurement card before any edit; save the "before" run (command, revision, raw samples).
- Report percentiles and the workload; never report only a mean or a single run.
- Say whether a number is field or lab, and which boundaries were stubbed or excluded.
- Use `Server-Timing` or equivalent phase timings so backend and browser views can be joined.
- Turn the final measurement into a budget with a negative control, or record why no gate fits.
