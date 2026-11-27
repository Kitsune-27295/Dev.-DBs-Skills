# Karpathy-Style Behavioral Rules: The Four Principles Analyzed

Sources: https://github.com/multica-ai/andrej-karpathy-skills (CLAUDE.md, README.md, EXAMPLES.md read raw), https://www.skillleaderboard.com/skill/multica-ai-andrej-karpathy-skills, https://www.orcarouter.ai/blog/karpathy-claude-md-file-explained · Last verified 2026-11-27

## What the artifact is (verified facts)

- The repo's `CLAUDE.md` is 65 lines, 2,357 bytes (measured on the raw file, main branch). It is short on purpose: four headed rules, one trade-off note, one closing "working if" line.
- Origin: the README says the file is "derived from" Andrej Karpathy's observations on LLM coding pitfalls, cites an X post, and quotes three complaints from it (silent wrong assumptions, overcomplication, side-effect edits to comments and code). The directory listing site states plainly that it is inspired by Karpathy and not written by him. So: **the repo author's distillation, not a Karpathy document.** The X post itself was not read (out of scope); only the README's quotes of it were.
- License: the README ends with "MIT", but no LICENSE file exists at the repo root (raw URLs for LICENSE, LICENSE.md, LICENSE.txt returned 404) and the GitHub API reports `license: null`. Treat as "MIT per README, license file unverified". This pack paraphrases and never copies the text.
- The file opens with a trade-off: it biases toward caution over speed, and trivial tasks need judgment.
- Install strings in the README use a different GitHub owner (`forrestchang/...`) than the repo URL (`multica-ai/...`); which copy is canonical is unclear.

## The four principles

| # | Principle | Label (full wording: the template in [karpathy-claude-md-audit-and-update-procedure.md](karpathy-claude-md-audit-and-update-procedure.md)) | Rationale | Failure it prevents | Verify | Detailed owner in this pack |
|---|---|---|---|---|---|---|
| 1 | Think Before Coding | Assumptions and readings before building | Otherwise the model picks one reading silently and builds on it | Wrong-problem work, hidden confusion | Transcript, not diff: assumptions listed before edits; question asked before code | `grilling` (interview), `model-effort-routing` (when to stop and ask vs proceed) |
| 2 | Simplicity First | Smallest solution for the stated request | Unrequested generality adds code to review and bugs to own | Bloat (the post's idea of 1000 lines where 100 would do) | Added lines vs. requirement; count new classes, parameters, config knobs with no caller | `kiss-yagni-aha`, `clean-code-for-agents` |
| 3 | Surgical Changes | Narrow diffs that trace to the request | Review cost and regression risk scale with diff size | Drive-by refactors, reformatting, deleted comments | Every hunk traces to the request (the file's own test); no whitespace-only or rename hunks | `code-review` (diff review), `layered-refactor` (when a refactor is the task) |
| 4 | Goal-Driven Execution | Checkable goal with a verify step per stage | Models loop well against a concrete pass/fail signal | "Make it work" with no stopping rule | A failing-then-passing test exists, or a named command output is quoted | `tdd`, `implement` (and your debugging routine) |

## Advisory versus enforceable

| Rule element | Nature | Enforce with |
|---|---|---|
| "Ask when unclear", "present tradeoffs" | Advisory; judgment-heavy | Prose in CLAUDE.md; reviewer reads the transcript |
| "No unrequested features", "if 200 lines could be 50" | Advisory | Review checklist; a size alarm in review (own suggestion, not in the repo) |
| "Every changed line traces to the request" | Checkable after the fact | `code-review` pass; optionally a diff-size or touched-file allowlist check in CI (own suggestion) |
| "Tests pass before and after" | Mechanically enforceable | CI, a pre-commit or stop hook running the suite |
| Style matching | Enforceable | Formatter and linter config, not prose |

Rule of thumb (own inference): if a command can check a line, move it out of prose into a hook or CI job. The general rule and the mechanisms are owned by [claude-md-official-guidance-and-limits.md](claude-md-official-guidance-and-limits.md) section 4 (ENF-01); the checks in the table above are own suggestions for these four rules.

## "Diff verification tests" (what the repo actually says)

The repo names no formal "diff verification test". It has informal checks: the Surgical Changes test (every changed line traces to the request), the Simplicity question (would a senior engineer call it overcomplicated), and the closing "working if" signals (fewer unnecessary diff changes, fewer overcomplication rewrites, clarifying questions before code rather than after). The README adds "clean, minimal PRs". These are self-reported signals; no benchmark is published (the OrcaRouter article says so too).

## What secondary analyses add or get wrong

- OrcaRouter (vendor blog, sells a gateway): accurate on the four principles and origin; adds a useful caution to audit each rule against failures you actually saw; notes missing benchmarks and the owner mismatch. It gives no line count. Its star and fork counts (222,612 / 22,321 on 2026-10-23) are stale; the directory site shows about 235k stars. Treat counts as volatile.
- Skill leaderboard: confirms "inspired by, not written by Karpathy"; shows the repo created 2026-01-27 and no license on the page. Its last-commit date (2026-01-28) conflicts with OrcaRouter's last push (2026-04-20): listing snapshot lag.
- MindStudio best-practices article: no Karpathy mention; its CLAUDE.md-as-suggestion advice is secondhand and its percentage claims are unsourced. Use only the hooks-for-hard-rules idea, labeled claimed.
- MindStudio "spec-driven method": describes a spec / verifier / environment trio attributed to Karpathy without a source. A different framework from the four principles; do not merge them.
- PR #104 (open, unmerged when read) shows the repo also ships a Cursor rule and a `skills/karpathy-guidelines` skill, and proposes Codex metadata. See the examples file.

## How an agent should apply this

- When asked to "add Karpathy rules", describe them as a derived four-rule set, never as Karpathy's own words, and note the license ambiguity.
- Map each rule to the pack skill above instead of restating detailed rules in the instruction file.
- Split every rule into advisory prose or an enforced check; propose hooks or CI only for the checkable ones.
- Keep the trade-off clause: skip the ritual for trivial edits.
- Re-verify volatile facts (stars, last push, license file) before quoting them.
