# OpenTelemetry: Signals, Span Model, Conventions and Collector Resilience

Sources: https://opentelemetry.io/docs/concepts/signals/ · https://opentelemetry.io/docs/concepts/signals/traces/ · https://opentelemetry.io/docs/concepts/semantic-conventions/ · https://opentelemetry.io/docs/collector/resiliency/ · Last verified 2026-11-23

## Signals

Supported: **Traces** (the path of a request), **Metrics** (measurements over time), **Logs** (individual event records), **Baggage** (context carried between signals). In development or proposal at read time: Events (a specialized log) and Profiles (code-level resource use).

## Trace model

- A **Tracer Provider** is a factory, created once per application lifetime, wired with Resource and Exporter; a **Tracer** makes spans.
- A **Span** is a unit of work: name, parent span id (empty for roots), start/end time, span context, attributes, events, links, status.
- **Span Context** is immutable: Trace ID, Span ID, Trace Flags, Trace State. It is what crosses process boundaries and what links use.
- **Attributes**: string keys; values are string, bool, float, int or arrays of those. Set them at span creation when sampling might depend on them.
- **Events**: a point-in-time annotation inside a span. Use an event when the timestamp matters; an attribute when it does not; a span when there is a duration.
- **Links**: causal association to other spans, for async follow-up work in a different trace.
- **Status**: Unset (default, no error), Error, Ok (explicit developer sign-off, usually unnecessary).
- **Span kind**: Client, Server, Internal (default), Producer, Consumer. A server span's parent is often a client span; a consumer's parent is always a producer.

## Mapping to resilience boundaries (own inference)

| Resilience event | Telemetry |
|---|---|
| each retry attempt | child client span or span event with attempt number and delay |
| breaker state change | span event plus a metric counter/gauge on state, and a log line |
| breaker rejecting a call | span with Error status and an attribute naming the breaker and state |
| bulkhead full | counter of rejections per bulkhead name |
| fallback served | attribute or event marking degraded response |

Keep IDs such as trace_id or order_id out of metric labels (cardinality); they belong in traces and logs.

## Semantic conventions

Standard names ("common names for different kinds of operations and data") exist for traces, metrics, logs, profiles and resources. Using them keeps your own code, libraries and platforms consistent, which is what makes dashboards and alerts portable. Prefer a convention attribute over inventing a name.

## Collector resiliency

Three tiers, each with a different failure profile:

| Mechanism | Survives collector crash | Outage coverage | Cost |
|---|---|---|---|
| in-memory sending queue | no | until queue full or retry window ends | low |
| file-backed queue (file_storage WAL) | yes | same limits, disk-bound | low to moderate |
| Kafka between agent and gateway | yes for data in Kafka | topic retention | high, needs Kafka skills |

Details: the exporter queue (about 1,000 items by default) absorbs outages; failed sends retry with exponential backoff and jitter within a window of roughly 5 minutes (`retry_on_failure`: initial_interval, max_interval, max_elapsed_time; `sending_queue.queue_size`). A full queue drops new data; data older than the window drops too. Watch `otelcol_exporter_queue_size` and `otelcol_exporter_queue_capacity`. WAL setup: define the `file_storage` extension, reference it from the exporter's queue storage, enable it under `service.extensions`; disk failure or a full disk loses data. With Kafka, the agent exports to a topic and the gateway consumes; if Kafka itself is down the producer still needs local buffering.

Loss scenarios to design against: outage beyond the retry window, queue overflow, crash with memory-only queue, disk failure, queue-system failure without producer buffering, misconfiguration, queues deliberately disabled.

## How an agent should apply this

- Emit all three signals at each resilience boundary, correlated by trace context, and name attributes per semantic conventions.
- Enable sending queues on every network exporter; add file_storage where restarts must not lose data.
- Use an Agent plus Gateway topology and focus durability on agent-to-gateway and gateway-to-backend hops; avoid heavy queues between SDK and local agent so the app is not harmed when the agent is down.
- Alert on queue-size versus capacity and failed-send counters.
- Never put high-cardinality identifiers on metric labels.
