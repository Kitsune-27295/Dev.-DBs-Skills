---
name: circuit-breaker-retry-telemetry
description: "Design, review or debug how a service survives failing dependencies and shows what happened: timeouts, retries with capped exponential backoff and jitter, retry budgets, circuit breakers (closed, open, half-open), bulkheads, fallbacks, how to nest them, and OpenTelemetry traces, metrics, logs and Collector buffering at each resilience boundary. Not for caching (`caching-strategies`), admission control or rate limiting (`rate-limiter-throttler`), making a retried write safe (`idempotency-fix`), error response contracts (`error-handling-problem-details`) or queue consumers that already have dead-letter queues. Use when adding or reviewing timeouts, retries or breakers, diagnosing retry storms or cascading failures, or instrumenting resilience events."
---

# Circuit Breaker, Retry, Bulkhead & OpenTelemetry

One idea: **transient faults need bounded retries with backoff and jitter; sustained outages need fast failure (breaker) and isolation (bulkhead); user-facing paths need an explicit fallback; and every resilience decision must be visible as correlated traces, metrics and logs.** Sources, retrieved statuses and unverified claims: [references/sources.md](references/sources.md).

Boundary: this skill owns the failure-handling policies and their telemetry. Making a retried write safe belongs to `idempotency-fix`. Bounding inbound load belongs to `rate-limiter-throttler`. Cache fallbacks belong to `caching-strategies`. The HTTP error contract belongs to `error-handling-problem-details`. Service decomposition belongs to `microservices-architecture` and `bff-pattern`.

## 1. Vocabulary

| Term | Meaning |
|---|---|
| Timeout | Longest a caller waits for connect and for the response before releasing its resources |
| Retry with backoff and jitter | Re-attempt after a delay that grows (for example `min(cap, base * 2^attempt)`) and is randomized so callers do not return in lockstep |
| Retry budget | A local token bucket: each retry spends a token, tokens refill slowly, and when empty only the first attempt is made (Brooker) |
| Circuit breaker | Proxy state machine, Closed to Open to Half-Open, that fails calls fast while a dependency looks unhealthy |
| Bulkhead | Separate pools (connections, threads, semaphores, instances) so one slow dependency cannot exhaust shared resources |
| Fallback | What the user gets when retries are exhausted or the breaker is Open: cached or default value, deferral, or an explicit error |

## 2. Core Rules

