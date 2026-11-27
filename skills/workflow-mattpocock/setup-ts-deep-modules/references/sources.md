# Sources — Setup TS Deep Modules (`setup-ts-deep-modules`)

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [mattpocock/skills — `skills/in-progress/setup-ts-deep-modules/`](https://github.com/mattpocock/skills/tree/main/skills/in-progress/setup-ts-deep-modules) (`SKILL.md`, `dependency-cruiser.config.cjs`) | 200 OK (raw files read; repository file tree confirms the path, under the upstream `in-progress` folder) | The entry-point boundary design, the four rules, the install/wire/scaffold/prove steps and the dependency-cruiser config. |
| [mattpocock/skills — `LICENSE`](https://github.com/mattpocock/skills/blob/main/LICENSE) | 200 OK | MIT License, Copyright (c) 2026 Matt Pocock. |

## License and attribution

The skill text and the config file are taken from the upstream repository under its MIT License (Copyright (c) 2026 Matt Pocock); the license notice is preserved here as required.

## Differences from upstream (`Dev.-DBs-Skills`)

- Frontmatter reduced to the portable `name` and `description`. Upstream (and a local copy) also set `disable-model-invocation: true`; a local copy added `model` and `effort`. All are harness-specific and removed; the description now ends with a "Use when ..." trigger, and the body says to run the skill only when the user asks.
- Sections numbered; added a note on the fifth rule in the config (`tests-folder-is-private`), "Quick Decision Checklist", "Deep references" and "Related skills in this pack".
- **Safety hardening**: step 2.7 now tells the user before creating a `CLAUDE.md`/`AGENTS.md` instead of creating one silently.
- `dependency-cruiser.config.cjs` is unchanged from upstream (read in full, not executed; it is a static configuration and `node --check` accepts it). It runs no commands and reads only source files.

## Reading limits

dependency-cruiser's option names were not re-verified against its current documentation; the config is as shipped upstream. The upstream skill sits in an `in-progress` folder, so it may change.

## Claims not adopted as fact

The "deep module" framing is the upstream author's design position, not an industry standard.
