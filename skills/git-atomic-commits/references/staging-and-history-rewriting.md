# Interactive Staging, History Rewriting and Patch-Series Workflow

Sources: https://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging · https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History · https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project · https://git-scm.com/docs/SubmittingPatches · Last verified 2026-11-23

## Interactive staging

`git add -i` opens a menu: status, update, revert, add untracked, patch, diff, quit, help. The power feature is **patch mode**, also `git add -p`: Git shows each hunk and asks `[y,n,a,d,/,j,J,g,k,K,s,e,?]`.

| Key | Effect |
|---|---|
| `y` / `n` | stage / skip this hunk |
| `a` / `d` | stage / skip this and all remaining hunks in the file |
| `s` | split the hunk into smaller hunks |
| `e` | edit the hunk by hand (for changes inseparable by `s`) |
| `/` | search for a hunk by regex |
| `j J k K g` | navigate undecided/any hunks |

A partly staged file shows as both staged and unstaged; `git commit` records only the staged part. Review with `git diff --cached` (staged) and `git diff` (rest).

Same hunk UI elsewhere: `git reset -p` unstage parts; `git stash push -p` stash parts (the book's `stash save --patch` is deprecated); `git restore -p` / `git checkout -p` **discard** working-tree changes and cannot be undone. Untracked files are not offered by `add -p` (use `git add -N <file>` first, not read from source).

## Rewriting: the cardinal rule

Rewrite only commits that have not been pushed. Rewritten commits get new SHAs; anyone who built on the old ones sees confusing duplicates.

## Amend

- `git commit --amend` edits message and/or content (stage forgotten changes first).
- `git commit --amend --no-edit` keeps the message (typo, forgotten file).
- Amending changes the SHA, so never on a pushed commit.

## Interactive rebase

`git rebase -i HEAD~3` (or `<parent of oldest>`) opens a todo list, **oldest first** (reverse of `git log`). Execution is top to bottom.

| Command | Effect |
|---|---|
| `pick` | keep |
| `reword` | keep, edit message |
| `edit` | stop to amend or split |
| `squash` | meld into previous, combine messages |
| `fixup` | meld into previous, drop this message |
| `drop` | delete the commit |
| `exec` | run a command after the line |
| `break` | pause here |

Deleting every line aborts. Reorder by moving lines. Dropping or reordering early commits can cause conflicts in later ones.

Split a commit: mark `edit`; at the stop run `git reset HEAD^`, then `git add`/`git commit` per piece, then `git rebase --continue`.

Fixup workflow (autosquash flags: not read from the fetched pages, standard Git): `git commit --fixup <sha>` creates a `fixup!` commit; `git rebase -i --autosquash <base>` auto-places and marks it. `git config rebase.autoSquash true` makes it default.

Recovery: `git rebase --abort` during; `git reflog` and reset to the old tip afterwards.

## filter-branch / purge tools

The book calls `git filter-branch` the nuclear option and says it is no longer recommended (pitfalls), pointing to `git-filter-repo`. Use only on non-public history. For removing a committed secret see `secrets-hygiene.md`.

## Patch-series workflow

From Pro Git and SubmittingPatches:
1. Branch from the right base (Git project: `maint` for fixes, `master` for features). In general, current mainline.
2. Commit logically separate changes with tests; run the suite and `git diff --check`.
3. Describe each commit (problem, why this fix, alternatives).
4. Fork workflow: work on a topic branch, `git push -u myfork featureA`, open a PR or `git request-pull`. If upstream moves: `git fetch`, `git rebase origin/main`, then force-push the topic branch with a lease (see `force-push-safety.md`), or push `featureAv2` instead.
5. Email workflow: `git format-patch -M -v2 origin/main` makes one file per commit; `git send-email` sends inline plain text; notes for reviewers go after the `---` line; a cover letter explains why, what, changes since last round, and base.
6. Iteration: early review rounds are **full replacements** of the series, fixed by rebasing so it reads as if written right the first time. Once merged, only small incremental fixes.
7. Squash-based hosts: the maintainer may rewrite the final message at merge, so only the PR title/description need care.

## Failure modes

- `git add .` sweeping in artifacts or secrets: stage by path/hunk.
- Rebasing a branch others pulled: duplicated commits and conflicts for them.
- Resolving conflicts mid-rebase blindly: re-run tests after `--continue`.
- Losing work: record `git rev-parse HEAD` before a rewrite; reflog keeps old tips for a while.

## How an agent should apply this

- Stage with `git add -p` or explicit paths; always check `git diff --cached` before committing.
- Rewrite only unpushed commits, and only when the user asked; confirm with `git log @{u}..` that they are unpushed.
- Prefer `--fixup` plus `--autosquash` for late fixes to earlier unpushed commits over new "oops" commits.
- Note the pre-rewrite tip and mention `git reflog` as the escape hatch.
- On a shared branch, propose `git revert` instead of a rewrite.
- Re-run the tests after any rebase before pushing.
