# Sources — Transaction fix

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Banco de Dados | Fundamentos para Vibe Coders #EP2", channel mano deyvin, published 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI — chapter 03 "Transação" (11:46-15:50) | Transcript read from a saved copy; video page not re-fetched | The transfer scenario (debit, credit, crash), begin/commit/rollback, the "separate API calls" risk on backend-as-a-service, the ERP sale example, "wrap, do not change business rules", ORMs not adding transactions unprompted |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe — section "2. Transação" | Saved copy read; page not re-fetched | The prompt (find multi-write operations, state what breaks, merge into one transaction, forced-error test, external calls outside the transaction) |

No external web page is cited for this topic.

## Claims and caveats

- The "ACID" remark (atomicity is the A) is general database knowledge stated by the video; no page was read for it.
- The Supabase remark (three separate API calls are not atomic; a database function or one server endpoint can bundle them) is the video's claim; it matches how HTTP-based table APIs work (inference: each call is its own transaction), but no Supabase page was read for it.
- The video's example SQL uses an informal `saldo` update; treat it as an illustration, not a pattern to copy.

## Discrepancies with SKILL.md (not edited)

- The handout prompt says external calls (email, payment gateway) stay outside the transaction; the video does not mention this at all. `SKILL.md` follows the handout. The advice to "commit first, then call" or record intent inside the transaction (an outbox-style pattern) is `SKILL.md`'s own addition, not from either source.
- `SKILL.md` adds "keep reads that decide the outcome inside it"; neither source says this.
