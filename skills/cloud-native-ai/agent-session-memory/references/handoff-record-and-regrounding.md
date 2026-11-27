# Handoff Record and Re-grounding

Sources: https://code.claude.com/docs/en/memory · https://www.anthropic.com/research/effective-context-engineering-for-ai-agents · https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions · Last verified 2026-11-27

## Two artifacts, two jobs

| | Handoff note | Handoff record |
|---|---|---|
| Purpose | Let the **next** session start without re-reading everything | Permanent, auditable history of session ends |
| Lifetime | Single use: marked consumed when read | Append-only: never edited |
| Content | Next concrete step, pointers, what to read first | Four required fields per row |
| Failure if misused | A stale note replayed as if fresh | An invented field trusted as fact |

Keeping them apart avoids a common mistake: editing one living "status" file until nobody can tell which parts are current.

## The single-use note

Write it for a specific next session. Contents:

1. **Goal of the next session** (one sentence; if the user gave one, use theirs).
2. **Next concrete step**, specific enough to start without re-deriving it.
3. **Pointers, not copies:** specs, issues, commits, diffs, decision records by path or URL. Duplicated content goes stale; a pointer stays correct.
4. **Skills or tools the next session should load**, by name.
5. **State claims with how to check them** ("branch `feature-x`, check with `git status`").

Redact secrets and personal data before writing; a handoff is a document other agents and people will read. Mark it **consumed** when the next session reads it (move it to an archive folder or stamp `consumed: <date>`). A consumed note is history, not instruction.

## The append-only record

One row per session end. All fields required, none defaulted:

| Field | Meaning | Rejects |
|---|---|---|
| `date` | When the session ended | missing date |
| `accomplished` | What was actually done, not attempted | "worked on X" with no result |
| `decided` | What was chosen **and what it rules out**; "nothing decided" is a valid value | blank, or a plausible-sounding invention |
| `next` | Concrete next step | "continue" |
| `open_questions` | Unresolved items; "none" only if true | blank |

Why "no defaults": a handoff with an invented field reads exactly like a real one, and the next session trusts it as a starting point. An empty value must be a decision made by the writer, not an omission. This rule is borrowed from an own, private handoff skill (idea only); the reasoning is this skill's.

Corrections: a past row is never edited. Append a new row with `corrects: <date or id of the old row>` and the right content. This mirrors supersede-not-delete practice in decision records (Nygard keeps the old record and links the replacement; see `adr-architecture`).

### Minimal validator (own example)

```python
REQUIRED = ("date", "accomplished", "decided", "next", "open_questions")

def validate(row: dict) -> list[str]:
    errors = [f"missing field: {k}" for k in REQUIRED if k not in row]
    errors += [f"empty field: {k}" for k in REQUIRED
               if k in row and not str(row[k]).strip()]
    return errors          # refuse to append when this list is non-empty

# append mode only: open(path, "a"); never rewrite earlier lines
```

The point is not the code but the refusal: the writer path must fail loudly on a missing or empty field.

### Example row

```
date: 2026-11-24
accomplished: Consumer wired to the new queue; integration test passes locally.
decided: Retry limit 5 with backoff (proposed 0007); rules out unbounded retry.
next: Add backoff jitter, then run the full suite on the shared runner.
open_questions: Whether the dead-letter queue needs its own alert; undecided.
```

## Re-grounding after compaction or cold start

Compaction mechanics and tuning are owned by `agent-skills-context-engineering`. Two facts matter here: the Claude Code memory docs say the project-root instruction file is re-read from disk after compaction, and an instruction given only in conversation can disappear. Consequence: **disk is the source of truth, the summary is a hint.**

Checklist:

1. Re-read hot and the newest handoff row from disk.
2. Verify each state claim against the live repo (branch, `git status`, files named as in progress, last commit). Prefer the repo when they disagree, and say so.
3. Restate focus and next step in one line.
4. Write down any conversational instruction that must persist (hot or lessons), now.
5. If the handoff note exists and is unconsumed, consume it; if it is already consumed, do not act on it as fresh.

## Failure modes

| Failure | Result | Prevention |
|---|---|---|
| Free-text handoff with optional fields | Missing parts silently skipped | Required fields; validator refusal |
| Note replayed after the work moved on | Agent redoes or reverses finished work | Consume on read |
| Handoff copies a spec | Two diverging copies | Pointers |
| Row edited later | History untrustworthy | Append a correcting row |
| Trusting the summary over the repo | Acting on drifted state | Re-ground step 2 |

## How an agent should apply this

- End every non-trivial session with a validated row; write "nothing decided" or "none" explicitly rather than leaving a field out.
- Write the single-use note for one named successor; mark it consumed on read.
- After any compaction, run the re-grounding checklist before editing files.
- Point to artifacts instead of pasting them; redact secrets.
- If the append capability is missing, report it and stop (P5); do not write the row somewhere unread.
