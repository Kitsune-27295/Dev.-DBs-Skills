# Sources — Database exposure

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Banco de Dados | Fundamentos para Vibe Coders #EP2", channel mano deyvin, published 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI — chapter 06 "A porta aberta" (24:10-26:37) | Transcript read from a saved copy; video page not re-fetched | The three closing rules (database not on the internet, service key never in the browser, grants on new tables), the three incidents, the report-first prompt |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe — section "5. A porta aberta" | Saved copy read; page not re-fetched | The audit prompt (port, secrets in front end and git, per-table access, report then fix one by one) |
| UpGuard, https://www.upguard.com/blog/everything-everywhere-systemic-data-exposure-in-supabase-apps | 200 (read through a summarizing fetch tool) | 16,326 databases, method, causes, limits |
| Wiz, https://www.wiz.io/blog/exposed-moltbook-database-reveals-millions-of-api-keys | 200 (read through a summarizing fetch tool) | Moltbook: key in client JavaScript, no RLS, about 1.5 million tokens |
| Tecnoblog, https://tecnoblog.net/noticias/fiesp-expoe-dados-pessoais/ | 200 (read through a summarizing fetch tool) | The 2018 FIESP exposure: open Elasticsearch servers, record counts |
| Supabase changelog 45329, https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically | 200 (read through a summarizing fetch tool) | The explicit-grant change and its dates |

## Claims and caveats

- UpGuard: verified 16,326 databases with readable tables, from about 300,000 domains showing signs of Supabase, probing for a `users` table. The article itself lists limits (third-party domain lists, `users`-table bias, mostly schema analysis rather than reading rows) and a commercial interest. The video also flags possible bias.
- Wiz: verified about 1.5 million agent API tokens, about 35,000 email addresses, 4,060 private conversations, write access; cause a Supabase key in client JavaScript without RLS. Disclosed 2026-01-31 and fixed within hours.
- Tecnoblog: the headline says 180 million records, but the body reports about 52 million across three databases (34,817,273 + 6,986,604 + 10,558,155); the article does not reconcile this (resolved 2026-11-24: re-fetched; headline and lede say 180 million, itemized figures sum to 52,362,032; the incidents reference now says so, citing the page). The video repeats "up to 180 million". The exposure was open Elasticsearch servers, not a Supabase or Postgres database.
- Supabase changelog: verified.

## Discrepancies with SKILL.md and the video (not edited)

- `SKILL.md` says the changelog entry is dated 28 April 2026, rolled out by project age; verified as availability date, with 30 May 2026 as default for new projects and 30 October 2026 for all existing projects. The video says "since 30 October" applies; consistent for existing projects.
- Date of the UpGuard post: the page is dated 23 September 2026; the video says "in October" (resolved 2026-11-24: re-fetched the post, date is 23 September 2026; `SKILL.md` and the incidents reference now state it).
- `SKILL.md` says "probing about 300,000 candidate domains for a `users` table"; verified.
- The video says "Moltbook, a social network of agents, in February, the Supabase key in JavaScript had no RLS rules"; the article's disclosure date is 31 January to 2 February 2026. Close enough.
