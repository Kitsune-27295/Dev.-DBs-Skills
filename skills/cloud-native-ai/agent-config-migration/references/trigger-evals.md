# Trigger Evals: agent-config-migration

Last verified 2026-11-27. Check the description against these before editing it.

## Should trigger

1. "I'm switching from Cursor to Claude Code; move my rules and MCP servers over without losing anything." -> `agent-config-migration`
2. "Write an import command that reads another agent's config and creates a removable bundle." -> `agent-config-migration`
3. "Convert my .mcp.json servers into Codex config.toml tables." -> `agent-config-migration`

## Near misses (another skill owns it)

1. "Which rules should live in CLAUDE.md and which should be hooks?" -> `skill-orchestrator`
2. "Restructure my SKILL.md so it loads lean." -> `agent-skills-context-engineering`
3. "Create a new skill from scratch for our release process." -> `skill-creation-workflow`
