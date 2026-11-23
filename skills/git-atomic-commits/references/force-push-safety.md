# Force-Push Safety: --force-with-lease, --force-if-includes, --force

Sources: https://git-scm.com/docs/git-push#Documentation/git-push.txt---force-with-lease · https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project · Last verified 2026-11-23

## Why a push is rejected

A branch update from A to B is a fast-forward only if B descends from A. If you built B on X while someone pushed A on X, accepting B would drop A's work, so Git refuses. Legitimate remedies: `git pull` (merge), `git pull --rebase` (replay yours on top), or force only if you truly intend to discard A (for example, you amended a commit nobody has fetched).

## The three tools

| Flag | Behaviour | Risk |
|---|---|---|
| `--force` / `-f` | disables the non-fast-forward check and the lease checks; the remote may lose commits | applies to **all** refs pushed (with `push.default=matching` or several destinations it can overwrite other branches) |
| `--force-with-lease` | forced update only if the remote ref still has the value you expect | protection depends on what "expected" means (below) |
| `--force-if-includes` | extra check: the remote-tracking tip must be reachable from your local reflog, i.e. you integrated what you fetched | only meaningful together with bare or `=<ref>` lease |

Lease forms:
- `--force-with-lease`: expect each updated ref to equal its remote-tracking branch.
- `--force-with-lease=<ref>`: same, one ref only.
- `--force-with-lease=<ref>:<expect>`: expect an explicit SHA (or tag). Empty `<expect>` means the ref must not exist.
The doc marks all forms except the explicit one as experimental in semantics.

## The background-fetch trap

The lease compares against your remote-tracking refs. If an IDE or cron job runs `git fetch`, those refs advance to include a teammate's new commits you never looked at, and the lease then happily overwrites them. Mitigations from the doc:
1. Use the explicit form with a marker you set yourself: `git tag base origin/feature` before rewriting, then `git push --force-with-lease=feature:base origin feature`.
2. Add `--force-if-includes` (or set `push.useForceIfIncludes=true`) so unseen remote commits block the push.
3. Fetch/push through a separate push-only remote that background jobs do not fetch (defeated by `fetch --all`).

## Scope the force

`git push origin +feature` forces only that refspec; prefer it over `--force` when several refs could be affected.

## Server-side limits

Forcing cannot override server settings such as `receive.denyNonFastForwards`, tags reject all updates, and branches only accept commits. Protected branches on hosting platforms typically refuse force-push (inference: host-specific).

## Recommended command

```
# after an approved rewrite of your own unpushed-by-others topic branch
git fetch origin
git log --oneline HEAD..origin/feature     # empty means nobody added commits
git push --force-with-lease --force-if-includes origin feature
```

## Decision rules

| Situation | Action |
|---|---|
| Your private topic branch, only you push | `--force-with-lease --force-if-includes` |
| Branch others may have pulled/pushed | do not force; merge or `git revert`; ask user |
| main / release / tagged | never force without explicit user approval of that exact branch |
| Lease rejected ("stale info") | someone pushed: fetch, inspect, integrate; do **not** retry with `--force` |
| Intend to discard remote commits | rare; get explicit user confirmation, then `--force` scoped to one ref |

## Failure modes

- Reflexive `--force` after any rejection: destroys a teammate's commits.
- Bare lease with an auto-fetching editor: false safety.
- Forcing right after `git pull --rebase` conflicts without rerunning tests.
- Updating the remote while the original local tip is not recorded: use reflog/tag to recover.

## How an agent should apply this

- Never run `git push --force` or `-f`; if forcing is justified and the user asked, use `--force-with-lease --force-if-includes` naming one branch.
- Before forcing: `git fetch`, then `git log HEAD..origin/<branch>`; if it shows commits, stop and report.
- Prefer a tag/SHA with the explicit `--force-with-lease=<ref>:<sha>` form in automation.
- If a lease push is rejected, treat it as information; investigate, do not escalate to `--force`.
- Never force-push a shared or protected branch without explicit approval; propose `git revert` as the alternative.
- Remember that `git push` itself is only done on user request.
