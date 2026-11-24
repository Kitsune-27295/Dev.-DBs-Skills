# Sources — To Questionnaire (`to-questionnaire`)

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [mattpocock/skills — `skills/productivity/to-questionnaire/`](https://github.com/mattpocock/skills/tree/main/skills/productivity/to-questionnaire) (`SKILL.md`) | 200 OK (raw file read; repository file tree confirms the path) | The "grill the send, not the subject" method, the three steps and the questionnaire template. |
| [mattpocock/skills — `LICENSE`](https://github.com/mattpocock/skills/blob/main/LICENSE) | 200 OK | MIT License, Copyright (c) 2026 Matt Pocock. |

## License and attribution

The skill text is taken from the upstream repository under its MIT License (Copyright (c) 2026 Matt Pocock); the license notice is preserved here as required.

## Differences from upstream (`Dev.-DBs-Skills`)

- Frontmatter reduced to the portable `name` and `description`. Upstream (and a local copy) set `disable-model-invocation: true`; a local copy added `model` and `effort`. All are harness-specific and removed; the description gained a "Use when ..." trigger and the body says to run the skill when the user asks.
- Sections numbered; added a line forbidding secrets and third-party personal data in the document (it is sent to someone else), "Quick Decision Checklist", "Deep references" and "Related skills in this pack".
- No scripts in this skill.

## Reading limits

Only the upstream `SKILL.md` was read; the upstream docs page for the skill was not included.

## Claims not adopted as fact

None.
