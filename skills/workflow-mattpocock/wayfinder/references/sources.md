# Sources — Wayfinder (`wayfinder`)

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [mattpocock/skills — `skills/engineering/wayfinder/`](https://github.com/mattpocock/skills/tree/main/skills/engineering/wayfinder) (SKILL.md) | 200 OK (raw files read; repository file tree confirms the path) | The skill text and its supporting files. |
| [mattpocock/skills — `LICENSE`](https://github.com/mattpocock/skills/blob/main/LICENSE) | 200 OK | MIT License, Copyright (c) 2026 Matt Pocock. |

## License and attribution

The skill text and supporting files are taken from the upstream repository under its MIT License (Copyright (c) 2026 Matt Pocock); the license notice is preserved here as required.

## Differences from upstream (`Dev.-DBs-Skills`)

- Frontmatter reduced to the portable `name` and `description` (upstream also carries harness keys such as `disable-model-invocation` and `argument-hint`; removed because they are harness-specific).
- Removed the upstream `agents/openai.yaml` (client-specific metadata).
- Example links in `GLOSSARY-FORMAT.md` (domain-modeling) and the map template (wayfinder) turned into code spans so link checks pass.
- Appended "Related skills in this pack" and "Deep references".

## Reading limits

Only the upstream files named above were read; no upstream history or issues were consulted.

## Claims not adopted as fact

None beyond the upstream text itself; other local copies were compared only to decide which generic additions to keep (none kept unless listed above).
