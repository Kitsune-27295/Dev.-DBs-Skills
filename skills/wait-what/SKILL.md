---
name: wait-what
description: "Stop. That last message did not land: re-pitch it. Use when the user says they did not understand your last message or where you have got to, and needs a plain-language re-explanation with context and the project's shared vocabulary."
---

# Wait, what?

Wait, I don't understand where you've got to here. Re-pitch that: give me a little bit of context, talk in ASD-STE100 Simplified Technical English, and use the ubiquitous language from `GLOSSARY.md` (follow `GLOSSARY-MAP.md` to the right one if the repo has more than one).

Provenance: [references/sources.md](references/sources.md). Upstream makes this a user-invoked skill: run it when the user asks.

## How to apply

1. Start with two or three sentences of context: what we are doing and why.
2. Say what you did or decided, then what you need from the user (if anything). Short sentences, one idea each, active voice, no idioms.
3. Use the project's glossary terms exactly; do not coin synonyms. If there is no `GLOSSARY.md`, use the terms the user already used.
4. If the glossary lacks a term you need, say so and propose one instead of inventing it silently.

## Quick Decision Checklist

- [ ] Context first, then the point
- [ ] Short sentences, plain words, glossary terms
- [ ] The next action for the user is explicit

## Deep references

- [references/sources.md](references/sources.md) — upstream source and license

## Related skills in this pack

- `grilling` and `grill-me` for question-driven alignment.
- `clean-code-for-agents` for naming and vocabulary discipline.
