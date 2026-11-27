# Absence and Failure Semantics

Sources: https://www.rfc-editor.org/rfc/rfc9413 · https://martinfowler.com/eaaCatalog/specialCase.html · https://sre.google/sre-book/monitoring-distributed-systems/ · https://opentelemetry.io/docs/concepts/signals/traces/ · Last verified 2026-11-24

This file expands questions 2 (ABSENCE) and 4 (FAILURE). They are one family: "no value" and "failed to get a value" are both routinely turned into a value of the type's zero, and the result looks like healthy data.

## The collapse, step by step

```text
source:     returns nothing (device down, key missing, query matched no rows)
collector:  maps "nothing" to []            (hop 1: absence becomes an empty list)
service:    sum([]) = 0, max([]) = default   (hop 2: empty becomes a number)
API:        { "alerts": [] }                 (hop 3: published as a normal answer)
UI:         renders "No problems"            (hop 4: empty is styled as success)
```

Each step is individually defensible, and each layer may have been reviewed on its own. The composition reports "healthy" about something that is not running. The method's job is to find the **first** hop that made "unknown" indistinguishable from "known and empty", because that is where a distinct state must be introduced.

## Question 2: how is absence represented at this hop?

Ask three sub-questions at each hop: (a) can this hop receive "no value", (b) how does it encode that on the way out, (c) can the next hop tell it apart from a real zero or empty result?

| Pattern in code | What it does to absence |
|---|---|
| `value ?? 0`, `value or 0`, `|| []`, `|| ""` | Replaces unknown with a plausible value |
| Non-nullable field in a DTO or schema with a default | Parser fills the gap silently |
| Aggregate over an empty set (sum, count, average, max) | Returns zero or a default instead of "no data" |
| "Row not found returns empty list" vs "access denied returns empty list" | Two different causes, one identical result |
| Boolean flag that is `false` when the source is unreachable | "Not enabled" and "do not know" merge |
| UI list or chart with no empty, loading, stale and error states | Only the "has data" and "empty" states exist |

The fix shape is almost always the same: give "unknown" its own representation (a nullable field, an explicit status such as `unknown` or `degraded`, a result type that carries the reason) and make every consumer handle it. How to model that in the domain is owned by `defensive-domain-modeling`; how to publish it in an API is owned by `error-handling-problem-details` and `arc42-api-contracts-architecture`.

### Special-case values are not a cure by themselves

Fowler's Special Case pattern replaces null with a special-case object that has the same interface, so callers stop repeating null checks. That is useful and it is also a risk for this problem: if the special-case object reports `0` or `[]` like real data, the null check is gone and the information is gone with it. (The risk is this skill's inference; the catalog page itself does not discuss that trade-off.) A safe special case for "unknown" must remain **distinguishable**: its numeric accessors should not pretend to be a measurement, and display code should be able to ask "is this known?" before formatting.

## Question 4: what happens on failure at this hop?

Ask: when a dependency of this hop fails, times out, returns an error, or returns a partial result, what leaves the hop? Classify the answer:

| Outcome | Verdict |
|---|---|
| Error propagates with its cause, the consumer renders an error state | Good |
| Marked degraded or stale, with the original age kept | Good, if the consumer renders the mark |
| Last-known value returned with its original timestamp | Acceptable when the UI shows the age |
| Empty or default value, normal status | **Finding**: failure disguised as data |
| Error logged, normal result returned | **Finding**: only operators know; users see a quiet lie |
| Retry that ends in a default after exhausting attempts | **Finding**: retry policy hides the outage (`circuit-breaker-retry-telemetry`) |
| 200 with an error-shaped or empty body | **Finding**: failure disguised in the transport layer |

Two points from the Google SRE chapter apply directly. First, errors can be **explicit** (an HTTP 500), **implicit** (a 200 response with wrong content) or **policy-based** (a response slower than a committed limit); it says load balancers catch complete failures but only end-to-end checks catch wrong content. A hop that turns a failure into a quiet 200 produces exactly the implicit kind, which no status-code dashboard will count. Second, it observes that a slow error is worse than a fast error, so failed and successful requests should be measured separately rather than blended into one average.

In tracing terms, a span ends with status Unset (completed without error), Error, or Ok (explicitly marked). A hop that swallows an exception and returns normally ends Unset, which is indistinguishable from success. That is the instrumentation view of the same defect.

## Why silent tolerance travels

RFC 9413 (the IAB's critique of the robustness principle, "be liberal in what you accept") argues that silently tolerating faulty or unexpected input lets problems accumulate, entrenches the tolerated behavior as a de facto standard, and hides faults that could have been fixed. It recommends "virtuous intolerance": define explicit handling for aberrant conditions and surface faults so they get fixed, ideally in a way humans can see. It also states a limit: the advice applies where implementations can be updated and redeployed. The RFC is about protocols, so applying it to internal data layers is this skill's analogy; the mechanism is the same, because a layer that repairs bad input quietly passes it on as valid-looking data.

Practical reading for a trace:

- A layer that fills a missing field with a default is being "liberal". Ask whether the default is documented, visible to the next hop, and counted somewhere.
- Prefer rejecting or flagging the malformed input at the earliest hop that can detect it. The earlier the flag, the fewer hops inherit the lie.
- Where tolerance is unavoidable (a legacy source you cannot change), keep it at one place, record it, and plan its removal; the RFC likewise says workarounds should be documented with a plan to remove them.

## Example: three "defensible" layers

```text
collector:  except TimeoutError: return []          # avoids crashing the cycle
service:    health = 100 - penalty(alerts)          # no alerts -> 100
UI:         health >= 80 -> green "Healthy"
```

Trace answer: first bad hop is the collector (failure became empty data). Fix: return a degraded marker carrying the cause and the age of the last good sample; the service maps "degraded" to an `unknown` health; the UI gets an "unknown / stale" state. Pin it with a test at the collector that simulates the timeout and asserts the marker, not an empty list.

## How an agent should apply this

- Grep each hop for fallbacks (`?? 0`, `|| []`, defaults in mappers or schemas, bare `catch` that returns data) and treat every hit as a candidate until the hop's input for the missing case is observed.
- Force the failure: stop or fake the upstream at that hop and capture what leaves it; do not infer from reading.
- Require "unknown" or "degraded" to have its own representation that the next hop can distinguish from zero or empty.
- Check the UI has loading, empty, stale and error states, not just "data" and "empty".
- Report disguised failures as findings even when they are locally intentional, and route the repair to the owning skill.
