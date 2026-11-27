# Sources — Agent Config Migration

Every URL below was re-fetched on 2026-11-27 (first checked 2026-11-24). Status is what the fetch tool returned.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://agents.md | 200 OK (2026-11-27) | AGENTS.md as plain Markdown with no required fields, root plus nested files, nearest file wins, user prompt overrides, rename-and-symlink migration advice, tools that need a setting (Aider, Gemini CLI). |
| https://agentskills.io/specification | 200 OK (2026-11-27) | Skill directory layout, frontmatter fields and limits (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`), progressive disclosure guidance, validation tool. |
| https://code.claude.com/docs/en/claude-directory | 200 OK (2026-11-27) | Where Claude Code reads instructions, rules, skills, commands, subagents, settings, MCP servers, output styles at user and project level; frontmatter field lists; what `~/.claude` holds besides configuration (transcripts, history, caches, credentials) and its retention. |
| https://code.claude.com/docs/en/settings | 200 OK (2026-11-27) | Settings scopes and precedence, list merging, strict JSON, `CLAUDE_CONFIG_DIR`, `~/.claude.json` contents. |
| https://code.claude.com/docs/en/memory | 200 OK (2026-11-27); the page was large and was read through targeted searches of the saved text rather than line by line | CLAUDE.md locations, `@path` imports (relative resolution, four-hop limit, code spans skipped), external-import approval, `.claude/rules/` with `paths:` frontmatter, `CLAUDE.local.md`. |
| https://code.claude.com/docs/en/mcp | 200 OK, partial: first 100,000 of about 178,300 characters read (2026-11-27) | MCP scopes, storage and precedence (entries not merged), JSON shape, `type` values (`stdio`, `http`, `sse`, `ws`, `sdk`), variable expansion rules and unset-variable behavior, `url` without `type` error, disabling through `/mcp` (`disabledMcpServers`). |
| https://cursor.com/docs/context/rules | 200 OK (2026-11-27) | Rule locations, four rule types by frontmatter, `.mdc` requirement, precedence Team then Project then User. Legacy `.cursorrules` not mentioned on the page. |
| https://cursor.com/docs/context/mcp | 200 OK (2026-11-27) | `.cursor/mcp.json` locations, JSON shape, `envFile`, interpolation syntax. |
| https://developers.openai.com/codex/config-basic | 308 to https://learn.chatgpt.com/docs/config-file/config-basic (target read OK, 2026-11-27) | Config file locations, TOML format, precedence list, profile files, trusted-project rule, `requirements.toml`. Does not show MCP syntax or the skills location. |
| https://developers.openai.com/codex/guides/agents-md | 308 to https://learn.chatgpt.com/docs/agent-configuration/agents-md (target read OK, 2026-11-27) | Instruction discovery order, override file, fallback filenames, 32 KiB combined cap. |
| https://learn.chatgpt.com/docs/extend/mcp | 200 OK (2026-11-27) | `[mcp_servers.<name>]` tables, stdio and HTTP keys, shared keys; `auth` and `[mcp_servers.<name>.oauth]`; the page still does not say where Codex skills live. |
| https://code.claude.com/docs/en/memory (second pass, added 2026-11-27) | 200 OK, large page read through searches | CLAUDE.md and CLAUDE.local.md locations, `@AGENTS.md` handling (reads AGENTS.md directly only when no CLAUDE.md exists above the working directory, v2.1.277 or later; ownership stays with `skill-orchestrator`). |
| Third-party skill read for ideas, no text reused (a coding-agent product's built-in migration skill; license not visible) | Read locally; 1 file | Idea only: discover then confirm then write one removable bundle, never touch sources, never echo secrets, list what does not convert, name-clash prefixing, rewrite variable syntax, size-cap awareness. All wording, tables and procedures here are original and target-neutral. |

## Reading limits

- Locations and formats drift between tool versions; each table is dated 2026-11-24 and says "re-verify before writing".
- Not found in the pages read: the Codex skills location and Cursor's legacy `.cursorrules` status (both re-checked 2026-11-27, still absent), and Gemini CLI formats (not read, not covered). Claude Code's per-server disable mechanism is now documented (`/mcp` toggle, `disabledMcpServers`).
- The MCP page was read in its first 100,000 of about 178,300 characters.
- No scripts or data files in this skill; the manifest and verification pseudocode were not executed.
- Mappings marked "inference" in the reference files combine documented key meanings with reasoning; test them against the target before relying on them.

## Claims not adopted as fact

- Any statement of how many tools support AGENTS.md (the site's own adoption counts) is not repeated; see `skill-orchestrator` for what was recorded there.
- Product-specific behaviors of the third-party skill's target (its plugin layout, trigger names, file caps) are not used.
- No claim is made that a migrated bundle behaves identically in the target; the skill requires verification and a loss report instead.
