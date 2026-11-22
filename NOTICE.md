# Notice: where these skills come from

This repository combines two families of self-contained engineering skills:

## 1. Software Architecture & Design Pattern Skills (13 skills)

Distilled from canonical software architecture literature, official cloud architecture guides, and reference repositories retrieved on 2026-11-22. Each skill folder carries its own `references/sources.md` table mapping specific claims, vocabulary, and trade-offs to their primary authors:

- **`hexagonal-architecture`**: Alistair Cockburn / Juan Manuel Garrido de Paz ("Ports and Adapters Pattern"), Marco Tulio Valente (*Engenharia de Software Moderna*), AWS Prescriptive Guidance, Netflix Tech Blog, Tom Hombergs, and Baeldung.
- **`layered-n-tier-architecture`**: Microsoft Azure Architecture Center ("N-tier architecture style" & "Architecture styles"), Marco Tulio Valente (*Engenharia de Software Moderna*, Cap. 7), and Microsoft .NET Architecture Guides.
- **`mvc-architecture`**: Martin Fowler ("GUI Architectures", *PoEAA* "Model View Controller"), MDN Web Docs ("MVC"), and Marco Tulio Valente.
- **`clean-architecture`**: Robert C. Martin ("The Clean Architecture", 2012), Marco Tulio Valente ("Building Software with a Clean Architecture"), Jason Taylor (`CleanArchitecture` template), and Microsoft .NET Architecture Guides.
- **`monolithic-architecture`**: Martin Fowler ("Monolith First", 2015), Microsoft .NET ("Common web application architectures"), and AWS Compare ("Monolithic vs. Microservices Architecture").
- **`modular-monolith-architecture`**: Kamil Grzybek (`modular-monolith-with-ddd`), Spring Team (*Spring Modulith Reference Documentation*), and Martin Fowler.
- **`microservices-architecture`**: James Lewis & Martin Fowler ("Microservices", 2014; "Microservices Guide") and Chris Richardson (`microservices.io` pattern language).
- **`serverless-architecture`**: Mike Roberts ("Serverless Architectures", Martin Fowler site), Badri Janakiraman ("bliki: Serverless"), and AWS Well-Architected Framework (*Serverless Applications Lens*).
- **`event-driven-architecture`**: Martin Fowler ("What do you mean by 'Event-Driven'?", 2017) and Microsoft Azure Architecture Center ("Event-driven architecture style").
- **`cqrs-pattern`**: Martin Fowler ("CQRS", 2011; "Command Query Separation", 2005 / Bertrand Meyer) and Microsoft Azure Architecture Center ("CQRS pattern").
- **`event-sourcing-pattern`**: Martin Fowler ("Event Sourcing", 2005), Microsoft Azure Architecture Center ("Event Sourcing pattern"), Chris Richardson (`microservices.io`), and Oskar Dudycz (`EventSourcing.NetCore`).
- **`bff-pattern`**: Sam Newman ("Pattern: Backends For Frontends", 2015), Microsoft Azure Architecture Center ("Backends for Frontends pattern"), and Chris Richardson ("Pattern: API Gateway / Backends for Frontends").
- **`micro-frontends-architecture`**: Cam Jackson ("Micro Frontends", 2019, Martin Fowler site), Michael Geers (`micro-frontends.org`), and Microsoft .NET Microservices Architecture Guide ("Creating composite UI based on microservices").

## 2. Engineering Fundamentals, Security & Database Diagnostics Skills (18 skills)

The eighteen engineering fundamentals and database diagnostic skills are procedures distilled from three videos of the channel "mano deyvin", their published prompts, and official database engine documentation:

| Source | Used for |
|---|---|
| "FUNDAMENTOS DE ENGENHARIA DE SOFTWARE PARA VIBE CODERS" (mano deyvin, 2026-10-27), https://www.youtube.com/watch?v=G8SeOH0qerk, and its prompts post | `fundamentals-audit`, `race-condition-fix`, `idempotency-fix`, `never-trust-the-client`, `layered-refactor`, `integration-tests` |
| "USOU VIBE CODING? TÁ CORRENDO RISCO" (mano deyvin, 2026-08-10), https://www.youtube.com/watch?v=6DJFl-g83dM | `security-audit`, and the second pass of `never-trust-the-client` |
| "BANCO DE DADOS - FUNDAMENTOS PARA VIBE CODERS #EP2" (mano deyvin), https://www.youtube.com/watch?v=TL4T9ZESamI, and its handout of prompts | `database-audit`, `database-exposure`, `backup-restore-drill`, `database-cost-guard`, `transaction-fix`, `schema-and-constraints`, `migrations-and-environments`, `query-performance` |
| Microsoft Learn (SQL Server 2019, 2022 and 2025 reference pages), the PostgreSQL 16-18 documentation and sqlite.org (pragma and dbstat pages), read on 2026-11-16 | `sql-server-diagnostics`, `postgres-diagnostics`, `sqlite-diagnostics`: the scripts are original queries over documented views; the version differences were checked against those pages and by running the scripts, as each README states |
| Martin Kleppmann, "How to do distributed locking" (2016), cited inside `race-condition-fix` | the reasoning for a database-side check instead of an external lock |

Facts about PostgreSQL (money and timestamp types, foreign-key indexes, `CREATE INDEX CONCURRENTLY`, `pg_dump`/`pg_restore`), the Firebase budget alerts, the Google Cloud billing overrun (The Register, 2020), the GitLab 2017 postmortem and the UpGuard Supabase count were checked against their public pages on 2026-11-16; the SaaStr database deletion is the founder's account, not verified.

Statistics and empirical anecdotes quoted in sources are marked as claims (`*claim*`) in `references/sources.md` or left out.
