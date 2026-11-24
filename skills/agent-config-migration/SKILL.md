---
name: agent-config-migration
description: "Migrate settings, instructions, skills, commands and MCP servers from one coding agent's configuration format to another's safely: discover what exists, classify what converts cleanly, lossy or not at all, show the plan, get the user's confirmation, write a new self-contained bundle that can be removed in one step, never modify or delete the sources, never print secrets, and verify the result. Covers the portable pieces (AGENTS.md, the Agent Skills format, MCP server definitions), the non-portable ones (permissions, hooks, per-tool settings), environment-variable syntax differences, name clashes, scope surprises and a manifest for undo. Use when moving from one coding agent to another, importing a teammate's or an old setup, syncing config across tools, or writing an import or migration command for an agent."
---

# Agent Config Migration

One idea: a migration is a **read-only discovery, a reviewed plan and a new, removable bundle**; the source configuration is never edited, nothing is written before the user confirms, and whatever cannot be converted is reported instead of guessed. Sources and claims: [references/sources.md](references/sources.md).

Boundary: which instruction files should exist, how long they should be, and which rules must be enforced by hooks or permissions belongs to `skill-orchestrator` (including the AGENTS.md standard and interoperability); do not restate that here. How a skill is structured, loaded and kept lean belongs to `agent-skills-context-engineering`. This skill owns the migration procedure and the mapping between formats.

---

## 1. Rules that do not bend

1. **Sources are read-only.** Never edit, move or delete the original files, even to "clean up". A migration that changes its sources cannot be undone.
2. **Plan, then confirm, then write.** Writing starts only after the user has seen the plan and said yes (in a non-interactive run, stop at the plan and report it).
3. **Write a new bundle**, in one directory the target tool loads, so removing that directory reverses the migration. Never merge into existing files.
4. **Never print secrets.** Refer to a token, key or header by its key name only; do not echo values into chat, logs or the plan.
5. **Report what was not migrated, and why.** Silence about dropped items is the main way migrations mislead.
6. **Verify, then hand back** with what was migrated, skipped and still to do by hand.

## 2. What converts, by artifact class

| Artifact | Portability | Typical handling |
|---|---|---|
| Project instructions | High: AGENTS.md is a plain-Markdown convention many tools read | Copy or reference; rewrite only tool-specific lines |
| Agent skills (`SKILL.md` folders) | High: the Agent Skills format is shared across tools | Copy the folder whole; validate frontmatter |
| MCP server definitions | Medium: same ideas, different syntax (JSON `mcpServers` vs TOML tables, env-var syntax) | Convert field by field; flag legacy transports |
| Custom commands and prompts | Medium: become skills or commands in the target | Rewrite argument placeholders; keep the body |
| Rules with triggers (globs, descriptions, always-on) | Medium to low: trigger models differ | Map the trigger; flag what has no equivalent |
| Subagents | Low: tool names, model fields and frontmatter differ | Convert body; map tool grants; drop unmappable fields and say so |
| Permissions, allow lists, hooks | **None to low**: tool names and rule syntax are tool-specific | Do not migrate; list them in the report |
| Auto-generated memory, history, caches, credentials stores | **Do not migrate** | Never copy; mention only if asked |
| Plugins, marketplaces, extensions | Tool-specific | Use the target's own import mechanism if it has one |

Per-tool locations and formats: [references/config-surfaces-by-agent.md](references/config-surfaces-by-agent.md). Field-level mapping and lossy cases: [references/mapping-and-lossy-conversions.md](references/mapping-and-lossy-conversions.md).

## 3. Workflow

### Step 1: Discover (read-only)

- Check each known location for each source tool; skip absent ones silently.
- Separate user-level from project-level files. Project-level files, once placed in a user-level bundle, apply in every workspace; flag this and offer to leave them out.
- Read only what you need: list directories, parse server names and keys, do not dump files.
- Note what the target already has (skills, servers, rules) to avoid duplicates and name clashes.

### Step 2: Classify

