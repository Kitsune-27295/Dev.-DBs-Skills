# The seven audits: order, rationale and report shape

Sources: author's handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, sections "A ordem que eu rodaria" and "Prompt de auditoria" (re-read); video https://www.youtube.com/watch?v=TL4T9ZESamI (not re-verified) · Last verified 2026-11-27

## The order and why

| Step | Area (skill) | Rationale |
|---|---|---|
| 1 | Open door (`database-exposure`) | Handout: a leak cannot be undone |
| 2 | Backup (`backup-restore-drill`) | Safety net for the fixes that follow (the video's framing; unconfirmed this round) |
| 3 | Monthly bill (`database-cost-guard`) | Handout: matters when the database charges per read |
| 4-6 | Transaction, constraints, migrations (`transaction-fix`, `schema-and-constraints`, `migrations-and-environments`) | Handout lists them as one block (its prompts 2, 1 and 6); this skill orders them as the video does |
| 7 | Performance (`query-performance`) | Handout: last, after the house is in order |

Underlying logic (restated): irreversible harms first (leak, data loss), then silent recurring harms (cost), then correctness, then speed. Backup precedes the fixes because every later fix touches the schema or data.

## Preconditions before any fix prompt (handout)

A separate branch, read the plan the AI proposes before accepting, and the AI never touches production: it hands over the command and a human runs it. The generic version is owned by `fundamentals-audit`; each fix skill adds its own rules line (never delete data to pass a constraint, no business-rule changes, no production runs).

## Anatomy of the general audit prompt

Read-only: no file edits, no writes to the database. Seven checks in the order above; a report listing each finding with its risk (high, medium, low) and which fix resolves it, ending with where to start. Each check is one question answerable from code and settings, defined by its owner skill in the table above.

## Report shape

```
# DB-AUDIT.md
Stack: <engine, host, ORM, migration tool>
Correct: <what already holds>
| # | Area | Finding | Evidence (file:line or setting) | Risk | Fix skill |
Start here: <first area with a high-risk finding>
```

The evidence column and the "not applicable" label are this skill's additions to the source prompt: a refinement, not a conflict.

## How an agent should apply this

- Follow `SKILL.md` (steps, run order, rules); this file adds the rationale and the report shape.
- Quote the lesson's statistics only as the author's claims.
