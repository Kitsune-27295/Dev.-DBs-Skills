# Sources — Race-condition fix

Every URL below was re-fetched during the rebuild (2026-11-27).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Martin Kleppmann, "How to do distributed locking", https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html | 200 OK, read | Efficiency vs correctness locks, lease expiry with pauses, fencing tokens, Redlock critique, the 90-second packet delay, recommendations |
| PostgreSQL docs, Transaction isolation, https://www.postgresql.org/docs/current/transaction-iso.html | 200 OK, read | Read Committed: second updater waits and re-evaluates `WHERE`; Repeatable Read and Serializable raise errors (`40001`) needing retry |
| PostgreSQL docs, Explicit locking, https://www.postgresql.org/docs/current/explicit-locking.html | 200 OK, read | `FOR UPDATE` semantics: blocks other writers and lockers until transaction end, plain reads unblocked, deadlock caveat |
| PostgreSQL docs, INSERT, https://www.postgresql.org/docs/current/sql-insert.html | 200 OK, read | `ON CONFLICT` needs a unique index or constraint; `DO UPDATE` atomic outcome statement; the command tag counts rows inserted |
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "1. Race condition" | 200 OK, read | Guard order (unique index, atomic UPDATE with affected-row check, `SELECT ... FOR UPDATE`), signs, UX-only button, no new infrastructure, duplicate-data and migration rules, the simultaneous-request test |
| Video https://www.youtube.com/watch?v=G8SeOH0qerk | 200 OK but text truncated: only the title was readable | Nothing newly verified; the bread-basket story and chapter times rest on the 2026-11-24 read of a saved transcript |

## Reading limits

- No scripts in this skill; none run. SQL examples are illustrative and were not executed.
- Engine behavior is verified for PostgreSQL only; MySQL, SQL Server, SQLite and MongoDB were not read, so the skill tells the agent to confirm them.
- Rebuild changes: Read Committed re-evaluation, `ON CONFLICT` and retry-on-`40001` added from PostgreSQL docs; the "one company" packet-delay wording corrected to the GitHub incident named in the article (4 additions or corrections).

## Claims not adopted as fact

- Video claims: that a negative stock row is a reliable sign of a missing guard, and that caches or queues "will not work" here. Speaker opinion from experience; not measured. The signs list is kept as heuristics.
- The handout says Kleppmann proposes a control number checked by the database. The article only requires the storage service to check tokens; it names ZooKeeper as a token source and a database with reasonable transactional guarantees for correctness locks. The database guards in this skill are the handout's mapping, not the article's.
- The article is about distributed locks; it does not discuss unique constraints or `UPDATE ... WHERE qty > 0`.
- The video transcript does not mention Kleppmann (as of the 2026-11-24 read; not re-checked).
