---
name: rate-limiter-throttler
description: "Design and review admission control: rate limiting vs throttling vs load shedding, token bucket, leaky bucket, fixed and sliding window algorithms, per-tenant/per-user limits, concurrency limits, request priorities, 429/503 with Retry-After, distributed counters, client-side pacing against throttled APIs, and Stripe-style layered limiters with fail-open, kill switches and dark launches. Use when protecting an API or dependency from overload, adding quotas, choosing a limiting algorithm, shedding low-priority traffic, or pacing batch calls to a throttled service."
---

# Rate Limiter & Throttler (Admission Control)

One idea: **decide at the door, cheaply and early, who and what gets in** — based on the resource that saturates first — and tell rejected callers exactly how to come back. Overload is a normal operating mode, so limits, priorities and rejection contracts are designed in, not bolted on. Sources and claims: [references/sources.md](references/sources.md).

Boundary: this skill is **admission control**. Data reuse belongs to `caching-strategies` (a cache lowers average load but not peak load; it is not a throttle). Async execution, queues and workers belong to `background-worker-job-scheduler` (workers drain at a limited rate; this skill supplies the limit). Retry, backoff and circuit breaking by *callers* is `circuit-breaker-retry-telemetry`. Where limiters are mounted: `api-gateway-reverse-proxy`, `middleware-interceptor-chain`; identity and tenant attribution: `authn-authz-guard`; error body format: `error-handling-problem-details`; runtime switches: `feature-flag-toggle-engine`; autoscaling and config: `twelve-factor-cloud-native`.

---

## 1. Vocabulary (Use Precisely)

| Term | Decides based on | Typical action |
|---|---|---|
| **Rate limiting** | Per principal (user, key, tenant, IP): count over a window | Reject or delay the over-limit caller |
| **Quota** | Per principal over long period (day, month) | Block or bill |
| **Throttling** (Azure sense) | Whole-system self-protection: SLO, saturation | Reject, degrade, defer, level load, scale |
| **Concurrency limit / bulkhead** | In-flight work count | Reject or queue extra |
| **Load shedding** | Whole-system health and request priority | Drop lowest-priority work first |
| **Client-side rate limiting** | Caller's own pacing vs a throttled service | Release work at an allowed rate |

## 2. Pick the Resource Before the Algorithm

Limit what saturates first: requests per second, **concurrent in-flight requests**, queue depth, CPU/memory, or a downstream's quota. RPS limits do not protect a system whose bottleneck is concurrency at a fan-out point. Weight operations by cost (reads cheap, writes and exports expensive); equal weights are an abuse vector.

## 3. Algorithms

| Algorithm | Behaviour | Choose when | Reject when |
|---|---|---|---|
| **Token bucket** | Steady refill, burst up to capacity | Default for APIs; absorb legitimate short spikes | Backend cannot tolerate bursts |
| **Leaky bucket** | Constant outflow | Backend needs steady ingress; client-side pacing | Callers need burst latitude |
| **Fixed window** | Counter per window | Rough, cheap quotas | Boundary bursts matter (about double rate across the edge) |
| **Sliding window** | Smooths boundary effect, more state | Accurate per-user fairness | State cost too high |
| **Concurrency limit** | Max in-flight per principal/endpoint | Expensive endpoints; clients that fork parallel jobs | Cheap idempotent reads |
| **Adaptive** (latency/queue driven) | Limit tracks health | Variable capacity | Always needs a fixed maximum and periodic review |

Details and a token-bucket sketch: [references/throttling-strategies-and-algorithms.md](references/throttling-strategies-and-algorithms.md).

## 4. Where Counters Live

| Option | Pro | Con |
|---|---|---|
| Local in-process | Fast | Undercounts across replicas |
| Central store (Redis) atomic counter/bucket | Exact global view | Latency per decision; new failure mode (so fail open) |
| Divided budget (limit / replicas, reconciled) | No hot path call | Approximate |
| Capacity leases (partitions with expiring ownership) | Coordinates uncoordinated processes | Lease handling complexity |

Counter updates must be atomic (single script/operation) or concurrent requests overspend.

## 5. Layered Limiters (Stripe Model)

Build in this order; each layer catches what the previous cannot:

1. **Request rate limiter** (per user, token bucket, burst allowance, identical in test and live). Start here.
2. **Concurrent requests limiter** (per user in-flight cap, e.g. 20) for CPU-heavy endpoints and retrying clients.
3. **Fleet usage load shedder**: split critical vs non-critical methods, reserve a share of fleet capacity for critical (e.g. 20%), reject non-critical beyond the rest with 503.
4. **Worker utilization load shedder**: on an overloaded machine shed lowest priority first (test traffic, then GETs, then POSTs; critical last), restore **slowly** to avoid flapping.

