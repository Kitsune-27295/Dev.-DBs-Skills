# Background Job Design, Triggers and Hosting

Sources: https://learn.microsoft.com/en-us/azure/architecture/best-practices/background-jobs · Last verified 2026-11-23

## When something is a background job

The main criterion: it can run without user interaction and the UI need not wait. Job kinds: CPU-bound, I/O-bound, batch (nightly), long-running workflows (order fulfilment, provisioning), and sensitive-data processing moved to a more secure isolated location. Keep interactive latency low by moving the work out of the request.

## Triggers

| Trigger | Mechanism | Typical work |
|---|---|---|
| Event-driven | Message in a queue; storage change; HTTP call to an endpoint | Image processing, emails, remote calls, provisioning |
| Schedule-driven | Timer in the app/OS, external scheduler calling an API, one-shot delayed timer | Batch routines, index updates, reports, retention cleanup, consistency checks |

Bursty queue input: use queue-based load leveling so the queue buffers and workers drain at a controlled rate. Important tasks: priority queue.

Schedule hazards (from the article): scaling the scheduler host creates several schedulers that start duplicate runs, and a run longer than the period overlaps the next. Mitigate with idempotent jobs plus a single-run guard (distributed lock, Kubernetes `concurrencyPolicy: Forbid`, Container Apps job concurrency, Functions timer distributed lock, WebJob `is_singleton`).

## Returning results

Ideal job is fire-and-forget. If the caller needs outcome: status endpoint + polling (async request-reply), reply queue (correlation id), event on completion, webhook callback, or status written to shared storage. Pick polling endpoints for HTTP APIs, events/webhooks for external or decoupled callers.

## Idempotency (non-negotiable)

Queues deliver at least once, schedulers overlap, restarts replay partial work. Same input must yield the same outcome when run twice: use a natural or generated idempotency key stored with the effect, upsert instead of insert, conditional updates, or a processed-message table. Deep dive: `idempotency-fix`.

```python
def handle(msg):
    if processed.exists(msg.id):          # dedupe key
        return ack(msg)
    with db.transaction():
        apply_effect(msg)                 # effect and marker commit together
        processed.add(msg.id)
    ack(msg)
```

## Hosting options (decision table)

| Host | Fits | Watch out |
|---|---|---|
| Serverless functions | Event/timer triggers, scale to zero; durable orchestration for long workflows (chaining, fan-out/fan-in, async HTTP API, human approval, monitor) | Pick plan by volume and cold-start needs; activities must be idempotent |
| Container jobs (run-to-completion; manual, cron or event triggered, KEDA scaling) | Batch, scheduled, event-driven discrete work | You maintain images; continuous consumers should be an app, not a job |
| Kubernetes Jobs/CronJobs (+ KEDA) | Need K8s API/control plane | Cluster ops burden |
| Managed batch compute | Large parallel/HPC workloads | Pool allocation latency vs idle nodes |
| Virtual machines | Full OS control, Windows services, special runtimes | You build monitoring and restart; higher cost |
| Web-app-attached jobs (WebJobs) | Existing web app needing colocated work | Shares compute with the app; not advised for new workloads |

Principle (own inference, generalizing the table): choose the lightest host that gives the trigger type, scaling signal and isolation you need; keep stack-specific names out of the job logic.

## Partitioning: same instance or separate?

Compare availability (queued work tolerates brief outage), recovery, security boundary (tighter network/credentials), manageability (separate release cadence), scalability (queue depth vs request rate). Separate compute costs money; weigh against independent scaling and failure isolation.

## Conflicts

Multiple job instances contend for databases/storage. Options: pessimistic locking; singleton execution (kills the reliability/throughput benefit of multiple instances); or partition the work. Ensure restart-on-failure and capacity for peaks.

## Coordination of multi-step jobs

Four building blocks: discrete steps joined by queues (pipes and filters; see `pipes-and-filters-pattern`), an orchestrator for sequencing/timeouts/progress (scheduler agent supervisor), compensating steps for failures (`saga-transactional-outbox-pattern`), and leader election when one active coordinator is required (see `leader-election-and-singleton-scheduling.md`).

## Reliability, security, observability, scaling

- Checkpoint long jobs (state in storage or message) so they resume, not restart. Shut down gracefully on SIGTERM: stop taking work, finish or checkpoint, exit; set the platform grace period (e.g. `terminationGracePeriodSeconds`) above a typical item duration.
- Separate transient from permanent failures: retry transient (timeouts, throttling), dead-letter permanent (malformed payload) immediately.
- Least privilege per job identity; put references, not secrets/PII, in messages.
- Log start, completion and failure with a correlation id and duration; alert on missed schedules (nothing ran, so no error exists), on dead-letter depth/age, and on enqueue-to-completion latency, not just processing time.
- Scale on queue depth, not CPU alone; scale to zero for intermittent work; scale the whole pipeline (broker throughput, database, downstream rate limits) rather than workers only.

## Anti-patterns

- Job that is not idempotent behind an at-least-once queue.
- Timer in every web instance with no single-run guard.
- Unbounded retry of permanent failures (poison loop).
- Monitoring only job start.
- Scaling workers past what the database or downstream API accepts (pair with `rate-limiter-throttler`).

## How an agent should apply this

- Classify the work (event vs schedule, short vs long, needs result?) before choosing a host; state the trigger and the single-run policy.
- Write the idempotency key and dedupe store in the design before writing the handler.
- Add graceful-shutdown handling, a dead-letter path, and a missed-schedule alert as part of "done".
- Return results via an explicit mechanism (status endpoint or event), not by having the UI wait.
- Use a separate deployable and identity for workers unless colocating is justified.
