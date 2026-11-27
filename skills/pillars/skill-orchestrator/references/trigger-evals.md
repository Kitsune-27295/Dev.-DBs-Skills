# Trigger evals: skill-orchestrator

Last verified 2026-11-27 · Sources: [sources.md](sources.md)

Should trigger:
1. "Audit my CLAUDE.md, it is 600 lines and Claude ignores half of it." -> skill-orchestrator
2. "Add the Karpathy-style rules to our AGENTS.md and keep a CLAUDE.md in sync." -> skill-orchestrator
3. "Three skills match this task; which apply and in what order?" -> skill-orchestrator

Near-misses (neighbor owns it):
1. "Which model and effort should this subagent use?" -> `model-effort-routing`
2. "Split this SKILL.md into references and fix its frontmatter limits." -> `agent-skills-context-engineering`
3. "Make sure every fact lives in one place across these docs." -> `ssot-and-dry`
