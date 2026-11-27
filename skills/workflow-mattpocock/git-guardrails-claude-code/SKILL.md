---
name: git-guardrails-claude-code
description: Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Use when user wants to prevent destructive git operations, add git safety hooks, or block git push/reset in Claude Code.
---

# Setup Git Guardrails

Sets up a PreToolUse hook that intercepts and blocks dangerous git commands before Claude executes them. Provenance and local changes: [references/sources.md](references/sources.md).

## 1. What gets blocked

- `git push` (all variants including `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

When blocked, Claude sees a message telling it that it does not have authority to access these commands. Git global options are handled (`git -C dir push` is blocked too).

## 2. Steps

### 2.1 Ask scope

Ask the user: install for **this project only** (`.claude/settings.json`) or **all projects** (`~/.claude/settings.json`)?

### 2.2 Show, then copy the hook script

The bundled script is [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh). Show the user what it does (it only reads the hook JSON from stdin and exits 0 or 2; it writes nothing and never prints the command), then copy it to:

- **Project**: `.claude/hooks/block-dangerous-git.sh`
- **Global**: `~/.claude/hooks/block-dangerous-git.sh`

Make it executable with `chmod +x`. It needs `jq`; without it the hook fails closed (blocks every Bash call and says why), so check `command -v jq` first and tell the user if it is missing.

### 2.3 Add the hook to settings

Add to the appropriate settings file:

**Project** (`.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

**Global** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

If the settings file already exists, merge the hook into the existing `hooks.PreToolUse` array. Do not overwrite other settings. Show the user the merged diff before saving.

### 2.4 Ask about customization

Ask if the user wants to add or remove patterns. Each entry in `DANGEROUS_PATTERNS` is `label|extended regex`; edit the copied script accordingly.

### 2.5 Verify

Run a quick test, one blocked and one allowed:

```bash
echo '{"tool_input":{"command":"git push origin main"}}' | <path-to-script>   # exit 2, BLOCKED on stderr
echo '{"tool_input":{"command":"git status"}}' | <path-to-script>             # exit 0, silent
```

## 3. Limits (say these to the user)

- It is a **guardrail against accidents, not a security boundary**. A shell alias, a script that runs git inside, `eval`, or an encoded command can bypass pattern matching. For hard guarantees use server-side branch protection and least-privilege credentials.
- It does not stop the user from running the commands by hand; it only stops the agent's Bash tool.
- Blocking `git push` means the agent cannot publish work; the user pushes. That is the intended default.
- In Claude Code's experimental Code Mode, git commands issued by the agent's code still reach a `Bash` hook, but the text can differ (for example `cd 'dir' && git push`), so match each part of a compound command. See `model-effort-routing` (`references/code-mode-and-tool-call-batching.md`).

## Quick Decision Checklist

- [ ] Scope chosen (project or global) and settings merged, not overwritten
- [ ] `jq` present
- [ ] User saw the script before it was installed
- [ ] Blocked and allowed test commands both behave as above
- [ ] User told the Limits

## Deep references

- [references/sources.md](references/sources.md) — upstream source, license, safety hardening

## Related skills in this pack

- `git-atomic-commits` for the commit discipline these guardrails protect.
- `verification-loop` and `code-review` for checking work before the user pushes it.
