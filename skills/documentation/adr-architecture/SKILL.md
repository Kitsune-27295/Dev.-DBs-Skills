---
name: adr-architecture
description: "Record why an architecture decision was made so later readers neither accept it blindly nor reverse it blindly: decide whether a choice is significant enough, write one short Architecture Decision Record (Nygard form, MADR or a Y-statement) with forces, considered options and honest consequences, keep it in Git, supersede instead of rewriting, and attach an automated check where possible. Use when a significant technical decision must be recorded, an ADR drafted or reviewed, an old ADR superseded, ADR process set up for a team, or when judging whether an old decision still holds. Not for choosing among styles or technologies (use architecture-decision-trees-tradeoffs), the domain glossary and terms captured in conversation (use domain-modeling) or full architecture documentation (use arc42-api-contracts-architecture)."
---

# Architecture Decision Records (ADRs)

One idea: **a short, version-controlled record of each significant decision, with the forces and the downsides, lets the next person change it for the right reasons.** Nygard names the two failures it prevents: accepting a decision blindly because nobody knows why it exists, and reversing it blindly and breaking what it protected. Sources, retrieved statuses and unadopted claims: [references/sources.md](references/sources.md).

## 1. Vocabulary

| Term | Meaning |
|---|---|
| Architecturally significant decision | a choice that shapes structure, non-functional characteristics, dependencies, interfaces or construction techniques (Nygard) |
| ASR | a requirement with a measurable effect on the architecture and its quality (adr.github.io) |
| AD | a justified design choice addressing an architecturally significant requirement |
| ADR | one AD with its rationale, trade-offs and consequences |
| Decision log | the set of ADRs of a project |
| Superseded | the decision was replaced; the old record stays and points to the new one |

## 2. Decide whether to write one

Write an ADR when future developers will need the "why", or the decision affects coordination, maintainability or an external interface. Skip non-architectural, tiny, low-risk or single-developer choices, decisions already covered by a standard, and temporary workarounds or experiments (Henderson). A new decision that replaces or invalidates an earlier one always gets a new record. Whether to choose A or B at all: `architecture-decision-trees-tradeoffs`.

## 3. Write the record

One decision per file, one or two pages. Sections (Nygard): Title, Context, Decision, Status, Consequences.

1. **Context**: the forces at play (technological, political, social, project-local), stated neutrally; say where they conflict.
2. **Considered options**: add this section even to the Nygard form (MADR makes it required). At least two options plus "do nothing", each with the real reason it lost; no straw men.
3. **Decision**: active voice, "We will ...", tied to the forces.
4. **Consequences**: all of them, positive, negative and neutral. A record with no downside is advocacy.
5. **Confirmation**: how the decision is checked (MADR's term), preferably an automated test or CI rule; see section 6.
6. **Status**: Proposed, Accepted, Rejected, Deprecated, or Superseded by a link.
7. Write full sentences as if talking to a future developer; bullets only for layout (Nygard).

Skeleton (own composition from the Nygard and MADR section sets):

```markdown
# 0007 Use PostgreSQL for order storage
Status: Accepted (2026-03-02)
## Context and problem
<forces, neutral, conflicts named>
## Considered options
<A chosen; B rejected because ...; do nothing: what breaks>
## Decision
We will ...
## Consequences
Good: ... Bad: ... Neutral: ...
## Confirmation
<test or check that keeps this true>
```

Y-statement short form, one sentence: use case, concern, chosen option, quality sought, accepted downside. The long form adds the neglected options and a "because" rationale (adr.github.io). Template choice and field details: [references/adr-team-governance-and-enforcement.md](references/adr-team-governance-and-enforcement.md).

## 4. Name, number and place

- Nygard: `doc/arch/adr-NNN.md`, numbers sequential and never reused. MADR: `NNNN-title-with-dashes.md` under `docs/decisions/`. Henderson: a present-tense imperative verb phrase, lowercase, dashes (`choose-database.md`). Pick one convention per repository and keep it.
- Store the record in the repository next to the code and review it in the pull request that builds the change (own recommendation).

## 5. Change, supersede, amend

- Reversal: write a new ADR that says what changed in the context; mark the old one superseded with a pointer, and link both ways. Never delete a record or hide a reversal.
- Mutability is disputed: Nygard keeps superseded records; Henderson says records are largely immutable yet teams found dated additions ("added after the decision") worked better in practice. Rule here: fix typos and add dated notes freely; never change the decision text itself.
- Review a record about a month after the decision against what happened, and periodically thereafter (Henderson's examples: one month; at least yearly).

## 6. Keep it from becoming shelfware

If a decision can be checked mechanically (dependency direction, "every state change emits an event"), put the check in CI and cite the ADR in it. Dependency-direction example: `hexagonal-architecture`, `clean-architecture`. Prose-only decisions decay; state which ones are prose-only.

## 7. Mistakes to catch

- A thirty-page architecture document instead of small records (Nygard: large documents go stale unread).
- Retroactive justification: pick the technology first, then invent weak alternatives.
- Context written as advocacy rather than forces.
- Only benefits under Consequences.
- Several decisions in one record.
- Editing an accepted decision in place when reversing it.
- ADRs turned into forced paperwork (Henderson: lead with the why).

## Quick Decision Checklist

- [ ] Is the decision significant and will a future reader need its why?
- [ ] One decision per record, one or two pages?
- [ ] Forces named neutrally, including conflicts?
- [ ] At least two real options plus do-nothing, each with a reason it lost?
- [ ] Negative and neutral consequences listed?
- [ ] Is there a check (automated if possible) or an explicit "prose only" note?
- [ ] If reversing: new record, old one marked superseded, links both ways?
- [ ] Stored in Git, numbered per the repository's convention, reviewed in the PR?

## Deep references

- [references/nygard-original-adr-form.md](references/nygard-original-adr-form.md): read when writing or reviewing an ADR's content and style.
- [references/adr-team-governance-and-enforcement.md](references/adr-team-governance-and-enforcement.md): read when setting team process, choosing a template or automating checks.
- [references/trigger-evals.md](references/trigger-evals.md): read when tuning this skill's description.
- [references/sources.md](references/sources.md): URL statuses, reading limits, claims not adopted.
