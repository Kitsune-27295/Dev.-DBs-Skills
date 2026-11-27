# Evidence, Risk and Interface Versus Behavior

Sources: https://google.github.io/eng-practices/review/developer/cl-descriptions.html · https://google.github.io/eng-practices/review/developer/small-cls.html · https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/reviewing-proposed-changes-in-a-pull-request · Last verified 2026-11-27

## What the sources say and what is own judgment

The Google pages say a description should include relevant background such as benchmark results, mention shortcomings of the approach, and explain why the chosen approach is best. The small-change page says a change should include its related tests, should keep the system working afterwards, and that small changes are simpler to roll back because large ones touch files that change before a revert. Breaking-change markers (`!`, `BREAKING CHANGE:`) are owned by `git-atomic-commits`. GitHub's review docs note that when required reviews and stale-review dismissal are both enabled, a code-changing push dismisses an approval, so the description should stay accurate across rounds.

The specific section layout below (interface versus behavior, door, blast radius, rollback, test design) is **own synthesis** from those sources plus general release-engineering practice; it is not a quoted standard. A third-party skill read for ideas (no text reused) suggested separating interface from behavior changes, showing before and after evidence, and stating how reversible a merge is; the wording and structure here were written independently.

## Evidence

A test claim is worth what a reviewer can verify. Present evidence from the cheapest, most direct form:

| Change type | Evidence that persuades |
|---|---|
| Bug fix | Failing test or reproduction before; same test passing after; the root cause in one sentence |
| New behavior | Test matrix: scenario, expected result, covering test |
| Refactor, no behavior change | Existing tests unchanged and green; snapshot or output comparison; explanation of why behavior is the same |
| Performance | Before and after numbers, with data size, machine, run count and how it was measured |
| UI or visible change | Before and after screenshot or short recording |
| Docs only | Links checked, examples run, rendered preview |
| Migration | Dry-run output, row counts before and after, rollback rehearsal |

Rules (aligned with `verification-loop`):

1. List only checks that really ran; label the environment (local, CI).
2. Put the command next to the result so a reviewer can repeat it.
3. Show that a check can fail: for a fix, the failing run before the fix.
4. Say what you did not test and why; do not leave silence to be read as coverage.
5. Keep logs short: counts and the relevant excerpt, with the rest linked or in a collapsible block.

## Interface versus behavior

**Interface changes** alter what other code or people couple to: exported functions, routes, CLI flags, config keys, env vars, event or message names, schemas, file formats. **Behavior changes** alter what happens when those interfaces are used: defaults, output, ordering, timing, error text, side effects, data written. A refactor can change neither; a bug fix usually changes behavior only; a rename of a public function changes interface with no behavior change.

Why separate them: reviewers check interface changes against *dependents* (who breaks?) and behavior changes against *users* (who notices?). Mixing them hides the first kind of risk.

Example:

```text
Interface changes
- New optional flag `--dry-run` on `import` (default off).
- None removed or renamed.

Behavior changes
- `import` now skips rows with a blank id and reports the count (before: aborted on first blank id).
```

When both are "None" and it is a pure refactor, say so explicitly: "No interface or behavior change; covered by existing tests, unchanged."

## Risk, blast radius and rollback

| Question | Answer format |
|---|---|
| One-way or two-way door? | One-way if data is migrated, an API is published, or an external side effect cannot be undone |
| Blast radius | A noun: "one report page", "all tenants", "billing data" |
| Rollback | The exact action: revert PR, toggle flag, down-migration with its script name, redeploy tag |
| Order of operations | Migration first, then code; or code then flag flip; note the compatibility window |
| Detection | What will show it is wrong: metric, alert, log line |
| Known weakness | Stated plainly |

Pair with `parallel-change-expand-contract` for breaking interface moves and `migrations-and-environments` for schema ordering.

## Failure modes

- "Behavior unchanged" with no evidence.
- One-way changes presented as trivially revertible.
- Evidence from a different branch, commit or environment than the one proposed.
- Test evidence that only shows the happy path.
- Risk section copied from a template and not adapted.

## How an agent should apply this

- Before writing Testing, run the checks now, in this session; copy actual counts and commands, never remembered ones.
- Split the Changes list into Interface and Behavior; write "None" where true.
- State door type, blast radius and rollback in three short lines for any non-trivial change.
- Name what you did not test; never imply coverage you do not have.
- If evidence is missing and cannot be produced, mark the PR as draft or "Partially validated" and say so (`verification-loop` completion states).
