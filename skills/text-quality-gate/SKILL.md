---
name: text-quality-gate
description: "Design a deterministic quality gate for generated text (docs, commit messages, code comments, PR and issue text, chat replies): a script that scans outgoing text, exits non-zero with a hit list, and runs from a git hook, CI or a Claude Code hook whether or not anyone remembers it. Covers rule versus gate, hard tells versus counted style signals, stripping quotes and code before scanning, exit status, wiring, false-positive handling and a small Python example. Use when generated text keeps carrying the same unwanted patterns despite style rules, or when a hook should check prose. Not for Husky or lint-staged formatting hooks (use setup-pre-commit) or blocking destructive git commands (use git-guardrails-claude-code)."
---

# Text Quality Gate

One idea: a style rule in an instruction file is **advisory** and fails exactly where the writer does not think it is writing; a **gate** is a small deterministic script on the output path that refuses the text and names the offending lines, so the rewrite is targeted and nothing depends on memory. Sources and claims: [references/sources.md](references/sources.md).

Boundary: this skill designs the gate. Which instruction files exist and which rules are enforced versus advisory is the job of `skill-orchestrator`; how to write code comments and names is `clean-code-for-agents`; commit structure and Conventional Commits are `git-atomic-commits`; how documentation is organized is `diataxis-documentation-architecture`. The gate only checks surface patterns in text those skills already govern.

---

## 1. Rule versus gate

| | Rule (instruction file, skill text) | Gate (script on the output path) |
|---|---|---|
| Mechanism | The model reads it and tries to comply | A process scans the text and returns an exit code |
| Failure mode | Skipped in steps the model treats as "not writing" (titles, labels, commit subjects, comments) | False positives, and blindness to anything the patterns do not describe |
| Cost | Tokens on every turn, forever | Nothing until it fires; one short message when it does |
| Evidence | None; compliance is a hope | The exit code and the hit list |
| Right for | Judgment ("explain why, not what") | Patterns that are mechanical and stable ("no emoji in headings") |

Decision: if the rule can be written as a pattern and a human would never defend a violation, move it from the instruction file into a gate and delete the prose. If it needs judgment, keep it as a rule and say so ("advisory"). Never claim a rule is enforced when no script runs.

Every surface that was never named explicitly is on the unchecked side of a rule: commit subjects, table headers, slide or section titles, diagram labels, code comments, alt text, issue and PR bodies, chat replies. A gate that scans text on its way out, whatever produced it, closes that hole.

## 2. Hard tells versus counted signals

Two tiers keep the gate usable instead of annoying.

| Tier | Behavior | What belongs here | Example patterns (own examples) |
|---|---|---|---|
| **Hard tell** | One hit fails | Patterns that are almost never right in your context | emoji at the start of a heading; "In conclusion," as a final paragraph opener; a flattery opener such as "Great question"; filler pre-announcements ("It is worth noting that") |
| **Counted signal** | Fails at a threshold, not on one hit | Words that are legitimate once and decoration in density | "robust", "seamless", "leverage", "streamline", "cutting-edge" |
| **Not a gate item** | Left to a reviewer | Anything that needs meaning to judge | invented structure, repeated paragraphs, wrong counts |

Rules for choosing the tier:

1. Start with the few patterns you have actually seen recur in your own output; do not import a long list.
2. A pattern is a hard tell only if you can state a rewrite that is always better. If a human could defend it in some context, make it counted or drop it.
3. Set the counted threshold from real samples (clean prose should score 0 or 1). A threshold nobody can explain gets disabled.
4. Prefer fewer patterns with a high hit-to-real-problem ratio. Each false positive trains people to bypass the gate.

## 3. Strip quotes and code before scanning

Scan the author's voice, not the exhibits. Before matching, blank out:

- fenced code blocks and inline code,
- quoted spans (double quotes and curly quotes; not apostrophes),
- front matter and URLs when a pattern could fire inside them,
- in a commit message, lines starting with `#` (git removes them).

Blank, do not delete: replace the span with spaces but **keep the newlines** so reported line numbers match the file. A document that quotes a tell as an example then does not fail on its own examples. Linters of prose behave the same way: Vale ignores block and inline code by default, and markdownlint lets a file switch rules off with inline comments (details in [references/sources.md](references/sources.md)).

## 4. Exit status and output

- Exit **0** when clean, **1** when a hard tell or threshold hit, **2** when the gate itself could not run (unreadable file, bad config). Vale separates "found errors" (1) from "could not run" (2) the same way; keep failures of the gate distinguishable from findings.
- Print one line per hit to stderr: `path:line: label: excerpt` (excerpt cut to ~60 characters). Editors and CI logs parse this shape.
- Print counts for threshold hits (`4 counted words: robust, seamless, ...`) so the fix is obvious.
- Print nothing on success. Never print the whole text back.
- A gate that only reports is a linter; the gate part is that the caller treats a non-zero exit as a block.

## 5. Wiring: where the gate runs

