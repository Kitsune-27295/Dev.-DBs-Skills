# Antigravity Skills: Format, Install Paths and Frontmatter

Sources: https://antigravity.google/docs/skills/ · https://codelabs.developers.google.com/getting-started-with-antigravity-skills · https://github.com/rmyndharis/antigravity-skills · https://github.com/google-deepmind/science-skills · Last verified 2026-11-27

The official skills page was re-read 2026-11-27 (install paths, frontmatter and loading unchanged from the earlier read); the codelab and community-repo pages were not re-fetched.

## Install locations (official docs)

| Surface | Project scope | Global scope |
|---|---|---|
| Antigravity App | `<workspace>/.agents/skills/<skill>/` (also parent folders up to repo root) | `~/.gemini/config/skills/<skill>/` |
| Antigravity CLI (`agy`) | same workspace path (+ parents) | `~/.gemini/config/skills/` (shared with App); additionally `~/.gemini/antigravity-cli/skills/` and `~/.gemini/skills/` (App does not read these); plugin skills under `~/.gemini/config/plugins/<plugin>/skills/` |
| Antigravity IDE (standalone) | same workspace path | `~/.gemini/config/skills/`; legacy `~/.gemini/antigravity/skills/` still read |

- Default project folder is `.agents/skills`; the older `.agent/skills` is still supported.
- The codelab adds: tools such as `npx skills` and `uvx google-agents-cli setup` install to `~/.agents/skills`, which the App sees but the CLI does not (copy to a project or global folder).
- The community port rmyndharis/antigravity-skills documents an `AG_SKILLS_DIR` env override for its installer (a repo feature, not an Antigravity feature).
- The codelab names two global paths without explaining the difference; the official page is the authority and the split is by surface.

## Folder layout

`SKILL.md` required; optional `scripts/`, `examples/`, `resources/` (official page). The codelab shows `references/` and `assets/` instead and does not say names are fixed. Treat all as conventions; reference them by relative path from the body.

## Frontmatter fields actually read

| Field | Status |
|---|---|
| `name` | optional, lowercase-hyphen, defaults to folder name |
| `description` | required; the only trigger signal the router sees |

The official page documents no other fields. There is NO `model`, `effort`, `allowed-tools`, `disable-model-invocation` or `paths` field in the documented schema (verified by absence on the official page and the codelab; unknown fields are undocumented, so do not rely on them). Consequence: model/effort choice cannot be pinned per skill in Antigravity; it must be written as body prose or handled by the harness/user model picker.

The community port's validator additionally rejects descriptions starting with "You are" or asking for proactive use, and rejects Claude-Code-only syntax (`$ARGUMENTS`, Task-tool steps). Recommended body sections there: "Use this skill when", "Do not use this skill when", "Instructions", plus "Safety" for infra changes.

## Loading model

1. Each turn the agent sees name + description of every skill (a "menu").
2. If relevant, it reads the full `SKILL.md`; scripts run by relative path.
3. Manual invocation: `/<skill-name>` in the App; in the CLI every skill is a slash command; run `/skills reload` after adding one mid-session; `/skills` lists them. IDE: Customizations menu.
- CLI plugin commands: `agy plugin list [--json]`, `agy plugin install <name|GitHub URL|path>`.
- Caveat (from antigravity-orchestra README): headless `agy -p` does not load the workspace `.agents/` config.
- Global Rules can mandate a skill and Workflows can chain skills (codelab).

## Anti-patterns

- Installing hundreds of skills: metadata overhead and spurious activation (rmyndharis recommends bundles/search over `install --all`).
- Vague descriptions ("Database tools"): the codelab calls them insufficient.
- Putting plugin-installed skill edits in the plugin dir: updates overwrite them (science-skills advises `~/.gemini/config/skills/` for custom skills).
- Science-skills (Google DeepMind, Apache-2.0 software, not an official Google product) documents no frontmatter fields and no model/effort routing.

## How an agent should apply this

- Writing for Antigravity: only `name` + `description`; make the description carry every trigger phrase.
- Never assume a `model:`/`effort:` field works there; put tier advice in the body.
- Install to `.agents/skills/` for a project, `~/.gemini/config/skills/` for global; check `/skills` after.
- For CLI-only extra paths, remember App and CLI read different global folders.
- Re-verify paths before documenting; Antigravity moved from `.agent` to `.agents` and from `~/.gemini/antigravity/skills` to `~/.gemini/config/skills`.
