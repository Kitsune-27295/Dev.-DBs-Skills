# Sources — Database audit

Every URL below was re-fetched on 2026-11-27 (summarizing WebFetch tool; Firecrawl unavailable).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe | 200, read 2026-11-27 | Relational vs document framing, "when in doubt, Postgres" (Supabase runs on Postgres), the run order (open port, backup, bill, then transactions/modeling/migrations, performance last), preconditions (branch, read the plan, AI never touches production), the read-only audit prompt (seven areas, risk rating, which prompt fixes each finding, where to start) |
| Video "Banco de Dados \| Fundamentos para Vibe Coders #EP2", channel mano deyvin, https://www.youtube.com/watch?v=TL4T9ZESamI | 200, but the fetched text held only the title; no channel, date or chapters | Nothing re-verified; the earlier chapter timestamps and the transcript-based claims (key-value, BaaS, 30:37 order) are unconfirmed this round |

## Reading limits

- Only the handout was read this round. Video content, publication date (earlier notes say 2026-11-12) and chapter times were not re-verified.
- No scripts or data files in this skill; nothing to re-run.

## Claims not adopted as fact

- Lesson statistics (58 ms to 0.37 ms, US$72k, 16,326 exposed databases): author's or third-party claims, never findings.
- "Postgres has a fixed price per instance": earlier text said so; no page read supports it and managed hosts can bill by usage, so it was removed.
- Redis as disposable storage, Firebase/Mongo opinions, and the key-value and BaaS rows of the choice table: video-only, labeled opinion.
- Run order differs slightly: the handout lists "transactions, modeling and migrations (prompts 2, 1 and 6)" as one block; this skill orders them as the video does (unconfirmed this round) and says so in SKILL.md.
- Seven fix prompts plus one audit prompt: the handout summary read this round shows the seven audit areas and prompt numbers 1 to 7; the "seven prompts" wording itself was not re-checked.
