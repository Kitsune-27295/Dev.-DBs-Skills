# Proportional Pre-Push Checks

Sources: https://git-scm.com/docs/githooks · https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project · https://git-scm.com/docs/git-rebase · Last verified 2026-11-27

## Principle

Run the smallest set of checks that would fail if this diff were wrong, once, and report the evidence. Broad suites belong to CI; repeating a check that just passed, or one the pre-push hook is about to run, adds time and no evidence. This is an editorial rule for agents (inference from practice), not a Git rule.

## Step 1: measure the outgoing diff

```sh
git status --short --branch                 # right branch, nothing unexpected
git fetch origin
git diff --name-status origin/main...HEAD   # three dots: since the merge base
git diff --check origin/main...HEAD         # whitespace errors
```

Use the verified base (the PR base or the stack parent), not a guess. `git diff --check` is the whitespace check recommended by the Git book's commit guidelines; the three-dot form is standard Git knowledge, not read from the fetched pages.

## Step 2: map paths to the narrowest evidence

| Diff touches | Minimal check |
|---|---|
| Behavior in one module | The owning test file or test name; add an adjacent test only if a shared contract changed |
| Types or public exports | Typecheck or build of that package |
| Manifests, build config, entry points | Build plus a smoke run of the built artifact |
| Docs or doc-linked comments | Link or doc check only |
| User-visible output | The snapshot or example that owns it |
| Generated files | Regenerate from the owner; the diff must be empty |
| Secret-prone files | Secret scan (see `secrets-hygiene.md`) |
| Pure rename or move | Build or typecheck, not the full test suite |

Every behavior change needs one test that would fail for its regression; add a broader check only for a surface the diff actually reaches.

## Step 3: respect hooks

`pre-push` runs on `git push`, receives the remote name and URL as arguments and one `<local-ref> <local-oid> <remote-ref> <remote-oid>` line per ref on stdin; a non-zero exit aborts the push. Hooks are local files (default `$GIT_DIR/hooks`, or a versioned directory set with `core.hooksPath`), so the repository does not carry them: confirm they exist in a fresh clone or worktree instead of assuming. Do not bypass a failing hook; fix the cause. The githooks page does not describe a pre-push bypass flag, so `--no-verify` is not sourced from it.

## After a rewrite

Rebased or reordered commits change the context code runs in: re-run the narrow checks on every rewritten layer that can break (for a stack, every layer, not only the tip). `git rebase -x "<fast check>"` runs a command after each replayed commit (`--exec`, read on the git-rebase page 2026-11-27; a failure stops the rebase).

## How an agent should apply this

- List the diff against the verified base first, then pick checks from the path map.
- State which checks ran and which were deliberately left to CI.
- Do not repeat a check that just passed and that the pre-push hook will run.
- After any history rewrite, validate each affected layer before pushing or merging.
- Never use `--no-verify` unless the user asks.
