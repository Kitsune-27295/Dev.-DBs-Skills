# Leader Election and Single-Instance Scheduling

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/leader-election · https://learn.microsoft.com/en-us/azure/architecture/best-practices/background-jobs · Last verified 2026-11-23

## Problem

Peer instances run the same code. Occasionally exactly one must coordinate: aggregate results of parallel work, run a non-idempotent scheduled task, own a shared resource, or assign partitions. No natural leader exists, so elect one, and make sure two instances never believe they lead at once.

## Mechanisms

| Mechanism | Notes |
|---|---|
| Race for a distributed mutex/lease | First to acquire leads; lease must expire if the leader dies. Adds a dependency (single point of failure: if the lock service is down, no election) |
| Coordination service/library | ZooKeeper with Curator recipes, etcd election API. Prefer established implementations over a custom algorithm |
| Kubernetes `Lease` objects | For controller-style workloads already on Kubernetes |
| Blob lease (cloud sample) | A blob with an exclusive timed lease; leader keeps renewing; others poll |

## Leader lifecycle

1. Candidates try to acquire the lease/lock; losers wait and retry.
2. Winner starts leader work and a renewal loop (heartbeat) before expiry.
3. If renewal fails or ownership cannot be confirmed, the leader **stops leader work** at once.
4. Others notice via polling/heartbeat expiry and elect a new leader.

```python
while not shutdown:
    lease = store.try_acquire("leader", ttl=30)       # returns token or None
    if not lease:
        sleep(5); continue
    with cancel_on_lost(lease, renew_every=10) as cancel:
        run_leader_work(cancel, fencing_token=lease.token)
    # leaving the block = leadership lost or voluntarily released
```

## Issues from the pattern page (and what to do)

- Lease expiry does not stop the old process. A delayed renewal can leave the old leader running after a new one is elected. Use **resource-side ownership checks** (fencing tokens: the target rejects writes carrying an older token) and idempotent operations so replayed work is harmless. The sample the page uses does not demonstrate fencing, so you must add it.
- Define and test a failover target: failure detection plus lease expiry plus retry delays plus new-leader startup. Do not assume immediate takeover (the example blob lease may take up to a minute to become acquirable after expiry).
- Monitor leader progress as well as lease renewal: a stalled leader can keep renewing and block takeover. Cancel leadership if work stops advancing.
- Persist coordination state (task assignments, partial results, checkpoints) in durable shared storage so a new leader can resume.
- On scale-in, checkpoint or stop leader work before voluntarily releasing.
- Keep the leader from becoming a bottleneck: it coordinates; every instance should still do normal work when not leader.
- For independent partitions, elect a leader per partition (separate election scope each) to spread coordination.
- Telemetry: record acquisition, loss, voluntary release; track leaderless duration, election frequency, renewal failures; alert when leaderless time exceeds the failover target or pending work stops progressing.
- Least privilege: scope roles to only the coordination resource; pre-create it with a separate deployment identity.
- Election is nondeterministic: never assume which instance wins.

## When leader election is the wrong tool

- A natural singleton exists (one dedicated process that can be restarted if unhealthy).
- You only need exclusive access to a shared resource: use optimistic or pessimistic locking instead.
- The job can be made idempotent and safe to run concurrently: then run it on every instance (cheapest, most robust).
- The scheduler is a platform feature: use a timer trigger with its built-in distributed lock, a Kubernetes CronJob with `concurrencyPolicy: Forbid`, a Container Apps job concurrency limit, or a single-instance web job flag.

Decision rule (own inference): prefer, in order, idempotent-everywhere, platform single-run guard, lock-around-the-critical-section, then full leader election.

## Anti-patterns

- Hand-rolled election with a plain database row and no expiry.
- Leader work continuing after renewal failure.
- No fencing, so a zombie leader corrupts shared state.
- Leader that does all the work and caps throughput.
- Treating "I held the lock when I started" as "I hold it now".

## How an agent should apply this

- First try to eliminate the need: make the task idempotent or use a platform guard; only then add election.
- When election is needed, use an existing library/service (ZooKeeper, etcd, Kubernetes Lease), with TTL-based leases and a renewal loop that cancels leader work on failure.
- Add fencing tokens or resource-side checks and idempotent leader operations.
- Document the failover target and alert on leaderless time.
- Persist leader state so a successor can resume.