| Hook point | Input | Blocks when | Notes |
|---|---|---|---|
| `git` `commit-msg` | Path of the message file as argument 1 | Non-zero exit aborts the commit | Right place for commit subjects and bodies; `--no-verify` bypasses it |
| `git` `pre-commit` | Staged files (you list them) | Non-zero exit aborts the commit | Scan staged `.md` and comment-heavy files; bypass with `--no-verify` |
| CI job | Files in the pull request | Failed job | The only place a bypass cannot be local; run the same script |
| Claude Code `PreToolUse` on `Write` or `Edit` | JSON on stdin with the tool input | **Exit code 2** blocks and returns stderr to the model; exit 1 does not block | Scans text before it lands on disk |
| Claude Code `Stop` | JSON on stdin including the last assistant message | JSON `{"decision":"block","reason":...}` | Scans the agent's own reply; expect it to fire often at first |

Wiring rules:

- One script, several callers. Put the patterns in a single file and let the git hook, CI and the tool hook all call it (`ssot-and-dry`).
- For the Claude Code hook, exit 2 and the JSON decision are alternatives for one decision; do not mix them. A hook that exits 1 only shows a notice and the action proceeds.
- Hook errors proceed by default; if the gate must fail closed, say so in the hook configuration rather than assuming.
- Log the payload once while wiring; tool input field names are the part most likely to drift.
- Repo hooks need the executable bit and a hooks path that is versioned (`core.hooksPath`), otherwise they silently do nothing on other machines.

Detailed wiring snippets: [references/rule-vs-gate-and-wiring.md](references/rule-vs-gate-and-wiring.md).

## 6. False positives and exemptions

1. **First fix the pattern**, not the text: tighten it to the failing context (anchor to line start, add word boundaries, require the surrounding words).
2. **Exhibits**: a document that must show a tell in its own voice (a style guide, a test fixture) carries an explicit marker with a reason, for example `gate-ok: style guide quotes tells`. A marker without a reason does not count.
3. **Never** add the marker to pass a gate you disagree with. Rewrite the text, or change the pattern list in the same commit and say why.
4. Keep a short **allowlist** for legitimate terms of art (a counted word that is the technical term in that field).
5. Track hits that were overridden. A pattern overridden often is a bad pattern.
6. Test the gate with a fixtures folder: files that must fail, files that must pass, and an exhibit file. Run it in CI (`tdd`).

## 7. What a regex gate cannot see

It cannot judge: a claimed count that the source does not contain, an invented framework, uniform sentence rhythm, a paragraph that repeats the previous one, an answer that is confidently wrong. Those need a reader. Use a reviewer (`code-review` for code and docs diffs), prefer one from a different model family than the author, and do not stretch the gate to cover them. A gate that grows into a meaning-checker produces noise.

## 8. Recipe for writing the gate in any language

1. **Inventory**: collect 20 to 50 real outputs; mark the lines a reviewer would change; list the recurring patterns.
2. **Classify** each into hard tell, counted signal or "needs a reader" (section 2).
3. **Write patterns** as data (a table of label to pattern), separate from the scanning code.
4. **Mask** code, quotes and exempt regions, preserving line numbers (section 3).
5. **Scan line by line** for hard tells; scan the whole text for counted signals against the threshold.
6. **Report** `path:line: label: excerpt` to stderr and return 0/1/2 (section 4).
7. **Test** with fixtures: one failing file per pattern, a clean file, an exhibit file, quotes and code containing a tell.
8. **Wire** it at the narrowest useful point first (`commit-msg`), then CI, then the tool hook (section 5).
9. **Review monthly**: remove patterns that never fire or often get overridden.

A worked Python example of about 40 lines and the hook adapters are in [references/writing-a-gate-script.md](references/writing-a-gate-script.md). Pattern design in more depth: [references/hard-tells-and-counted-signals.md](references/hard-tells-and-counted-signals.md).

## Quick Decision Checklist

1. Is the rule mechanical and stable enough to be a pattern? If not, keep it as an advisory rule.
2. Is each hard tell something a human would never defend? Otherwise make it counted.
3. Are quotes and code masked, with line numbers preserved?
4. Does it exit 0, 1 or 2, and print `path:line: label: excerpt` to stderr?
5. Does the caller treat non-zero as a block (exit 2 for Claude Code hooks, non-zero for git)?
6. Is there one script and one pattern file for all call sites?
7. Is every exemption explicit, with a reason?
8. Are there fixtures, including an exhibit and a quoted-tell case?
9. Did you say what the gate cannot see and name the reviewer for it?

## Deep references

- [rule-vs-gate-and-wiring.md](references/rule-vs-gate-and-wiring.md) - read when deciding what to enforce and when wiring git hooks, CI or Claude Code hooks (exit codes, payloads, decisions).
- [hard-tells-and-counted-signals.md](references/hard-tells-and-counted-signals.md) - read when choosing patterns, thresholds, masking rules and exemption handling, with prose-linter parallels.
- [writing-a-gate-script.md](references/writing-a-gate-script.md) - read when implementing the gate; includes a runnable Python example, fixtures and hook adapters.
- [sources.md](references/sources.md) - sources, retrieval status and claims not adopted.
