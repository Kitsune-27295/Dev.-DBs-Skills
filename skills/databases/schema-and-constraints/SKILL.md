---
name: schema-and-constraints
description: Review or design a relational schema so the database itself rejects bad data - money as exact numbers, timestamps with time zone, foreign keys, not-null, unique and check constraints, one row per subject. Counts the rows that already break each rule and proposes reversible migrations, one rule each, without deleting data. PostgreSQL-centric. Not for slow queries (use query-performance), renaming or retyping columns with zero downtime (use parallel-change-expand-contract), migration tooling or environments (use migrations-and-environments) or a whole-database audit (use database-audit). Use when a schema is new, or when duplicates, orphans, wrong totals or shifted dates appear.
---

# Schema and constraints

Application code has bugs; a constraint does not forget. The goal is that the database refuses bad data even when the code is wrong. Shared database rules: `database-audit`. Index side of foreign keys: `query-performance`. Source handling: [references/sources.md](references/sources.md).

## 1. Steps (report first)

1. **List every table with its columns, types and constraints.** Done when each table shows its primary key, foreign keys, and which columns are `not null`, `unique` or checked. Flag text columns that hold numbers or dates, and data copied across tables that should live in one place.
2. **Money.** Any price, balance or total stored as `float` or `double` is a finding (this skill's own guidance: floats cannot hold decimal fractions exactly; the PostgreSQL wiki does not discuss `float`). The wiki calls the `money` type a poor fit (no fractional cents, rounding, meaning tied to the `lc_monetary` setting) and prefers `numeric`, with the currency in an adjacent column. Integer **cents** is the common alternative; the wiki mentions integer only as a rare option.
3. **Time.** A `timestamp` without zone where the moment matters is a finding: use `timestamptz`. The wiki allows plain `timestamp` only for values handled abstractly, with no date arithmetic, and not for UTC values.
4. **Missing rules.** Read the validations in the code (front end and back end) and write the equivalent constraint for each. Then, for each relation without a **foreign key**, each column that should be `not null`, each natural identifier (email, slug, external id) without `unique`, and each value with a valid range or set without a `check`, write the constraint you would add. **One per subject** tables (one profile per user) need a unique key on the subject.
5. **Count the damage first.** Before proposing a constraint, run a read-only `count` query for the rows that already break it (orphans, duplicates, nulls, out-of-range), on a recent restored copy, or hand the read-only query to the owner. Report the number. `unique` and primary keys need clean rows first. `NOT VALID` skips the scan of existing rows for a foreign key or check, and in the current PostgreSQL 19 docs for `not null` too (check your version); `VALIDATE CONSTRAINT` runs later under a lighter lock. The large-table procedure is in `parallel-change-expand-contract`.
6. **Propose migrations**, one rule per migration, each with a way back (the reverse statement) and a plan for the rows that already break the rule (fix, or quarantine and ask). Never delete data to make a constraint pass; the owner decides.

## 2. Rules

- Nothing runs against production: you hand over the SQL and the counts.
- Tests on a real test database prove a bad insert is rejected; see `integration-tests`.
- Renaming or dropping columns is a different change; keep this one to adding rules.
- A foreign key does not index the referencing column; the fix and its reasoning are in `query-performance`.

Source: the handout of the second database lesson of mano deyvin (prompt "the schema that refuses bad data"); type and constraint points were re-checked against the PostgreSQL wiki and documentation on 2026-11-27; the `float` rule is this skill's own.

## Quick Decision Checklist

- [ ] Did I list every table with its keys, types and constraints before proposing anything?
- [ ] Is any money stored as float, double or `money`? Use numeric (or integer cents) plus a currency column.
- [ ] Is any moment-in-time stored as timestamp without zone where timestamptz is needed?
- [ ] Does every code-side validation have an equivalent constraint: foreign key, not null, unique, check?
- [ ] Did I count rows that already break each rule, with a read-only query, before proposing it?
- [ ] Is each migration one rule, with a way back and a plan for the offending rows?
- [ ] Am I avoiding deleting data to make a constraint pass, and avoiding any run against production?
- [ ] Did I pair each foreign key with an index on the referencing column, or say why not?

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were re-verified and which are the lesson's own
- [PostgreSQL column-type pitfalls](references/postgres-column-type-pitfalls.md) — when you review money, time, text or id column types
- [Constraint types and indexes](references/constraint-types-and-indexes.md) — when you choose constraints, foreign key actions, NOT VALID, or must know which constraints create an index
- [Keys, identifiers and partitioning](references/keys-identifiers-and-partitioning.md) — when you choose primary keys, review quoted names or consider partitioning
- [Trigger evals](references/trigger-evals.md) — when you tune the description or check whether a request belongs here or to a neighbor
