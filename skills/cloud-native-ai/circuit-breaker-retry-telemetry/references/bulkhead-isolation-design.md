# Bulkhead Isolation: Partitioning Consumers and Services

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead · Last verified 2026-11-27 (source page ms.date 2026-03-19)

## Problem

Two failure shapes share one cause, a shared resource pool:

1. **Consumer side**: a client calls services A, B and C through one connection/thread pool. A hangs, requests to A pile up and consume the pool, and calls to B and C now fail too.
2. **Service side**: one noisy consumer exhausts a service's capacity, so other consumers are starved, producing cascading failure.

## Solution

Partition so that failure or load in one partition cannot consume another's resources (also called cell-based architecture).

- **Consumer bulkheads**: a separate connection pool, thread pool or semaphore per downstream service. A failing service only saturates its own pool. Libraries named by the source: Resilience4j and Polly.
- **Service bulkheads**: group service instances by consumer class or SLA, e.g. a premium consumer gets its own instances; each of three clients gets its own instance so one flood is contained.
- **Messaging**: isolate by queue; each queue has dedicated workers, or a shared worker group with a dequeue-and-dispatch policy.

Benefits: containment of cascades, partial functionality during outages, and differentiated quality of service (high-priority consumers bound to high-priority services). The security pillar adds that segmentation also confines an incident to the compromised cell.

## Design decisions

| Decision | Guidance from the source |
|---|---|
| Where to draw lines | business and technical requirements; with tactical DDD, align to bounded contexts |
| Isolation mechanism | consumers: processes, thread pools, semaphores; services: separate VMs, containers or processes (containers are a good isolation/overhead balance) |
| Granularity | e.g. one tenant per partition or several tenants per partition; finer is safer but costlier |
| Cost | isolation lowers resource efficiency; weigh against manageability |
| Observability | monitor each partition's performance against its SLA |
| Platform controls | use built-in rate limits, RU isolation, container resource limits instead of rebuilding them in code |
| AI/inference | deployment quotas and concurrency limits call for strict bulkheads per workload or tenant |

## When to avoid

Skip it when the efficiency loss is unacceptable or the added complexity is unneeded, for example a single low-traffic dependency with no shared pool contention.

## Example (Kubernetes isolation, adapted)

```yaml
containers:
- name: drone-management
  resources:
    requests: {memory: 64Mi, cpu: 250m}
    limits:   {memory: 128Mi, cpu: "1"}
```

A bounded in-process analogue (our sketch, not from the source):

```
pools = {"payments": Semaphore(20), "search": Semaphore(50)}
def call(dep, fn):
    if not pools[dep].acquire(blocking=False): raise BulkheadFull(dep)
    try: return fn()
    finally: pools[dep].release()
```

## Composition

Bulkhead bounds concurrency, Timeout bounds duration, Retry handles transients, Circuit Breaker stops hopeless calls, Fallback handles the user-visible result. The source recommends combining bulkheads with retry, circuit breaker and throttling for richer fault handling.

## How an agent should apply this

- Identify every shared pool (HTTP client, DB pool, worker threads) and ask which dependency can starve it.
- Give each slow-prone dependency its own bounded pool or semaphore, and reject on full rather than queue unboundedly.
- Size partitions from SLAs and expose per-partition saturation metrics.
- Prefer platform quotas (API gateway, Kubernetes limits) over bespoke code.
- Do not partition everything by default; justify each bulkhead by a named failure scenario.
