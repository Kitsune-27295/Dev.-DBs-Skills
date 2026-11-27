# Finding the Dominant Cost

Sources: https://www.brendangregg.com/usemethod.html · https://www.brendangregg.com/flamegraphs.html · https://en.wikipedia.org/wiki/Amdahl%27s_law · https://en.wikipedia.org/wiki/Little%27s_law · https://nodejs.org/en/learn/getting-started/profiling · https://docs.python.org/3/library/profile.html · Last verified 2026-11-27

## Goal

Out of everything that could be slow, pick the one thing that accounts for most of the time, and prove it. Four tools do this: a resource checklist (USE), two laws that bound what a fix can achieve (Amdahl, Little), and a profiler with a flame graph.

## The USE method: a resource checklist

For every resource, check utilization, saturation and errors (Brendan Gregg). Utilization is how busy the resource was, saturation is how much work is queued that it cannot serve, errors are counted failures. Start from the resources (CPU, memory, network, storage, and software ones like thread pools, connection pools, locks and file-descriptor limits), not from the metrics you happen to have.

Reading the numbers:
- Sustained 100% utilization usually marks a bottleneck; confirm with saturation. Short bursts hide inside averages (the author's example: five-minute averages under 80% while CPUs hit 100% for seconds). Unpreemptible resources such as disks can hurt above about 70%.
- Any non-zero saturation (queue length, wait time) can indicate a problem.
- Non-zero errors deserve a look, particularly if they keep rising while performance is poor.
- All-clear on a resource is still useful: it removes that resource from the search.
- The method finds bottlenecks and errors only; a system can have several problems, so the first one found may not be the main one. Caches are excluded on purpose (check hit rates after systemic bottlenecks are ruled out), and software resources are a lower-priority extension. Use it as the first sweep, then drill down with a profiler or tracing.

For an application, add the software resources that actually queue: database connection pool wait, worker or thread pool queue, event-loop lag, lock waits, rate-limit rejections. A slow request with idle CPU often points at waiting, not computing.

## Amdahl's law: how much can a fix be worth

If a fraction `p` of the time is spent in the part you speed up by a factor `s`, overall speedup is `1 / ((1 - p) + p / s)`. The improved part's share caps the gain. With p = 0.10 and a 10,000x speedup of that part, the whole improves only about 1.11x. Use it before working: measure `p` for each candidate, and discard candidates whose best case does not meet the target.

Worked check (own example): a request takes 600 ms; a query is 480 ms (p = 0.8) and serialization is 60 ms (p = 0.1). Halving serialization saves 30 ms (5%). Halving the query saves 240 ms (40%). Start with the query.

## Little's law: concurrency, throughput and latency

In a stable (stationary) system, the long-run average number of items in the system equals the effective arrival rate times the average time in the system (`L = lambda x W`). It holds regardless of arrival or service distribution; "effective" means items that actually entered, not ones turned away by a full queue. Uses:
- Infer an unmeasured quantity from the other two (average latency from in-flight count and throughput).
- Size pools: a pool of 10 connections with 200 ms average hold time caps throughput near 50 per second; more load queues.
- Reason about fixes: to serve double the arrivals at the same capacity, time in the system must halve.
Over short windows it need not hold directly, because items in flight at the start and end distort the count.

## Profilers and flame graphs

A **sampling profiler** records the call stack at intervals; cost is low and the result shows relative time share. A **deterministic profiler** hooks every call and return, giving exact call counts with more overhead and a clock resolution limit (Python docs: the clock ticks roughly every millisecond).

Node: run with `--prof` under a realistic load, process the log with `--prof-process`, then read the summary (share in JavaScript, C++, GC), the native-function table and the bottom-up (heavy) profile to see which callers cause the hot function. The Node guide's example found most time in synchronous password hashing blocking the event loop (about 52% of ticks in one native function); moving to the asynchronous API raised throughput from 5.33 to 19.46 requests per second in that one run (not a general figure). CPU profiles through the inspector and DevTools were not confirmed on the pages read.

Python: current docs describe a deterministic profiler as `profiling.tracing`, with `cProfile` kept as a backward-compatible alias, a sampling profiler as `profiling.sampling`, and the pure-Python `profile` module as deprecated since 3.15 (removal in 3.17); check the docs of your Python version, since older ones name `cProfile` directly. Results are read with `pstats`. Reading heuristics (from the docs' prose, not column definitions): internal time finds hot loops, cumulative time finds high-level cost, call counts expose surprising repetition (N+1 in code form). Exact CLI flags and column names are not re-verified; check them on the `cProfile` and `pstats` pages.

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
