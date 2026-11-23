---
name: git-atomic-commits
description: "Craft atomic, reviewable git commits: when to split a change, Conventional Commits 1.0.0 types/scopes/breaking-change footers and their SemVer effect, commit message craft (imperative subject <=50 chars, body explains why), interactive staging with git add -p, safe local history rewriting (amend, rebase -i, fixup/autosquash), --force-with-lease vs --force, patch-series/contributing workflow, and keeping secrets out of history. Use when about to commit, split or squash a diff, word a commit message, clean up a branch before review, decide whether history may be rewritten, or recover from a committed secret."
---

# Git Atomic Commits, Messages & Safe History

One idea: a commit is the unit of **review, revert, bisect and blame**, so each one should be a single logical change that builds and passes tests, with a message that tells the future reader **why**. History may be polished only while it is private; once shared, it is append-only. Sources and claims: [references/sources.md](references/sources.md).

Boundaries: reviewing someone's diff is `code-review`; the red/green/refactor cadence that produces commits is `tdd`; running a ticket end to end is `implement`; multi-step breaking migrations are `parallel-change-expand-contract` (this skill only says each step is its own commit); recording architecture decisions is `adr-architecture`; deep secret/exposure audits are `security-audit` and `database-exposure`; schema rollout across environments is `migrations-and-environments`; trust boundaries in code are `never-trust-the-client`.

---

## 0. Agent guard rails (read first)

- **Do not commit, push, amend, rebase or force-push unless the user asked.** Preparing a message or a proposed split is fine; executing history-changing commands needs an explicit request.
- Rewriting is allowed **only for commits not yet pushed** (check `git status -sb` / `git log @{u}..`). Never rewrite a shared branch (main, release, anything others fetched) without explicit user approval naming that branch.
- Never use `--no-verify`, `--force` or `git add -A` on autopilot. Stage by path or hunk, then read `git diff --cached`.
- A committed secret is an incident, not a typo: revoke first, then clean (see section 8).

## 1. Decision: split or keep together?

| Signal in the diff | Decision |
|---|---|
| Subject needs "and" / two verbs | Split |
| Refactor/rename/format plus behavior change | Refactor commit first, behavior commit second |
| Bug fix plus unrelated cleanup | Separate commits (fix stays small and cherry-pickable) |
| New API plus its first caller | Keep together (reviewer needs the use) |
| Logic change plus its tests | Keep together |
| Generated files / lockfile churn | Commit with the change that caused them, or separate "chore" when mechanical |
| Mechanical bulk change (tool-driven rename, delete) | Own commit, say the command used |
| Revert would need to undo half | Split along that line |

Test of atomicity: each commit builds, passes its tests, and can be reverted alone without breaking the rest. Rough size: about 100 lines is comfortable, ~1000 is too big; unsure means go smaller. Details: [atomic-and-small-changes.md](references/atomic-and-small-changes.md).

## 2. Message format

```
<type>[(scope)][!]: <imperative subject, <=50 chars, no period>

<body: wrapped ~72, explains WHY and the old vs new behaviour>

<footers: Refs: #123 / BREAKING CHANGE: ... / Co-authored-by: ...>
```

Rules:
1. Subject is imperative: completes "If applied, this commit will ___". Hard stop at 72 chars.
2. Blank line between subject and body; body answers why, what was wrong, why this approach. Not "how" (the diff shows it).
3. No reference to mailing-list or chat threads as the only explanation: summarize.
4. Trailers (sign-off, co-authors, reviewers, issue refs) go in the **footer**, one per line.
5. Subject-only is fine for trivial changes (typo, docs).

Details and examples: [message-craft.md](references/message-craft.md).

## 3. Type, scope and SemVer map

| Type | Meaning | SemVer bump |
|---|---|---|
| `feat` | new capability | MINOR |
| `fix` | bug correction | PATCH |
| `feat!` / `fix!` / any type with `BREAKING CHANGE:` footer | incompatible public change | MAJOR |
| `docs` `style` `refactor` `perf` `test` `build` `ci` `chore` `revert` | common non-spec types (Angular-derived); no bump unless breaking | none |

Scope = one noun for the area, in parentheses: `feat(parser): ...`. Keep the scope list short and agreed per repo. `BREAKING CHANGE` must be uppercase; `!` may replace the footer but then the description must state the break. While the project is `0.y.z`, SemVer allows anything to change, yet Conventional Commits advises treating it as released. If the repo does not use Conventional Commits, follow its existing style; do not impose it. Details: [conventional-commits-and-semver.md](references/conventional-commits-and-semver.md).

