# Sources — Handoff (`handoff`)

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [mattpocock/skills — `skills/productivity/handoff/`](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff) (`SKILL.md`; also `skills/in-progress/claude-handoff/SKILL.md` for the optional section) | 200 OK (raw files read; repository file tree confirms the path) | The skill text and its supporting files. |
| [mattpocock/skills — `skills/in-progress/claude-handoff/`](https://github.com/mattpocock/skills/tree/main/skills/in-progress/claude-handoff) | 200 OK | The `claude --bg` launch variant. |
| [mattpocock/skills — `LICENSE`](https://github.com/mattpocock/skills/blob/main/LICENSE) | 200 OK | MIT License, Copyright (c) 2026 Matt Pocock. |

## License and attribution

The skill text and supporting files are taken from the upstream repository under its MIT License (Copyright (c) 2026 Matt Pocock); the license notice is preserved here as required.

## Differences from upstream (`Dev.-DBs-Skills`)

- Frontmatter reduced to the portable `name` and `description` (upstream also carries harness keys such as `disable-model-invocation` and `argument-hint`; removed because they are harness-specific).
- Removed the upstream `agents/openai.yaml` (client-specific metadata).
- Appended "Related skills in this pack" and "Deep references".
- Folded the upstream `in-progress/claude-handoff` skill in as the clearly marked optional section "Optional: Claude Code CLI variant" (reworded to be conditional; the upstream folder is marked in-progress).

## Reading limits

Only the upstream files named above were read; no upstream history or issues were consulted.

## Claims not adopted as fact

None beyond the upstream text itself; other local copies were compared only to decide which generic additions to keep (none kept unless listed above).
