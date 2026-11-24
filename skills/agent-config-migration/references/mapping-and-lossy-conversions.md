# Mapping and Lossy Conversions

Sources: https://code.claude.com/docs/en/mcp · https://cursor.com/docs/context/mcp · https://cursor.com/docs/context/rules · https://learn.chatgpt.com/docs/extend/mcp · https://code.claude.com/docs/en/memory · https://agentskills.io/specification · Last verified 2026-11-24

The mappings below follow what the three tools document; where a rule is my inference it is marked "inference". A third-party built-in migration skill (read for ideas only) showed the value of listing what cannot convert and of rewriting variable syntax; the tables here are original.

## 1. MCP servers

| Concept | Claude Code (JSON) | Cursor (JSON) | Codex (TOML) |
|---|---|---|---|
| Container | `mcpServers` map | `mcpServers` map | `[mcp_servers.<name>]` table per server |
| Local process | `type: "stdio"`, `command`, `args`, `env` | `type: "stdio"`, `command`, `args`, `env`, `envFile` | `command`, `args`, `env`, `env_vars`, `cwd` |
| Remote | `type: "http"`, `url`, `headers` | `url`, `headers`, optional `auth` | `url`, `http_headers`, `env_http_headers`, `bearer_token_env_var` |
| Legacy streaming transport | `type: "sse"` (deprecated) | HTTP/SSE under `url` | not documented on the page read |
| Variable syntax | `${VAR}`, `${VAR:-default}` | `${env:VAR}`, `${workspaceFolder}`, `${userHome}` | names only (`env_vars`, `bearer_token_env_var`, header-env maps) |
| Disable without deleting | not shown on the page read | not shown | `enabled = false` |

Conversion rules:

1. Convert the container first: JSON object entries to TOML tables (or the reverse), keeping the server name as the key.
2. Stdio: `command`, `args`, `env` map directly. `cwd` exists in Codex; where the target has no `cwd`, wrap the command or report the loss.
3. Remote: `url` maps everywhere. Headers: static values go to `headers` or `http_headers`. A header whose value is a placeholder becomes an environment-variable reference in the target's own form.
4. Variables: rewrite `${VAR}`, `${env:VAR}` and `$VAR` into the target's syntax; for Codex express a bearer token as `bearer_token_env_var = "VAR"` and a pass-through variable as an `env_vars` entry (inference: from the key meanings on the page). List every variable name the user must provide; never write their values.
5. Pass-through entries (`"X": "${X}"`) are redundant when the target inherits the process environment; drop them and say so (inference, check the target).
6. Make relative paths absolute when the target resolves them against a different base.
7. Servers whose command lives in the old tool's own directory (a plugin root variable) cannot be converted without the plugin; skip and report.
8. Drop keys the target does not know (per-tool trust, timeouts, auto-approve lists) and report each class of dropped key once.
9. Secrets: keep a literal secret only if the target needs a literal and the bundle stays local and untracked; otherwise convert to an environment reference.

Minimal example (placeholders only):

```json
{ "mcpServers": { "docs": { "type": "stdio", "command": "npx",
    "args": ["-y", "some-mcp-server"], "env": { "TOKEN": "${TOKEN}" } } } }
```
```toml
[mcp_servers.docs]
command = "npx"
args = ["-y", "some-mcp-server"]
env_vars = ["TOKEN"]        # forwards TOKEN from the environment; no value written
```

## 2. Instructions and rules

| Source form | Target form | Loss or decision |
|---|---|---|
| AGENTS.md | AGENTS.md (same) | none; do not duplicate when the target reads it already |
| CLAUDE.md | AGENTS.md or the target's file | remove lines naming Claude-only features; imports (`@path`) must be inlined or re-expressed |
| Cursor rule with `alwaysApply: true` | always-loaded instruction (a section of AGENTS.md, or a rule with no scoping) | none |
| Cursor rule with `globs` | path-scoped rule (Claude Code `.claude/rules/*.md` with `paths:` frontmatter) | glob syntax must be re-expressed; Cursor takes comma-separated patterns |
| Cursor rule with only a `description` | no exact equivalent in Claude Code (inference): keep as a skill with that description, or always-load it | state which; behavior changes |
| Cursor rule with neither (manual) | a skill invoked by name, or drop | state which |
| Claude Code rule with `paths:` | Cursor rule with `globs` | frontmatter rewrite |
| Personal/local instruction files | do not migrate into shared bundles | privacy |

Size: respect the target's cap (for example Codex stops adding AGENTS.md content at 32 KiB combined by default; Claude Code recommends about 200 lines per file). If a source exceeds a cap, tell the user and propose a split; never truncate silently. What to keep in instruction files at all is governed by `skill-orchestrator`.

## 3. Skills, commands, subagents

- **Skills**: copy the folder whole (including `scripts/` and `references/`). Validate: frontmatter present, `name` equals folder name and matches the naming rule, non-empty `description` up to 1,024 characters. If a source skill lacks frontmatter, write one from its first paragraph and flag it.
- **Tool-specific frontmatter** (model, effort, hooks, tool permissions): not portable. Remove from the portable copy and list the removed keys. Keep in the original untouched.
- **Commands and prompts** to skills (or the reverse): the body becomes the skill body; the filename becomes the name; use the command's own description or its first line. Replace argument placeholders (`$ARGUMENTS`, `$1`, `{{args}}`) with a plain sentence ("apply this to what the user asked for") unless the target has its own placeholder syntax.
- **Subagents**: keep the Markdown body as the system prompt; map `name` and `description`; map tool grants to the target's tool names where an equivalent exists and report the ones that do not; drop model and color fields; an omitted tools field may mean all tools in one tool and a small default in another, so write the intended set explicitly in the target and say so.

## 4. Things never to convert

- Permission allow and deny lists: tool names and pattern syntax are tool-specific and a wrong translation can grant more access than intended. List them for the user to recreate.
- Hooks: event names and payloads differ; list them.
- Auto memory, history, transcripts, caches, credentials: not configuration.
- Plugins and extensions: use the target's own import command if it has one.
- Organization-managed settings: not user-owned; skip.

## 5. Name and scope clashes

- Same name already present in the target: prefix the migrated item with its source (for example `claude-` plus the original name) and say so; never overwrite.
- Project-level source into a user-level bundle: scope widens to every project; flag it and let the user exclude those items.
- Worktrees and personal files: a gitignored personal file exists in one checkout only; do not assume it is in the repository.

## How an agent should apply this

- Convert MCP servers field by field with the table, rewriting variable syntax and listing the variables the user must supply.
- Map rule triggers explicitly and report each lossy mapping (description-only and manual rules especially).
- Copy skills whole after validating frontmatter; strip tool-specific keys only in the copy.
- Skip permissions, hooks, memory, credentials and plugins, and list them in the hand-back.
- On a name clash, prefix and report; on a size overrun, split and report.
