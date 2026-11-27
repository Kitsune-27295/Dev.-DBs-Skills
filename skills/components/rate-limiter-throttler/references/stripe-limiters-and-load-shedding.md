# Stripe's Four Limiters, Priorities and Rollout

Sources: https://stripe.com/blog/rate-limiters (Paul Tarjan, Stripe Engineering, 2017-03-30) · https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling · Last verified 2026-11-27

Note: figures below are as stated in the 2017 article for one month of Stripe traffic; they illustrate relative frequency, not targets. The linked implementation gist was not read.

## Why limit

Four scenarios: one user causing a spike, a misbehaving or malicious script, low-priority traffic hurting high-priority traffic, and internal failures where low-priority requests must be dropped. Rate limiting works when clients can spread requests without changing outcomes (the article says clients almost always can, even batch payment processing). Real-time events that cannot be spaced out need more capacity instead.

Distinction: a **rate limiter** decides per user; a **load shedder** decides from whole-system state during incidents to keep core functions alive.

## The four limiters (build in this order)

| # | Limiter | Rule | Observed | Notes |
|---|---|---|---|---|
| 1 | Request rate limiter | N requests/second per user (token bucket) | Rejected requests in the month described | Most important; start here. Same limits in test and live so scripts do not get surprised. Allow short bursts above the cap (flash sales) |
| 2 | Concurrent requests limiter | Cap in-flight requests per user (example 20) | About 12,000 triggers in the month | Helps CPU-heavy endpoints where users retry slow calls, piling on. May be tuned to reject more readily than the rate limiter; suits clients that fork N parallel jobs, whereas the rate limiter suits clients that back off on 429 |
| 3 | Fleet usage load shedder | Classify traffic critical (create charge) vs non-critical (list charges); count in-flight per class in a Redis cluster; reserve a fraction for critical (the article's hypothetical reservation is 20%, so non-critical beyond 80% would get 503) | Small share of requests per the article | Sheds by importance, not by user |
| 4 | Worker utilization load shedder | Track workers with spare capacity; four classes: critical methods, POSTs, GETs, test-mode traffic; when a machine is overloaded shed lowest priority first (test-mode first), restore gradually when healthy, escalate if not | Only 100 rejections in the month but sped recovery in past incidents | Final line of defense. Shed and restore slowly to avoid flapping; tuned to shed a lot within minutes |

The article lists the four classes without ranking them; it says only that test-mode traffic is shed first. Derive the rest from business impact (own inference, e.g. payment path above listing).

## Implementation facts

- Algorithm: token bucket; every user has a bucket; each request takes a token; tokens drip back over time; empty means reject. Centralized bucket in Redis (self-hosted or managed).
- Response codes: choose 429 vs 503 by situation (per-user over-rate vs system overloaded); error messages should be actionable.

## Safety practices (the transferable part)

1. **Fail open**: catch exceptions at every level; a limiter bug or Redis outage must not take the API down.
2. **Kill switches**: feature flags to disable any limiter quickly if it misfires (see `feature-flag-toggle-engine`); metrics and alerts on trigger frequency.
3. **Dark launch**: run each limiter in observation mode to see what it would block; tune thresholds so existing legitimate patterns are untouched; work with affected users to change their code.
4. **Roll out incrementally**: request rate limiter first, then the others as scale demands.

```python
def check(user):
    try:
        if not bucket(user).take():       # limiter 1
            return Reject(429, retry_after=bucket(user).wait())
        if inflight(user) >= 20:          # limiter 2
            return Reject(429, "too many concurrent requests")
        if fleet_noncritical_over_share(req) :    # limiter 3
            return Reject(503)
    except Exception:
        log.exception("limiter error")    # fail open
    return Allow()
```

## Mapping to this skill's layers

- Per-user limits sit at the edge/service; where the request first becomes attributable (`api-gateway-reverse-proxy`, `middleware-interceptor-chain`, identity from `authn-authz-guard`).
- Fleet and worker shedders sit close to the compute and read local or fleet-wide saturation.
- All of them cooperate with callers by emitting 429/503 plus `Retry-After`; callers' backoff is in `circuit-breaker-retry-telemetry`.

## Anti-patterns

- Fail-closed limiter dependent on a single Redis.
- Launching a limiter at enforcement on day one without observing it.
- Shedding and restoring fast enough to oscillate.
- Equal treatment of critical and non-critical operations.
- Different limits in test and production environments.

## How an agent should apply this

- Implement a per-principal token-bucket request limiter first, with burst allowance and identical limits across environments.
- Add a concurrency cap for expensive endpoints before adding more complex shedders.
- Define traffic classes by business criticality and reserve capacity for the critical class.
- Wrap every limiter in fail-open handling, a kill switch, metrics and a dark-launch mode.
- Make shedding stateful and slow (ramp down and up), and record which class was shed and why.
