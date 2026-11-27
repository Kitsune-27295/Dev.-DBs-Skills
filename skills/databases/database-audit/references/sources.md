# Sources — Database audit

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Banco de Dados | Fundamentos para Vibe Coders #EP2", channel mano deyvin, published 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI — chapter 01 "Qual banco usar" (02:07-06:25) and closing chapter "A ordem que eu rodaria" (30:37-end) | Transcript and chapter list read from a saved copy; the video page itself was not re-fetched | The relational vs document vs key-value vs backend-as-a-service framing, the "when in doubt, Postgres" default, and the run order |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe — sections "Qual banco usar", "A ordem que eu rodaria" and "Prompt de auditoria (raio X geral)" | Saved copy read; page not re-fetched | The read-only audit prompt (seven checks, risk rating, which prompt fixes each finding) and the five-step run order |

No external page is cited for this topic: the lesson's claims about database choice are the author's opinion, not sourced.

## Claims and caveats

- The video's choice guidance (analogies, "do not use Mongo where you do not need it", "Firestore is a problem") is opinion. The reference file presents it as the author's stance with trade-offs added as marked inference.
- Run order differs slightly between sources. Video (30:45 onward): door closed, backup, spend limit, transaction, constraints, migrations, performance last. Handout: door, backup, bill, then "transaction, modeling and migrations (prompts 2, 1 and 6)", then performance. `SKILL.md` follows the video order (transaction, schema, migrations); no conflict, but the handout's grouping lists them as a block.
- The video says the handout holds "seven prompts"; the handout has seven fix prompts plus the general audit prompt. `SKILL.md` is consistent with this.
- Numbers quoted in the lesson (58 ms to 0.37 ms, US$72k, 16,326 databases) are not claims of this skill; see the sibling skills' sources for what was verified.
- Discrepancies between sources and `SKILL.md`: none found for this skill.
