---
name: background-worker-job-scheduler
description: "Design and review background workers and job schedulers: moving work off the request path, event-driven vs schedule-driven triggers, queue-based competing consumers, idempotent jobs, poison messages and dead-letter queues, graceful shutdown and checkpointing, single-instance scheduling, leader election with leases and fencing, result reporting, and scaling on queue depth. Use when adding async/batch/cron work, building a worker or consumer, preventing duplicate scheduled runs, choosing a job host, or deciding whether you need leader election."
---

# Background Worker & Job Scheduler

One idea: background work is **at-least-once, possibly overlapping, restartable execution of detached tasks**. Design for duplicates, restarts and overlap first (idempotency, checkpoints, single-run guards); throughput comes second. Sources and claims: [references/sources.md](references/sources.md).

Boundary: this skill is **async execution**. Data reuse and staleness belong to `caching-strategies`; admission control, quotas and load shedding belong to `rate-limiter-throttler` (use it to keep workers from overwhelming a throttled downstream). Retries, backoff and circuit breakers: `circuit-breaker-retry-telemetry`. Duplicate-effect prevention in depth: `idempotency-fix`. Reliable publish-after-commit and compensations: `saga-transactional-outbox-pattern`. Broker and event design: `event-driven-architecture`. Concurrent writers on shared rows: `race-condition-fix`. Process-level deployment concerns (disposability, config): `twelve-factor-cloud-native`. Multi-stage processing as filters: `pipes-and-filters-pattern`. Workflow state: `state-machine-workflow-engine`.

---

## 1. Should It Be a Background Job?

Yes when the task can finish without the user waiting and without UI interaction: thumbnails, emails, order workflows, report generation, imports, cleanup, syncs, sensitive processing moved to an isolated location. No when the caller must have the result to continue; then keep it synchronous, or use async request-reply (return an operation URL, poll) so the *user-facing contract* stays honest.

## 2. Choose the Trigger

| Trigger | Use for | Hazard | Guard |
|---|---|---|---|
| Queue message (event-driven) | Work created by user action or another job | Duplicates, reordering, poison | Idempotent handler, DLQ, max deliveries |
| Storage change / HTTP call | Integration points | Missed events | Reconciliation job |
| Timer / cron (schedule-driven) | Batch, cleanup, reports, consistency checks | Scaled-out host runs N copies; overlap if run longer than period; a skipped run raises no error | Single-run guard (section 6), idempotency, missed-schedule alert |
| One-shot delayed timer | Reminders, expiry | Lost on restart if in-memory | Persist the due time |

Bursty producers: put a queue in front (load leveling) and let workers drain at a controlled rate. Mixed importance: separate queues per priority tier.

## 3. Idempotent by Construction

Queues are at-least-once, schedulers overlap, restarts replay half-done work. Same input, same outcome, however many times.

- Give every job a stable **idempotency key** (message id or business key) and record it **in the same transaction** as the effect.
- Prefer upserts, conditional updates, set-style operations over increments and blind inserts.
- External side effects (emails, charges): pass the key downstream or log intent first, then act.
- Never rely on "exactly once" from the broker.

## 4. Competing Consumers (Scaling Out)

Run N identical consumers on one queue; each message goes to one consumer. Rules:

1. Peek-lock/visibility timeout longer than p99 processing, or renew the lock.
2. Complete only after the effect is durable; abandon on transient failure.
3. **Max delivery count then dead-letter queue**; classify permanent failures (bad payload) and dead-letter immediately; alert on DLQ depth and age.
4. Do not assume order. If order matters, carry a sequence number or use broker sessions/partition keys; prefer order-independent design.
5. Scale on **queue depth** (and age), with a hard maximum sized to downstream capacity; scale to zero if idle is common.
6. Return results by correlation id: status endpoint, reply queue, event, or webhook.

Details: [references/competing-consumers-and-poison-messages.md](references/competing-consumers-and-poison-messages.md).

## 4b. Lifecycle Rules for Any Worker

- **Graceful shutdown**: on SIGTERM stop taking work, finish or checkpoint the current item, exit; set the platform grace period above a typical item.
- **Checkpoint** long or multi-step jobs (state in storage or the message) so restarts resume.
- **Separate transient vs permanent failures**; retry only the former (policy in `circuit-breaker-retry-telemetry`).
- **Least privilege** identity per job type; keep secrets and PII out of payloads, pass reference ids.
- **Observe completion, not start**: job type, correlation id, duration, enqueue-to-completion latency, DLQ depth, missed-schedule alert.

