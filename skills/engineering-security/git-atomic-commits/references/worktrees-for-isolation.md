# Git Worktrees for Isolation

Sources: https://git-scm.com/docs/git-worktree · https://git-scm.com/docs/git-rebase · Last verified 2026-11-27

## What it gives you

A repository can have several working directories sharing one object store. The main worktree comes from `git init` or `clone`; linked worktrees come from `git worktree add`. Use one when you need a second branch checked out without stashing: an urgent fix during a refactor, a clean tree to validate a stack layer, or parallel agents that must not share a working tree.

## Commands

```sh
git worktree add -b fix-x ../wt-fix-x origin/main   # new branch from a start point
git worktree add --detach ../wt-scratch             # throwaway, no branch
git worktree list                                   # shows locked/prunable
git worktree remove ../wt-fix-x                     # clean trees only; -f otherwise
git worktree prune                                  # drop entries whose dir vanished
git worktree repair                                 # reconnect after a manual move
```

## Rules that bite

- One branch, one worktree: `add` refuses a branch already checked out elsewhere (`--force` overrides; avoid it, two trees on one branch invite lost work).
- Shared vs per-worktree: refs under `refs/` are shared (a commit made in one tree is visible to all), except `refs/bisect`, `refs/worktree`, `refs/rewritten`; `HEAD` and the index are per worktree. The repo config is shared unless `extensions.worktreeConfig` is enabled.
- `rebase --update-refs` does not update branches checked out in another worktree; handle those by hand.
- Do not delete a linked directory by hand; use `git worktree remove`. A hand-deleted directory leaves admin data until `prune` or automatic expiry, and the branch may still look checked out.
- `lock` protects a worktree on removable storage from pruning.
- Untracked local files (env files, build output, dependencies) are not in the new tree, and hooks live in the local hooks directory: restore or regenerate them and confirm hooks exist (inference from how hooks are stored).

## Submodule caveat

The Git manual says multiple checkout is still experimental and submodule support is incomplete, and it advises against multiple checkouts of a superproject. `move` cannot relocate a worktree containing submodules and `remove` needs `--force` for one. Inference: in a repository with submodules, prefer a separate clone for isolation, and tell the user rather than silently using a worktree.

## How an agent should apply this

- Create a worktree on a new branch from the verified base, commit there, then remove it with `git worktree remove`.
- Never check one branch out twice; never use `--force` around that guard.
- Run `git submodule status` before choosing a worktree; if submodules exist, warn and prefer a separate clone.
- After creating a tree, restore local-only setup (dependencies, env files, hooks) and confirm the base commit.
- Run `git worktree list` before cleanup and remove only trees you created.
