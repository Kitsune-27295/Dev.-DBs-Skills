# Sources — Wizard (`wizard`)

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [mattpocock/skills — `skills/engineering/wizard/`](https://github.com/mattpocock/skills/tree/main/skills/engineering/wizard) (`SKILL.md`, `template.sh`) | 200 OK (raw files read; repository file tree confirms the path) | The scope-map-author-verify process and the bash wizard library (stages, prompts, `.env` upsert, `gh` writes). |
| [mattpocock/skills — `LICENSE`](https://github.com/mattpocock/skills/blob/main/LICENSE) | 200 OK | MIT License, Copyright (c) 2026 Matt Pocock. |

## License and attribution

The skill text and the script template are taken from the upstream repository under its MIT License (Copyright (c) 2026 Matt Pocock); the license notice is preserved here as required.

## Differences from upstream (`Dev.-DBs-Skills`)

- Frontmatter reduced to the portable `name` and `description` (a local copy also carried `model` and `effort` keys; they are harness-specific and removed).
- Appended "Quick Decision Checklist", "Deep references" and "Related skills in this pack"; sections numbered.
- Scoping step now says to read `.env.example`/non-secret config and variable names only, not a real `.env`, and never to print secrets into the conversation.
- **Safety hardening** of `template.sh` (the script was reviewed in full, not executed; `bash -n` passes):
  - `umask 077` and a `trap` that always removes the temporary file used by `write_env` (upstream left a world-readable temp copy of the env file in the system temp directory and deleted it only on the success path).
  - `write_env`: validates the key as a plain identifier, rejects values containing line breaks (dotenv line injection), and warns when a newly created env file inside a git repository is not git-ignored. The mode-0600 creation is kept.
  - `ask`, `ask_secret`, `set_secret`, `set_var`: key/name validated before it reaches `printf -v` or `gh`.
  - `set_secret` and `set_var`: explicit y/N confirmation that names the target repository before anything is sent to GitHub; declining records the item under "still to do by hand". Values are never printed (they already travel through stdin, not argv, for secrets).
  - `open_url`: only well-formed `https://` URLs are passed to the operating-system opener.
- Everything else in the library is unchanged, including `set -euo pipefail` and quoted variables (already present upstream).

## Reading limits

Only the two upstream files were read. The upstream repository also ships `agents/openai.yaml` for another harness and a docs page; neither is included.

## Claims not adopted as fact

The UX claims ("delightful", cross-platform URL opening including WSL) were not tested on every platform; only the script syntax was checked.
