# Nygard's Original ADR: Rationale, Form, Style

Sources: https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions · https://adr.github.io/ · Last verified 2026-11-23

## Why records exist

Agile projects reach architecture incrementally. Big specification documents go stale and are unread; small modular documents survive. A newcomer facing an old decision has two bad options: accept it blindly (it may be obsolete) or reverse it blindly (it may break a requirement it served). ADRs give the "why" so both can be avoided.

## What counts as significant

Decisions affecting structure, non-functional characteristics, dependencies, interfaces or construction techniques. One ADR = one decision for one project; it should shape how the rest of the project runs.

## The five parts

| Part | Content | Style rule |
|---|---|---|
| Title | Short noun phrase ("ADR 9: LDAP for Multitenant Integration") | |
| Context | Forces at play: technological, political, social, project-local; they often conflict, say so | Neutral, factual |
| Decision | The response to the forces | Active voice, "We will ..." |
| Status | Proposed, accepted, deprecated or superseded (with pointer) | |
| Consequences | The resulting context: positive, negative, neutral | All of them, not only benefits |

Mechanics: file at `doc/arch/adr-NNN.md` in the repo, Markdown or similar, sequential numbers never reused, a reversed decision stays and is marked superseded, 1-2 pages, written as a conversation with a future developer in full sentences (bullets only for layout).

```markdown
# ADR 7: Use PostgreSQL for order storage
Status: Accepted
## Context
We need transactional integrity across orders and payments; the team knows SQL; ops already runs Postgres.
## Decision
We will store orders in PostgreSQL and keep search in the existing index.
## Consequences
Transactions are simple. Horizontal write scaling is harder; revisit above ~N writes/s (ADR 12 would supersede).
```

## Compounding effect

One ADR's consequences are the next ADR's context, as in Alexander's pattern language. Nygard's experience report: six to ten rotating developers found the context useful, and ADRs were especially good for recording long-term intentions (planned re-architectures) so present work does not make them harder. Objection about accessibility for managers: render Markdown in the hosted repo and share links.

## Vocabulary (adr.github.io)

- Architectural Decision (AD): justified design choice addressing an architecturally significant requirement.
- ASR: requirement with measurable effect on architecture.
- ADR: one AD with rationale, trade-offs, consequences. Decision log: the set of ADRs. All belong to Architectural Knowledge Management.
- The site is an index: it points to Zdun's Y-statement, a seven-template comparison (WICSA 2015) and tooling, without detailing them (those details come from the next reference file).

## Failure modes
- Context written as advocacy rather than forces.
- Only positive consequences listed.
- Multiple decisions in one record.
- Editing an old record to hide a reversal (instead of superseding).

## How an agent should apply this

- Check the decision is architecturally significant before writing one.
- Write Context as conflicting forces in neutral language; Decision as "We will ...".
- List negative and neutral consequences explicitly.
- Never delete or silently rewrite an accepted ADR; add a superseding one.
- Link new ADRs to the ones whose consequences created their context.
