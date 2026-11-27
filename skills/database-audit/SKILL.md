---
name: database-audit
description: Use to audit an application's database against seven fundamentals at once (exposure, backups, usage cost, transactions, schema constraints, migrations and environments, query performance) without changing anything, to pick which fix to run first, and to decide which database fits. Read-only; writes one report. Also holds the database rules every fix skill follows.
---

# Database audit (router)

Read-only. It inspects, ranks and writes **DB-AUDIT.md**; it changes nothing. The generic safety steps before any fix (branch, backup, tests, one change at a time) live in `fundamentals-audit`; this page adds the database part.

## Steps

1. **Detect:** engine and host, ORM or query layer, migration tool, where the app connects from, and what the code reads (never print secret values). Done when the stack is stated. For SQL Server, PostgreSQL or SQLite, `sql-server-diagnostics`, `postgres-diagnostics` and `sqlite-diagnostics` hold ready read-only scripts for the engine in use: reach for them to gather the evidence of the areas below.
2. **Check each area read-only,** using the matching skill's steps as the checklist and marking a part **not applicable** when it does not apply:
   - exposure, secrets and access rules: `database-exposure`
   - backups that restore: `backup-restore-drill`
   - bills that scale with usage: `database-cost-guard`
   - multi-write operations: `transaction-fix`
   - constraints, money and time types: `schema-and-constraints`
   - schema history and environments: `migrations-and-environments`
   - slow queries and indexes: `query-performance`
3. **Rate each finding** with a risk (high, medium, low) and a `file:line` or setting that proves it.
4. **Write DB-AUDIT.md:** what is correct, findings by risk each with the skill that fixes it, where to start, and the run order below.

## Run order

Closed doors cannot be reopened, lost data cannot be rebuilt, bills grow silently, and speed comes last:

1. `database-exposure` (the open door)
2. `backup-restore-drill`
3. `database-cost-guard`
4. then `transaction-fix`, `schema-and-constraints`, `migrations-and-environments`, in that order
5. last `query-performance`

Where to start: the first area with a high-risk finding, in that order.

## Which database

Default to a relational database, **Postgres**, for anything with money, users, orders or relations: constraints, transactions and a fixed price per instance come built in. A **document** store (Firestore, Mongo) fits loosely structured data with simple access patterns, but relations and consistency move into your code and usage pricing needs `database-cost-guard`. Say the reason in one sentence and let the owner decide; this skill never migrates data.

## Rules

- No file other than DB-AUDIT.md is created; no query runs against production.
- Statistics quoted in the lesson (bills, counts of exposed databases, speed-ups) are third-party or the author's claims, not findings; cite a source or omit.
- Each fix starts from the report and waits for the owner's OK.

Source: the handout of the second database lesson of mano deyvin (audit prompt, run order and "which database" note).

## Quick Decision Checklist

- [ ] Is this read-only, writing only DB-AUDIT.md and running no query against production?
- [ ] Have I stated the engine, host, ORM, migration tool and connection origin without printing secrets?
- [ ] Did I check all seven areas, marking any that do not apply as not applicable?
- [ ] Does each finding carry a risk rating and a file:line or setting that proves it?
- [ ] Does the run order start with exposure, then backups, then cost, and end with query performance?
- [ ] Do I cite a source or omit third-party statistics from the lesson?
- [ ] Will each fix wait for the owner's OK, with no data migration done by this skill?

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were verified and which are the lesson's own
- [Choosing a database](references/database-choice-reasoning.md) — when you must justify a relational vs document vs key-value vs BaaS recommendation
- [Audit order and report shape](references/audit-order-and-report-shape.md) — when you write DB-AUDIT.md or must explain why the seven areas run in this order
