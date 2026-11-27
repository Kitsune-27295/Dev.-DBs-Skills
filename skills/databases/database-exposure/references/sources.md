# Sources — Database exposure

Every URL below was re-checked on 2026-11-27 (fetched through a summarizing fetch tool; the page text was not read in full).

| Source | Retrieved status | What it contributed |
|---|---|---|
| UpGuard, https://www.upguard.com/blog/everything-everywhere-systemic-data-exposure-in-supabase-apps | 200 | 16,326 databases, method, percentages, causes, limits |
| Wiz, https://www.wiz.io/blog/exposed-moltbook-database-reveals-millions-of-api-keys | 200 | Moltbook timeline, counts, cause, recommendations |
| Tecnoblog, https://tecnoblog.net/noticias/fiesp-expoe-dados-pessoais/ | 200 | FIESP: open Elasticsearch servers, counts, dates |
| Supabase changelog 45329, https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically | 200 | Rollout dates, affected and unaffected, grant guidance |
| Supabase RLS guide, https://supabase.com/docs/guides/database/postgres/row-level-security (added 2026-11-27) | 200 | Policy `to` rule, anon/authenticated, secret key bypass |
| Firebase insecure rules, https://firebase.google.com/docs/firestore/security/insecure-rules (added 2026-11-27) | 200 | `allow read, write: if true` flagged; fixes |
| PostgreSQL pg_hba.conf, https://www.postgresql.org/docs/current/auth-pg-hba-conf.html (added 2026-11-27) | 200 | `trust` meaning; loopback default for `listen_addresses` |
| Video "Banco de Dados / Fundamentos para Vibe Coders #EP2", mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI | Page content truncated; only the title was confirmed | Lesson framing (chapter 06); transcript from an earlier saved copy |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe | 200, section "The open door" re-read | The audit prompt (port, secrets, per-table access, report then fix) |

## Corrections made on 2026-11-27

1. Supabase: the old text said "rolled out by project age"; the changelog gives dates (28 April opt-out, 30 May default for new projects, 30 October existing projects). Fixed.
2. UpGuard: added the 9.7% hard-credential share, the Table Editor versus API distinction and its limits.
3. Wiz: email figures differ between summary and body; fixed with exact timeline. "Within a few hours" confirmed (21:48 to about 01:00 UTC).
4. Tecnoblog: the 52,362,032 sum was re-confirmed; added dates.
5. Supabase RLS rules for `to` clause and anonymous sign-ins added; duplicate RLS explanation replaced by a pointer to `security-audit`.

## Reading limits

Pages were read through a summarizing tool, so exact wording was not checked. The video page returned only a title. The video chapter timings (24:10-26:37) were not re-verified. The claim that the Table Editor enables RLS by default rests on UpGuard alone; the Supabase RLS guide does not mention it.

## Claims not adopted as fact

- Any percentage from UpGuard applied to a specific app.
- The video's "up to 180 million" FIESP figure (page itemizes about 52 million).
- Time-limited Firebase test-mode rules (the page read does not cover them).
