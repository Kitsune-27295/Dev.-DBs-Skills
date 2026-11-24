# Value and Freshness Checks

Sources: https://sre.google/sre-book/monitoring-distributed-systems/ · https://opentelemetry.io/docs/concepts/signals/traces/ · Last verified 2026-11-24

This file expands questions 1 (VALUE) and 3 (FRESHNESS). Cache design itself is owned by `caching-strategies`; this file only covers how to detect that a cache or poll is the hop where truth was lost.

## Question 1: is the value what we expect here?

"Expected" must be stated before observing. For each hop write the expected value from the previous hop's output and the rule the hop applies. Then check these drift families, in order of how often they bite (the ordering is a practical heuristic, not a measured statistic):

| Drift | What to compare | Example |
|---|---|---|
| Unit or scale | Ratio vs percent, bytes vs kilobytes, seconds vs milliseconds | Source emits 0.734, consumer treats it as already a percent and shows 0.7% |
| Aggregation | Sum vs average vs max vs last; per-entity vs fleet-wide | A tile says "average" but the service returns the worst entity |
| Window | Last 5 minutes vs today vs rolling hour; timezone and day boundaries | Two screens agree except around midnight |
| Identity | Entity key, tenant, environment, alias vs canonical ID | Value is correct for the wrong entity because a key was truncated or defaulted |
| Rounding and formatting | Where rounding happens, locale, truncation vs rounding | Two roundings in a row (service, then UI) shift a total by one |
| Recomputation | A downstream layer recomputes what an upstream layer already computed | UI derives a status from raw numbers using different thresholds than the service |
| Filtering | Soft-deleted, test, archived or hidden rows | Totals differ by exactly the filtered rows |

A useful move: **compute the expected value yourself from the source of truth** (one read-only query or one raw call), then compare it to each hop's output. The first hop whose output differs from your own computation, without a documented rule, is the suspect.

### Intentional duplicates

Some systems compute the same metric in two places on purpose (for example a server-side score and a client-side mirror, or two data sources that coexist). Before calling a difference a bug ask three things for each screen: which definition, which window, which source. If the duplication is intentional, verify that the two sides still agree on every shared rule and report drift; do not merge them in the middle of the trace (`ssot-and-dry` owns that decision).

## Question 3: is the value fresh, and does the timestamp survive?

Freshness has three parts, and each can fail independently:

1. **Produced-at:** when the source observed the value. This is the only timestamp that tells the user how old the number is.
2. **Served-at:** when this hop last computed or fetched it. Easy to confuse with produced-at; many mappers overwrite one with the other.
3. **Refresh path:** who updates it next (a poll, a push, a cache TTL, a replica, a nightly batch) and what the longest possible staleness is.

Check at each hop:

- Does the payload carry produced-at, and does the next hop keep it? A timestamp dropped in a mapper makes every later hop unable to say "old".
- Is the displayed freshness the produced-at time or merely the page-load time? A "Last updated" label driven by the client clock proves nothing.
- Does any layer cache? Compute worst-case staleness as the sum of stacked delays (source interval + collector poll + server cache + client cache + UI poll); stacked layers add up, they do not overlap. (Arithmetic of this kind is this skill's inference; compare it with the freshness the screen implies.)
- What happens when refresh fails: is the last value kept and shown with its original age, shown as fresh, or cleared? Showing a stale value as fresh is a failure-question finding too (see `absence-and-failure-semantics`).
- Does the identity of the freshest value survive merges? When two sources feed one number, the merge must say which one won and when it was produced.

## Averages hide the tail

The Google SRE chapter on monitoring warns that averages can hide a slow tail: a service averaging 100 ms can still have a small percent of requests at seconds, and one backend's slow tail becomes a page's typical latency when a page depends on several backends. It recommends counting requests in latency buckets (a histogram) rather than relying on means. For a value trace this matters when the symptom is "sometimes wrong or late": a single sample or an average at one hop can look fine while a tail of stale or timed-out reads reaches some users. Capture the distribution or several samples, not one.

The same source notes that measurement resolution should match the goal: a one-minute average can miss short spikes. If a displayed value is an average over a window, check that the window is short enough to show the behavior the user cares about.

## Timestamps in the tracing model

The OpenTelemetry trace docs treat start and end timestamps as part of every span and advise recording data as an event when its timestamp matters and as an attribute when it does not. Apply the same test to the data under investigation: if the age of a number matters to the reader, it is not metadata to drop; it must travel with the value as a first-class field.

## Example: a stale value that looks live

```text
source:     cpu=71   produced 10:00:02
collector:  cpu=71   served 10:00:05 (poll 60 s)      timestamp dropped by the mapper
API:        cpu=71   no produced-at field
BFF cache:  cpu=71   TTL 5 min
UI:         "CPU 71%" label "updated just now" (client clock)
reality at 10:04:40: source now reads 95
```

Findings: the mapper dropped produced-at (freshness lost, first bad hop), the BFF cache adds up to 5 minutes, and the UI label invents freshness. Fix order: restore the timestamp at the mapper, expose it in the contract, render real age in the UI, then revisit the TTL.

## How an agent should apply this

- Write the expected value at each hop before observing it, and compute it independently from the source.
- Run the drift table (unit, aggregation, window, identity, rounding, recomputation, filtering) at the first hop that differs.
- Track produced-at, served-at and refresh path separately; flag any hop that overwrites one with the other.
- Sum stacked cache and poll delays to get worst-case staleness and compare it with what the UI promises.
- For intermittent symptoms collect several samples or a distribution, not a single reading.
