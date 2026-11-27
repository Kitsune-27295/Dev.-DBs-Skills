# Configuration Surfaces by Agent

Sources: https://code.claude.com/docs/en/claude-directory · https://code.claude.com/docs/en/settings · https://code.claude.com/docs/en/memory · https://code.claude.com/docs/en/mcp · https://cursor.com/docs/context/rules · https://cursor.com/docs/context/mcp · https://learn.chatgpt.com/docs/config-file/config-basic · https://learn.chatgpt.com/docs/agent-configuration/agents-md · https://learn.chatgpt.com/docs/extend/mcp · https://agents.md · https://agentskills.io/specification · Last verified 2026-11-27

(The Codex pages at `developers.openai.com/codex/...` redirect with HTTP 308 to the `learn.chatgpt.com` addresses above. Locations change between versions; re-check before relying on a path.)

## 1. Claude Code

| Item | User level | Project level |
|---|---|---|
| Instructions | `~/.claude/CLAUDE.md` | `./CLAUDE.md` or `./.claude/CLAUDE.md`; private: `./CLAUDE.local.md` |
| Rules (topic files, optional `paths:` frontmatter) | `~/.claude/rules/*.md` | `.claude/rules/*.md` |
| Skills | `~/.claude/skills/<name>/SKILL.md` | `.claude/skills/<name>/SKILL.md` |
| Commands (single-file prompts; same mechanism as skills) | `~/.claude/commands/*.md` | `.claude/commands/*.md` |
| Subagents | `~/.claude/agents/*.md` | `.claude/agents/*.md` |
| Settings (permissions, hooks, env, model) | `~/.claude/settings.json` | `.claude/settings.json` (shared), `.claude/settings.local.json` (personal) |
| MCP servers | `~/.claude.json` (user scope; local scope, the default, nests under the project path) | `.mcp.json` in the project root (needs approval in interactive sessions) |
| Output styles | `~/.claude/output-styles/*.md` | `.claude/output-styles/*.md` |
| Auto memory | `~/.claude/projects/<project>/memory/` | not project files |
| Workflows, themes, keybindings | `~/.claude/workflows/*.js`, `themes/*.json`, `keybindings.json` | `.claude/workflows/*.js` |

Details that affect migration:

- `CLAUDE_CONFIG_DIR` moves the whole `~/.claude` tree (and `~/.claude.json`).
- Settings precedence, highest first: managed, command line, project local, shared project, user. Lists such as `permissions.allow` merge across files.
- CLAUDE.md files import others with `@path` (relative to the importing file, maximum four hops); imports inside code spans are not followed.
- `@` imports that resolve outside the working directory trigger an approval prompt on first use (a safety measure for committed files).
- Settings files are strict JSON; comments or trailing commas make the file fail to load.
- MCP entries: `type` is `stdio`, `http` (alias `streamable-http`), `sse` (deprecated; v2.1.265 and later try HTTP first and fall back) or `ws`; `sdk` entries are skipped; a `url` entry without a type is an error; stdio uses `command`, `args`, `env`; remote uses `url`, `headers`; `${VAR}` and `${VAR:-default}` expand in command, args, env, url and headers. An unset variable without a default loads the server with the literal text and warns; credential variables such as `ANTHROPIC_API_KEY` read as empty inside a remote `url` or `headers`, so copy them to a variable with another name.
- The same server name in several scopes is not merged: the whole entry from the highest scope wins (local, then project, then user, then plugin servers, then claude.ai connectors). Disabling a server without deleting it is the `/mcp` toggle, recorded per project as `disabledMcpServers` in `~/.claude.json`; `disabledMcpjsonServers` rejects `.mcp.json` servers.
- The local settings file (`.claude/settings.local.json`) sits at the git repository root since v2.1.211, and it is not read in cloud sessions.
- Plugins live under `~/.claude/plugins` and are managed by plugin commands, not copied by hand. The directory also holds transcripts, history and credentials, which are not configuration and must not be migrated.
- Claude Code can read an existing `AGENTS.md` (see `skill-orchestrator` for the exact fallback rules and versions).

## 2. Cursor

