# Atomic Commits and Small, Reviewable Changes

Sources: https://google.github.io/eng-practices/review/developer/small-cls.html · https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project · https://git-scm.com/docs/SubmittingPatches · Last verified 2026-11-23

## Definition

An atomic commit is one self-contained logical change that addresses a single concern, leaves the build working, and carries its own tests and docs. The Pro Git book: make each commit a logically separate changeset; the end snapshot is identical either way, but small commits are easier to review, pull out, or revert. Google's engineering practices apply the same idea to review units ("CLs"); the unit may be a commit or a small PR (mapping is inference).

## Why small wins

Per Google's guidance: reviewed faster and more thoroughly, fewer bugs, less wasted work if rejected, easier merges, simpler rollbacks, and the author can keep working while waiting. Reviewers may reject a change purely for size.

## What counts as small

- One concern; often one slice of a feature.
- Tests for the logic in the same unit; a new API ships with at least one real use.
- Understandable from its description plus existing code.
- No fixed line count: roughly 100 lines is reasonable, 1000 usually too large; many files count as larger. When unsure, go smaller.
- Exceptions: whole-file deletion (counts as about one line) and trusted automated refactors (still need testing and merge care).

## Splitting strategies

| Strategy | How | When |
|---|---|---|
| Prepare-then-change | refactor commit (no behavior change), then feature commit | code is hard to extend as it stands |
| Stacking | submit small change 1, build change 2 on top | review latency is blocking you |
| By file/owner | e.g. schema/proto change separate from consumers | different reviewers |
| Horizontal | stub shared API/interface first, layers proceed independently | multiple people on layers |
| Vertical | thin full-stack slice per feature | features parallelize |
| Tests-first support | test helpers or coverage for existing code land first | missing safety net (see `tdd`) |

Refactors belong in separate changes from features or fixes, though a tiny local rename can ride along. Every commit in a dependent series must leave the system working. If a change cannot shrink, first try a refactor-only change that prepares the way; as a last resort agree with reviewers in advance and be extra careful with tests.

## Splitting in practice (single working tree, mixed edits)

```
git status                # inventory
git add -p src/parse.py   # stage only the refactor hunks
git diff --cached         # verify
git commit -m "refactor(parse): extract tokenizer"
git add -p                # now the behavior hunks + their tests
git commit -m "fix(parse): reject empty tokens"
```
Already one big commit, unpushed: `git rebase -i <base>`, mark `edit`, then `git reset HEAD^` and recommit in pieces, then `git rebase --continue`.

## Whitespace and noise

Run `git diff --check` before committing. Keep formatting-only changes in their own commit (or avoid), so blame and review stay readable.

## Failure modes

- "Kitchen sink" commits mixing fix, refactor and formatting: unreviewable and unrevertable.
- Over-splitting into commits that do not build: breaks `git bisect`.
- Commits that fix the previous commit ("oops"): fold them in before sharing (`--fixup`).
- Giant generated diffs hiding hand edits: separate generated output into its own commit stating the command.

## Sizing rule of thumb for agents (inference)

If the staged diff exceeds roughly 300 changed lines or touches unrelated directories, pause and ask whether it should be several commits.

## How an agent should apply this

- Before committing, list the distinct concerns in the diff; if more than one, stage and commit them separately.
- Put refactors and formatting first, behavior next, each with its tests.
- Verify each commit builds (run the quick test/build between commits when feasible).
- Keep generated artifacts out unless the repo tracks them; if so, isolate them.
- For multi-step migrations or breaking changes, one commit per step, see `parallel-change-expand-contract`; for review of the result, `code-review`.
- Do not run the split on pushed history; propose a follow-up instead.
