# Hop Evidence Ledger

Sources: https://opentelemetry.io/docs/concepts/signals/traces/ · https://sre.google/sre-book/monitoring-distributed-systems/ · Last verified 2026-11-24

## Why borrow the tracing model

Distributed tracing answers "where did this request go and what happened at each step". The OpenTelemetry docs define a **trace** as the path of a request through an application, built from **spans** that share a trace ID and form a parent/child hierarchy; a span is one unit of work with a name, start and end timestamps, attributes, events, links and a status. A value investigation asks the same question about **data** instead of a request: where did this number go and what happened to it at each step. The mapping below is this skill's own adaptation, not part of the OpenTelemetry specification.

| Tracing concept (as documented) | Use in a value trace |
|---|---|
| Trace: end-to-end path across processes and services | The whole walk from source of truth to screen for one named value |
| Span: one unit of work, with start and end time | One hop: collector, service, endpoint, BFF handler, cache read, render |
| Attributes: key-value metadata on a span | The per-hop facts: value in, value out, unit, window, entity key, timestamp |
| Span events: a moment in time inside a span; use an event when the timestamp matters, an attribute when it does not | A value change at a known instant (cache refill, retry attempt) is an event; a unit or window is an attribute |
| Span status: Unset (finished without error), Error, Ok | The **failure** answer for the hop; see the warning below |
| Span links: causal relation without direct parentage, typically for async work | A queue, scheduled job or batch between two hops: link the producer's output to the consumer's input |
| Span context propagated between services | An identifier carried with the value (request ID, sample ID, source timestamp) so a downstream hop can be matched to the upstream one |

## Warning: status is not the answer to "was the value right"

A span (or a hop) can finish with no error and still carry a wrong value. In the tracing model an Unset status only says the operation completed without an error. A value trace therefore records **two separate judgments per hop**: did the hop complete (failure question) and is the value still true (value, absence, freshness questions). Never let "no error" fill the value column.

## What to record per hop

Keep the ledger small and comparable. Per hop:

1. **Identity:** hop name, which code or system owns it, and how you observed it (log, debugger, recorded response, test).
2. **Input and output value** with unit, scale and the entity/window keys actually used (not the ones intended).
3. **Absence handling:** how this hop encodes "no value" on the way in and on the way out.
4. **Timestamp and age:** the source timestamp if it survived, the time this hop produced or served the value, and who refreshes it.
5. **Failure behavior:** what is returned when the upstream call fails, times out or returns nothing, observed or "not exercised".
6. **Evidence pointer:** the log line, response capture, test name or trace ID.

Example row, in prose-shaped form: `API layer | in 0.734 (ratio), out 73 (percent, rounded) | missing sample -> field omitted | no source timestamp in payload | upstream timeout -> 200 with last cached value | response capture #3`. That single row already shows two findings: rounding at the hop and a timestamp that does not survive.

## Manual trace or instrumented trace

- If the system already emits traces, use them to find hop order, durations and error statuses fast, then still fill the value columns by reading attributes or logs; a trace without value attributes proves path, not meaning.
- If tracing is not wired in, a manual ledger is enough. State that in the report ("manual trace, no propagation IDs") so nobody assumes production correlation exists. Do not add instrumentation as a side effect of the investigation; hand that to `circuit-breaker-retry-telemetry` as a follow-up.
- A trace shows where **time and errors** concentrate; it does not show a wrong number inside a successful call. Pair it with direct reads of values.

## Black-box and white-box views

The Google SRE book separates black-box monitoring (symptoms visible from outside, "what is broken") from white-box monitoring (internal signals, "why"), and notes the same condition can be a symptom at one layer and a cause at another. The same applies to the ledger: the screen and the public API are black-box observations; the collector and service internals are white-box. Start with the black-box disagreement to name the value, then use white-box evidence per hop to find the cause. (The mapping of this idea onto hops is this skill's inference.)

## How an agent should apply this

- Create the ledger before reading deeply, with one row per hop you can name, and add hidden hops (proxy, queue, job, cache) as you discover them.
- Fill every cell with captured evidence or the words "not checked"; never leave an assumption unmarked.
- Record value-correctness and completion status separately for each hop.
- Add an identifier column (request ID, sample ID, source timestamp) when the stack propagates one; otherwise note that correlation is manual.
- Put instrumentation gaps in the report's "not checked" or follow-up section instead of fixing them inline.
