---
name: database-audit
description: Read-only audit of an application's database across seven areas (exposure, backups, usage cost, transactions, schema constraints, migrations and environments, query performance). It detects the stack, rates each finding with evidence, writes one DB-AUDIT.md naming which fix skill to run first, and gives the default engine choice (relational Postgres unless the data is loose). It also holds the database rules every fix skill follows. Changes nothing; runs nothing against production. Not for tests, client trust or races (use fundamentals-audit) or a deep engine health check (use postgres-diagnostics, sql-server-audit or sqlite-diagnostics). Use when someone asks "is my database OK", wants an X-ray before launch, or must decide which database problem to fix first.
---

# Database audit (router)

Read-only. It inspects, ranks and writes **DB-AUDIT.md**; it changes nothing. The generic safety steps before any fix (branch, plan first, human review of migrations, one change at a time) live in `fundamentals-audit`; this page adds the database part. Source handling: [references/sources.md](references/sources.md).

## 1. Steps

1. **Detect:** engine and host, ORM or query layer, migration tool, where the app connects from, and what the code reads (never print secret values). Done when the stack is stated. For SQL Server, PostgreSQL or SQLite, `sql-server-diagnostics`, `postgres-diagnostics` and `sqlite-diagnostics` hold ready read-only scripts: reach for them to gather evidence for the areas below.
2. **Check each of the seven areas in the run order below, read-only,** using the matching skill's steps as the checklist; mark a part **not applicable** when it does not apply.
3. **Rate each finding** with a risk (high, medium, low) and a `file:line` or setting that proves it.
4. **Write DB-AUDIT.md:** what is correct, findings by risk each with the skill that fixes it, where to start, and the run order.

## 2. Run order

Closed doors cannot be reopened, lost data cannot be rebuilt, bills grow silently, and speed comes last:

| # | Area | Skill |
|---|---|---|
| 1 | exposure, secrets and access rules (the open door) | `database-exposure` |
| 2 | backups that restore | `backup-restore-drill` |
| 3 | bills that scale with usage | `database-cost-guard` |
| 4 | multi-write operations | `transaction-fix` |
| 5 | constraints, money and time types | `schema-and-constraints` |
| 6 | schema history and environments | `migrations-and-environments` |
| 7 | slow queries and indexes (last) | `query-performance` |

Where to start: the first area with a high-risk finding, in that order. The source handout lists areas 4 to 6 as one block; this page orders them as the video does. The reasoning is in the audit-order reference.

## 3. Which database

Default to a relational database, **Postgres**, for anything with money, users, orders or relations: the engine enforces constraints and transactions, which a document store pushes into your code. A **document** store (Firestore, Mongo) fits loosely structured data with simple access patterns; check usage-based pricing with `database-cost-guard`. Say the reason in one sentence and let the owner decide; this skill never migrates data. The reasoning and its limits are in the choice reference.

## 4. Rules

- No file other than DB-AUDIT.md is created; no query runs against production.
- Statistics quoted in the lesson (bills, counts of exposed databases, speed-ups) are third-party or the author's claims, not findings; cite a source or omit.
- Each fix starts from the report and waits for the owner's OK.
- Rules every fix skill follows: production is never touched (hand over the statement and let a human run it), and data is never deleted to make a rule pass.

## Quick Decision Checklist

- [ ] Is this read-only, writing only DB-AUDIT.md and running no query against production?
- [ ] Have I stated the engine, host, ORM, migration tool and connection origin without printing secrets?
- [ ] Did I check all seven areas, marking any that do not apply as not applicable?
- [ ] Does each finding carry a risk rating and a file:line or setting that proves it?
- [ ] Does the run order start with exposure, then backups, then cost, and end with query performance?
- [ ] Do I cite a source or omit third-party statistics from the lesson?
- [ ] Will each fix wait for the owner's OK, with no data migration done by this skill?

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were re-verified and which are the lesson's own
- [Choosing a database](references/database-choice-reasoning.md) — when you must justify a relational vs document vs key-value vs BaaS recommendation
- [Audit order and report shape](references/audit-order-and-report-shape.md) — when you write DB-AUDIT.md or must explain why the seven areas run in this order
- [Trigger evals](references/trigger-evals.md) — when you tune the description or check whether a request belongs here or to a neighbor
