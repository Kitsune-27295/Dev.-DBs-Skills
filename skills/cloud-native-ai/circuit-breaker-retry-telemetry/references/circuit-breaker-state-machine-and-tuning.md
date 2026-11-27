# Circuit Breaker: State Machine, Counters and Tuning

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker · Last verified 2026-11-27 (source page ms.date 2025-02-05)

## Purpose and boundary with Retry

A circuit breaker is a proxy in front of a remote call that tracks recent failures and decides whether to let the call through or fail immediately. Retry assumes the next attempt will probably succeed; the breaker assumes it will probably fail and refuses to try. They compose: Retry may call through a breaker, but the retry logic must recognize the breaker's "open" exception as non-transient and stop.

The problem it solves is resource pinning. A caller with a timeout still holds a thread, connection or memory for the whole timeout; when a dependency is down, many concurrent callers pin resources and unrelated features starve. Failing fast releases them.

## States and counters

| State | Behavior | Counter | Exit |
|---|---|---|---|
| Closed | calls pass; failures counted | failure counter is **time-windowed** and resets periodically, so sporadic errors never trip it | threshold of failures inside the window -> Open, start timeout timer |
| Open | calls fail at once with an exception (or a meaningful default) | none | timer expires -> Half-Open |
| Half-Open | a **limited** number of trial calls pass | success counter of **consecutive** successes | enough consecutive successes -> Closed (reset); any failure -> Open (restart timer) |

Half-Open exists so a recovering service is not flooded the instant the timer fires. Recovery itself is external (restart, repair); the breaker only detects it.

## Tuning forces

- **Open duration too long**: errors continue after the fault is fixed. **Too short**: the breaker flaps and trial calls add latency. Match it to the realistic recovery pattern; an increasing timeout (seconds first, then minutes) is a valid adaptation.
- **Probe instead of timer**: Open can end by pinging a health endpoint or replaying a previously failed call rather than waiting blindly.
- **Failure type weighting**: the page's example requires a larger number of timeout exceptions than "service unavailable" failures before tripping; a breaker can look at the exception type.
- **Accelerated tripping**: an error response can carry enough information (for example that an overloaded shared resource wants a retry in a few minutes) for the breaker to trip at once and stay tripped for a minimum time. Reading a `Retry-After` header for this is our application of that idea.
- **Resource differentiation**: one breaker per independent backend (shard, tenant, region), never one for a whole logical service, or one sick shard blocks healthy ones.
- **Manual override**: when recovery time is highly variable, expose force-open and force-close controls.
- **Concurrency**: many instances share the breaker; its bookkeeping must not serialize calls.
- **Failed request replay**: while Open, requests may be journaled and replayed later instead of dropped.
- **Long external timeouts**: a breaker cannot save you if each call blocks for a long timeout before counting as a failure; shorten timeouts and add a bulkhead.
- **Adaptive thresholds**: the page notes that static counts are deterministic but sometimes suboptimal and that AI or ML-adjusted thresholds can improve resiliency (treat as optional, not baseline).
- **Multiregion and mesh**: the page also covers region-aware breaking through global load balancers, and service-mesh sidecars that break circuits without code changes.
- **Monitoring**: the page asks for visibility into failed and successful requests and suggests distributed tracing; a state-change event per transition is a good alert source.

## When not to use

- Local in-memory resources (pure overhead).
- As a substitute for business-logic exception handling.
- When dependencies already handle retries well and the breaker only adds complexity.
- Message/event-driven flows where dead-letter queues already isolate failures.
- When the platform (service mesh sidecar, global load balancer health checks) already breaks circuits.
- When waiting for a reset would add unacceptable delay.

## Example: pseudo-code

```
call(op):
  if state == OPEN:
      if now < reopenAt: return fallback() or raise CircuitOpen
      state = HALF_OPEN; trial = 0
  try:
      r = op(timeout=connect+request)
      if state == HALF_OPEN and ++trial >= N: state = CLOSED; failures.reset()
      return r
  except Transient:
      failures.add(now)            # sliding window
      if state == HALF_OPEN or failures.count(window) >= T:
          state = OPEN; reopenAt = now + backoffOpen()
      raise
```

The Azure worked example guards a free-tier database that answers 429 when quota is exceeded: the first 429 opens the breaker, requests return cached/default data with a user-visible notice, an alert tells operators to add capacity, and a timed Half-Open probe restores service.

## How an agent should apply this

- Place breakers per dependency partition, emit an event on every state transition, and alert on Open.
- Make Retry treat the breaker-open exception as terminal, and always define the Open-state behavior (fallback, cached value, or explicit error).
- Reject breakers around local calls and around queue consumers that already have a DLQ.
- Pair a breaker with short timeouts; reject designs that rely on the breaker to cope with 60-second timeouts.
- Prefer a probe or capped Half-Open trial count over letting all traffic through at timer expiry.
