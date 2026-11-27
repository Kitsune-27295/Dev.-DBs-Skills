# Sources — Circuit Breaker, Retry, Bulkhead and OpenTelemetry

Every URL below was checked during skill authoring (2026-11-22) and re-checked in a from-zero rebuild (2026-11-27). Last verified 2026-11-27.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker | 200 OK via WebFetch, 2026-11-27 (ms.date 2025-02-05), read in full | Closed, Open, Half-Open states; time-windowed failure counter and consecutive success counter; design considerations; when not to use; 429 free-tier example; retry must respect breaker exceptions |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/retry | 200 OK via WebFetch, 2026-11-27 (ms.date 2024-07-18), read in full | Cancel, retry immediately, retry after delay; idempotency; single-context retry advice; INFO-then-ERROR logging; when not to use |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead | 200 OK via WebFetch, 2026-11-27 (ms.date 2026-03-19), read in full | Consumer and service partitioning, messaging isolation, design considerations, platform controls, Kubernetes example |
| https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/ | 301 Moved Permanently to https://builder.aws.com/content/3EumjoZascWd1oZiEgL8ORlv3qE/timeouts-retries-and-backoff-with-jitter, which returned 200 OK via WebFetch, 2026-11-27 (published 2019-12-05) | Timeout derivation (p99.9), selfish retries, 3^5 = 243 amplification, token bucket (SDK, 2016), breaker caution, jitter for periodic work, idempotency tokens, capped-backoff caveat, TLS timeout anecdote |
| https://azure.microsoft.com/en-us/blog/using-the-retry-pattern-to-make-your-cloud-application-more-resilient/ | 200 OK via WebFetch, 2026-11-27 (2018 blog post) | Cloud hosting does not give resilience by itself; SDK retries; EF Core retry example; Polly and service meshes |
| https://opentelemetry.io/docs/concepts/signals/ | 200 OK via WebFetch, 2026-11-27 | Traces, Metrics, Logs, Baggage supported; Events and Profiles in development or proposal |
| https://opentelemetry.io/docs/concepts/signals/traces/ | 200 OK via WebFetch, 2026-11-27 | Span model, span context, attributes, events vs attributes, links, status, kinds, tracer provider |
| https://opentelemetry.io/docs/concepts/semantic-conventions/ | 200 OK via WebFetch, 2026-11-27 | Purpose and scope of semantic conventions; the page makes no stability statement |
| https://opentelemetry.io/docs/collector/resiliency/ | 200 OK via WebFetch, 2026-11-27 | In-memory queue, file_storage WAL, Kafka; default queue size and 5 minute retry window; metrics to watch; loss scenarios; topology advice |
| https://opentelemetry.io/docs/specs/semconv/http/http-spans/ (added 2026-11-27) | 200 OK via WebFetch | `CLIENT` kind, Error status on 4xx and 5xx, `http.request.resend_count`, `error.type`, stability |
| https://opentelemetry.io/docs/specs/semconv/http/http-metrics/ (added 2026-11-27) | 200 OK via WebFetch | `http.client.request.duration` histogram in seconds, required attributes, cardinality notes |
| https://opentelemetry.io/docs/specs/otel/logs/data-model/ (added 2026-11-27) | 200 OK via WebFetch | Trace context fields on log records, severity ranges |
| https://www.w3.org/TR/trace-context/ (added 2026-11-27) | 200 OK via WebFetch | `traceparent` format, `tracestate`, Recommendation status (2021-11-23 edition) |
| https://www.pollydocs.org/strategies/index.html and https://www.pollydocs.org/pipelines/index.html (added 2026-11-27) | 200 OK via WebFetch | Built-in strategies (retry, circuit breaker, fallback, hedging, timeout, rate limiter); pipeline nesting examples; no stated universal order |
| https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/ (added 2026-11-27) | 200 OK via WebFetch, but both reads returned only site navigation (body truncated); content not read | Nothing; the full, equal and decorrelated jitter formulas were not verified from it |

## Reading limits

- Fetches go through a summarizing model, so quotes are as reported by that summary; recheck a clause before quoting it.
- Firecrawl was not used (no credits); WebFetch only.
- The Azure circuit-breaker page and the Azure caching-related links to other patterns were not followed beyond the pages above.
- No scripts or data files exist in this skill.

## Claims not adopted as fact

- The nesting order Fallback, Retry, Breaker, Timeout and Bulkhead: Polly's pages show nesting in both directions and no universal rule. Kept only as our reasoned default.
- 4xx terminal and 5xx, 429, timeouts retryable: not read from a fetched source; kept as our working rule.
- Full jitter as `random(0, min(cap, base * 2^n))`: our formulation; the original AWS jitter post could not be read.
- `resilience.circuit_breaker.state`, `resilience.retry.attempts`, `resilience.bulkhead.rejected`, `fallback.used`: our own names; no OpenTelemetry convention for them was found in the pages read.
- The earlier draft's "4^4 = 256 attempts" and "3^4 = 81" examples: arithmetic was inconsistent; only the source's 3^5 = 243 is kept.
- The earlier draft's "retry must be inside" or "abort when Open" wording beyond the Azure statement that retry logic should stop when the breaker indicates a non-transient fault.
- Setting span status Error only on ultimate failure: contradicts the HTTP client span convention for each attempt; replaced.
