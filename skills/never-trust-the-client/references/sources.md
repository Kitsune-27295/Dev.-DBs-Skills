# Sources — Never trust the client

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Fundamentos de Engenharia de Software para Vibe Coders", channel "mano deyvin", published 2026-10-27, https://www.youtube.com/watch?v=G8SeOH0qerk, chapter "Por que você não deve confiar no usuário" (13:26-20:32) | Page 200 OK; transcript read in full (local export), apart from a gap before 13:26 that belongs to the previous chapter | The DevTools price-tampering example (79 to 1), "recompute on the server", public vs secret keys, the `NEXT_PUBLIC_` / `VITE_` prefix warning, per-user data access (orders filtered by the authenticated user), and what the prompt does (move rules, hunt leaked keys, explain policies in plain language, produce a report) |
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "3. Nunca confie no cliente" and its prompt | Page 200 OK; handout read in full (local export) | The checklist: client-only rules, secret classification with the `EXPO_PUBLIC_` prefix, RLS review steps (a to e), report columns, report-first then one-fix-at-a-time with separate migrations, never disabling existing protections |

## Claims and caveats

- Statistic: the video says "170 of 1,645" low-code apps had broken row-level security; the handout attributes it to a named researcher analyzing apps built on one low-code platform, looking only at the landing page. Both are the author's citations; the underlying study was not opened. SKILL.md does not repeat the figure.
- The video claims bots scan for leaked LLM keys and that a black market resells them; plausible but stated without a source. SKILL.md repeats it as fact ("bots hunt because leaked paid keys are resold"); flagged here. (resolved 2026-11-24: SKILL.md now words it as "reportedly" and "can be resold")
- The video says an unauthenticated call to the filtered query "returns 500"; the handout does not. SKILL.md says "fails with an error"; consistent in substance.
- Items in SKILL.md not found in the video or handout: step 4's IDOR check on every by-id access and rate limits against id enumeration, and step 5 (input validation, output escaping, upload checks). They are the skill author's additions (the video covers the list-by-owner part only); they are common practice but not sourced here. (left as is: SKILL.md never presents them as the video's; they stay marked here as the skill's own guidance)
- The video's remark that AI models may skip server recomputation unless told is the speaker's observation.
- No external pages are cited for this topic.
