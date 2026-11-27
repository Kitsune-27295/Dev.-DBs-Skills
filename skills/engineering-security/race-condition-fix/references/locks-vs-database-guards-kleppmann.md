# Locks versus database guards (Kleppmann's argument)

Sources: https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html; handout section "1. Race condition" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-27

## What the article establishes

- A lock serves either efficiency (a failure only means duplicated work, such as a duplicate email) or correctness (a failure corrupts data). Decide which before choosing a mechanism.
- Distributed locks are leases with a timeout. A client can pause (stop-the-world garbage collection, page faults, CPU contention, SIGSTOP) past its lease, resume and write believing it still holds the lock. Checking the lease just before writing does not close the gap, because the pause can fall between check and write. The article also cites a GitHub incident where packets were delayed about 90 seconds.
- The remedy is a fencing token: a number that strictly increases on every grant and is sent with each write; the storage service remembers the highest token seen and rejects lower ones. ZooKeeper's `zxid` or znode version can serve as the token. This needs the store to participate.
- Redlock (multi-node Redis locking) is criticized for producing no such tokens and for safety that depends on bounded network delay, bounded pauses and accurate clocks. The article calls it neither fish nor fowl: too heavy for efficiency locks, not safe enough for correctness.
- Recommendation: efficiency-only locks can use a single Redis instance and be documented as approximate; correctness locks need a consensus system such as ZooKeeper, or at least a database with reasonable transactional guarantees, plus token checks at the resource.

## How the handout uses it

The handout cites the article against "put a Redis in front to lock" and reads it as: the correct fix is a check number validated where the write lands, i.e. the database. That is a fair application of the principle (writer-side arbitration) but a loose paraphrase: the article does not describe unique constraints or conditional updates. Treat the database guards as the practical equivalent, not as something Kleppmann prescribes.

## Practical contrast (own analysis)

| Approach | Failure mode |
|---|---|
| In-memory lock | Invisible to other processes or instances; lost on restart |
| Redis lock with TTL | Holder pauses past the TTL; two writers proceed unless the write itself is checked |
| `UPDATE ... WHERE qty > 0`, unique index, `FOR UPDATE` | The store holding the data decides, atomically; no lease to expire |

A cached stock read has a different flaw: it can be stale with no pause at all.

## How an agent should apply this

- When you find a lock around a database write, ask: if the holder stalls, does the database still refuse the bad write? If not, add the database guard.
- Classify each lock as efficiency or correctness in the report; flag correctness locks that rely only on a TTL.
- Cite Kleppmann for the lease-expiry hazard and fencing tokens, not as saying databases check tokens.
- Recommend an external lock only when the contended resource lives outside the database, and then require token checking at that resource.