Safety for all four: **fail open** (limiter or Redis bug must not break the API), **kill switch** (feature flag) and alerts on trigger rate, **dark launch** (observe what it would block before enforcing), incremental rollout. Details: [references/stripe-limiters-and-load-shedding.md](references/stripe-limiters-and-load-shedding.md).

## 6. Priorities and Fairness

- Classify traffic by business criticality (payment path above listing, interactive above batch, paying tier above free, live above test).
- Reserve capacity for the critical class instead of only capping the others.
- Isolate tenants: per-tenant limits so one tenant cannot monopolize (noisy neighbour); high-value tenants may have separate queues or endpoints.
- Defer rather than reject when work is deferrable: queue with priority (`background-worker-job-scheduler`).
- Graceful degradation: switch off non-essential features before rejecting essential requests.

## 7. Rejection Contract

| Situation | Status | Required |
|---|---|---|
| Caller exceeded its rate/quota | `429 Too Many Requests` | `Retry-After`; name the limit and scope |
| Service overloaded / shedding | `503 Service Unavailable` | `Retry-After`; no blame on the caller |
| Downstream throttled you | Propagate 429/503 (do not mask as 500) | Pass the back-pressure signal upstream |

Make it actionable: which limit, remaining budget, when to retry, a rate that would succeed (optional `RateLimit-*` style headers; shape is an ecosystem convention, not read from the sources). Rejection must be cheaper than the work: reject before auth-heavy parsing, validation or DB access, and load test the rejection path.

## 8. Be Proactive, Not Just Reactive

A limiter that rejects only at 100% utilization causes a latency spike first. Start rejecting a growing fraction as utilization nears the hard limit; trigger on **p99 latency against the SLO**, not averages. Combine with autoscaling: throttle while scaling out, relax after. Keep reserve capacity if demand can outgrow scale-out speed.

## 9. Client-Side Pacing (When You Are the Caller)

Blind retry-on-reject multiplies traffic (the source's example sends 30,000 records to deliver 10,000). Instead: durable queue, workers dequeue at the budget, release in small slices (e.g. 20 ops per 200 ms for a 100/s limit), honour `Retry-After`, bounded retries with jitter, and lease capacity when several processes share one quota. Not suitable when the call must be synchronous and low latency, or when the bottleneck is concurrency. Details: [references/client-side-rate-limiting-and-capacity-leasing.md](references/client-side-rate-limiting-and-capacity-leasing.md).

## 10. Operating Rules

- Decide early; retrofitting throttling is expensive.
- Limits are runtime configuration (no redeploy during an incident).
- Review limits periodically: SLOs, dependency capacity, per-operation cost drift.
- Edge protection (DDoS, WAF) and app-level throttling are separate layers; use both.
- Metrics: allowed/rejected by limiter, principal, class; p99; saturation; retry rate. Logs name which limiter fired.
- Test overload explicitly (load test beyond limit, kill the limiter store, flip the kill switch).

## 11. Review Smells (Reject)

| Smell | Fix |
|---|---|
| Rate limit but no concurrency cap on heavy endpoint | Add in-flight limit |
| Per-replica memory counters with a promised global limit | Central/atomic or divided budget |
| 429 with no `Retry-After` or explanation | Add header and body |
| Limiter store down means API down | Fail open |
| Enforce on day one without observing | Dark launch |
| Same weight for export and read | Cost-weighted tokens |
| Shed/restore oscillation | Slow ramps, hysteresis |
| Caching presented as overload protection | Add a real limiter (`caching-strategies` for the cache side) |
| Hidden retries of downstream 429 | Propagate back-pressure |
| Limits hard-coded | Runtime config |

## Quick Decision Checklist

- [ ] Which resource saturates first, and which principal is limited?
- [ ] Algorithm chosen on purpose (token bucket default; concurrency cap for heavy endpoints)?
- [ ] Counter location, atomicity and failure mode (fail open) defined?
- [ ] Traffic classes and reserved capacity for critical work defined?
- [ ] Per-tenant isolation and cost weighting in place?
- [ ] 429/503 plus `Retry-After` and actionable message; downstream throttling propagated?
- [ ] Early shedding keyed to p99 vs SLO; cooperation with autoscaling planned?
- [ ] Kill switch, dark-launch mode, metrics and alerts present?
- [ ] Limits are runtime-configurable and reviewed periodically?
- [ ] Client-side pacing designed for batch callers of throttled services?

## Deep references

- [Throttling strategies and algorithms](references/throttling-strategies-and-algorithms.md) — read when choosing algorithms, counters, shedding thresholds, rejection codes.
- [Client-side rate limiting and capacity leasing](references/client-side-rate-limiting-and-capacity-leasing.md) — read when pacing batch/bulk calls to a throttled service or sharing its quota.
- [Stripe's four limiters and load shedding](references/stripe-limiters-and-load-shedding.md) — read when layering limiters, setting priorities, or rolling out safely.
- [Sources](references/sources.md) — retrieval status and what each source contributed.
