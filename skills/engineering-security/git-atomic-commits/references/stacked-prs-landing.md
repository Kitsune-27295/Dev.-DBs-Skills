# Landing a Stack of Dependent PRs (A <- B <- C)

Sources: https://docs.github.com/en/pull-requests/get-started/about-stacked-prs · https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands · https://git-scm.com/docs/git-rebase · Last verified 2026-11-27

## What a stack is

A stack is a chain of dependent PRs in one repository: the bottom PR targets the trunk, and each higher PR targets the branch of the PR below it. Each PR shows only its own layer's diff. This is the review-side counterpart of the series advice in `SKILL.md` section 9.

## Step 0: verify the platform feature, do not assume it

GitHub documents native stacks (overview and CLI reference; the `gh stack` extension). The CLI reference read on 2026-11-27 states GitHub CLI 2.0 or later and Git 2.36 or later (an earlier note citing 2.90 came from a search summary and was wrong). Install with `gh extension install github/gh-stack`. Facts read on the official pages:

- All branches must live in the same repository; cross-fork stacks are not supported; GitHub Desktop is not supported.
- Branch protection and the bottom PR's base set the merge requirements for every PR in the stack.
- Merging the top PR merges the whole stack; merging a mid-stack PR merges the PRs below it and the ones above retarget automatically. Merges go bottom-up. Merge, squash and rebase methods are supported, and merge queues are understood.
- Stacks are exposed in the CLI, web, mobile, REST and GraphQL; API merges need the asynchronous merge API.
- The page body does not label the feature a preview; linked resources carry a public-preview campaign tag (inference: it may still change). The commit-per-PR versus one-commit-per-group merge result was not re-checked; read the live page before relying on it.

**Hard stop.** Before touching any PR state, run `gh stack --version` and confirm the repository is same-repo. If the extension or server feature is missing, or the chain crosses forks, do not improvise merges with `gh pr merge` plus manual retargeting as if it were a stack: use the fallback below only with the user's go-ahead, or stop and ask.

## Native path (when verified)

1. `gh stack view --json` (or the GraphQL `stack` field) to read the real order and membership; never infer it from branch names.
2. Link missing members additively: `gh stack link --base <trunk> <bottom> ... <top>` in bottom-to-top order. Never dissolve or reorder an existing stack without asking.
3. Refresh only when trunk moved: `gh stack sync` (or `rebase`) runs a cascading rebase bottom-up and pushes with `--force-with-lease`; on conflict `sync` restores all branches, then use `gh stack rebase` with `--continue` or `--abort`.
4. After any rewrite, re-run the relevant checks on every affected layer (see `proportional-pre-push-checks.md`) before merging.
5. Land with `gh stack merge` (all or nothing), up to the chosen PR.

## Fallback: rebase-based chain (no native stack)

Land strictly bottom-up and replay each remaining layer onto the new trunk using only its own commits:

```sh
# A merged into main (squash or merge). B was built on A's old tip.
git fetch origin
git rebase --onto origin/main <old-A-tip> B     # replay only B's own commits
git push --force-with-lease origin B            # see force-push-safety.md
# retarget B's PR to main, wait for checks, merge; then C on B's old tip
git rebase --onto origin/main <old-B-tip> C
```

From the Git docs: `--onto <newbase> <upstream> <branch>` replays the commits on `<branch>` that are not in `<upstream>`, so the upstream argument must name the OLD base tip. Record each layer's tip before merging; the reflog (for example `B@{1}`) is a last resort. Using this after a squash merge is an extrapolation of the documented pattern, not an example on the page. `--update-refs` moves intermediate branches in one rebase but does not update branches checked out in another worktree. Clean cherry-picks already upstream are dropped automatically, which does not help after a squash merge; hence the explicit old-tip upstream.

## Failure modes

- Merging the top PR into a mid branch by hand: strands lower layers.
- Rebasing a layer without recording old tips: duplicated commits after a squash merge.
- Retargeting before the base lands: the PR diff balloons to include lower layers.
- Pushing rewritten layers without a lease: see `force-push-safety.md`.

## How an agent should apply this

- Verify native stack support from the official docs and the live CLI before using it; hard-stop when absent.
- Record every layer's head SHA before landing anything.
- Land bottom-up, one layer at a time; rebase the next layer with `--onto <new trunk> <old tip of the layer below>`.
- Push rewrites only with `--force-with-lease`, then re-validate affected layers.
- Never run cross-fork chains through the stack feature; ask the user.
