# The Docs Variant: Grill While Keeping an ADR and a Glossary

Sources: https://github.com/mattpocock/skills/blob/main/skills/engineering/grill-with-docs/SKILL.md (MIT) · https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/SKILL.md (MIT) · Last verified 2026-11-24

## What it is
The upstream `grill-with-docs` is a thin wrapper: run the grilling interview and, alongside it, the domain-modeling discipline, so decisions and vocabulary are written down as they settle instead of living only in chat.

## How to run it here
- Run the rounds exactly as in `SKILL.md`; additionally load `domain-modeling` for its glossary and ADR formats.
- When a round settles a term, add it to the glossary at once (create the file lazily on the first term). When two words collide, ask which one the project means, then record the winner and the rejected synonyms.
- When a round settles a hard-to-reverse, surprising decision with a real trade-off, write one ADR for it. Decision records and their template: `adr-architecture`; glossary and model-sharpening discipline: `domain-modeling`.
- Do not write a doc for a decision the user has not confirmed; a recommended answer is not a decision until accepted.
- The end condition is unchanged (empty frontier, user confirms), plus: every settled term and decision is on disk.

## How an agent should apply this
- Use this variant only when the user asks for docs or the project already keeps a glossary or ADR folder.
- Keep one owner per rule: interview mechanics stay in `SKILL.md`; doc formats stay in `domain-modeling` and `adr-architecture`.
