# Sources — Agent Config Migration

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://agents.md | 200 OK | AGENTS.md as plain Markdown with no required fields, root plus nested files, nearest file wins, user prompt overrides, rename-and-symlink migration advice, tools that need a setting. |
| https://agentskills.io/specification | 200 OK | Skill directory layout, frontmatter fields and limits (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`), progressive disclosure guidance, validation tool. |
| https://code.claude.com/docs/en/claude-directory | 200 OK | Where Claude Code reads instructions, rules, skills, commands, subagents, settings, MCP servers, output styles at user and project level; frontmatter field lists; what `~/.claude` holds besides configuration (transcripts, history, caches, credentials) and its retention. |
| https://code.claude.com/docs/en/settings | 200 OK | Settings scopes and precedence, list merging, strict JSON, `CLAUDE_CONFIG_DIR`, `~/.claude.json` contents. |
| https://code.claude.com/docs/en/memory | 200 OK; the page was large and was read through targeted searches of the saved text rather than line by line | CLAUDE.md locations, `@path` imports (relative resolution, four-hop limit, code spans skipped), external-import approval, `.claude/rules/` with `paths:` frontmatter, `CLAUDE.local.md`. |
| https://code.claude.com/docs/en/mcp | 200 OK, partial: first 100,000 of about 158,600 characters read | MCP scopes and storage (`~/.claude.json`, `.mcp.json`), JSON shape, `type` values, variable expansion syntax. |
| https://cursor.com/docs/context/rules | 200 OK | Rule locations, four rule types by frontmatter, `.mdc` requirement, precedence Team then Project then User. Legacy `.cursorrules` not mentioned on the page. |
| https://cursor.com/docs/context/mcp | 200 OK | `.cursor/mcp.json` locations, JSON shape, `envFile`, interpolation syntax. |
| https://developers.openai.com/codex/config-basic | 308 to https://learn.chatgpt.com/docs/config-file/config-basic (canonical variant used; read OK) | Config file locations, TOML format, precedence list, profiles, trusted-project rule. Does not show MCP syntax or the skills location. |
| https://developers.openai.com/codex/guides/agents-md | 308 to https://learn.chatgpt.com/docs/agent-configuration/agents-md (canonical variant used; read OK) | Instruction discovery order, override file, fallback filenames, 32 KiB combined cap. |
| https://learn.chatgpt.com/docs/extend/mcp | 200 OK (one extra page, reached from the config page's link) | `[mcp_servers.<name>]` tables, stdio and HTTP keys, shared keys; a list of what the page leaves unspecified. |
| Third-party skill read for ideas, no text reused (a coding-agent product's built-in migration skill; license not visible) | Read locally; 1 file | Idea only: discover then confirm then write one removable bundle, never touch sources, never echo secrets, list what does not convert, name-clash prefixing, rewrite variable syntax, size-cap awareness. All wording, tables and procedures here are original and target-neutral. |

## Reading limits

- Locations and formats drift between tool versions; each table is dated 2026-11-24 and says "re-verify before writing".
- Not found in the pages read: the Codex skills location, Cursor's legacy `.cursorrules` status, Claude Code's per-server disable key, and Gemini CLI formats (Gemini CLI was not read and is not covered).
- Mappings marked "inference" in the reference files combine documented key meanings with reasoning; test them against the target before relying on them.

## Claims not adopted as fact

- Any statement of how many tools support AGENTS.md (the site's own adoption counts) is not repeated; see `skill-orchestrator` for what was recorded there.
- Product-specific behaviors of the third-party skill's target (its plugin layout, trigger names, file caps) are not used.
- No claim is made that a migrated bundle behaves identically in the target; the skill requires verification and a loss report instead.
