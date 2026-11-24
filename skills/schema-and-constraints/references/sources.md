# Sources — Schema and constraints

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Banco de Dados | Fundamentos para Vibe Coders #EP2", channel mano deyvin, published 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI — chapter 02 "Modelagem e constraints" (06:25-11:46) | Transcript read from a saved copy; video page not re-fetched | Primary and foreign keys, float vs numeric for money, timestamp with zone, the four constraints, "validate in the back end too", the prompt's "never delete data to pass a constraint" rule |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe — section "1. Modelagem e constraints" | Saved copy read; page not re-fetched | The schema review prompt (list columns, missing foreign keys, equivalent constraints, count violating rows first, one migration per subject) |
| PostgreSQL wiki "Don't Do This", https://wiki.postgresql.org/wiki/Don%27t_Do_This | 200 (read through a summarizing fetch tool) | `money`, `timestamp` vs `timestamptz`, `char(n)`, `varchar(n)`, `serial`, `NOT IN`, `BETWEEN` on timestamps |
| PostgreSQL docs "Constraints", https://www.postgresql.org/docs/current/ddl-constraints.html | 200 (read through a summarizing fetch tool) | Each constraint type, which ones create an index, foreign key actions |

## Claims and caveats

- `0.1 + 0.2 = 0.30000000000000004` is floating-point behavior stated by the video and handout. The wiki page, as read, does not discuss `float`; it warns against `money`. The `float` rule is therefore the lesson's claim backed by general knowledge, not by that page (resolved 2026-11-24: re-read the wiki, confirmed it has no float section; `SKILL.md` now labels the `float` rule as the skill's own guidance and no longer credits the wiki for it).
- The video says to store dates in "timestamp Z", meaning `timestamptz`. The wiki confirms `timestamptz` for points in time and says `timestamp(0)` style rounding and `BETWEEN` on timestamps are traps.
- Video example (Manaus order at 11 pm landing on the next day in a report) is illustrative, not from a source.

## Discrepancies with SKILL.md (not edited)

- (resolved 2026-11-24: re-read the wiki; its "When should you?" text allows plain `timestamp` for timestamps handled in an abstract way or just saved and retrieved, with no arithmetic. `SKILL.md` no longer says "never compared", which the page does not state; the page allows UTC values in it only when compatibility with non-timezone databases trumps all else.)
- `SKILL.md` says `foreign key` and `check` can be added `NOT VALID` and validated later. That is standard PostgreSQL behavior but is not in the constraints page as summarized here; marked as not read from source.
- The video presents the prompt as covering "not null, unique, check"; the handout prompt names foreign keys too. No conflict.

## Added 2026-11-24

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.postgresql.org/docs/current/ddl-identity-columns.html | 200 (summarizing fetch tool) | identity semantics; no serial comparison on the page (added 2026-11-24) |
| https://www.postgresql.org/docs/current/datatype-uuid.html | 200 (summarizing fetch tool) | UUIDv4 and v7 support; function versions and ordering benefits are general knowledge, not on the page (added 2026-11-24) |
| https://www.postgresql.org/docs/current/sql-syntax-lexical.html | 200 (summarizing fetch tool) | case folding and 63-byte truncation (added 2026-11-24) |
| https://www.postgresql.org/docs/current/ddl-partitioning.html | 200 (summarizing fetch tool) | benefits, key in unique constraints, limits, many-partition caveat (added 2026-11-24) |
| https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization | 200 after redirect from owasp.org (summarizing fetch tool) | random ids supplement but do not replace access checks (added 2026-11-24) |
| Third-party skill collection on Postgres and Supabase best practices, read for topic coverage only, no text reused (license: MIT per the collection; not verified here) | read locally | topic coverage only (added 2026-11-24) |
