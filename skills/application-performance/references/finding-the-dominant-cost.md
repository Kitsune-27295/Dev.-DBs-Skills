# Finding the Dominant Cost

Sources: https://www.brendangregg.com/usemethod.html · https://www.brendangregg.com/flamegraphs.html · https://en.wikipedia.org/wiki/Amdahl%27s_law · https://en.wikipedia.org/wiki/Little%27s_law · https://nodejs.org/en/learn/getting-started/profiling · https://docs.python.org/3/library/profile.html · Last verified 2026-11-24

## Goal

Out of everything that could be slow, pick the one thing that accounts for most of the time, and prove it. Four tools do this: a resource checklist (USE), two laws that bound what a fix can achieve (Amdahl, Little), and a profiler with a flame graph.

## The USE method: a resource checklist

For every resource, check utilization, saturation and errors (Brendan Gregg). Utilization is how busy the resource was, saturation is how much work is queued that it cannot serve, errors are counted failures. Start from the resources (CPU, memory, network, storage, and software ones like thread pools, connection pools, locks and file-descriptor limits), not from the metrics you happen to have.

Reading the numbers:
- Utilization near 100% usually marks a bottleneck; short bursts hide inside averages (80% over five minutes can include seconds of full saturation).
- Any non-zero saturation (queue length, wait time) can indicate a problem.
- Non-zero errors deserve a look, including recoverable ones such as retries.
- All-clear on a resource is still useful: it removes that resource from the search.
- The method finds bottlenecks and errors only; it is hardware- and OS-centric, and the author says software resources are better handled by other methods when metrics do not fit. Use it as the first sweep, then drill down with a profiler or tracing.

For an application, add the software resources that actually queue: database connection pool wait, worker or thread pool queue, event-loop lag, lock waits, rate-limit rejections. A slow request with idle CPU often points at waiting, not computing.

## Amdahl's law: how much can a fix be worth

If a fraction `p` of the time is spent in the part you speed up by a factor `s`, overall speedup is `1 / ((1 - p) + p / s)`. The improved part's share caps the gain. With p = 0.10 and a 10,000x speedup of that part, the whole improves only about 1.11x. Use it before working: measure `p` for each candidate, and discard candidates whose best case does not meet the target.

Worked check (own example): a request takes 600 ms; a query is 480 ms (p = 0.8) and serialization is 60 ms (p = 0.1). Halving serialization saves 30 ms (5%). Halving the query saves 240 ms (40%). Start with the query.

## Little's law: concurrency, throughput and latency

In a stable system, the average number of items in the system equals arrival rate times average time in the system (`L = lambda x W`). It holds regardless of arrival or service distribution, provided the system is stationary and you count only items that actually entered. Uses:
- Infer an unmeasured quantity from the other two (average latency from in-flight count and throughput).
- Size pools: a pool of 10 connections with 200 ms average hold time caps throughput near 50 per second; more load queues.
- Reason about fixes: to serve double the arrivals at the same capacity, time in the system must halve.
It does not apply directly over short windows, so estimate carefully on short samples.

## Profilers and flame graphs

A **sampling profiler** records the call stack at intervals; cost is low and the result shows relative time share. A **deterministic profiler** hooks every call and return, giving exact call counts with more overhead and a clock resolution limit (Python docs mention roughly a millisecond).

Node: run with `--prof` under a realistic load, process the log with `--prof-process`, then read the summary (share in JavaScript, C++, GC), the native-function table and the bottom-up (heavy) profile to see which callers cause the hot function. The Node guide's example found most time in synchronous password hashing blocking the event loop, and the fix moved it to the asynchronous API, increasing throughput several-fold (figures are from that example, not general). The inspector with Chrome DevTools also records CPU profiles.

Python: `cProfile` (the module is the C implementation of the deterministic profiler; newer docs rename it under `profiling.tracing` and mark pure-Python `profile` deprecated) run with `python -m cProfile -s cumtime script.py` or saved to a file and read with `pstats`. `tottime` is time inside the function itself (hot loops), `cumtime` includes callees (algorithm-level cost), `ncalls` exposes surprising call counts (N+1 in code form).

**Reading a flame graph:** the x axis is the sorted population of sampled stacks, not time; frame width is the share of samples containing that frame. Scan the top edge for wide plateaus (what was on CPU) and follow the frames below for the callers. Pitfalls: missing frames when stacks cannot be walked (for example interpreters), CPU graphs show on-CPU time only (waiting needs an off-CPU view or tracing), and a flame chart with time on the x axis is a different visualization.

## One slow thing versus many fast things

| Signal in the trace | Diagnosis | Fix family |
|---|---|---|
| One span is most of the total | One slow thing | Fix that span (query plan, blocking call, algorithm) |
| Hundreds of similar short spans | Many fast things (N+1, per-item calls, per-node render) | Batch, join, prefetch, memoize, virtualize |
| Idle CPU, long wall time | Waiting (I/O, lock, queue, pool) | Reduce waits, parallelize independent calls, size pools |
| CPU pegged, wide plateau in one function | CPU-bound hot path | Algorithm or data-structure change, move off main thread |
| Time grows non-linearly with data size | Complexity problem | Measure at two or three sizes; fix the growth term |

Test by changing the workload size: measure at N and 10N. Linear-per-item work with a large per-item constant is the "many fast things" shape; a flat large constant is the "one slow thing" shape.

## How an agent should apply this

- Do a USE sweep over hardware and software resources first; record "?" where a metric is unavailable instead of skipping it.
- Compute each candidate's share `p` and its best-case saving (Amdahl) before editing anything.
- Profile under a realistic workload with the production build and entry path; read plateaus and callers, not only the top function.
- Classify the shape (one slow thing, many fast things, waiting, CPU-bound, complexity) and pick the fix family from that.
- After the fix, re-profile: the old plateau should shrink and no new resource should now be saturated.