1. **Timeouts first, on every remote call.** Set both a connect and a request timeout. Derive the value from a tolerated false-timeout rate and the matching downstream latency percentile (Brooker's example: 0.1 percent, so p99.9), then add network delay for internet-facing callers. Too low creates retry traffic; too high pins resources. Detail: [references/retry-timeouts-jitter-and-budgets.md](references/retry-timeouts-jitter-and-budgets.md).
2. **Retry only what is safe and transient.** Cancel when the fault is not transient (Azure Retry pattern). Retry reads freely; retry a write only if it is idempotent or carries a client token (`idempotency-fix`). Treating 4xx as terminal and 5xx, 429 and timeouts as retryable is our working rule, not a quoted standard; honor a `Retry-After` hint when present.
3. **Retry at one layer.** Layered retries multiply: 5 layers each retrying 3 times put 3^5 = 243 times the load on the failing dependency (Brooker). Lower layers fail fast and report upward; the layer with full context retries. Capping delay without capping attempts leaves every client retrying at the capped cadence, so cap attempts too.
4. **Add jitter and a budget.** Randomize delays (full jitter: a random value between zero and the capped delay is our formulation; see sources for why it was not read from the original post). Add a token-bucket budget so retries cannot exceed a fraction of traffic. Jitter also periodic jobs and timers; a stable per-host offset is easier to diagnose than fresh randomness.
5. **Breakers per failure domain, with short timeouts.** One breaker per independent shard, tenant, region or provider, never one for a whole logical service (Azure). A breaker cannot help if each call blocks for a long timeout before counting as failed; shorten timeouts and add a bulkhead. Tuning: [references/circuit-breaker-state-machine-and-tuning.md](references/circuit-breaker-state-machine-and-tuning.md).
6. **Retry must treat "breaker open" as terminal.** The Azure pages say retry through a breaker is valid only if the retry logic stops when the breaker reports a non-transient fault. Define the Open behavior (fallback, cached value or explicit error) before shipping.
7. **Bulkhead what can starve.** Give each slow-prone dependency a bounded pool or semaphore and reject when full instead of queuing without limit. Prefer platform limits (gateway, container quotas) over bespoke code, and justify each bulkhead by a named failure scenario. Detail: [references/bulkhead-isolation-design.md](references/bulkhead-isolation-design.md).
8. **Do not use a breaker where the platform or broker already isolates failure:** local in-memory calls, message consumers with dead-letter queues, or paths where a mesh or load balancer already breaks circuits (Azure "when not to use").

## 3. Composition Order (a default, not a standard)

Outer to inner, as a starting point:

1. **Fallback** (outermost): serves the degraded result on terminal failure or open breaker.
2. **Total-operation timeout** (optional) and **Retry**: one layer, with backoff, jitter and budget.
3. **Circuit breaker**: sees every attempt, so it can trip across them.
4. **Per-attempt timeout and bulkhead** (innermost): bounds each attempt and the concurrency.

Why this order is our reasoning: retry outside the breaker lets the breaker count each attempt; a per-attempt timeout inside turns slowness into a failure the breaker can count. Polly's docs show nesting both ways (per-attempt timeout inside retry, or one overall timeout outside) and state no universal order; what matters is whether a timeout bounds one attempt or the whole operation. Libraries named by the Azure pages: Polly (.NET), Resilience4j (Java); a service mesh can supply policies without code.

## 4. Telemetry at Every Boundary

Detail and Collector settings: [references/opentelemetry-signals-spans-and-collector-resilience.md](references/opentelemetry-signals-spans-and-collector-resilience.md).

- **Traces:** propagate W3C `traceparent` (and `tracestate`) across hops. Each outbound HTTP attempt is a `CLIENT` span; per the HTTP semantic conventions it is `Error` on 4xx and 5xx, so per-attempt spans can be `Error` even when a later retry succeeds. Put the final outcome on the enclosing operation span. The stable attribute `http.request.resend_count` records the retry ordinal. Use a span event when the timestamp matters (breaker transition, retry delay) and an attribute when it does not.
- **Metrics:** use the stable `http.client.request.duration` histogram (seconds) for attempts. Names such as `resilience.circuit_breaker.state`, `resilience.retry.attempts` and `resilience.bulkhead.rejected` are our own naming, not an OpenTelemetry convention; check the semantic-convention registry before inventing others. Keep attributes low-cardinality: no user, order or trace IDs, no full URLs.
- **Logs:** structured, carrying `trace_id` and `span_id` (log records have TraceId, SpanId and TraceFlags fields). Log early failed attempts at INFO and only the exhausted failure at ERROR, so self-healing blips do not page anyone (Azure Retry pattern). OTel severity numbers: INFO 9-12, WARN 13-16, ERROR 17-20.
- **Collector:** enable the exporter `sending_queue` and `retry_on_failure`; add `file_storage` where a restart must not lose data; Kafka between agent and gateway for long outages. Defaults and loss scenarios are in the reference.

## 5. Build Order

1. Classify each dependency: idempotency, transient vs terminal errors, latency percentile, acceptable fallback.
2. Timeouts and bulkhead first, then retry with backoff, jitter and budget, then the breaker.
3. Wire the OTel SDK and an OTLP exporter to a Collector; emit the events from section 4.

## 6. Testing

| Component | Test | Proves |
|---|---|---|
| Retry | Fault injection with 503, 429 and 400 | Transient faults succeed within the cap; 400 gets zero retries; delays include jitter |
| Breaker | Deterministic clock | Opens after N failures in the window; fails fast while Open; Half-Open admits few probes and closes or reopens |
| Bulkhead | Load above the pool limit | Excess is rejected at once and unrelated pools are unaffected |
| Telemetry | In-memory exporter | `CLIENT` spans, resend counts, breaker events, logs share trace and span IDs |
| Amplification | Failure of a leaf under a 3-layer chain | Total attempts at the leaf stay within the budget |

## Mistakes to Catch

- Retry without jitter, or on a non-idempotent call without a token.
- Retries at several layers; or a retry loop that keeps hitting an Open breaker.
- One breaker or pool shared across unrelated shards, tenants or providers.
- A 60-second timeout under a breaker, so threads pile up before it trips.
- Putting IDs or full URLs in metric attributes.
- Logging every retried blip at ERROR.
- Taking the composition order in section 3 or the `resilience.*` names as a published standard.

## Quick Decision Checklist

- [ ] Connect and request timeouts set, derived from a latency percentile?
- [ ] Retries only for safe, transient failures, at one layer, with capped delay, capped attempts, jitter and a budget?
- [ ] Retry stops on breaker-open, and the Open behavior is defined?
- [ ] Breakers and bulkheads partitioned by failure domain?
- [ ] No breaker where a broker, mesh or platform already isolates the failure?
- [ ] Traces, metrics and logs correlated; attributes low-cardinality; ERROR only for exhausted failures?
- [ ] Collector exporters have a queue, retry and (where needed) persistent storage?

## Deep references

- [references/circuit-breaker-state-machine-and-tuning.md](references/circuit-breaker-state-machine-and-tuning.md): read when setting thresholds, Open duration, probes or per-partition breakers.
- [references/retry-timeouts-jitter-and-budgets.md](references/retry-timeouts-jitter-and-budgets.md): read when deriving timeouts, preventing retry amplification, or choosing breaker vs token bucket.
- [references/bulkhead-isolation-design.md](references/bulkhead-isolation-design.md): read when partitioning pools, queues or service instances.
- [references/opentelemetry-signals-spans-and-collector-resilience.md](references/opentelemetry-signals-spans-and-collector-resilience.md): read when instrumenting resilience boundaries or sizing Collector buffering.
- [references/trigger-evals.md](references/trigger-evals.md): read when tuning the description or checking neighbor boundaries.
- [references/sources.md](references/sources.md): retrieved status of every source, reading limits and claims not adopted.
