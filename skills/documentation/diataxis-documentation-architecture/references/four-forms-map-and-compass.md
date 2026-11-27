# Diátaxis: Four Forms, the Map and the Compass

Sources: https://diataxis.fr/ · https://diataxis.fr/start-here/ · https://diataxis.fr/tutorials/ · https://diataxis.fr/how-to-guides/ · https://diataxis.fr/reference/ · https://diataxis.fr/explanation/ · https://diataxis.fr/application/ · Last verified 2026-11-27

## What the framework is

A systematic approach to technical documentation covering content (what to write), style (how) and architecture (how to organize), built on four user needs. It is meant to be learned by applying it, not by mastering the theory first. The site claims adoption in hundreds of projects and shows vendor testimonials; these are self-reported endorsements, not evidence.

## The four forms

| Form | Reader state | Writing posture | Example title |
|---|---|---|---|
| Tutorial | learning by doing | the teacher is responsible; follow-along steps, each with a visible result; no side paths; no explanation | "Build a simple game" |
| How-to guide | competent, has a goal | steps toward a real-world goal; conditional branches allowed; no teaching | "How to configure X" |
| Reference | working, needs facts | neutral, consistent, structured like the machinery; brief examples | API tables, CLI options |
| Explanation | studying, wants understanding | the why, alternatives, history, reasoned opinion | "About tenant sharding" |

## The compass

| Informs | Serves | Form |
|---|---|---|
| action | study | tutorial |
| action | work | how-to guide |
| cognition | work | reference |
| cognition | study | explanation |

Useful when writing (to clarify intent) and when reviewing (to spot a block in the wrong form).

## Example: splitting a mixed page

A "Configuring caching" page holds a walk-through, a table of every option, and two paragraphs on why TTLs matter. Compass result: the walk-through is a how-to, the table is reference, the TTL discussion is explanation; each links to the others.

```text
how-to/enable-caching.md          steps, links to the option table
reference/cache-options.md        table only
explanation/cache-ttl-tradeoffs.md
```

## Failure modes

- A tutorial that stops to explain theory or lists every option.
- Reference that tells stories or gives opinions.
- A how-to that teaches basics to a beginner.
- Explanation hidden inside procedures.

## How an agent should apply this

- Classify each paragraph with the compass before rewriting; split rather than blend.
- Keep tutorials linear and safe, with expected output; move rationale to explanation links.
- Keep reference neutral and shaped like the thing it documents.
- Make one small improvement per pass instead of a full restructure.
- Cross-link forms instead of duplicating content.
