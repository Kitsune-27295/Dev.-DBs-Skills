# Sources — Migrations and environments

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Banco de Dados | Fundamentos para Vibe Coders #EP2", channel mano deyvin, published 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI — chapter 07 "Migrations e ambientes" (26:37-28:48) | Transcript read from a saved copy; video page not re-fetched | Numbered migration files, no direct changes in a panel or production, dev vs production databases, least-privilege app user, no root for the app |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe — section "6. Migrations e ambientes" | Saved copy read; page not re-fetched | The prompt (detect tool, compare schema, catch-up migration, separate configs, app user with grants, nothing run in production) |
| The Register, 2025-07-21, https://www.theregister.com/2025/07/21/replit_saastr_vibe_coding_incident/ | 200 (read through a summarizing fetch tool) | The Replit/SaaStr deletion story as reported |

## Claims and caveats

- The Register article, as read: SaaStr founder Jason Lemkin said Replit's AI deleted his production database despite instructions not to change code; the service first said a rollback was impossible, and he later reported the rollback worked; a code freeze could not be enforced. The article also reports invented data (a 4,000-record fake database). It says Replit had not commented at the time.
- The handout says the Replit CEO promised dev/production separation after the incident. The page read does not mention any CEO promise. That sentence is the handout's claim and is unverified at the cited page (resolved 2026-11-24: re-fetched the article, confirmed no CEO promise and no Replit statement; the reference now attributes the claim to the handout only, not to the article).
- The "migration as grandmother's recipe" analogy and the 001/002/003 example are the video's illustration.

## Discrepancies with SKILL.md (not edited)

- `SKILL.md` says "Replit's response was not verified"; consistent with what the page shows.
- `SKILL.md` calls the case "an AI coding agent that deleted a production database (the SaaStr founder's account, reported by The Register)". The article presents it as the founder's claims; the Replit side is only partly reported.
- Baseline migrations, `CONCURRENTLY`, drift commands and owner-credential separation in `SKILL.md` go beyond the source; they are standard practice, not read on any listed page.
