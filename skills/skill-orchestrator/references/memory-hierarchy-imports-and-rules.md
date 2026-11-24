# Memory Hierarchy, Imports and Rules in Claude Code

Sources: https://code.claude.com/docs/en/memory (undated page, fetched 2026-11-24; versions cited inline) · https://code.claude.com/docs/en/best-practices · secondary: https://xerj.org/answers/claude-code-memory · Last verified 2026-11-24

## 1. Load order is concatenation, not override

The docs list four CLAUDE.md scopes, in load order from broadest to most specific:

| Scope | Location |
|---|---|
| Managed policy | macOS `/Library/Application Support/ClaudeCode/CLAUDE.md`; Linux/WSL `/etc/claude-code/CLAUDE.md`; Windows `C:\Program Files\ClaudeCode\CLAUDE.md` |
| User | `~/.claude/CLAUDE.md` |
| Project | `./CLAUDE.md` or `./.claude/CLAUDE.md` |
| Local | `./CLAUDE.local.md` (gitignore it) |

Mechanics:
- All discovered files are concatenated; none overrides another. Within the directory tree the order runs from filesystem root down to the working directory, so the file closest to the launch directory is read last. In each directory `CLAUDE.local.md` comes after `CLAUDE.md`.
- User rules load before project rules; neither overrides the other. On conflict "Claude may follow either" (docs wording), so keep them consistent.
- Ancestors of the working directory load at launch. Subdirectory CLAUDE.md files load on demand when Claude reads, writes or edits a file there (a single-file `cat`/`head` counts as a read).
- Managed CLAUDE.md cannot be removed with `claudeMdExcludes`. A `claudeMd` key in managed settings can carry the text; it is ignored in user, project or local settings.
- `--add-dir` directories do not load CLAUDE.md unless `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1`.

Author-claim check ("precedence/hierarchy"): "later = higher priority" is **inaccurate as a precedence rule**. Later position is only a recency effect; conflicts are resolved by the model, so remove contradictions instead of relying on order. Real override precedence exists for settings (permissions, hooks), not for CLAUDE.md text.

## 2. @imports

- Syntax `@path/to/file`, relative (to the importing file, not the cwd) or absolute; `@~/...` works.
- Recursive, **maximum depth four hops** (docs).
- Spaces in a path need a backslash before each space; quoted paths are not imported.
- Code spans and fenced blocks are not parsed: write `` `@README` `` to mention without importing.
- Imports do not save tokens: the imported text loads with the importer.
- A project-level import resolving outside the working directory triggers a one-time approval dialog; declining disables them. User-scope files (`~/.claude/CLAUDE.md`, `~/.claude/rules/`) skip the dialog (exception: Cowork desktop sessions).
- Block-level HTML comments are stripped before injection, so they cost no tokens (kept inside code blocks).

Example sharing personal notes across worktrees:

```markdown
# Personal
- @~/.claude/my-project-instructions.md
```

## 3. `.claude/rules/`

- Markdown files, discovered recursively; one topic per file.
- Without `paths` frontmatter: loaded at launch with the same priority as `.claude/CLAUDE.md`.
- With `paths` (YAML list or comma-separated string): loaded when Claude uses Read/Write/Edit (or a single-file Bash read) on a matching file. Patterns are relative to the folder containing `.claude`; user-level rules use the primary working directory.
- `paths` is the only frontmatter field read; others are silently ignored. Invalid YAML makes the rule load unconditionally (see `claude --debug`).
- Globs: `**/*.ts`, `src/**/*`, `/*.md` (base directory only), brace expansion allowed; a rule's whole list shares a budget of 1,000 expanded patterns and 4 MiB.
- Symlinks allowed (circular ones handled). A link pointing outside the working directory is treated like an external import: needs approval, and then only unscoped rules load. Network-path links (UNC, `/net`) are not followed. Keep shared rules in `~/.claude/rules/` to avoid the dialog.
- Project rules respect `--setting-sources`; from v2.1.211, on-demand rules also honor excluding `project`.
- Enforcement status of rules: see [claude-md-official-guidance-and-limits.md](claude-md-official-guidance-and-limits.md) section 4 (ENF-03).

```markdown
---
paths:
  - "src/api/**/*.ts"
---
- Validate bodies with the zod schemas in src/api/schemas/
```

## 4. CLAUDE.md versus auto memory

| | CLAUDE.md | Auto memory |
|---|---|---|
| Author | you | Claude |
| Holds | rules, workflows | learnings, corrections, project context not in code |
| Loaded | every session | first 200 lines or 25KB of `MEMORY.md`; topic files read on demand |
| Location | scopes above | `~/.claude/projects/<project>/memory/` (shared by worktrees of one repo; machine-local) |

Toggle with `/memory`, `autoMemoryEnabled`, or `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`. Subagents do not receive the main auto memory. Rule: put anything a teammate must also know in CLAUDE.md (versioned); leave personal drift to auto memory.

## 5. Compaction and exclusions

Project-root CLAUDE.md is re-read from disk after `/compact`. Nested files and path-scoped rules reload on demand. Instructions given only in chat can be lost. `claudeMdExcludes` (any settings layer, arrays merge) skips ancestor files in monorepos; symlinked rules match either path from v2.1.239.

## How an agent should apply this

- Never claim a higher-scope file "wins"; resolve contradictions by editing, and place the single owner of each rule in one file.
- Choose the narrowest home: user file for personal habits, project file for team rules, `paths` rules for subtree rules, skills for procedures.
- Use imports for organization and sharing, not for saving context; count imported lines against the 200-line target.
- Add a `paths` rule only after confirming the glob matches with `claude --debug` or the `InstructionsLoaded` hook.
- Do not rely on a symlinked or external import without confirming approval happened; verify with `/memory`.
- Quote versions (v2.1.211, v2.1.239, v2.1.309) when a behavior is version-gated.
