# Sources — Schema and constraints

Every URL below was re-fetched on 2026-11-27 (summarizing WebFetch tool; Firecrawl unavailable). The PostgreSQL pages served were the version 19 documentation.

| Source | Retrieved status | What it contributed |
|---|---|---|
| PostgreSQL wiki "Don't Do This", https://wiki.postgresql.org/wiki/Don%27t_Do_This | 200 | `money`, `timestamp` vs `timestamptz`, `timestamp(0)`, `BETWEEN`, `char(n)`, `varchar(n)`, `serial`, `NOT IN`, `timetz`, inheritance, rules, `trust` auth; confirmed: no `float` section |
| https://www.postgresql.org/docs/current/ddl-constraints.html | 200 | Each constraint type, null behavior, MATCH FULL, FK actions and column-list form, index advice, immutability assumption of CHECK |
| https://www.postgresql.org/docs/current/sql-altertable.html | 200 | `NOT VALID` for foreign key, check and not-null (not unique or primary key), `VALIDATE CONSTRAINT` lock, `USING INDEX` |
| https://www.postgresql.org/docs/current/ddl-identity-columns.html | 200 | identity semantics, no uniqueness guarantee, no serial comparison |
| https://www.postgresql.org/docs/current/datatype-uuid.html | 200 | UUIDv4 and v7 generation; no ordering or release remarks |
| https://www.postgresql.org/docs/current/sql-syntax-lexical.html | 200 | case folding, quoting, 63-byte truncation |
| https://www.postgresql.org/docs/current/ddl-partitioning.html | 200 | benefits, when it pays, key in unique constraints, concurrent index workaround, many partitions, attach |
| https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization | 200 | random ids are a prevention step; authorization checks are the main one |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, section "1. Modelagem e constraints" | 200 | numeric or cents never float, timestamptz, count violators first, reversible migrations, never alter data to pass a constraint, nothing run in production |
| Video "Banco de Dados \| Fundamentos para Vibe Coders #EP2", https://www.youtube.com/watch?v=TL4T9ZESamI | 200, text truncated to the title | Nothing re-verified; chapter timestamps and the Manaus example are unconfirmed |

## Reading limits

Pages were read through a summarizing tool, not verbatim. Third-party Postgres/Supabase skill collection (MIT per the collection) was read earlier for topic coverage only, no text reused; not re-read.

## Claims not adopted as fact

- `0.1 + 0.2` float drift and the "never float" rule: general knowledge and the lesson; the wiki does not discuss `float`, so the skill labels it its own guidance.
- Not-null `NOT VALID` in older PostgreSQL versions: only the version 19 page was read.
- `uuidv7()` introduced in PostgreSQL 18, and its B-tree benefit: not on the type page (general knowledge, verify).
- Gapless sequences are not guaranteed: not on the identity page; general knowledge.
- `OVERRIDING SYSTEM VALUE` syntax: used by the identity page's text but its example is not shown there.
- "Use snake_case, short names": the skill's rule, not a docs requirement.
- Manaus 11 pm report example: illustrative only.
