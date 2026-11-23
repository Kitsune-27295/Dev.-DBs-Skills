# Retries, Timeouts, Jitter and Retry Budgets

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/retry · https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/ (301 redirect to https://builder.aws.com/content/3EumjoZascWd1oZiEgL8ORlv3qE/timeouts-retries-and-backoff-with-jitter, read there) · https://azure.microsoft.com/en-us/blog/using-the-retry-pattern-to-make-your-cloud-application-more-resilient/ · Last verified 2026-11-23

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
- Cap both delay and attempt count; a cap on delay alone leaves every client retrying at the same capped cadence.
- Retry only while the dependency looks healthy; stop when retries no longer raise availability.

## Jitter

Without randomness, callers that failed together back off to the same instant and collide again. Add jitter to retry delays and also to periodic jobs, timers and delayed work, because short spikes hide inside aggregated metrics. The article's examples: per-minute schedules that all fired at the top of the minute or at midnight did the same work with less capacity once jittered. A stable per-host offset is easier to debug than fresh randomness each time.

## Budgets versus circuit breakers

Brooker cautions that breakers add modal behavior that is hard to test and can slow recovery, and favors a local token bucket: each retry spends a token; tokens refill slowly; when empty, only the first attempt is made (or retries drop to a fixed trickle). AWS SDKs adopted this in 2016. Azure's guidance favors the breaker for sustained outages. Use both if you want: the budget bounds amplification, the breaker adds fast-fail plus fallback.

## Idempotency and what to retry

- Retry reads freely. Retry writes only if idempotent or protected by a client-supplied token (EC2 RunInstances style).
- 4xx generally not retryable; 5xx may be. Eventual consistency blurs this: a "not found" right after create can later succeed.
- Consumers of redelivered messages need the Idempotent Consumer pattern.

## Logging and tests

Log early failed attempts at informational level and only the final exhausted failure as an error, so self-healing blips do not page anyone. Test retry code against each failure mode for load amplification, races and bottlenecks.

## Platform reality

Hosting in the cloud or containers does not make an app resilient (Azure blog). Many SDKs retry by default but some need explicit enabling (the eShopOnContainers sample configured EF Core to retry up to 10 times with delays capped at 30 s). Libraries (Polly, Resilience4j) or a service mesh (Istio, Linkerd) can provide policies without hand-written loops.

## Example

```
delay = min(cap, base * 2**attempt)
sleep(random(0, delay))             # full jitter
if not budget.try_spend(): raise    # token bucket
```

## How an agent should apply this

- Audit every call path for retries at more than one layer and collapse them to one.
- Require connect plus request timeouts derived from a latency percentile, never library defaults left unexamined.
- Use capped exponential backoff with jitter plus an attempt cap and a retry budget.
- Block retries of non-idempotent calls unless a token or dedupe key exists.
- Log intermediate retries as info and only the terminal failure as error.
