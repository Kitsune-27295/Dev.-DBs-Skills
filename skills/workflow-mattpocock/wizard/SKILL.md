---
name: wizard
description: Generate an interactive bash wizard that walks a human through steps only they can perform. Use when provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover. Don't invoke this for steps the agent can perform itself.
---

# Wizard

A **wizard** is a bash script that walks a human, step by step, through a manual procedure that's tedious to do by hand and tedious to re-explain to an AI every time. It opens each URL, says exactly what to click and copy, captures the values, writes them where they belong (`.env`, GitHub secrets), confirms at every stage, and shows how many stages are left. It might configure third-party services, run a one-off migration, or move the project from one state to another. Provenance and safety changes: [references/sources.md](references/sources.md).

The delightful UX is already solved by [template.sh](template.sh): stage-by-stage progress, confirmation gates, cross-platform URL opening (including WSL), hidden secret entry, idempotent `.env` upserts, `gh secret`/`gh variable` writes (each behind an explicit confirmation), and a closing summary. **Your job is only to scope the procedure and author its stages.** The library above the `STAGES` marker is identical in every wizard; that consistency is the point: never hand-edit it.

A wizard is ephemeral by default: built for one run, saved to a scratch or `scripts/` path, deleted when the job's done. Commit it only when the user wants a repeatable setup path that should live in the repo.

## 1. Process

### 1.1 Scope the procedure

Work out every manual step the human must take and every value that gets captured along the way. Read the repo first, don't ask cold:

- For setup: `.env.example` and other **non-secret** config (`README`, `docker-compose*`, framework config, `.github/workflows/*`; every `secrets.*` / `vars.*` reference is a value the wizard must produce). Read variable **names** only; do not open a real `.env` or print secret values into the conversation.
- For a migration or transition: the current state, the target state, and the irreversible actions between them.

Then show the user the ordered list of stages and the values each produces, and confirm: they may add, drop, or reorder.

**Done when:** every stage is named in order, and for each captured value you know (a) where the human gets it, (b) where it's written (`.env`, a GitHub secret, both, or nowhere; some stages are pure actions), and (c) whether it's secret (hidden entry) or public.

### 1.2 Map each stage's journey

For each stage, write the precise path a human follows: which URL to open, what to do there, where a value is shown, which variable it fills: e.g. "Dashboard → Developers → API keys → Reveal test key → copy". Where you don't actually know the current UI or the exact command, say so and ask the user or check the docs: never invent steps that may not exist.

**Done when:** every stage traces to concrete instructions a stranger could follow.

### 1.3 Author the wizard

Copy `template.sh` to the target path. Replace the example stage with one `stage` per step, in dependency order. Use the library helpers: `stage`, `say`/`step`, `open_url`, `ask`/`ask_secret`, `write_env`, `set_secret`/`set_var`, `pause`/`confirm`. Set `TOTAL_STAGES` to the number of stages you wrote.

Hold the bar the template sets:

- open the URL (https only) before asking for its value;
- `ask_secret` for anything secret, never `ask`;
- `write_env` every persisted value, and make sure the env file is git-ignored;
- `set_secret` only the values CI actually needs; the library asks the human to confirm the target repository first;
- `confirm` before any irreversible action;
- never `echo`/`say` a secret value, and never pass one on a command line (the library pipes it through stdin).

Each `stage` clears the screen so only the current step is visible: keep a stage to one focused task so nothing the human needs scrolls away. Don't touch the library above the marker.

### 1.4 Verify and hand off

- `bash -n <script>`; run `shellcheck` if available.
- `chmod +x <script>`.
- Don't run it end-to-end yourself: it opens browsers and blocks on human input. Trace it statically instead: every value from step 1.1 is captured and lands where step 1.1 said, and every `set_secret` name exactly matches a `secrets.*` reference in CI.
- Tell the user how to run it, and that it stores secrets in the env file (mode 0600) and, after confirmation, in GitHub. If it's a repeatable setup path, commit it (without values) and link it from the README so the next person runs the script instead of asking an AI.

## Quick Decision Checklist

- [ ] The steps really need a human (otherwise do them yourself, no wizard)
- [ ] Stages and captured values confirmed with the user
- [ ] Secret values entered with `ask_secret`, never echoed
- [ ] Env file git-ignored; `set_secret` limited to what CI needs
- [ ] Library above the marker untouched; `bash -n` passes
- [ ] Not executed by the agent

## Deep references

- [references/sources.md](references/sources.md) — upstream source, license, safety hardening

## Related skills in this pack

- `diagnosing-bugs` (its human-in-the-loop script template follows the same idea).
- `twelve-factor-cloud-native` for where configuration and secrets should live.
- `security-audit` and `never-trust-the-client` before committing any setup script that handles credentials.
- `git-atomic-commits` when the wizard is committed to the repo.