## 4. Staging procedure

1. `git status`, then `git diff` to see everything.
2. Pick the first logical change; stage with `git add -p` (answer `y`/`n`, `s` to split a hunk, `e` to edit one).
3. `git diff --cached` and `git diff --check` (whitespace). Confirm only that change is staged.
4. Run the tests/build relevant to the unit.
5. Commit; repeat. Leftovers stay unstaged. Oops: `git restore --staged -p` / `git reset -p` unstage hunks (`git restore -p` and `checkout -p` **discard** work irreversibly).

Details: [staging-and-history-rewriting.md](references/staging-and-history-rewriting.md).

## 5. When history may be rewritten

| Situation | Allowed? | Tool |
|---|---|---|
| Last commit, unpushed: fix message/forgotten file | Yes (if user asked to commit/amend) | `git commit --amend [--no-edit]` |
| Several unpushed commits: reorder, squash, reword, split, drop | Yes | `git rebase -i <base>` |
| Late fix belongs to an earlier unpushed commit | Yes | `git commit --fixup <sha>` then `git rebase -i --autosquash` |
| Personal topic branch pushed, nobody else uses it | Yes, with lease | `git push --force-with-lease` |
| Shared branch, others fetched it | **No** without explicit user approval; prefer `git revert` | `git revert <sha>` |
| Released/tagged history | No | revert, new fix commit |

Before a rewrite: note the current tip (`git rev-parse HEAD` or rely on reflog); recovery is `git rebase --abort` mid-way or `git reflog` afterward.

## 6. Pushing rewritten history

Never bare `--force`. Use `git push --force-with-lease --force-if-includes origin <branch>` (or the explicit `--force-with-lease=<ref>:<expected-sha>`), scoped to one branch. Background fetches can defeat a bare lease. Full mechanics: [force-push-safety.md](references/force-push-safety.md).

## 7. Pre-commit checklist

- [ ] `git diff --cached` read line by line; only one logical change
- [ ] No secrets, tokens, `.env`, private keys, dumps (scanner/pre-commit hook run if the repo has one)
- [ ] No generated artifacts, build output, editor files, unrelated lockfile churn
- [ ] No debug prints, commented-out code, stray TODOs from this session
- [ ] `git diff --check` clean
- [ ] Tests cover the unit changed (logic change without test = incomplete)
- [ ] Message: type/scope correct, imperative subject <=50, body says why, breaking change footed
- [ ] Not committing/pushing unless the user asked

## 8. Secrets in history (summary)

Order matters: **revoke, rotate, delete, then optionally purge** history. Purging does not un-leak a secret. Prevent with pre-commit scanning and `.gitignore`. Full procedure: [secrets-hygiene.md](references/secrets-hygiene.md); infrastructure-level exposure belongs to `database-exposure` and `security-audit`.

## 9. Sending a series

One topic branch, a clean ordered series, each commit explained; rebase on the current base before submitting; early review rounds replace the series rather than stack "fix typo" commits; keep a cover note (why, what changed since last round, base branch). See [staging-and-history-rewriting.md](references/staging-and-history-rewriting.md) and [atomic-and-small-changes.md](references/atomic-and-small-changes.md).

## Quick Decision Checklist

1. Did the user ask me to commit/push? If not, stop at proposing.
2. One logical change per commit? If the subject needs "and", split.
3. Refactor separated from behavior? Tests with the logic?
4. Staged diff reviewed, no secrets, no generated files?
5. Message: imperative, <=50, why in body, breaking change marked, SemVer effect right?
6. Is the commit unpushed? Only then rewrite; otherwise revert.
7. Pushing rewritten work: `--force-with-lease` + `--force-if-includes`, one branch, never bare `--force`.
8. Secret committed: revoke and rotate first.

## Deep references

- [Conventional Commits and SemVer](references/conventional-commits-and-semver.md) — read when choosing types, scopes, `!`/BREAKING CHANGE or version bumps.
- [Commit message craft](references/message-craft.md) — read when wording subject/body/trailers or fixing a vague message.
- [Atomic and small changes](references/atomic-and-small-changes.md) — read when deciding how to split a diff or size a review unit.
- [Staging and history rewriting](references/staging-and-history-rewriting.md) — read when using `git add -p`, amend, `rebase -i`, fixup/autosquash, or building a patch series.
- [Force-push safety](references/force-push-safety.md) — read before any push of rewritten history.
- [Secrets hygiene](references/secrets-hygiene.md) — read when preventing, detecting or responding to committed secrets.
