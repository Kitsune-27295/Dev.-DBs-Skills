---
name: schema-and-constraints
description: Use to review or design a relational schema so the database itself rejects bad data - money as exact numbers, timestamps with time zone, foreign keys, not-null, unique and check constraints, one row per subject. Finds columns that let invalid data in, counts the rows that already break each rule, and proposes migrations that can be reversed. Use on a new schema or when duplicates, orphans or wrong totals appear.
---

# Schema and constraints

Application code has bugs; a constraint does not forget. The goal is that the database refuses bad data even when the code is wrong. Shared database rules: `database-audit`. Index side of foreign keys: `query-performance`.

## Steps (report first)

1. **List every table with its columns, types and constraints.** Done when each table shows its primary key, foreign keys, and which columns are `not null`, `unique` or checked. Flag text columns that hold numbers or dates, and data copied across tables that should live in one place.
2. **Money.** Any price, balance or total stored as `float` or `double` is a finding (this skill's own guidance: floats cannot hold decimal fractions exactly; the wiki does not discuss `float`). The PostgreSQL wiki advises against the `money` type. Use `numeric(p,s)` or integer **cents**, with the currency kept beside the amount.
3. **Time.** A `timestamp` without zone where the moment matters is a finding: use `timestamptz` (the wiki allows plain `timestamp` only for values handled in an abstract way, saved and retrieved with no arithmetic).
4. **Missing rules.** Read the validations in the code (front end and back end) and write the equivalent constraint for each. Then, for each relation without a **foreign key**, each column that should be `not null`, each natural identifier (email, slug, external id) without `unique`, and each value with a valid range or set without a `check`, write the constraint you would add. Also: **one per subject** tables (one profile per user) need a unique key on the subject.
5. **Count the damage first.** Before proposing a constraint, run a read-only `count` query for the rows that already break it (orphans, duplicates, nulls, out-of-range). Run it on a recent restored copy, or hand the read-only query to the owner. Report the number. `not null` and `unique` need clean rows first; `foreign key` and `check` can be added `NOT VALID` and validated once the bad rows are handled.
6. **Propose migrations**, one rule per migration, each with a way back (the reverse statement) and a plan for the rows that already break the rule (fix, or quarantine and ask). Never delete data to make a constraint pass; the owner decides.

## Rules

- Nothing runs against production: you hand over the SQL and the counts.
- Tests on a real test database prove a bad insert is rejected; see `integration-tests`.
- Renaming or dropping columns is a different change; keep this one to adding rules.
- Adding a foreign key does not create an index on the referencing column (PostgreSQL documentation): add it separately.

Source: the handout of the second database lesson of mano deyvin (prompt "the schema that refuses bad data"); the `money` type, timestamp and foreign-key points were checked against the PostgreSQL wiki and documentation; the `float` rule is this skill's own.

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were verified and which are the lesson's own
- [PostgreSQL column-type pitfalls](references/postgres-column-type-pitfalls.md) — when you review money, time, text or id column types
- [Constraint types and indexes](references/constraint-types-and-indexes.md) — when you choose constraints, foreign key actions, or must know which constraints create an index
