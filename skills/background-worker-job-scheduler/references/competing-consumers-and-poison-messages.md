# Competing Consumers, Message Handling and Poison Messages

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/competing-consumers · https://learn.microsoft.com/en-us/azure/architecture/best-practices/background-jobs · Last verified 2026-11-23

## The pattern

Many consumer instances read from one queue; each message goes to exactly one consumer. The queue is both the channel and a buffer, so any application instance can feed any consumer and a failed consumer blocks no producer. Contrast with publish-subscribe, where every subscriber gets every message.

Benefits: load leveling (bursts absorbed by the queue; a long task does not block others), reliability (no message pinned to a failed instance), no complicated coordination between consumers, scaling (autoscale on queue depth, down to zero), and transactional reads: a message read in a transaction returns to the queue if the consumer fails.

Use when: work divides into independent, parallel, asynchronous tasks; volume is variable; high availability matters. Avoid when: tasks are tightly dependent, must be synchronous with the caller, or must run in a strict sequence.

## Lock-and-settle flow (peek-lock style)

1. Consumer receives the message; broker hides it (visibility timeout or lock).
2. Consumer processes it.
3. Success: complete/delete. Failure: abandon, so it reappears. Long work: renew the lock, or it reappears while still running and a second consumer duplicates it.
4. After a max delivery count, the broker dead-letters it.

```python
def consume(msg):
    try:
        handle(msg)               # idempotent
        msg.complete()
    except TransientError:
        msg.abandon()             # redeliver, count increments
    except PermanentError as e:
        msg.dead_letter(reason=str(e))   # no point retrying
```

## Design considerations from the sources

| Concern | Rule |
|---|---|
| Ordering | Not guaranteed; arrival order differs from creation order. Make handlers idempotent and order-independent; where order is unavoidable use a sequence number/key, or broker sessions that route a group to one consumer |
| Resiliency | Failed instances get restarted and messages reprocessed; operations must be idempotent |
| Poison messages | A malformed message or unavailable dependency can fail forever, blocking the consumer, the queue and eventually the app. Cap deliveries; move to a dead-letter queue; capture details for analysis |
| Results | Producer and consumer are decoupled; return results via shared storage or a reply queue with correlation id, and signal completion so callers never read partial data |
| Queue scale | One queue can become the bottleneck; partition producers to queues or spread across several queues |
| Messaging reliability | Use a broker that never loses a message once accepted; at-least-once delivery is the contract |

## Transient vs permanent failure

Transient (timeout, downstream throttling): let the queue redeliver, with backoff (see `circuit-breaker-retry-telemetry`). Permanent (bad payload, missing referenced record): dead-letter immediately rather than burning retries. Monitor dead-letter depth and age; failed work accumulates silently otherwise. Resubmit after fixing the cause.

## Fair concurrency and downstream protection

More consumers only help while downstream capacity exists. Cap max concurrency per consumer and per fleet, and if the downstream is throttled, gate consumers through a rate limiter or capacity lease (see `rate-limiter-throttler`). Priority: separate queues per priority tier (priority-queue pattern) so low-value work cannot starve urgent work. Own inference: size prefetch/batch counts to lock duration so locks do not expire mid-batch.

## Anti-patterns

- Non-idempotent handler on an at-least-once queue.
- Infinite redelivery of a message that always fails.
- Lock shorter than processing time and no renewal.
- Assuming FIFO across parallel consumers.
- Putting sensitive data in the payload instead of a reference id.
- Auto-scaling consumers without checking the database or API they call.

## Relationship to neighbors

Reliable publication of the message after a DB commit is the outbox problem: `saga-transactional-outbox-pattern`. Broker topology, events vs commands: `event-driven-architecture`. Race conditions between consumers touching the same row: `race-condition-fix`.

## How an agent should apply this

- Verify the queue guarantees, set a max delivery count and a dead-letter queue, and add an alert on DLQ depth/age.
- Make every handler idempotent before enabling more than one consumer.
- Classify exceptions into transient vs permanent and route accordingly.
- Choose lock/visibility duration above p99 processing time or implement renewal.
- Scale on queue depth with a hard max that respects downstream limits.
