# Sources — Diagnosing Bugs (`diagnosing-bugs`)

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [mattpocock/skills — `skills/engineering/diagnosing-bugs/`](https://github.com/mattpocock/skills/tree/main/skills/engineering/diagnosing-bugs) (`SKILL.md`, `scripts/hitl-loop.template.sh`) | 200 OK (raw files read; repository file tree confirms the path) | The six-phase diagnosis discipline (feedback loop first, reproduce and minimise, ranked falsifiable hypotheses, one-variable instrumentation, regression test at a correct seam, cleanup) and the human-in-the-loop script template. |
| [mattpocock/skills — `LICENSE`](https://github.com/mattpocock/skills/blob/main/LICENSE) | 200 OK | MIT License, Copyright (c) 2026 Matt Pocock. |

## Licence and attribution

The skill text and the script template are taken from the upstream repository under its MIT License (Copyright (c) 2026 Matt Pocock); the licence notice is preserved here as required.

## Differences from upstream (`Dev.-DBs-Skills`)

- Frontmatter reduced to the portable `name` and `description` (a local copy also carried `model` and `effort` keys; they are harness-specific and removed).
- Appended the section "Related skills in this pack" (links to `race-condition-fix`, `transaction-fix`, `idempotency-fix`, `query-performance`, `tdd`, `playwright-qa-orchestrator`, `code-review`).
- The script template is unchanged; it only prompts for observations and prints them, and writes no files or secrets.

## Possible future refinement (not done)

Cross-check the phases against public sources on debugging method (for example Agans, *Debugging*; SRE incident practice) and record any differences here.