## 5. Hosting Decision

| Need | Lean toward |
|---|---|
| Event/timer, spiky, scale to zero | Serverless functions (durable orchestration for long, stateful flows) |
| Run-to-completion batch or cron in containers | Container jobs / Kubernetes CronJob+Job |
| Continuous queue consumer | A long-running service/deployment with queue-depth autoscaling (not a one-shot job) |
| Heavy parallel compute | Managed batch/HPC pool |
| OS-level control or special runtime | VM (you own monitoring and restart) |
| Tiny add-on to an existing web app | Colocated web-app job only if lifecycle is truly shared; not for new workloads |

Separate worker deployables from the web tier when availability, security boundary, release cadence or scaling signal differ. Details: [references/background-job-design-and-hosting.md](references/background-job-design-and-hosting.md).

## 6. Single-Instance Work: Escalation Ladder

When something must not run concurrently, take the first rung that works:

1. **Make it idempotent and safe to run on every instance.** Cheapest, most robust.
2. **Platform single-run guard**: timer-trigger distributed lock, Kubernetes `concurrencyPolicy: Forbid`, job concurrency settings, single-instance flag.
3. **Lock around the critical section** (database advisory lock, optimistic/pessimistic lock) with expiry.
4. **Leader election** only when one *active coordinator* must direct others and a standby must be able to take over.

Leader election rules: use an established mechanism (ZooKeeper/etcd election, Kubernetes Lease, lease on a store) with **expiring, renewable leases**; **stop leader work when ownership is lost or cannot be confirmed**; add **fencing/ownership checks at the resource** because lease expiry does not kill the old process; test a failover time that includes detection, expiry and startup; persist coordinator state; monitor leader *progress*, not just renewal; keep the leader from being the throughput bottleneck; consider one leader per partition. Details: [references/leader-election-and-singleton-scheduling.md](references/leader-election-and-singleton-scheduling.md).

## 7. Scheduling Rules

- Store schedules and last-run state durably, not in process memory.
- Record start, end and outcome of every run; alert when an expected run did not happen.
- Handle overlap explicitly: skip, queue, or kill; never silently stack.
- Make run window and missed-run catch-up (backfill) an explicit decision.
- Use UTC internally; handle daylight-saving jumps deliberately.
- Jitter periodic jobs across a fleet to avoid synchronized spikes on a shared database (inference).

## 8. Review Smells (Reject)

| Smell | Fix |
|---|---|
| Handler not idempotent behind a queue | Idempotency key plus transactional marker |
| `cron` in every web instance | Platform guard or dedicated scheduler |
| Infinite redelivery of one message | Max delivery, DLQ, classify errors |
| Worker autoscale ignores the DB/API limit | Cap concurrency, gate with `rate-limiter-throttler` |
| Only start is logged | Log completion and failure; alert on silence |
| Leader keeps working after lease loss | Cancel on loss; fencing tokens |
| Secrets or PII in the message body | Reference id plus protected store |
| In-memory job queue for important work | Durable broker |
| Long job with no checkpoints | Persist progress; resume |

## Quick Decision Checklist

- [ ] Can the work complete without the caller waiting? If the caller needs the outcome, is there a status/event contract?
- [ ] Trigger chosen (queue, event, timer) and overlap/duplicate policy stated?
- [ ] Handler idempotent, with key stored transactionally with the effect?
- [ ] Max deliveries, dead-letter queue and DLQ alert configured? Transient vs permanent failures separated?
- [ ] Lock/visibility timeout exceeds p99 duration or is renewed?
- [ ] Graceful shutdown and checkpointing implemented?
- [ ] Scaling on queue depth with a downstream-safe maximum?
- [ ] Single-run need solved by the lowest rung of the ladder; leader election only if truly required, with fencing?
- [ ] Logs/metrics for completion, latency, missed schedules?
- [ ] Least-privilege identity; no secrets in payloads?

## Deep references

- [Background job design, triggers and hosting](references/background-job-design-and-hosting.md) — read when choosing triggers, hosts, partitioning, or reliability/observability rules.
- [Competing consumers and poison messages](references/competing-consumers-and-poison-messages.md) — read when scaling queue consumers or handling failures and ordering.
- [Leader election and single-instance scheduling](references/leader-election-and-singleton-scheduling.md) — read when work must run exactly once at a time or one coordinator is required.
- [Sources](references/sources.md) — retrieval status and what each source contributed.
