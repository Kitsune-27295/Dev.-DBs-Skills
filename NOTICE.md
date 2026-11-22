# Notice: where these skills come from

The eighteen skills are procedures **distilled** by an AI assistant (Claude) from three videos of the channel "mano deyvin"
and from the prompts the author published for the first and the third. They are condensed and re-written, not copies of the
videos; a few ideas, examples and one test snippet follow the sources closely, so credit goes to the author.

| Source | Used for |
|---|---|
| "FUNDAMENTOS DE ENGENHARIA DE SOFTWARE PARA VIBE CODERS" (mano deyvin, 2026-10-27), https://www.youtube.com/watch?v=G8SeOH0qerk, and its prompts post (linked in the video description) | `fundamentals-audit`, `race-condition-fix`, `idempotency-fix`, `never-trust-the-client`, `layered-refactor`, `integration-tests` |
| "USOU VIBE CODING? TÁ CORRENDO RISCO" (mano deyvin, 2026-08-10), https://www.youtube.com/watch?v=6DJFl-g83dM | `security-audit`, and the second pass of `never-trust-the-client` |
| "BANCO DE DADOS - FUNDAMENTOS PARA VIBE CODERS #EP2" (mano deyvin), https://www.youtube.com/watch?v=TL4T9ZESamI, and its handout of prompts | `database-audit`, `database-exposure`, `backup-restore-drill`, `database-cost-guard`, `transaction-fix`, `schema-and-constraints`, `migrations-and-environments`, `query-performance` |
| Microsoft Learn (SQL Server 2019, 2022 and 2025 reference pages), the PostgreSQL 16-18 documentation and sqlite.org (pragma and dbstat pages), read on 2026-11-16 | `sql-server-diagnostics`, `postgres-diagnostics`, `sqlite-diagnostics`: the scripts are original queries over documented views; the version differences were checked against those pages and by running the scripts, as each README states |
| Martin Kleppmann, "How to do distributed locking" (2016), cited inside `race-condition-fix` | the reasoning for a database-side check instead of an external lock |

Facts about PostgreSQL (money and timestamp types, foreign-key indexes, `CREATE INDEX CONCURRENTLY`, `pg_dump`/`pg_restore`), the Firebase budget alerts, the Google Cloud billing overrun (The Register, 2020), the GitLab 2017 postmortem and the UpGuard Supabase count were checked against their public pages on 2026-11-16; the SaaStr database deletion is the founder's account, not verified.

Statistics quoted in the videos (apps scanned, secrets leaked, share of AI code with flaws) are the authors' claims; the
skills cite them as claims or leave them out. Nothing here was verified against the sources by running them.

**Use:** personal and internal use is the intent of this pack. Before you publish or sell it, check the terms of the
original material yourself; this file is not legal advice.
