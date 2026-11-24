# Notice: where these skills come from

This repository combines five families of self-contained engineering skills (88 skills total):

## 1. Software Architecture, Design Principles & Documentation Skills (62 skills)

Distilled from canonical software architecture literature, official cloud architecture guides, reference repositories, and primary engineering blogs/handbooks. Each skill folder carries its own `references/sources.md` table mapping specific claims, URLs (including retrieval HTTP status), and trade-offs to their primary authors:

- **`pragmatic-solid-and-ssot`**: Thomas & Hunt (*The Pragmatic Programmer* 20th Anniv. — DRY chapter), Martin Fowler (*BoundedContext*, *Yagni*), Robert C. Martin (*SOLID Relevance*, *SRP*, *OCP*, *Interface Considered Harmful*), Sandi Metz (*The Wrong Abstraction*), Kent C. Dodds (*AHA Programming*), and Harvard Kempner Institute (*Software Design Principles*).
- **`defensive-domain-modeling`**: Alexis King (*Parse, Don't Validate*), Scott Wlaschin (*Designing with Types: Making Illegal States Unrepresentable*, *Railway Oriented Programming*, *Recipe Part 2*, example repo), Martin Fowler (*ValueObject*, *TellDontAsk*, *CommandQuerySeparation*, *Guard Clauses*), Lieberherr & Holland / C2 Wiki (*Law of Demeter*).
- **`mermaid`**: Official Mermaid syntax docs (Flowchart, Sequence, ER, State, Class, C4, Architecture, Syntax Reference), GitHub Docs (*Creating diagrams*, *Copilot Cookbook*), `mermaid-js/mermaid-cli` (`mmdc`), and workflow/semantic-preservation rules adapted from the official Mermaid Chart VS Code extension (MIT; account-bound features omitted).
- **Software Components & Foundational Principles (19 skills: `router-front-controller-routing` … `error-handling-problem-details`)**: sources listed per skill in `references/sources.md` (Martin Fowler's EAA catalog, Enterprise Integration Patterns, Microsoft Azure Architecture Center, OWASP Cheat Sheets, IETF/HTTPWG RFCs 9110, 9111, 9457, 9700, 6749, Robert C. Martin, Mark Seemann, Sandi Metz, Scott Wlaschin, Alexis King, OpenFeature, Stately). Pages were read through WebFetch digests; unread pages are flagged in each file.
- **Remaining Architecture, Cloud-Native, Evolution, Testing & Docs skills (36 skills)**: Alistair Cockburn, Martin Fowler, Robert C. Martin, Sam Newman, Simon Brown, Daniele Procida, Mark Richards & Neal Ford, Vlad Khononov, Jimmy Bogard, Chris Richardson, Gregor Hohpe, Eric Evans, Microsoft Azure Architecture Center, AWS Well-Architected, Google / OpenTelemetry / Anthropic guidelines (see each skill's `references/sources.md`).

## 2. Engineering Fundamentals, Security & Database Diagnostics Skills (18 skills)

The fifteen engineering fundamentals and database governance skills are procedures distilled from three videos of the channel "mano deyvin" and their published prompts. The three database engine diagnostic skills come from the pack author's own SQL Server 2022 best-practice DDL/SQL files (private, not published), later ported to SQL Server 2019 and 2025 and followed by PostgreSQL and SQLite; official engine documentation was used afterwards only to verify claims:

| Source | Used for |
|---|---|
| "FUNDAMENTOS DE ENGENHARIA DE SOFTWARE PARA VIBE CODERS" (mano deyvin, 2026-10-27), https://www.youtube.com/watch?v=G8SeOH0qerk, and its prompts post | `fundamentals-audit`, `race-condition-fix`, `idempotency-fix`, `never-trust-the-client`, `layered-refactor`, `integration-tests` |
| "USOU VIBE CODING? TÁ CORRENDO RISCO" (mano deyvin, 2026-08-10), https://www.youtube.com/watch?v=6DJFl-g83dM | `security-audit`, and the second pass of `never-trust-the-client` |
| "BANCO DE DADOS - FUNDAMENTOS PARA VIBE CODERS #EP2" (mano deyvin), https://www.youtube.com/watch?v=TL4T9ZESamI, and its handout of prompts | `database-audit`, `database-exposure`, `backup-restore-drill`, `database-cost-guard`, `transaction-fix`, `schema-and-constraints`, `migrations-and-environments`, `query-performance` |
| The pack author's SQL Server 2022 best-practice files (private); SQL Server 2019/2025 ports; PostgreSQL and SQLite follow-ups. Verification sources, read 2026-11-16 and 2026-11-24: Microsoft Learn (SQL Server 2019, 2022, 2025), PostgreSQL 16-18 documentation, sqlite.org | `sql-server-diagnostics`, `postgres-diagnostics`, `sqlite-diagnostics`: original queries over documented views; the official pages confirm the documented behavior and version differences (see each skill's `references/sources.md`), and the scripts were run as each README states |
| Martin Kleppmann, "How to do distributed locking" (2016), cited inside `race-condition-fix` | the reasoning for a database-side check instead of an external lock |

Facts about PostgreSQL (money and timestamp types, foreign-key indexes, `CREATE INDEX CONCURRENTLY`, `pg_dump`/`pg_restore`), the Firebase budget alerts, the Google Cloud billing overrun (The Register, 2020), the GitLab 2017 postmortem and the UpGuard Supabase count were checked against their public pages on 2026-11-16; the SaaStr database deletion is the founder's account, not verified.

Statistics and empirical anecdotes quoted in sources are marked as claims (`*claim*`) in `references/sources.md` or left out.

## 3. AI Engineering Workflow & Deep-Module Design Pack (9 skills, adapted from `mattpocock/skills`)

Adapted and integrated from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT License, Copyright (c) 2026 Matt Pocock; retrieved 2026-11-22) covering the interactive spec-to-code-review construction workflow highlighted in Felipe Borges ("As 5 Melhores Skills da Nova Era do Claude Code", 2026-08-13):

- **`grill-me`** & **`grilling`**: design-tree interview in frontier rounds with fresh-context fact lookup.
- **`setup-matt-pocock-skills`**: per-repo scaffolding for issue tracker (GitHub, GitLab, local `.scratch/`), triage labels, and `GLOSSARY.md` / `docs/adr/` domain docs.
- **`to-spec`**: conversation synthesis into spec + testing seams without re-interviewing.
- **`to-tickets`**: tracer-bullet vertical slices with `Blocked by` edges and expand–contract wide-refactor exception.
- **`implement`**: vertical red-green TDD slices + pack design/security guardrails + two-axis review.
- **`tdd`**: seam-oriented red → green loop (`tests.md`, `mocking.md`), cross-linked with `codebase-design` and `integration-tests`.
- **`code-review`**: clean/fresh-context parallel **Standards** (repo standards + Fowler's 12 smells + pack security/DB cross-checks) and **Spec** subagents.
- **`codebase-design`**: Ousterhout deep-module / seam / Deletion Test vocabulary (`DEEPENING.md`, `DESIGN-IT-TWICE.md`).
