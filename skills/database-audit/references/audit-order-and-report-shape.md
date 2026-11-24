# The seven audits: order, rationale and report shape

Sources: video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI), chapter "A ordem que eu rodaria" 30:37-end; handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, sections "Antes de colar qualquer prompt", "A ordem que eu rodaria" and "Prompt de auditoria" · Last verified 2026-11-24

## The order and why

| Step | Area (skill) | Rationale stated by the author |
|---|---|---|
| 1 | Open door (`database-exposure`) | A leak has no way back |
| 2 | Backup (`backup-restore-drill`) | The safety net for everything after it (handout: "your insurance for the rest") |
| 3 | Monthly bill (`database-cost-guard`) | Matters when the database bills per read |
| 4-6 | Transaction, constraints, migrations (`transaction-fix`, `schema-and-constraints`, `migrations-and-environments`) | Organizing the house; the video lists them in this sequence, the handout groups them |
| 7 | Performance (`query-performance`) | Last: first organize the house, then see whether it is fast |

Underlying logic (the author's, restated): irreversible harms first (leak, data loss), then silent recurring harms (cost), then correctness, then speed. Note that backup comes before the changes that follow because every later fix touches the schema or data.

## Safety rules shared by every prompt (handout)

Run on a separate branch; read the plan the AI proposes before accepting it; never let the AI touch production: it hands over the command and a human runs it. Each fix prompt also carries its own "rules" line (never delete data to pass a constraint, no business-rule changes, no production runs).

## Anatomy of the general audit prompt

The prompt is read-only: no file edits, no writes to the database. It fixes seven checks in order and asks for a report with, per finding, the risk (high, medium, low) and which of the seven fix prompts resolves it, ending with "where to start". Each check is phrased as a question that can be answered from code and settings:

1. Door: does the database accept outside connections; keys or passwords in front end or git; who reads and writes each table through the public API.
2. Backup: does one exist, where, has anyone tested a restore.
3. Cost: how it bills, where code reads too much (loop, listener, offset).
4. Transaction: multi-table writes without a transaction.
5. Constraints and modeling: money as float, timestamps without time zone, missing foreign keys, rules only in code.
6. Migrations: real schema against migration files; dev and production separated.
7. Performance: foreign keys without index, function on a column in `WHERE`, `count` instead of `EXISTS`, high `OFFSET`.

## Report shape

```
# DB-AUDIT.md
Stack: <engine, host, ORM, migration tool>
Correct: <what already holds>
| # | Area | Finding | Evidence (file:line or setting) | Risk | Fix skill |
Run order: exposure, backup, cost, transaction, schema, migrations, performance
Start here: <first area with a high-risk finding>
```

## Evidence discipline (differences from the source prompt)

The source prompt lists seven checks in the video's "door, backup, cost, transaction, schema, migrations, performance" order; `SKILL.md` adds an evidence column and a "not applicable" label for parts that do not apply. That is a refinement, not a conflict.

## How an agent should apply this

- Run all seven checks read-only, in the order above, and write one report; do not start a fix inside the audit.
- Give every finding a risk and proof (a `file:line` or a setting); mark parts that do not apply as not applicable.
- Pick "where to start" as the first area, in run order, that has a high-risk finding.
- Quote the lesson's statistics only as the author's claims.
- Require the owner's OK per fix and keep production out of reach.
