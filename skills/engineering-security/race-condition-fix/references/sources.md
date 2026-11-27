# Sources — Race-condition fix

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Fundamentos de Engenharia de Software para Vibe Coders", channel "mano deyvin", published 2026-10-27, https://www.youtube.com/watch?v=G8SeOH0qerk, chapter "Evitando o caos com Race Condition" (2:51-7:11) | Page 200 OK; transcript read in full (local export) | The bread-basket analogy, the stock-goes-negative walk-through, the "no Redis, no queue" stance, the three database guards (unique constraint, atomic operation, row lock) and what the prompt does (find read-then-write paths, explain the double-request outcome, fix in the database, write a simultaneous-request test) |
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "1. Race condition" and its prompt | Page 200 OK; handout read in full (local export) | The ordered preference (unique index, atomic UPDATE with affected-row check, SELECT ... FOR UPDATE), the "signs" list, the UX-only button rule, the duplicate-data cleanup rule and the "show the plan first" rule |
| Martin Kleppmann, "How to do distributed locking", https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html | 200 OK; read in full via WebFetch | Lease expiry plus process pauses, fencing tokens, the efficiency-vs-correctness split; cited by the handout and by the `## Source` note in SKILL.md |

## Claims and caveats

- Video claims (not independently verified): that a negative stock row is a reliable sign of a missing guard; that caches or queues "will not work" for this problem. The speaker states these from maintenance experience; they are opinion, not measured.
- Discrepancy: SKILL.md says Kleppmann's correct fix is "a monotonically checked token validated at the place that writes, which here is the database". The article only says the storage service must check tokens and reject writes carrying a lower one; it names ZooKeeper (`zxid` or znode version) as a token source and, for correctness locks, recommends "a database with reasonable transactional guarantees". It does not say databases check fencing tokens by default. The database guards in this skill (unique key, conditional UPDATE, row lock) apply the same idea of letting the store that holds the data arbitrate, but that mapping is the handout author's, not Kleppmann's. (resolved 2026-11-24: SKILL.md's `## Source` now points to the Kleppmann reference, which states the storage-service wording and marks the database guards as the handout's mapping)
- The article is about distributed locks between processes; it does not discuss unique constraints or `UPDATE ... WHERE qty > 0`.
- The video transcript does not mention Kleppmann; only the handout cites him.
