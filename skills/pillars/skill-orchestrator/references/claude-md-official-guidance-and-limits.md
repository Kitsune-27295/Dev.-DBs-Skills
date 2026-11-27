# CLAUDE.md: Official Guidance and Limits

Sources: https://code.claude.com/docs/en/memory · https://code.claude.com/docs/en/best-practices · https://www.anthropic.com/research/claude-code-best-practices (published 2025-04-18, marked "no longer maintained" since 2026-01-26) · https://www.anthropic.com/constitution (priority ordering only) · secondary, cross-checked only: https://xerj.org/answers/claude-code-memory · https://github.com/luongnv89/claude-howto/blob/main/02-memory/README.md · Last verified 2026-11-27

## 1. The core fact: it is context, not configuration

The memory page says Claude treats CLAUDE.md files and auto memory as context, not enforced configuration. The troubleshooting section adds that the content arrives as a user message after the system prompt, with no guarantee of strict compliance, especially for vague or conflicting text. The best-practices page frames two layers:

| Layer | Examples | Who decides |
|---|---|---|
| Non-deterministic | prompt, CLAUDE.md, skills Claude picks up itself | the model |
| Deterministic | hooks, deny rules, managed settings | the harness (Claude Code) |

Verdict on the author's claim "CLAUDE.md is advisory, not a hard block": **verified**, in the docs' own words. The managed-policy section repeats it: settings are enforced "regardless of what Claude decides"; CLAUDE.md "shapes behavior" but is not a hard layer. Even a managed CLAUDE.md (exclusion rules: [memory-hierarchy-imports-and-rules.md](memory-hierarchy-imports-and-rules.md)) is still guidance, not a hard layer.

## 2. What to include and exclude

Include only what Claude cannot derive from the code (best-practices, "Keep CLAUDE.md short"):
- exact verification commands (test, typecheck, lint, run one test);
- places where the code misleads (legacy patterns not to copy);
- decisions not visible in the repo (deploy flow, chosen error helper);
- anything corrected twice already.

Exclude: architecture overviews and file layouts Claude can read itself, dependency lists, multi-step procedures (move to a skill), rules for one subtree (move to a path-scoped rule), personal preferences (use `CLAUDE.local.md` or `~/.claude/CLAUDE.md`). The 2025 article's "include everything useful" category list is older; the 2026 docs are stricter. Prefer the 2026 docs.

Write instructions that can be verified: "Use 2-space indentation" beats "format code properly".

## 3. Size

- Docs target **under 200 lines per CLAUDE.md file** (memory page, "Write effective instructions"). Verdict: **verified**. It is a target, not a hard cap. Over it, Claude Code shows a startup and `/status` warning, plus a warning when files that are each short add up past a combined limit (each CLAUDE.md, rules file and `@import` counts as a file).
- Launch-loaded files load whole up to 4 MiB; a bigger file loads none of it.
- On-demand files (subdirectory CLAUDE.md, path-scoped rules) are truncated to a per-file limit: 40,000 characters on a 200K window; on a 1M window 200,000 (Opus 4.6, Sonnet 4.6) or 150,000 (later models). Introduced v2.1.309. Version-sensitive.
- Imports and auto memory (`MEMORY.md`) have their own limits: see [memory-hierarchy-imports-and-rules.md](memory-hierarchy-imports-and-rules.md) (IMP-02, MEM-04).

## 4. Enforcement belongs elsewhere

Best-practices rule of thumb: if a line keeps being missed even with emphasis, it is either lost in a long file or a rule with zero exceptions, so make it a hook, deny rule or managed setting. The reverse also holds: preferences do not deserve hooks. Keep the enforced set small (the page warns that forty hooks are probably mostly preferences).

| Need | Mechanism |
|---|---|
| Never read `.env`, never edit `migrations/` | `permissions.deny` or a `PreToolUse` hook exiting 2 |
| Formatter after every edit | `PostToolUse` hook |
| Typecheck before finishing | `Stop` hook (blocks; capped at eight consecutive blocks by default) |
| Path-specific conventions | `.claude/rules/` with `paths` |
| Procedures | skill |

`prompt` and `agent` hooks ask another model, so they are not deterministic; use `command`/`http`/`mcp_tool` hooks, with `onFailure: "block"` when a crash must also stop the action. The author's claim "mandatory rules belong in hooks/permissions/rules": **partly differing**. Hooks and permissions yes; `.claude/rules/` rules are still context (loaded text), not enforcement. Treat rules as scoping, not as a guarantee.

## 5. Emphasis

2025 article: Anthropic sometimes tuned adherence with "IMPORTANT" or "YOU MUST". 2026 best-practices reverses this: current models follow plain wording and heavy emphasis tends to cause over-application. Shorten the file or move the rule to a hook instead.

## 6. Verifying adherence

- `/context all`: confirms which files appear under Memory files (subdirectory files load on demand and will not appear at launch).
- `/memory`: lists loaded files (AGENTS.md specifics: [agents-md-standard-and-interoperability.md](agents-md-standard-and-interoperability.md)).
- `InstructionsLoaded` hook: logs which instruction files load, when and why.
- `/doctor prompt-audit` (needs v2.1.283+): flags outdated, missing-file and contradictory instructions; changes nothing until asked.
- Test by behavior: give a task where the rule applies and check the outcome; a rule never observed is unverified.

## 7. Priority of values (constitution, only the relevant part)

The constitution orders values: broadly safe, then broadly ethical, then Anthropic's guidelines, then helpfulness; it calls the ordering holistic, not strict. Inference (mine): project instruction files are operator-like helpfulness input, so they sit below safety and ethics. A CLAUDE.md line can never be assumed to override those.

## Secondary-source notes

xerj.org (updated 2026-11-14) and claude-howto agree with the official docs on 200 lines and load order; neither is independent proof. The Reddit thread was not readable (fetch blocked). Cited versions (v2.1.277 to v2.1.316) come from the docs; recheck against the changelog before relying on them.

## How an agent should apply this

- Treat every CLAUDE.md/AGENTS.md line as a request. If a rule has zero exceptions, propose a hook or deny rule, and say so.
- Keep each file under 200 lines; list only non-derivable facts; delete lines that restate the code.
- Move procedures to skills and subtree rules to path-scoped rules rather than growing the root file.
- Write each rule so it is checkable (command, path, number), and avoid ALL-CAPS emphasis.
- After any edit, verify with `/context all` or `/memory`, and run `/doctor prompt-audit` when available.
- State the Claude Code version when citing a limit; flag version-gated facts as such.
- Remember that a CLAUDE.md rule does not constrain calls made inside agent-written code (Claude Code's experimental Code Mode); only deny rules, hooks and the sandbox act there. Details: `model-effort-routing`, `references/code-mode-and-tool-call-batching.md`.
