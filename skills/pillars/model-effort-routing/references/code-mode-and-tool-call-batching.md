# Code Mode and Tool-Call Batching

Sources: https://code.claude.com/docs/en/code-mode · https://code.claude.com/docs/en/changelog · https://www.anthropic.com/engineering/code-execution-with-mcp · https://www.youtube.com/watch?v=8Ofrox5ycgQ · Last verified 2026-11-25

Code Mode is a spend lever that sits beside model and effort choice: it cuts the number of model round trips, not the price of each one. It is experimental and off by default, so treat every statement below as version-gated (Claude Code 2.1.332 was the newest changelog entry on 2026-11-25).

## 1. What it changes

Without it, the model asks for one tool call at a time (Bash, Read, Edit), reads each result, then decides the next call. With it, the model writes a short JavaScript program. The host runs that program, which can run commands in parallel, feed one result into the next call, filter output, and return only what the model needs to read.

Illustration (own example): to raise a retry limit, one program finds the file, edits it, runs the matching tests and returns the path plus the test output. The classic path takes four or more model turns for the same work.

The user sees the tool calls (for example the diff), not the code. The code is readable in the transcript viewer as collapsed "Code" rows.

## 2. Where the saving comes from

| Mechanism | Effect on cost |
|---|---|
| Fewer model turns | Each turn re-reads the context; fewer turns means fewer cache reads and less output. |
| Intermediate results stay in the runtime | Large listings or logs are filtered before the model sees them. |
| Parallel and chained calls | Less wall-clock waiting between calls (not guaranteed, see section 4). |

The same idea appears in Anthropic's engineering article on code execution with MCP: tool definitions and intermediate results both pass through the context window in the direct style. Its worked example reports a drop from 150,000 to 2,000 tokens (98.7%) for a document-to-CRM transfer. That is a vendor illustration of a best case with many large intermediate results, not a general rate. The article also names the price: a sandbox, resource limits and monitoring are needed, and they add operational overhead.

## 3. What was measured (anecdotal)

A public video ran one project in two terminals, one with Code Mode and one without, over three prompts (build a site, add a database with login and booking rules, then a cleanup pass with lint, types and build). The author's own session-comparison script reported roughly 21% lower cost on the subscription, about half the processed tokens and about half the model round trips with Code Mode. Wall time was longer (about 21 versus 11 minutes on the first prompt, 13 versus 12 on the second), and part of the third prompt stalled for about ten minutes on a script that did not finish.

Read it as one run per arm, one project, one person's script: no repeats, no variance, no blind quality grading. It fits the direction the vendor describes and nothing more. Quote it with the labels in `claims-vs-evidence-on-savings.md`.

## 4. When to try it, and when not to

Try it on work made of many related tool calls: the same edit across many files, a search whose results need filtering, several independent commands that can run together.

Skip it, or test before relying on it, when:
- the task is a single read, edit or question (no round trips to save);
- the session must be resumable on a cloud provider after it ran in this mode, or resumed without the setting on (a Code Mode session resumes only with the mode on);
- the surface is not an interactive terminal session (the documentation lists the VS Code panel, the desktop app and cloud sessions as unsupported);
- latency matters more than tokens (the long-running code stops after ten minutes unless it runs in the background, which needs an auto or bypass permission mode).

## 5. Requirements checklist (as documented on 2026-11-25)

- Claude Code 2.1.323 or later; 2.1.331 or later on a cloud provider; native build; Git for Windows on Windows.
- A subscription, Console account or supported cloud provider; not a gateway, not an API key helper, not HIPAA or zero-data-retention organizations.
- Models: Opus 5.5, Sonnet 5.5, Haiku 5.5 or Fable 5.2, by full model name (an alias can resolve to an older model on some providers).
- Switch: environment variable `CLAUDE_CODE_EXPERIMENTAL_CODE_MODE` set to `1` in the shell or in user settings; a `0` anywhere wins. Organizations block it with the same variable set to `0` in managed settings.
- Subagents with an explicit `tools` list need `REPL` added to that list to use the mode.
- On start, the session prints a line starting `Code Mode (experimental) isn't available` plus the reason when a requirement fails; run `/status` for the reason.

## 6. Control model changes

Safety rules written for individual tool calls still apply, but the places they act change:
- `deny` and `ask` permission rules and `PreToolUse` hooks fire on the usual tool names (for example `Bash`) for calls made by the code. A hook that parses shell text must check each part of a compound command, because a call can arrive as `cd 'dir' && git push`.
- In auto mode a classifier reviews the code once, not each call, and cannot see values computed at run time. Keep rules or hooks for anything that must never happen.
- A `PreToolUse` hook on the `REPL` tool can read the program from its input; a `PostToolUse` hook on `REPL` can redact the result before the model reads it.
- Sandbox settings cover the shell commands the code runs, not the JavaScript itself or its file, web and MCP calls.
- Telemetry: events for calls made by code carry the usual tool names; filter by call-id prefix to separate them.
- Instruction files stay advisory in both styles. Anything that must hold goes in a hook or deny rule (see `skill-orchestrator` and `git-guardrails-claude-code`).

## 7. What this file does not own

Tool-definition economy and context hygiene belong to `agent-skills-context-engineering`. Measuring a real session and pricing it belong to `agent-cost-report`. Hook design for blocking dangerous commands belongs to `git-guardrails-claude-code`. This file only places Code Mode among the spend levers.

## How an agent should apply this

- Treat Code Mode as an opt-in experiment, never as a default recommendation or a promised saving.
- Suggest it only for batch-shaped work, after confirming the requirement checklist for the user's version, surface and provider.
- If the user turns it on, keep the deny rules and hooks that guard destructive commands; do not rely on a rule in an instruction file.
- To judge it, compare two comparable sessions with `agent-cost-report` and record model turns, tokens, wall time and a quality check, with several tasks and not one.
- Quote savings only with their basis: vendor illustration, one-run anecdote or own measurement.
- Re-check the version-gated facts against the current documentation before repeating them; the feature may change or be removed in any release.
