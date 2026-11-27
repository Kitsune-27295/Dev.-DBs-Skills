# Nygard's Original ADR: Rationale, Form, Style

Sources: https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions · https://adr.github.io/ · Last verified 2026-11-27

## Why records exist

Agile projects reach architecture gradually, so it has to be documented in small pieces; large documents go stale and are not read. Without the reasons behind past decisions a newcomer either accepts them without understanding or reverses them without knowing what they protect. Both can damage the project.

## What counts as significant

Decisions affecting structure, non-functional characteristics, dependencies, interfaces or construction techniques. One record covers one decision.

## The five parts

| Part | Content | Style rule |
|---|---|---|
| Title | Short noun phrase with a number (his example: "ADR 9: LDAP for Multitenant Integration") | |
| Context | Forces: technological, political, social, project-local; they often conflict | Neutral, factual |
| Decision | The response to the forces | Full active-voice sentences starting "We will" |
| Status | Proposed, accepted, or later deprecated or superseded, with a pointer | |
| Consequences | The resulting context: all results, including negative and neutral | Not only the favorable ones |

Mechanics: file at `doc/arch/adr-NNN.md` in the repository, Markdown or similar, numbers sequential and never reused, a reversed decision stays and is marked superseded, one to two pages, written like a conversation with a future developer in full sentences (bullets only for layout).

```markdown
# ADR 7: Use PostgreSQL for order storage
Status: Accepted
## Context
We need transactional integrity across orders and payments; the team knows SQL; operations already runs Postgres.
## Decision
We will store orders in PostgreSQL and keep search in the existing index.
## Consequences
Transactions are simple. Horizontal write scaling is harder; if write volume outgrows one node, a later ADR would supersede this one.
```

## Compounding effect

One record's consequences become the next record's context, like a pattern language. Nygard's experience report: six to ten rotating developers over several projects since August 2011 said the records gave useful context, and they captured long-term plans such as a future re-architecture. The author concedes the trial was short, so treat this as anecdote. Concern that non-developers cannot use version control: private GitHub repositories render Markdown and links can be shared.

## Vocabulary (adr.github.io)

AD: justified design choice addressing an architecturally significant requirement. ASR: requirement with measurable effect on the architecture. ADR: one AD with rationale, trade-offs and consequences. Decision log: the ADRs of a project. The site credits Nygard's 2011 post with popularizing the idea; its overview page does not itself detail templates or the Y-statement.

## Failure modes

- Context written as advocacy instead of forces.
- Only positive consequences.
- Several decisions in one record.
- Editing an old record to hide a reversal.

## How an agent should apply this

- Check significance before drafting; say so when a choice does not qualify.
- Write Context as conflicting forces in neutral prose and Decision as "We will ...".
- List negative and neutral consequences explicitly.
- Never delete or silently rewrite an accepted record; add a superseding one.
- Link a new record to those whose consequences created its context.
