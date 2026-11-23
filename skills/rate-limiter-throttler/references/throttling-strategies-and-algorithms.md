# Throttling Strategies, Algorithms and Server-Side Considerations

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling · https://stripe.com/blog/rate-limiters · Last verified 2026-11-23

## Throttling is a control loop

Not a single yes/no check. Overload is a normal mode that a mature system detects and recovers from. The loop needs low-latency signals at three layers (infrastructure utilization, application state, per-principal counters), enforces limits at defined boundaries, and adapts as traffic changes. Throttling gives self-preservation: keep meeting the SLO under sudden or sustained load, and buy time while autoscaling provisions capacity (new capacity costs time and money; demand beyond growth or budget creates a deficit).

Terminology used by this skill: **rate limiting** = per-caller quota/rate control (who may send how much); **throttling** = the system's broader self-protection (reject, degrade, defer, level load); **load shedding** = dropping low-priority work based on whole-system state (Stripe's distinction: a limiter looks at one user, a shedder looks at the fleet).

## The five strategies

| Strategy | What it does | Pick when |
|---|---|---|
| Per-principal rate limit | Reject callers exceeding rate over a window | Need fairness and noisy-neighbor protection; requires attributing each request to a principal |
| Graceful feature degradation | Switch off or downgrade non-essential features (e.g. lower video resolution) | Essential paths must stay up; trade completeness for availability |
| Load leveling | Buffer in a queue; process at a steady rate; priority queue or separate endpoints per tier | Work can be deferred; tenants differ in SLA |
| Priority-based deferral | Suspend/limit lower-priority tenants or apps; return an error to retry later | Mixed-value traffic during scarcity |
| Outbound rate limit | Reduce own in-flight calls when a dependency fails, restore after recovery | Protect an unhealthy downstream and your logs/retry cost |

Combine with autoscaling: throttle during scale-out, relax after capacity arrives. If demand outgrows autoscale speed, even throttling may fail; keep reserve capacity or scale more aggressively.

## Choose the limited resource, then the algorithm

Limit the dimension that saturates first: request rate, concurrent in-flight requests, queue depth, CPU/memory, or a downstream's limit. A requests-per-second cap does not protect a system bottlenecked on concurrency at a fan-out point (use bulkheads/concurrency limits there). Normalize per-operation cost (reads cheap, writes expensive); ignoring cost is an attack vector.

| Algorithm | Behavior | Best fit | Weakness |
|---|---|---|---|
| Token bucket | Tokens refill at a steady rate; burst up to bucket size; empty bucket rejects | Gateways absorbing short spikes (Stripe uses it) | Burst may pass straight to a fragile backend |
| Leaky bucket | Constant outflow rate | Backends needing steady ingress | Delays or drops bursts; queue sizing |
| Fixed window | Counter per time window | Simplest | Back-to-back bursts at window boundaries (up to 2x limit around the edge: own inference) |
| Sliding window | Smooths boundary problem | Accurate per-caller limits | More state per key |

Token bucket in a few lines (single node):

```python
def allow(bucket, now, rate, capacity, cost=1):
    bucket.tokens = min(capacity, bucket.tokens + (now - bucket.ts) * rate)
    bucket.ts = now
    if bucket.tokens >= cost:
        bucket.tokens -= cost
        return True
    return False
```

## Where does the counter live?

Local counters are fast but undercount when one caller hits several replicas. A central store (e.g. Redis) sees every request but adds latency to each decision. Approximation: divide the global limit across replicas and reconcile periodically. Update the counter atomically (single script/operation), otherwise concurrent requests overspend.

## Proactive shedding

A throttle that only rejects after saturation lets latency spike before callers feel back-pressure. As utilization nears the hard limit, reject a growing fraction early. Use p99 latency against the SLO as the trigger (average utilization can look healthy while p99 already breached). Shed lower-value or more retryable work first.

## Rejection contract

- `429 Too Many Requests`: caller exceeded its rate over a window.
- `503 Service Unavailable`: service cannot handle it now (load spike, shedding).
- Always include `Retry-After`, and enough context to act: which limit, which scope, a rate that would succeed.
- Propagate overload from dependencies; do not hide a downstream 429/503 behind silent retries or a generic 500, otherwise callers cannot slow down and retries amplify (retry storm). See `circuit-breaker-retry-telemetry` and `error-handling-problem-details` for body shape.

## Operational rules

- Decide throttling early; retrofitting is expensive.
- Rejection must cost less than the work: reject before heavy auth, parsing or policy evaluation, and load test the rejection path.
- Make limits changeable at runtime (external configuration), not a redeploy during an incident.
- Adaptive limiters (latency or queue-depth driven) must still have a fixed maximum; review limits periodically as SLOs, dependency capacity and per-operation cost drift.
- Caching is not a substitute: it lowers average, not peak, load (see `caching-strategies`).
- Edge protection (DDoS, WAF rules) and application throttling are different layers; use both. Edge drops volumetric/malicious traffic; app throttling meters legitimate traffic against app-defined limits.
- Coarse boundaries (regional gateway) can punish unrelated users; scope limits to the principal or tenant.

## Anti-patterns

- One global limit with no per-tenant fairness.
- Limits on RPS where concurrency is the bottleneck.
- Rejection without `Retry-After` or explanation.
- Counters in local memory with N replicas and a promised global limit.
- Static limits never revisited; limits baked into code.
- Throttle that triggers only at 100% utilization.

## How an agent should apply this

- Name the saturating resource and the principal being limited before choosing an algorithm; default to token bucket per principal, plus a concurrency cap for expensive endpoints.
- Specify the counter location and atomicity; for multi-replica global limits use a central atomic counter or a divided budget.
- Define 429 vs 503 semantics with `Retry-After` and a structured error body.
- Add early-shed thresholds on p99 latency, not just utilization.
- Expose limits as runtime configuration with metrics on rejections per limiter and principal.
