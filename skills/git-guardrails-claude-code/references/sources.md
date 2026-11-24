# Sources — Git Guardrails for Claude Code (`git-guardrails-claude-code`)

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [mattpocock/skills — `skills/misc/git-guardrails-claude-code/`](https://github.com/mattpocock/skills/tree/main/skills/misc/git-guardrails-claude-code) (`SKILL.md`, `scripts/block-dangerous-git.sh`) | 200 OK (raw files read; repository file tree confirms the path) | The PreToolUse hook approach, the list of blocked commands, the install steps and the verification command. |
| [mattpocock/skills — `LICENSE`](https://github.com/mattpocock/skills/blob/main/LICENSE) | 200 OK | MIT License, Copyright (c) 2026 Matt Pocock. |

## License and attribution

The skill text and the hook script are taken from the upstream repository under its MIT License (Copyright (c) 2026 Matt Pocock); the license notice is preserved here as required.

## Differences from upstream (`Dev.-DBs-Skills`)

- Frontmatter reduced to the portable `name` and `description` (a local copy also carried `model` and `effort` keys; they are harness-specific and removed).
- Sections numbered; added "Limits", "Quick Decision Checklist", "Deep references", "Related skills in this pack"; install step now says to show the script to the user first, check for `jq`, and show the merged settings diff.
- **Safety hardening** of `scripts/block-dangerous-git.sh` (read in full, not executed; `bash -n` passes; the regular expressions were checked against sample commands with `grep -E`):
  - `#!/usr/bin/env bash` with `set -euo pipefail` (upstream had neither).
  - Fails closed: if `jq` is missing or the hook JSON cannot be parsed, the call is blocked with an explanation instead of silently allowing everything (upstream passed an empty command and allowed it).
  - The blocked message no longer echoes the full command (it can contain tokens or passwords that would land in the transcript); it names only the matched label.
  - Variables quoted and `printf '%s'` used instead of `echo`; `grep -qE --` so a command starting with a dash is not read as an option.
  - Patterns now tolerate git global options (`git -C dir push`) and extra spaces, and use anchored forms (`git branch -D`, `git clean -f` with combined flags such as `-xdf`) instead of loose substring matches. The redundant `push --force` and `reset --hard` bare patterns were removed because `git push` and `git reset --hard` already cover them.

## Reading limits

The script cannot be verified against every shell form an agent might use; this is stated in the skill's "Limits" section.

## Claims not adopted as fact

The upstream wording "The user has prevented you from doing this" is kept as the agent-facing message, but the skill does not claim the hook is a security control; it is a guardrail against accidents.
