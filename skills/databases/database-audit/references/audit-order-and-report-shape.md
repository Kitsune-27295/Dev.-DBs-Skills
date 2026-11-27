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

Branch, backup and tests before any fix: `fundamentals-audit`. Each fix prompt also carries its own "rules" line (never delete data to pass a constraint, no business-rule changes, no production runs).

## Anatomy of the general audit prompt

The prompt is read-only: no file edits, no writes to the database. It fixes seven checks in the order above and asks for a report with, per finding, the risk (high, medium, low) and which fix skill resolves it, ending with "where to start". Each check is one question answerable from code and settings, defined by its owner skill in the table above.

## Report shape

```
# DB-AUDIT.md
Stack: <engine, host, ORM, migration tool>
Correct: <what already holds>
| # | Area | Finding | Evidence (file:line or setting) | Risk | Fix skill |
Start here: <first area with a high-risk finding>
```

## Evidence discipline (differences from the source prompt)

The source prompt lists seven checks in the video's "door, backup, cost, transaction, schema, migrations, performance" order; `SKILL.md` adds an evidence column and a "not applicable" label for parts that do not apply. That is a refinement, not a conflict.

## How an agent should apply this

- Follow `SKILL.md` (steps, Run order, Rules); this file adds the rationale and the report shape.
- Quote the lesson's statistics only as the author's claims.
