# Rule versus Gate, and Wiring the Gate

Sources: https://git-scm.com/docs/githooks · https://code.claude.com/docs/en/hooks · https://docs.vale.sh/topics/cli · Last verified 2026-11-27

## 1. Why advisory rules leak

An instruction file is read once and applied by judgment. The model applies it in the step it labels "writing the answer" and tends not to apply it in steps it labels "filling a template field": a commit subject, a table header, a section title, a diagram label, a code comment. Every surface nobody listed is unchecked. This is an inference from repeated observation of agent output, not a measured rate; treat it as the working hypothesis that justifies a gate, then verify on your own outputs (collect samples before you build anything).

A gate does not depend on the writer's attention. It runs on the output path and answers with an exit code. That also gives you evidence: you can count how often it fires and which patterns fire.

## 2. Git hooks (read from the githooks documentation)

| Hook | Arguments | Runs | Non-zero exit | Bypass |
|---|---|---|---|---|
| `pre-commit` | none | before the commit message is obtained and the commit created | `git commit` aborts | `git commit --no-verify` |
| `commit-msg` | one: the file holding the proposed message | after the message is written | the command aborts (also for `git merge`) | `--no-verify` |

Facts to rely on:

- `commit-msg` may edit the message file in place (to normalize it) or refuse after inspecting it.
- The hook directory defaults to `$GIT_DIR/hooks`; `core.hooksPath` points elsewhere, for example a versioned `.githooks` folder. Hooks without the executable bit are ignored.
- Hooks run from the working tree root in a non-bare repository.
- `GIT_EDITOR=:` is set when the commit will not open an editor.

Minimal `commit-msg` hook that calls your gate (the file must be executable):

```sh
#!/bin/sh
# .githooks/commit-msg : scan the message, ignoring git's own comment lines
grep -v '^#' "$1" | python3 tools/text_gate.py -
```

A local hook is a convenience, not enforcement, because `--no-verify` skips it. Run the same script in CI for the real block. See `setup-pre-commit` for wiring pre-commit tooling and `git-atomic-commits` for what a good message contains.

## 3. Claude Code hooks (read from the hooks reference on 2026-11-27, about 300,000 characters in three passes; the last ~1,700 were not read)

Events relevant to a text gate:

| Event | When | Can it stop the action? |
|---|---|---|
| `PreToolUse` | before a tool runs (match `Write`, `Edit`, an MCP tool) | yes |
| `Stop` | when the agent finishes a reply (not after a user interrupt) | yes: it prevents stopping, so the agent continues and sees your reason |

Input: a JSON object on stdin with `session_id`, `transcript_path`, `cwd`, `hook_event_name`; tool events add `tool_name`, `tool_input` and `tool_use_id`; `Write` carries `file_path` and `content`, `Edit` carries `file_path`, `old_string`, `new_string`, `replace_all`; `Stop` adds `stop_hook_active` and `last_assistant_message`. The transcript file can lag the live conversation, so read the message from the payload when it is there.

Exit codes for command hooks:

| Exit | Meaning |
|---|---|
| 0 | success; stdout is parsed as JSON if it is one object |
| 2 | blocking error; stderr is shown to the model as the reason |
| any other (including 1) | non-blocking error: a notice appears, the action **proceeds** |

So a gate that returns 1 for "found tells" works in git but silently does nothing in a Claude Code hook. Use a thin adapter that translates: gate exit 1 becomes hook exit 2 (or a JSON deny).

Two equivalent ways to block, never both for the same decision:

```json
{ "hookSpecificOutput": { "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "3 style tells: line 4 flattery opener" } }
```

```json
{ "decision": "block", "reason": "reply contains hard tells; list below" }
```

The first (exit 0 plus JSON) is for `PreToolUse`; the second is the top-level form used by `Stop`. On `Stop`, exit 2 routes the same way (stderr is the reason); if both are present the JSON reason wins. On `PreToolUse`, exit 2 keeps the call blocked even if JSON says allow. Other `permissionDecision` values are `allow`, `ask` and `defer`; silence is not approval.

Loop guard: a `Stop` hook that always blocks would loop. Read `stop_hook_active` (true when Claude Code is already continuing because of a stop hook); Claude Code also overrides the block after 8 consecutive continuations (resets when a tool is called; `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` raises it).

Failure policy: by default a hook that fails to start, times out or exits with anything but 0 or 2 lets the action proceed. `"onFailure": "block"` on a `command`, `http` or `mcp_tool` hook makes such failures block (documented from Claude Code 2.1.295; no effect on `Stop`, `SubagentStop` or background hooks). If the gate must fail closed, set it deliberately and test the failure path.

Matcher configuration example (structure from the docs, command is yours):

```json
{ "hooks": { "PreToolUse": [ { "matcher": "Write|Edit",
    "hooks": [ { "type": "command",
      "command": "python3 \"$CLAUDE_PROJECT_DIR/tools/text_gate_hook.py\"" } ] } ] } }
```

## 4. Exit codes in prose linters (for naming your own)

Vale documents three exit codes: 0 when no `error`-level alert is found (warnings and suggestions do not change it), 1 when at least one error is found, 2 when the run itself failed (bad config, rule failed to load, unreadable document). `--no-exit` turns 1 into 0 for report-only CI jobs but does not change 2. Levels are `suggestion`, `warning` (default) and `error`; only errors affect the exit code. This is a good template for a gate: findings and tool failure get different codes, and severity decides whether the exit code changes.

## 5. Placement guide

- Commit messages: `commit-msg` (local) plus CI over the pull request's commits.
- Documentation files: `pre-commit` over staged `.md`, plus CI.
- Agent-authored files: `PreToolUse` on `Write|Edit`, so the model sees the reason immediately and rewrites.
- Agent chat replies: `Stop`, only if you accept that it will fire often; start in report-only mode.
- Everything: one script, one pattern file (`ssot-and-dry`). In an instruction file, state which of these exist and mark remaining rules advisory (`skill-orchestrator`).

## How an agent should apply this

- Before adding a style rule to an instruction file, ask whether a pattern could catch violations; if yes, build or extend the gate and keep the prose to one line pointing at it.
- Translate exit codes for the caller: git wants non-zero, Claude Code wants 2 or a JSON decision.
- Test the block path by feeding a known-bad input and confirming the action really stops, not just that a notice appears.
- Put the same script in CI so a local `--no-verify` cannot defeat it.
- Report what runs and what does not: name the hook, hook point and bypass in the change summary.
