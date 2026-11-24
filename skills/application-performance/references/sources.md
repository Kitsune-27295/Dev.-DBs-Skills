# Sources — Application Performance

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [web.dev — Web Vitals](https://web.dev/articles/vitals) | 200 OK | Core Web Vitals definitions (LCP, INP, CLS), "good" thresholds, 75th percentile rule, field versus lab data, TBT as the INP lab proxy. |
| [web.dev — Learn Performance](https://web.dev/learn/performance) | 200 OK (only a single module on web workers and the main thread was returned; the full course outline was not) | Main-thread limits and web workers for heavy computation. |
| [web.dev — Optimize LCP](https://web.dev/articles/optimize-lcp) | 200 OK | The four LCP subparts, ideal shares, procedure to find the dominant subpart. |
| [web.dev — Optimize INP](https://web.dev/articles/optimize-inp) | 200 OK | Three interaction phases, field-first diagnosis, yielding, layout thrashing, DOM size. |
| [web.dev — Performance budgets 101](https://web.dev/articles/performance-budgets-101) | 200 OK | Budget types, per-page-type budgets, enforcement in build and CI, continued real-user measurement. |
| [Chrome DevTools — Performance](https://developer.chrome.com/docs/devtools/performance) | 200 OK (summary returned) | Recording setup, throttling, overview charts, flame chart, long tasks, forced reflow. |
| [Chrome DevTools — Performance reference](https://developer.chrome.com/docs/devtools/performance/reference) | 200 OK | Live metrics, Insights sidebar, field comparison, call tree, bottom-up, ignore list. |
| [Brendan Gregg — The USE Method](https://www.brendangregg.com/usemethod.html) | 200 OK | Utilization, saturation, errors per resource; metric interpretation; limits of the method. |
| [Brendan Gregg — Flame Graphs](https://www.brendangregg.com/flamegraphs.html) | 200 OK | How to read a flame graph (x axis is not time), plateaus, pitfalls (sampling, missing frames, on-CPU only). |
| [Google SRE book — Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) | 200 OK | Four golden signals, distributions over averages, separating failed and successful latency, buckets and percentiles. |
| [Amdahl's law (Wikipedia)](https://en.wikipedia.org/wiki/Amdahl%27s_law) | 200 OK | Formula and the 10% / 10,000x example (about 1.11x overall). Encyclopedia source, used for the formula only. |
| [Little's law (Wikipedia)](https://en.wikipedia.org/wiki/Little%27s_law) | 200 OK | `L = lambda x W`, conditions, latency and concurrency implications. Encyclopedia source. |
| [Node.js — Profiling guide](https://nodejs.org/en/learn/getting-started/profiling) | 200 OK (covers `--prof` only; `--inspect` is on a different page, not read) | `--prof` and `--prof-process` workflow and the synchronous-hashing example. |
| [Python docs — profile and cProfile](https://docs.python.org/3/library/profile.html) | 200 OK (page is the newest docs version; it describes `profiling.tracing` as the new name, `cProfile` as an alias, and `profile` as deprecated) | Deterministic versus sampling profiling, overhead and clock resolution; `pstats` column meanings came from general knowledge flagged on the page. |
| [MDN — Server-Timing](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Server-Timing) | 200 OK | Header syntax, `PerformanceServerTiming`, `Timing-Allow-Origin`, security cautions. |

## Ideas-only sources (no text reused)

- Third-party skill read for ideas, no text reused (a performance-investigation skill from a third-party harness; license not confirmed, no path cited): contributed the idea of a measurement card, separating backend and browser measurements, excluding network and model latency with an explicit statement, requiring a negative control for budgets, and checking retained memory with time.
- Internal project skill read for the method only, no text reused: contributed the end-to-end triage order (query, N+1, index, payload, cache, browser) and the question "is it one slow thing or many fast things".

## Reading limits

- Pages were read through a fetch tool that returns a model-written summary of each page, not the raw HTML; wording was paraphrased from those summaries. Numeric thresholds were reported as given there and match the published guidance at the time of reading.
- The web.dev course index and Chrome DevTools insights pages returned partial content; nothing was inferred beyond what was returned.
- Python `pstats` column definitions and Node `--inspect` details were not on the pages read and rest on general knowledge.

## Claims not adopted as fact

- Any "N times slower" figure for a particular database feature that appeared in an internal skill (unverified there, not cited here).
- The USE method's "solves about 80% of server issues with 5% of the effort" is the author's own claim, not a measured result.
- The Node guide's requests-per-second table is one example run on one machine, not a general speedup.
- The web.dev default budget numbers (TTI under 5 s, 170 KB) assume baseline devices and networks and may not suit your audience.
- The triage order is a heuristic from experience, not a published standard.
