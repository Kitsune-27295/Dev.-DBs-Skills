# Memory Channels and Size Caps

Sources: https://code.claude.com/docs/en/memory · https://www.anthropic.com/research/effective-context-engineering-for-ai-agents · https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions · https://arxiv.org/abs/2310.08560 · Last verified 2026-11-24

## Why four channels

One undifferentiated notes file fails in a predictable way: it grows, everything in it competes for attention, and nobody can tell a current priority from a year-old observation. Splitting by **lifetime and purpose** lets each channel have its own cap and its own rewrite rule. The split is this skill's design; the ingredients are supported by public sources:

- Anthropic's context-engineering article describes agents writing notes outside the context window and reading them back later, so progress survives resets (it names a notes file as an example without prescribing a format).
- The Claude Code memory docs describe an index loaded at session start (first 200 lines or 25 KB) with detail moved into topic files read on demand, and a reminder to keep one line per entry and to merge or drop stale ones.
- MemGPT separates a small, fixed-size, writable "working context" from larger external stores that must be explicitly retrieved, and warns the model when the window approaches its limit so it can save what matters.
- Nygard's decision-record form keeps one decision per short document and keeps superseded records as history.

## The channels in practice

### Hot (in flight)
The only channel that is **rewritten**, not appended. It answers "what must the next hour of work know". Cap: 60 lines. At wrap-up, move finished items to the journal and delete them from hot.

```
## Focus
- Migrating the export job to the new queue; step 3 of 5 (consumer wiring).
## Waiting on the user
- Decision on retry limit (proposed, see decisions/0007).
## Remember
- Test suite needs the local broker; start it before running integration tests.
```

### Lessons (with the incident)
Format: rule, then the incident and date. The incident is what lets a later reader judge whether the rule still applies; a bare rule cannot be checked and becomes folklore.

```
- Run the migration dry-run before the real one. Because: 2026-11-03, a
  column rename was applied to the shared dev database and broke two branches.
```

Cap: 500 characters per entry, about 40 entries. When a lesson repeats, promote it: propose it as a rule for the instruction layer (see `skill-orchestrator`) and, once accepted, remove it here so there is one owner (`ssot-and-dry`). When a lesson is contradicted by a newer one, supersede it (see `memory-hygiene`) instead of silently editing.

### Journal
One dated line per milestone or stopping point. It is the cheap answer to "what happened last week". Cap: 500 characters per line. Append-only; old months can be archived to a separate file without being edited.

```
2026-11-24  Export job consumer wired; flaky timeout traced to broker start order; next: backoff.
```

### Decisions
A decision is recorded when a choice has lasting consequences and is not obvious from the code. Required parts: name, context, decision, consequences. Status starts as `proposed`. The agent never marks its own record accepted. Never overwrite a record; a change of mind is a **new** record that supersedes the old one, and the old one keeps its text (the full practice is in `adr-architecture`). Size: aim for one page; Nygard recommends one to two pages so records are actually read.

## Cap reasoning

| Cap | Reason |
|---|---|
| 60 lines hot | Fits comfortably inside any index limit and forces triage. Larger hot files stop being read in full. |
| 500 characters per lesson or journal line | One thought per entry; longer text is usually a transcript in disguise. Refuse and shorten, do not truncate: a cut-off sentence can invert meaning. |
| About 40 lessons | Beyond this, lessons stop being scanned. Merge duplicates or promote repeated ones to rules. |
| One page per decision | Same reason as Nygard: long records go unread and unmaintained. |

These numbers are defaults chosen for this skill (inference, not measured values). The platform limits are different: for an auto-memory index they are the documented 200 lines or 25 KB, and anything beyond is not loaded.

## What to write when

| Moment | Action |
|---|---|
| Focus change | Replace the focus block in hot. |
| Trap discovered | Add one lesson with incident. |
| Milestone | One journal line. |
| Lasting choice | Proposed decision; tell the user. |
| Session end | Wrap-up (journal, decisions, lessons, hot, handoff, 3-line report). |

## Failure modes

- **Overflow by diligence:** every small observation becomes a lesson. Apply P3 (store what cannot be re-derived) and the incident requirement.
- **Two homes for one fact:** a rule in hot and in the instruction file. Keep one owner and link.
- **Stale hot:** an item "in flight" for a month. At wrap-up, either it is finished (journal), parked (a decision or handoff next-step), or dropped.
- **Cap-dodging:** splitting one long lesson into five lines. The cap measures information per entry; if five lines are one thought, it is still too long.

## How an agent should apply this

- Choose the channel by lifetime first, then size the entry to the cap; shorten yourself on refusal.
- Never write a lesson without the incident and its date; if you cannot name one, do not store it.
- Rewrite hot at every wrap-up; append to the journal; supersede, never overwrite, decisions and lessons.
- Keep one home per fact and point to it from elsewhere.
- Where a harness has its own memory index with limits, stay under them and link to `skill-orchestrator` for what those limits are.
