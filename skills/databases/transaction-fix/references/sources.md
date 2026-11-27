# Sources — Transaction fix

Every URL below was re-fetched during the rebuild (2026-11-27).

| Source | Retrieved status | What it contributed |
|---|---|---|
| PostgreSQL docs, Transactions tutorial, https://www.postgresql.org/docs/current/tutorial-transactions.html | 200 OK, read (page header: PostgreSQL 19) | All-or-nothing wording, implicit per-statement transactions, aborted state after an error, savepoints |
| PostgreSQL docs, Explicit locking, https://www.postgresql.org/docs/current/explicit-locking.html | 200 OK, read | Row locks last until transaction end and block other writers; long-open transactions discouraged |
| microservices.io, Transactional Outbox, https://microservices.io/patterns/data/transactional-outbox.html | 200 OK, read | Outbox row in the same local transaction; relay publishes at least once |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, section "2. Transação" | 200 OK, read | The four-step prompt (find multi-write operations, one-sentence inconsistency, one transaction, forced-error test) and rules (no business-rule changes, plan first, external calls outside) |
| Video "Banco de Dados / Fundamentos para Vibe Coders #EP2", https://www.youtube.com/watch?v=TL4T9ZESamI | 200 OK but text truncated: only the title was readable; channel, date and chapters not confirmed | Nothing newly verified; its scenarios (transfer, ERP sale, backend-as-a-service calls) rest on the 2026-11-24 read of a saved transcript |

## Reading limits

- No scripts or SQL files in this skill; none were run.
- Engine behavior (aborted state, implicit transactions) is verified for PostgreSQL only; MySQL, SQL Server and SQLite were not read.
- Rebuild additions from the PostgreSQL docs: the aborted-state trap and short transactions (2 additions, 0 reversals).

## Claims not adopted as fact

- "ACID's A is atomicity" and the transfer story: general knowledge, not tied to a page beyond the PostgreSQL atomicity wording.
- Backend-as-a-service claim (each API call is its own operation, bundle in a function or endpoint): the video's claim; no provider page read, so the mechanism is left to the provider's documentation.
- "Commit first, then call", "record intent inside the transaction" and "keep decision reads inside": this skill's own practice, not from a source (the outbox shape is described in the microservices.io page).
- The video's chapter times and the saved-transcript details: not re-verified.