| Item | Location | Format |
|---|---|---|
| Project rules | `.cursor/rules/` (subfolders allowed) | `.mdc` files with frontmatter `description`, `globs`, `alwaysApply`; a plain `.md` file there is ignored |
| AGENTS.md | project root or subdirectories | plain Markdown, nearest file wins |
| User rules | Customize, Rules (inside the app) | stored by the app, not as a project file |
| Team rules | Cursor dashboard | managed centrally |
| MCP servers | `.cursor/mcp.json` (project), `~/.cursor/mcp.json` (global) | JSON `mcpServers`; stdio entries use `command`, `args`, `env`, `envFile`; remote entries use `url`, `headers` and optionally an `auth` object (static OAuth) |

Rule types by frontmatter: `alwaysApply: true` is always included; `globs` set and `alwaysApply: false` attaches when matching files are in context; `description` only lets the agent decide; none of these means manual (included on an `@` mention). Precedence for conflicts: Team, then Project, then User rules. The page read does not mention the older single-file `.cursorrules` format; treat it as unconfirmed.

MCP interpolation in Cursor: `${env:NAME}`, `${userHome}`, `${workspaceFolder}`, `${workspaceFolderBasename}`, `${pathSeparator}` (also `${/}`); `envFile` is available for stdio servers only; hosted cloud agents do not read the global file.

## 3. Codex

| Item | Location | Format |
|---|---|---|
| Config | `~/.codex/config.toml`; project `.codex/config.toml` layers (loaded only for trusted projects); `/etc/codex/config.toml` on Unix; admin `requirements.toml` constrains behavior on managed machines | TOML |
| Profiles | `~/.codex/<profile>.config.toml`, selected with `--profile` | TOML |
| Instructions | `~/.codex/AGENTS.md` (or `AGENTS.override.md`), then `AGENTS.md` files from the project root down to the working directory | Markdown |
| MCP servers | `[mcp_servers.<name>]` tables in `config.toml` | TOML |

Details:

- Config precedence, highest first: command-line overrides, project `.codex/config.toml`, selected profile, user config, cloud-managed defaults, system config, built-in defaults.
- Instruction discovery: at the global level the first non-empty of `AGENTS.override.md` then `AGENTS.md`; per directory from root to the working directory one file at most, checking `AGENTS.override.md`, `AGENTS.md`, then names in `project_doc_fallback_filenames`; files concatenate root first. The combined size stops at `project_doc_max_bytes` (32 KiB by default).
- MCP stdio keys: `command` (required), `args`, `env`, `env_vars` (names to forward), `cwd`. HTTP keys: `url` (required), `auth` (`oauth` by default, or `chatgpt`), `bearer_token_env_var`, `http_headers`, `env_http_headers`, `http_headers_helper`; OAuth settings live in a `[mcp_servers.<name>.oauth]` table. Shared: `enabled`, `required`, timeouts, `enabled_tools`, `disabled_tools`.
- Where Codex looks for skills was not on the config page; not read. Check the product's skills page before writing there.

## 4. Portable standards

**AGENTS.md** (agents.md): plain Markdown, no required fields or headings, root file plus nested files in monorepos, nearest file wins, explicit user prompts override. The site's migration advice is to rename an existing agent file to `AGENTS.md` and keep the old name as a symlink; some tools need a setting to read it (the page names Aider's `read` option and Gemini CLI's context-file setting). Interoperability rules, versions and the CLAUDE.md fallback are owned by `skill-orchestrator`.

**Agent Skills** (agentskills.io): a skill is a directory with `SKILL.md` (YAML frontmatter then Markdown), optional `scripts/`, `references/`, `assets/`. Required fields: `name` (1 to 64 characters, lowercase letters, digits and single hyphens: none leading, trailing or doubled, equal to the directory name) and `description` (1 to 1,024 characters, what it does and when to use it). Optional: `license`, `compatibility` (up to 500 characters), `metadata` (string map), `allowed-tools` (experimental, space-separated). Recommended: body under about 5,000 tokens and 500 lines, files referenced one level deep. Claude Code accepts more frontmatter fields than the spec (for example `model`, `effort`, `hooks`), which are tool-specific: keep them out of a portable copy or list them as lost. How skills load and stay lean is `agent-skills-context-engineering`.

## How an agent should apply this

- Look only in the locations that exist for each tool and note whether each is user-level or project-level.
- Treat settings, permissions, hooks, transcripts, history, memory and credentials as non-portable and never copy them.
- Prefer the portable standards (AGENTS.md, Agent Skills) as the migration vehicle whenever the target supports them.
- Record unconfirmed locations (for example Codex skills, Cursor legacy rules) as "needs checking in the product docs" rather than guessing.
- Re-verify paths against the installed version before writing; these docs change often.
