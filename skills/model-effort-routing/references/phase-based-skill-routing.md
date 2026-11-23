# Phase-Based Skill Routers and Multi-Model Run Composition

Sources: https://github.com/eric861129/Workflow-skill-router · https://github.com/haowjy/orchestrate · https://github.com/orchestra-research/AI-research-SKILLs · https://github.com/tiagopgr/skills-ia · https://github.com/topics/antigravity-skills · Last verified 2026-11-23

## 1. Workflow-skill-router (MIT; Claude Code and Codex plugins)

Picks the lead Skill for the current phase, adds only the support that phase needs, and shows the plan before work.
- Work shapes: Single (one intent), Phased (e.g. contract, implementation, verification; each phase has a primary skill, optional support, an exit gate, rerouted from current evidence), Managed Goal (resumable dependency graph; the Codex Goal stays host-owned).
- Route steps: read task and explicit choice, apply a Routing Profile (keywords/domains/tags/modes), check runtime capabilities (a planned skill is "intended-unverified" until confirmed installed), expose route, gaps and needed consent.
- Precedence: host hard constraints, user-named skill, workspace profile, personal profile, built-in routing; a matched workspace tree replaces the personal one wholesale.
- Boundaries: a user-named skill is authoritative; extra support needs consent; rejected support stays out; unavailable capability fails closed with a typed response; it does not install skills, select the model, grant deploy permission or mutate the goal. No telemetry by default. Its own evaluation is described as exploratory, showing no proven cost/speed/quality gain. Needs Node 24+ and Python 3.11+ for plugins; the standalone Codex skill cannot enforce consent state.
- Note it explicitly does NOT pick models: phase routing and model routing are separate concerns.

## 2. haowjy/orchestrate (MIT; Claude Code, Codex, OpenCode)

A run = model + skills + prompt; skills discovered at runtime from frontmatter. `run-agent` picks the harness from the model name: `claude-*` to Claude Code, `gpt-*`/`o1-*`/`o3-*`/`codex-*` to Codex, `provider/model` to OpenCode (Gemini reached this way). `--variant` (default `high`) maps to `--effort` (Claude), `model_reasoning_effort` (Codex), `--variant` (OpenCode); presets low/medium/high are portable, other values pass through, and unknown providers silently ignore it (still logged). Profiles set default model, variant, skills, tools, sandbox; CLI flags override. Config in `.orchestrate/config.toml`; `--strict-skills` fails on unknown skills. Security warning: with no agent profile it runs Claude with `--dangerously-skip-permissions` and Codex with approval/sandbox bypass; use only in an externally sandboxed environment. A Python rewrite is announced. The model-guidance logic itself was not described on the page.

## 3. AI-research-SKILLs (Orchestra Research, MIT)

98 skills (page also says 87; inconsistent) in 23 numbered categories. The `0-autoresearch-skill` is a router with an inner optimization loop and an outer synthesis loop across five phases: literature survey, ideation, experiments, synthesis, paper writing; state persisted in files (`research-state.yaml`, `findings.md`, `research-log.md`), runnable under Claude Code `/loop`. Installer puts skills in `~/.orchestra/skills/` and symlinks into detected agents (copies on Windows). Frontmatter: name, description, version; kebab-case names, third-person descriptions. Antigravity not mentioned.

## 4. Low-relevance sources

- tiagopgr/skills-ia (MIT): 1,100+ Portuguese prompt-library "skills" in 13 categories, plugin-installable; no router, no model rules, no frontmatter.
- github.com/topics/antigravity-skills: lists no real router; nearest are agentic-awesome-skills (AAS Core: catalog search plus plan preview, "does not rank or recommend") and superpowers-antigravity (workflow skills).

## 5. Design lessons (partly inference)

- Separate three decisions: which skill leads a phase, which model/effort runs it, which harness hosts it.
- Exit gates per phase beat free-form "keep going".
- Persist state in files so a router can resume across sessions.
- Verify capability before planning on it.

## How an agent should apply this

- For multi-phase work, name a lead skill and an exit gate per phase; reroute from evidence between phases.
- Let a user-named skill win; ask before adding support skills.
- When composing cross-vendor runs, map effort through a portable low/medium/high vocabulary and log it.
- Never run subagents with permission-bypass flags outside a sandbox.
- Persist phase state to disk if the work spans sessions.
