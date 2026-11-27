---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
---

Write a handoff document summarizing the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows) - not the current workspace.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

## Optional: Claude Code CLI variant (`claude-handoff`)

Only when the user is on the Claude Code CLI and asks to launch the next session immediately. Everything above still applies (redaction, no duplication, suggested skills). After writing the summary file, start a background agent seeded with it: `claude --bg --name "<descriptive name>" -- "$(cat <summary file>)"`. Passing the file keeps the shell from running backticks or expanding `$` in the summary. It starts in the current working directory and returns immediately; the user manages it with `claude agents`. Always pass `--name` with a descriptive name (for example `--name "Fix login bug"`). The summary becomes the agent's prompt, so redact secrets first. This variant comes from the upstream `in-progress` folder and may change.

## Related skills in this pack

- `skill-orchestrator`: choosing which skills the next agent should call.
- `implement`, `to-tickets`: the usual work the next session continues.
- `retro`: improve the environment after a session.

## Deep references

- [references/sources.md](references/sources.md): upstream provenance, MIT license and local differences.
