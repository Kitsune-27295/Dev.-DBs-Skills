# Locks versus database guards (Kleppmann's argument)

Sources: https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html; handout section "1. Race condition" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-24

## What the article establishes

- A lock serves either efficiency (avoid duplicate work; a rare failure costs little, such as a duplicate email) or correctness (a failure corrupts data). Decide which before choosing a mechanism.
- Distributed locks are leases with a timeout. A client can pause (garbage collection, page faults, slow disk, a stopped process, delayed packets; the article cites packet delays of about 90 seconds at one company) past its lease, then resume and write believing it still holds the lock. Checking the lease just before writing does not close the gap, because the pause can happen between check and write.
- The remedy is a fencing token: a number that increases on every grant and is sent with each write; the store rejects any write with a lower token than one it has already seen. This needs the store to participate.
- Redlock (multi-node Redis locking) is criticized for lacking such tokens and for depending on bounded clocks and pauses. For efficiency-only locks the article accepts a single Redis; for correctness it recommends a consensus system or at least a database with reasonable transactional guarantees.

## How the handout uses it

The handout cites the article against "put a Redis in front to lock". Its reading: the correct fix is a check number validated where the write lands, i.e. the database. That is a fair application of the principle (writer-side arbitration) but a loose paraphrase: the article does not describe unique constraints or conditional updates. Treat the database guards as the practical equivalent, not as something Kleppmann prescribes.

## Practical contrast (own analysis)

| Approach | Failure mode |
|---|---|
| In-memory lock | Invisible to other processes or instances; lost on restart |
| Redis lock with TTL | Holder pauses past the TTL; two writers proceed unless the write itself is checked |
| `UPDATE ... WHERE qty > 0`, unique index, `FOR UPDATE` | The store holding the data decides, atomically; no lease to expire |

A cached stock read has a different flaw: it can be stale even with no pause at all.

## How an agent should apply this

- When you find a lock around a database write, ask: if the lock holder stalls, does the database still refuse the bad write? If not, add the database guard.
- Classify each lock as efficiency or correctness in the report; flag correctness locks that rely only on a TTL.
- Do not cite Kleppmann as saying databases check fencing tokens; cite him for the lease-expiry hazard.
- Recommend an external lock only when the contended resource lives outside the database, and then require token checking at that resource.
