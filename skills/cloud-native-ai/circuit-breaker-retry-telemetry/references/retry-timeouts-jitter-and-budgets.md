# Retries, Timeouts, Jitter and Retry Budgets

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/retry (ms.date 2024-07-18) · https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/ (301 redirect to https://builder.aws.com/content/3EumjoZascWd1oZiEgL8ORlv3qE/timeouts-retries-and-backoff-with-jitter, read there; article by Marc Brooker, published 2019-12-05) · https://azure.microsoft.com/en-us/blog/using-the-retry-pattern-to-make-your-cloud-application-more-resilient/ (2018) · Last verified 2026-11-27

## Timeouts come first

- Every remote call needs both a connect timeout and a request timeout, including calls to another process on the same host.
- Derivation (AWS, Brooker): choose a tolerable false-timeout rate (the article uses 0.1%), then take the matching downstream latency percentile (p99.9). Add worst-case network delay for internet clients, and padding where p99.9 is close to p50.
- Too low: spurious timeouts create retry traffic that can turn a blip into an outage. Too high: resources are held too long.
- Prefer the timeouts of mature client libraries; kernel socket timeouts are a weak end-to-end bound and some timeouts skip DNS or TLS setup. The article's anecdote: a 20 ms timeout broke after deploys because it included new TLS connection setup; pre-establishing connections at startup fixed it.

## Retry strategies (Azure)

1. **Cancel** when the fault is not transient.
2. **Retry immediately** for rare one-off faults such as a corrupted packet.
3. **Retry after delay** for common busy/connectivity faults, spacing instances apart so they do not all return together. Delay may grow incrementally or exponentially.

Match the policy to context: an interactive request should give up after few short retries and tell the user; a batch job can afford many attempts with growing delays. Policies can differ per downstream service and per exception type. Retried operations inside a transaction need tuning so success is maximized and undo work minimized.

## Why retries are dangerous

Retries are "selfish": they spend server capacity to raise one caller's odds. In overload they deepen the problem. Layering multiplies: with 5 stacked layers each retrying 3 times, a failing database sees 3^5 = 243 times the load. Rules that follow:

- Retry at one layer only (usually the one with the fullest context); lower layers fail fast and report the reason upward.
- Cap both delay and attempt count; the article notes that a cap on delay alone leaves many clients retrying constantly at the capped rate, and prefers limiting retries and handling failure earlier in the architecture.
- Retry only while the dependency looks healthy (our corollary: stop when retries no longer raise availability, which a budget or breaker enforces).
- The article also says a single retry point can still waste work done by earlier calls, so choose the layer with the most context.

## Jitter

Without randomness, callers that failed together back off to the same instant and collide again. Add jitter to retry delays and also to periodic jobs, timers and delayed work, because short spikes hide inside aggregated metrics. The article's examples are clients on regular schedules that synchronize at the start of a minute or after midnight. It recommends a consistent per-host offset over fresh randomness, so overload patterns repeat and are easier to diagnose. It gives no jitter formula and points to a separate AWS Architecture Blog post, whose body could not be read (see sources).

## Budgets versus circuit breakers

Brooker cautions that breakers add modal behavior that is hard to test and can significantly lengthen recovery, and favors a local token bucket: calls retry while tokens remain, then retries drop to a fixed rate. The article says AWS added this to its SDK in 2016. Azure's guidance favors the breaker for sustained outages. Use both if you want: the budget bounds amplification, the breaker adds fast-fail plus fallback.

## Idempotency and what to retry

- Retry reads freely. Retry writes only if idempotent or protected by a client-supplied token (EC2 RunInstances style).
- Our working rule: 4xx is generally terminal, while 5xx, 429 and timeouts may be retried, and eventual consistency can blur it (a "not found" right after create can later succeed). This rule was not read from a fetched source.
- Consumers of redelivered messages need the Idempotent Consumer pattern.

## Logging and tests

The Azure Retry pattern says to log early failures as informational entries and only the failure of the last attempt as an error, so self-healing blips do not flood operators with alerts. It also asks that retry code be tested against varied failure conditions for load, races and bottlenecks.

## Platform reality

Hosting in the cloud or containers does not make an app resilient (Azure blog). Many SDKs retry by default but some need explicit enabling (the eShopOnContainers sample configured EF Core to retry up to 10 times with delays capped at 30 s). Libraries (Polly, Resilience4j) or a service mesh (Istio, Linkerd) can provide policies without hand-written loops.

## Example

```
delay = min(cap, base * 2**attempt)
sleep(random(0, delay))             # our full-jitter formulation
if not budget.try_spend(): raise    # token bucket
```

## How an agent should apply this

- Audit every call path for retries at more than one layer and collapse them to one.
- Require connect plus request timeouts derived from a latency percentile, never library defaults left unexamined.
- Use capped exponential backoff with jitter plus an attempt cap and a retry budget.
- Block retries of non-idempotent calls unless a token or dedupe key exists.
- Log intermediate retries as info and only the terminal failure as error.
