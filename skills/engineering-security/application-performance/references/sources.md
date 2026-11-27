# Sources — Application Performance

Every URL below was re-checked on 2026-11-27 (WebFetch; Firecrawl unavailable).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [web.dev — Web Vitals](https://web.dev/articles/vitals) | 200 OK, read (page updated 2024-10-31) | LCP 2.5 s, INP 200 ms, CLS 0.1 "good" targets (the page text gives no "poor" bounds), 75th percentile split by mobile and desktop, INP replacing FID, field vs lab, TBT as the INP lab proxy, Lighthouse cannot measure INP |
| [web.dev — Optimize LCP](https://web.dev/articles/optimize-lcp) | 200 OK, read (updated 2025-03-31) | Four LCP subparts, ideal shares (about 40, under 10, about 40, under 10), procedure, fix order by likely impact |
| [web.dev — Optimize INP](https://web.dev/articles/optimize-inp) | 200 OK, read (updated 2025-09-02) | Three interaction phases, field-first diagnosis, yielding, layout thrashing, DOM size, `content-visibility` |
| [web.dev — Performance budgets 101](https://web.dev/articles/performance-budgets-101) | 200 OK, read (no date shown) | Budget types, per-page-type budgets, defaults (TTI under 5 s, 170 KB), CI enforcement, continued real-user monitoring |
| [web.dev — Learn Performance](https://web.dev/learn/performance) | 200 OK, but the page is now the resource-hints module; no web-worker content (changed since last pass) | Nothing; the earlier worker claim was re-sourced to MDN |
| [MDN — Using web workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers) | 200 OK, read (added 2026-11-27) | Workers as background threads, no DOM access, `postMessage` copying, intended for heavy computation |
| [Chrome DevTools — Performance](https://developer.chrome.com/docs/devtools/performance) | 200 OK, read (summary) | Incognito recording, CPU throttling (4x in tutorial, 20x suggested for low-end), long-task red triangle, flame chart axes, forced reflow warnings |
| [Chrome DevTools — Performance reference](https://developer.chrome.com/docs/devtools/performance/reference) | 200 OK, read (summary) | Live metrics, Insights sidebar, field comparison, call tree, bottom-up, ignore list, 50 ms shading |
| [Brendan Gregg — The USE Method](https://www.brendangregg.com/usemethod.html) | 200 OK, read | Definitions, interpretation (100%, bursts, about 70%, any saturation), limits (caches excluded, software resources secondary) |
| [Brendan Gregg — Flame Graphs](https://www.brendangregg.com/flamegraphs.html) | 200 OK, read | x axis not time, width as share, plateaus, on-CPU only, flame chart vs flame graph |
| [Google SRE book — Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) | 200 OK, read | Four golden signals, percentiles and exponential buckets, failed vs successful latency |
| [Amdahl's law (Wikipedia)](https://en.wikipedia.org/wiki/Amdahl%27s_law) | 200 OK, read | Formula and the 10% / 10,000x example (about 1.11x); the limit is derived from the formula, not stated there |
| [Little's law (Wikipedia)](https://en.wikipedia.org/wiki/Little%27s_law) | 200 OK, read | `L = lambda x W`, stationarity, effective arrival rate, short-window caveat |
| [Node.js — Profiling guide](https://nodejs.org/en/learn/getting-started/profiling) | 200 OK, read | `--prof` / `--prof-process` workflow; example 5.33 to 19.46 requests per second (about 3.7x), about 52% of ticks in one native function |
| [Python docs — profile](https://docs.python.org/3/library/profile.html) | 200 OK, read (newest docs) | `profiling.tracing` with `cProfile` alias, `profiling.sampling`, `profile` deprecated since 3.15 (removal 3.17), deterministic vs statistical, clock tick about 1 ms |
| [MDN — Server-Timing](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Server-Timing) | 200 OK, read | Header syntax, `PerformanceServerTiming`, `Timing-Allow-Origin`, security cautions |

## Ideas-only sources (no text reused)

- Third-party skill read for ideas, no text reused (a performance-investigation skill from a third-party harness; license not confirmed): the measurement card, separating backend and browser measurements, excluding network and model latency with an explicit statement, a negative control for budgets, checking retained memory with time.
- Internal project skill read for the method only, no text reused: the end-to-end triage order and the "one slow thing or many fast things" question.

## Reading limits

- Pages were read through a fetch tool that returns a model-written summary, not raw HTML; wording is paraphrased from those summaries.
- The Python docs page does not document `python -m cProfile -s ...` flags or `pstats` column names, and the Node pages read do not cover `--inspect`; those details are not re-verified and the skill says so.
- No scripts exist in this skill.

## Claims not adopted as fact

- Any "N times slower" figure for a particular database feature from an internal skill.
- The USE method's "about 80% of server issues with 5% of the effort": the author's own estimate, not a measured result.
- The Node guide's requests-per-second table: one run on one machine, not a general speedup.
- The web.dev default budget numbers (TTI under 5 s, 170 KB): they assume baseline devices and networks and may not suit your audience.
- The triage order: a heuristic from experience, not a published standard.
- "Worker overhead dominates small tasks": my judgment, not stated by MDN.
