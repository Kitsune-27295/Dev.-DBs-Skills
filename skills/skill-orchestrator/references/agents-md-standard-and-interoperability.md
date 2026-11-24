# AGENTS.md Standard and Interoperability

Sources: https://agents.md/ · https://github.com/agentsmd/agents.md · https://code.claude.com/docs/en/memory · https://github.com/TechSpokes/agency-specifications-files-agents-md (secondary, low adoption) · https://devops.com/claude-code-adds-agents-md-fallback-cutting-instruction-file-sprawl (not readable: HTTP 403) · Last verified 2026-11-24

## 1. The standard

AGENTS.md is an open, plain-Markdown "README for agents" (agents.md). Facts read from the site:
- No required fields or headings; common sections are overview, build/test commands, code style, testing, security, PR rules.
- Root file at the repo root; in monorepos add one per subproject. Agents read the nearest file up the tree and the closest wins. Explicit user prompts override everything. (The GitHub README itself says nothing on nesting; the site does.)
- Stewarded by the Agentic AI Foundation under the Linux Foundation (site statement); repo license MIT.
- Site claims 60k+ open-source projects; the page names adopters including Codex, Jules, Cursor, Gemini CLI, GitHub Copilot coding agent, Windsurf, Zed, VS Code, Aider, goose, Devin, Junie, Amp, Warp, Kilo Code, Augment Code. Treat adoption counts as the site's own claim.
- Migration advice on the site: rename the existing file to AGENTS.md and symlink the old name.

Secondary: TechSpokes proposes a stricter folder-scoped layout (title, standalone summary, must-follow rules, must-read documents, guidelines, context, references). It shows 1 star and no benchmarks, so use it as an idea source only (hard rules first, flat lists), not a standard.

## 2. Claude Code behavior (official docs, version-sensitive)

Claude Code reads `AGENTS.md` directly **from v2.1.277**. Default setting `claude-md-or-agents-md`:

| Repo has | Claude reads |
|---|---|
| AGENTS.md only | AGENTS.md |
| AGENTS.md plus a CLAUDE.md / .claude/CLAUDE.md / CLAUDE.local.md in or above the working dir | CLAUDE.md files only |
| CLAUDE.md that imports AGENTS.md | CLAUDE.md with AGENTS.md included |

Details:
- `~/.claude/CLAUDE.md`, managed CLAUDE.md and `.claude/rules/` do not count as "a CLAUDE.md", so they still load beside AGENTS.md.
- A personal `CLAUDE.local.md` silently turns the fallback off for you.
- Nested `AGENTS.md` loads on demand when Claude reads a file in a subdirectory that has no CLAUDE.md of its own. `AGENTS.local.md`, `AGENTS.override.md` and `.agents/` are not read.
- Other values of **Project instructions** (via `/config`, or `pluginConfigs` > `cc-plugin-agents-md@builtin` > `instructionFiles`; ID was `agents-md@builtin` before v2.1.285): `claude-md-and-agents-md` (both, no double read), `claude-md`, `managed-only`.
- Unavailable before v2.1.277; before v2.1.281 some sessions (Bedrock, telemetry off) were CLAUDE.md-only; before v2.1.280 `/memory` did not list it.
- Differences: `InstructionsLoaded` hooks do not fire for settings-read AGENTS.md; `--add-dir` AGENTS.md is not loaded.

Author-claim check ("Claude Code reads AGENTS.md as a fallback"): **verified**, with the exact condition above (only when no CLAUDE.md-family file exists at or above the working directory; v2.1.277+). The devops.com article could not be read, so its claims are unverified here.

## 3. One source of truth across tools

Rule owner: AGENTS.md holds all tool-neutral rules; tool-specific files hold only tool-specific deltas.

| Pattern | Use when | Caveat |
|---|---|---|
| CLAUDE.md = `@AGENTS.md` + a short Claude section | repo has other CLAUDE content, Windows contributors, or older Claude versions | docs-recommended default for sharing |
| `ln -s AGENTS.md CLAUDE.md` | no Claude-specific content, POSIX only | Edit/Write refuse to write through a symlink and redirect to the target; on Windows Git checks it out as a one-line text file unless `core.symlinks` is on |
| Rely on the fallback | repo has no CLAUDE.md anywhere | breaks the moment someone adds CLAUDE.local.md |
| Cursor/Gemini/Copilot files | the tool does not read AGENTS.md | generate or import from AGENTS.md; do not hand-copy |

Never keep two hand-edited copies of the same rule (copy drift). Claude's `/import` makes only a one-time copy, so after it the copy needs an owner. `/init` can fold Cursor and Copilot rules into a CLAUDE.md once. Check each non-Claude tool's current docs for what it reads; that was not verified here (inference: tools listed on agents.md should read it, but behavior varies).

Example Claude-side file:

```markdown
@AGENTS.md

## Claude Code
- Plan first for changes under src/billing/.
```

After either pattern run `/context all` and confirm CLAUDE.md is listed.

## How an agent should apply this

- When asked to add rules to a repo with both files, edit AGENTS.md for shared rules and the Claude section only for Claude-only ones.
- Prefer `@AGENTS.md` import over a symlink unless the repo is POSIX-only and has no Claude-specific text.
- Warn the user that adding CLAUDE.md or CLAUDE.local.md changes what Claude reads; suggest `claude-md-and-agents-md` if both are needed.
- Check `claude --version` against v2.1.277 before assuming the fallback works.
- Put nearest-file overrides in nested AGENTS.md, and keep subdirectory files short.
- Remove old workarounds (SessionStart hook printing AGENTS.md) once direct reading works, to avoid duplicate context.
