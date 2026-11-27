# Sources — Setup Pre-Commit Hooks (`setup-pre-commit`)

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [mattpocock/skills — `skills/misc/setup-pre-commit/`](https://github.com/mattpocock/skills/tree/main/skills/misc/setup-pre-commit) (`SKILL.md`) | 200 OK (raw file read; repository file tree confirms the path) | The Husky + lint-staged + Prettier setup steps, default configs and verification list. |
| [mattpocock/skills — `LICENSE`](https://github.com/mattpocock/skills/blob/main/LICENSE) | 200 OK | MIT License, Copyright (c) 2026 Matt Pocock. |

## License and attribution

The skill text is taken from the upstream repository under its MIT License (Copyright (c) 2026 Matt Pocock); the license notice is preserved here as required.

## Differences from upstream (`Dev.-DBs-Skills`)

- Frontmatter reduced to the portable `name` and `description` (a local copy also carried `model` and `effort` keys; they are harness-specific and removed).
- Sections numbered; added "Quick Decision Checklist", "Deep references" and "Related skills in this pack".
- **Safety hardening** (the skill has no scripts): the final step no longer commits automatically; it lists the files and commits only after the user agrees, staging only those files and never using `--no-verify`. Dependency install is announced first, and an existing `prepare` script or `.husky/pre-commit` is not overwritten.
- Added a note on slow commit-time test suites.

## Reading limits

Husky, lint-staged and Prettier behavior was not re-verified against their current documentation; the commands are those of the upstream skill.

## Claims not adopted as fact

None beyond the upstream defaults, which are presented as defaults, not recommendations for every repository.