For every item, assign one of: **convert cleanly**, **convert with loss** (say what is lost), **skip** (not portable, reason), **already present**, **needs a manual step** (sign-in, an environment variable). Keep the list in one table.

### Step 3: Show the plan and confirm

Show counts and names grouped by source ("Tool A: 3 MCP servers, 2 skills, 1 instruction file"), the skip list with one-line reasons, scope warnings, name clashes and the bundle path and name. Ask once, in a single message: proceed with everything or leave some out, and confirm the bundle name (suggest a new name; if the folder exists, suggest another instead of overwriting). Wait for the answer.

### Step 4: Write the bundle

- One directory, new name, created only after confirmation. Contents only for what was approved.
- Write a **manifest** (source path, destination path, content hash of source, classification, notes) so the migration is auditable and reversible.
- Convert with the rules in the mapping reference; resolve relative paths to absolute where the target resolves them differently.
- Keep secrets where they were: reference environment variables rather than copying values when the target supports it; if a literal value must be carried, keep it only in a file that stays local and is excluded from version control, and never echo it.
- On a name clash, rename the new item with a source prefix rather than overwrite.

### Step 5: Verify

- Every generated JSON or TOML file parses.
- Every skill has frontmatter with `name` equal to its folder and a non-empty description of at most 1,024 characters.
- Size caps of the target are respected (for example a combined instruction-size limit); if exceeded, report instead of truncating silently.
- Source hashes before and after are identical (proves the sources were not touched).
- The manifest lists every file in the bundle and nothing else.
- If the target has a way to list loaded items, run it and compare against the plan.

### Step 6: Hand back

Say what was migrated, what was skipped and why, what the user must still do (sign in to a remote server, set variables, enable the bundle), where the bundle is, and how to remove it (delete that folder). Link nothing the user did not ask for.

Full procedure with a plan template, a manifest format and verification pseudocode: [references/safe-migration-procedure.md](references/safe-migration-procedure.md).

## 4. Traps

- **Scope inflation**: a project rule set imported into a user-level bundle now applies to every project.
- **Environment-variable syntax differs** between tools; a placeholder copied verbatim may be passed literally. Rewrite it for the target and list the variables the user must provide.
- **Legacy transports**: an older remote transport may have no equivalent in the target; offer a bridge or skip with a reason.
- **Relative paths** resolve against a different base in the target; make them absolute at conversion time.
- **Trigger models**: always-on, glob-scoped, description-selected and manual rules do not map one to one; decide per rule and report the loss.
- **Instruction lines that name the old tool** ("use the Bash tool") are wrong in the target; list them for review rather than deleting silently.
- **Duplicate imports**: if the target already reads the same file (for example the shared AGENTS.md), do not also copy it into the bundle.
- **Secrets in plans**: never put values in the plan, manifest or hand-back; hashes and key names only.

## Quick Decision Checklist

1. Are the sources read-only for the whole run (hash before and after)?
2. Was discovery limited to what is needed, with absent sources skipped?
3. Is every item classified (clean, lossy, skip, present, manual) with a reason?
4. Did the user see the plan and confirm before any write?
5. Is the output one new, removable bundle with a manifest?
6. Are secrets referenced by name only, never echoed?
7. Are scope changes (project to user level), name clashes and path changes flagged?
8. Do generated files parse and meet the target's size and frontmatter rules?
9. Does the hand-back list migrated, skipped, manual steps and the undo step?

## Deep references

- [config-surfaces-by-agent.md](references/config-surfaces-by-agent.md) - read when you need locations, file formats and precedence for Claude Code, Cursor, Codex, AGENTS.md and Agent Skills.
- [mapping-and-lossy-conversions.md](references/mapping-and-lossy-conversions.md) - read when converting MCP servers, rules, commands and subagents, or deciding what is lost.
- [safe-migration-procedure.md](references/safe-migration-procedure.md) - read when running or writing a migration: plan template, manifest, undo, verification.
- [sources.md](references/sources.md) - sources, retrieval status and claims not adopted.
