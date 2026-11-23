# Cross-Harness Portability Checklist (Claude Code, Antigravity, Codex, Gemini CLI)

Sources: https://antigravity.google/docs/skills/ · https://github.com/sickn33/agentic-awesome-skills · https://github.com/rmyndharis/antigravity-skills · https://github.com/haowjy/orchestrate · https://github.com/eric861129/Workflow-skill-router · https://github.com/orchestra-research/AI-research-SKILLs · Last verified 2026-11-23

## Common ground

Every source uses a folder with `SKILL.md` (YAML frontmatter + Markdown) and optional `scripts/`, `references/`. All agree on progressive disclosure: name+description always visible, body loaded on match. The one field you can count on everywhere is `description`.

## Per-harness facts verified from the sources

| Harness | Install/target evidence | Notes |
|---|---|---|
| Antigravity | `.agents/skills/` (project), `~/.gemini/config/skills/` (global) | frontmatter: `name`, `description` only documented |
| Claude Code | plugins (`/plugin marketplace add`, `/plugin install`) per Workflow-skill-router, AI-research-SKILLs, skills-ia; AAS `--agent claude-code` | richer frontmatter exists in Claude Code but is not covered by these sources |
| Codex | plugin (`codex plugin ...`) or standalone skill folder; AAS `--agent codex --scope user --pin <tag>` | standalone mode cannot enforce router consent |
| Gemini CLI | AAS `--agent gemini-cli`; Antigravity CLI also reads `~/.gemini/skills/` | exact Gemini CLI path not documented in the pages read |
| Installers | AAS supports Cursor, Copilot, Kiro, OpenCode, AdaL, `--dir`; `npx skills` writes `~/.agents/skills` | App reads it, `agy` does not |

AAS (agentic-awesome-skills, formerly antigravity-awesome-skills, 3,100+ skills, tool MIT / content CC BY 4.0, imported skills keep their licenses incl. some AGPL) pins installs to release tags and previews with `gh skill preview`.

## Portability rules

1. Frontmatter: keep `name` (== folder, kebab-case) and a trigger-rich `description`; treat any other field (`model`, `effort`, `allowed-tools`, `disable-model-invocation`) as harness-specific and optional. Antigravity documents none of them.
2. Body: avoid harness-only syntax. The Antigravity port validator rejects `$ARGUMENTS` and Task-tool steps, and descriptions starting "You are".
3. Model/effort: say tiers in vendor-neutral words (cheap/fast, mid, strongest) with a mapping table per harness, since Antigravity cannot pin models per skill. For effort, a portable low/medium/high vocabulary maps to `--effort` (Claude), `model_reasoning_effort` (Codex), `--variant` (OpenCode) per haowjy/orchestrate.
4. Paths in the body: relative only; never hardcode `~/.claude`.
5. Scripts: prefer cross-platform (Python/Node); the orchestra template uses PowerShell, which is Windows-biased.
6. Headless modes may skip skill loading (`agy -p` ignores workspace `.agents/`); test the actual mode you ship for.
7. Delegation tools differ per host; use only what the host exposes and say so (subagent-orchestrator guardrail).
8. Do not install the whole catalog: metadata overhead and false activations grow with count.
9. Licenses: check each imported skill; MIT/Apache/CC-BY/AGPL mix in AAS.

## Verification routine

- After install: ask "what skills are available?" or run `/skills`; in `agy` use `/skills reload` after additions.
- Test a trigger phrase in each harness and confirm the same skill activates.
- Diff the frontmatter against each harness's validator.

## How an agent should apply this

- Author once with the minimal frontmatter, then add harness extras in a clearly separated block or sibling file.
- Ship a per-harness install table in the skill references and date it.
- Put model/effort guidance in prose with a tier-to-model table, not in unsupported fields.
- Run a trigger smoke test in every target harness before claiming portability.
- Flag any path or field you could not verify as "not read from source".
