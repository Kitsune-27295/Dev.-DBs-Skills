# Diátaxis: Four Forms, the Map and the Compass

Sources: https://diataxis.fr/ · https://diataxis.fr/start-here/ · Last verified 2026-11-23

## What the framework is

A pragmatic way of thinking about documentation that prescribes content (what to write), style (how) and architecture (how to organize), built on four user needs. The name comes from Greek *dia* (across) and *taxis* (arrangement). Authors recommend using it like a handbook: learn by applying it to a real problem, not by reading everything first. The site claims adoption in hundreds of projects (vendor testimonials from Vonage, Gatsby and Cloudflare are on the front page; treat them as endorsements, not evidence).

## The four forms

| Form | Reader state | Writing posture | Typical title |
|---|---|---|---|
| Tutorial | Learning by doing | Lead the learner through a guided practice; the writer is responsible since no instructor is watching; keep explanation minimal and link out | "Build a simple game" |
| How-to guide | Competent, has a goal | Steps toward a specific real-world outcome; supports work | "Configure X", "Troubleshoot deploys" |
| Reference | Working, needs facts | Accurate, neutral, complete; structure mirrors the thing described | API tables, CLI flags |
| Explanation | Studying, wants understanding | Context, "why", opinions, alternatives | "Why we shard by tenant" |

## The map and the compass

Map: two axes show how forms relate; many documentation faults come from mixing or blurring forms.
Compass: ask two questions of any content.
1. Does it inform action or cognition?
2. Does it serve acquisition of skill (study) or application of skill (work)?

| Informs | Serves | Form |
|---|---|---|
| Action | Study | Tutorial |
| Action | Work | How-to guide |
| Cognition | Work | Reference |
| Cognition | Study | Explanation |

## Workflow (iterate, do not scaffold)

1. Look at current docs, or note none exist.
2. Ask what would improve them.
3. Pick one small improvement.
4. Do it; repeat.
The four-part structure emerges from repeated compass application rather than empty upfront directories.

## Example: splitting a mixed page

A "Configuring caching" page contains a walk-through, a table of every option, and two paragraphs on why TTLs matter. Compass result: walk-through becomes a how-to; the option table becomes reference; the TTL discussion becomes explanation; each links to the others.

```text
how-to/enable-caching.md      -> steps, links to reference/cache-options.md
reference/cache-options.md    -> table only
explanation/cache-ttl-tradeoffs.md
```

## Failure modes

- Tutorial that stops to explain theory or lists every option.
- Reference that tells stories or opinions.
- How-to that teaches basics to a beginner.
- Explanation hidden inside procedures.
- Building four empty folders first.

## How an agent should apply this

- Classify each paragraph with the compass before rewriting; split rather than blend.
- Keep tutorials as guided, safe, linear practice; move rationale to explanation links.
- Keep reference neutral and structured like the thing it documents.
- Make one small improvement per pass instead of a full restructure.
- Cross-link forms instead of duplicating content.
