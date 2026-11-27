# Sources — Fundamentals audit and run order

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Fundamentos de Engenharia de Software para Vibe Coders", channel "mano deyvin", published 2026-10-27, https://www.youtube.com/watch?v=G8SeOH0qerk; whole video, with the run-order summary at about 30:07-31:16 and the framing at 0:00-2:51 | Page 200 OK; transcript read in full (local export), with a gap of about 11:33-13:21 in the idempotency chapter | The "watch first, then run" principle, the recommended run order (integration tests, client trust, race conditions, idempotency, separation), "separate branch, read what the AI delivers", and the five failure scenarios across the chapters |
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, sections "Antes de colar qualquer prompt", "A ordem que eu rodaria" and "Prompt de auditoria (os 5 de uma vez, sem alterar nada)" | Page 200 OK; handout read in full (local export) | The pre-run safety rules, the order list, the combined read-only audit prompt (five steps) and the `AUDITORIA.md` deliverable shape |
| Martin Kleppmann, https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html (cited in the handout's race-condition section) | 200 OK; read via WebFetch | Background for the audit's step on lock-based protections (see `race-condition-fix` sources) |
| Vitest guide https://vitest.dev/guide/ and Playwright https://playwright.dev/ (cited in the handout's test section) | Both 200 OK; read via WebFetch | Background for the audit's test-tool check (see `integration-tests` sources) |

## Claims and caveats

- Order discrepancy to note: the handout lists race condition and idempotency together as step 3; the video orders them separately (race third, idempotency fourth). SKILL.md follows the handout grouping.
- Handout deliverable file is named `AUDITORIA.md`; SKILL.md names it `AUDIT.md` (translated). Intentional.
- SKILL.md adds, beyond the handout prompt: the instruction to apply `database-exposure` and `security-audit`, and a pointer to `database-audit`. These are repository cross-references, not from the sources.
- SKILL.md names `EXPO_PUBLIC_` and `VITE_` prefixes; the video names `NEXT_PUBLIC_` and `VITE_`, the handout adds `EXPO_PUBLIC_`.
- Statistics and anecdotes (the low-code RLS figure, the black market for leaked keys, the mid-project productivity dip) are the video's or handout's claims and are not reproduced in SKILL.md except the leaked-key remark in `never-trust-the-client`.
- The video says no prompt is "magic" and that the reader must understand a prompt before running it; this is the author's stance and is mirrored in SKILL.md's rules.
