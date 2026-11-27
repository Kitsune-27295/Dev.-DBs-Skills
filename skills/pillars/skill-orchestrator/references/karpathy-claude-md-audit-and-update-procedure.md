# Auditing and Updating a CLAUDE.md Against the Four Principles

Sources: https://github.com/multica-ai/andrej-karpathy-skills (README sections "Customization" and "How to Know It's Working"), https://www.orcarouter.ai/blog/karpathy-claude-md-file-explained, https://www.mindstudio.ai/blog/anthropic-claude-code-best-practices-2025 · Last verified 2026-11-24

## Procedure

1. **Measure.** Count lines and bytes of the instruction file and everything it imports. Reference point: the source file's size is recorded in [karpathy-four-principles-analysis.md](karpathy-four-principles-analysis.md). Own budget suggestion: behavioral block at most about 40 lines; the whole file as small as the project allows. If over budget, cut before adding.
2. **Map.** Mark each existing rule as serving one principle (Think, Simplicity, Surgical, Goal) or as a "project fact" (commands, paths, conventions). Project facts stay; they are not Karpathy-style rules.
3. **Find conflicts.** Common clashes: "always refactor touched files" versus Surgical; "add docstrings and types everywhere" versus Surgical and Simplicity; "never ask, just do it" versus Think; "skip tests to ship" versus Goal-Driven. Project rules win by default (the source itself says to merge with project instructions); resolve by rewording, not by keeping both.
4. **Dedupe against the pack.** Do not paste detailed rules owned by other skills; the owner column of [karpathy-four-principles-analysis.md](karpathy-four-principles-analysis.md) says which skill owns which principle, and `model-effort-routing` owns model and effort choice. Keep one line per principle in the file and point to the skill.
5. **Classify advisory versus enforced.** Anything a command can check moves to a hook or CI; prose stays for judgment rules. Mechanisms and the emphasis caveat: [claude-md-official-guidance-and-limits.md](claude-md-official-guidance-and-limits.md) sections 4-5 (ENF-01, EMP-01); per-principle checks: the advisory table in [karpathy-four-principles-analysis.md](karpathy-four-principles-analysis.md).
6. **Test against real failures.** For each kept rule, name a past failure it prevents (OrcaRouter's advice, paraphrased); delete rules with none. Then run 3 sample tasks and check the signals the repo lists: smaller diffs, fewer overbuilt rewrites, questions before code.
7. **Record.** Keep the trade-off clause and a date note; recheck after model upgrades, since the need for some rules may shrink (own inference).

## Update triggers

A repeated failure; a model change; new tooling that can enforce a rule; the file grew past budget; a conflict raised in review.

## Minimal template (own wording)

```markdown
# Behavior rules (merge with the project facts below)
Bias: care over speed. For trivial edits, use judgment and skip the ritual.

## 1. Clarify first
- List your assumptions before editing; ask if a wrong guess would be costly.
- If the request has several readings, name them and recommend one.
- Say so when a simpler route exists.

## 2. Smallest solution
- Build only what was asked: no extra options, no one-use abstractions.
- No handling for cases that cannot occur. Shrink anything that grew past need.

## 3. Narrow diffs
- Every changed line must trace to the request.
- Match local style. Do not reformat or reword neighbors.
- Remove only what your change orphaned; report other dead code, do not delete it.

## 4. Prove it
- Turn the task into a check (failing test, command, output) before coding.
- Plan multi-step work as "step -> verify". Loop until the check passes.
- Report what you ran and its result.

# Project facts
- Test: <command>   Lint: <command>   Layout: <notes>
```

About 28 lines. Adapt the wording to the project.

## How an agent should apply this

- Run steps 1-3 read-only first and show the user the conflict list before editing the file.
- Keep the behavioral block short and delegate depth to the named pack skills.
- Propose hooks or CI for checkable rules instead of adding prose.
- Never delete project facts or user-owned rules without confirmation.
- Report size before and after, and which rules were removed and why.
