# Sources — Query performance

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Banco de Dados | Fundamentos para Vibe Coders #EP2", channel mano deyvin, published 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI — chapter 04 "A linha que falta" (15:50-21:28) | Transcript read from a saved copy; video page not re-fetched | The index-as-book-index analogy, the foreign key without index case, "do not index everything", the prompt's checks (WHERE, JOIN, ORDER BY, loops, high offset, EXPLAIN ANALYZE) |
| Author's handout, https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe — section "3. Performance: a linha que falta" | Saved copy read; page not re-fetched | The four measured pairs, the prompt text, and the rules on `CREATE INDEX CONCURRENTLY` |
| PostgreSQL docs "Constraints", https://www.postgresql.org/docs/current/ddl-constraints.html | 200 (read through a summarizing fetch tool) | Confirms primary key and unique constraints create an index and a foreign key does not create one on the referencing columns |

## Claims and caveats (the author's measurements, not verified here)

- 5 million orders: foreign key lookup 58 ms without an index, 0.37 ms with one. Handout adds `date(col)` vs range 151 ms to 0.64 ms, `count(*) > 0` vs `EXISTS` 104 ms to 0.15 ms, `OFFSET` vs cursor 232 ms to 0.18 ms. The test ran on a 2 vCPU, 8 GB VPS. These are the video's claims; I did not reproduce them. Treat them as illustrative orders of magnitude.
- The video's throughput remarks (20 users, about 5 requests per second at about 4 seconds each without the index; 9,503 requests in 2 ms with it) are not explained well enough in the transcript to interpret; do not quote them.
- The documentation statement that the foreign key does not auto-index is verified at the page.

## Discrepancies with SKILL.md (not edited)

- `SKILL.md` says to create the index with `CREATE INDEX CONCURRENTLY` and notes it cannot run in a transaction block; the handout only says to use it for large production tables and warn first. (resolved 2026-11-24: the CREATE INDEX page confirms `CONCURRENTLY` cannot run in a transaction block and a failed run leaves an invalid index to drop and retry, so the `SKILL.md` attribution to the PostgreSQL documentation holds.)
- `SKILL.md` adds `NOT IN` to `NOT EXISTS` and expression indexes for wrapped columns; the PostgreSQL wiki (see `schema-and-constraints`) supports `NOT EXISTS`, the rest is general knowledge.
- The video mentions "function on a column" and "offset" checks; the handout adds `count` vs `EXISTS`. `SKILL.md` includes all.
