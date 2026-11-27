# Sources — Git Atomic Commits, Messages & Safe History

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.conventionalcommits.org/en/v1.0.0/ | 200 OK (via WebFetch; Firecrawl had no credits) | Header grammar, 16 rules, feat/fix/BREAKING CHANGE, `!`, footers, SemVer mapping, FAQ (multiple types, wrong type fix, reverts) |
| https://cbea.ms/git-commit/ | 200 OK (WebFetch) | Seven message rules, imperative test, 50/72 limits, why vs how |
| https://semver.org/ | 200 OK (WebFetch) | MAJOR/MINOR/PATCH rules, 0.y.z, pre-release/build metadata, deprecation and accidental-break FAQ |
| https://google.github.io/eng-practices/review/developer/small-cls.html | 200 OK (WebFetch) | Why small changes, what is small, refactor/test separation, splitting strategies, keeping build green |
| https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project | 200 OK (WebFetch) | Commit guidelines, `diff --check`, workflows (small team, managed, fork, email patches), rebase+force on topic branches |
| https://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging | 200 OK (WebFetch) | `git add -i`, `add -p` hunk keys, reset/checkout/stash patch modes |
| https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History | 200 OK (WebFetch) | amend, rebase -i commands, reorder/squash/split/drop, filter-branch caveat, recovery |
| https://git-scm.com/docs/SubmittingPatches | 200 OK (WebFetch) | Separate logical commits, message content, DCO sign-off, trailers, cover letter, iterating by replacement |
| https://git-scm.com/docs/git-push#Documentation/git-push.txt---force-with-lease | 200 OK (WebFetch; fragment ignored, whole page read) | `--force`, lease forms, `--force-if-includes`, background-fetch caveat, recommendations |
| https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | 200 OK (WebFetch) | Source-control leaks, pre-commit detection, revoke/rotate/delete/log order, history purge caveat, least privilege, auditing |

Notes: WebFetch returns model-condensed summaries, not raw pages; quotes are paraphrased. Items labeled "inference" in reference files are the author's own reasoning; items labeled "not read from source" (e.g. `--fixup`/`--autosquash` flags, `git filter-repo` usage, `git restore --staged`) are standard Git knowledge not shown on the fetched pages.

## Added 2026-11-24

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://docs.github.com/en/pull-requests/get-started/about-stacked-prs | 200 OK (WebFetch; found via search; the guessed URL `.../about-stacked-pull-requests` returned 404) (added 2026-11-24) | Stack definition, same-repo requirement, no cross-fork or GitHub Desktop, bottom-up merge, retargeting, merge methods, branch-protection inheritance |
| https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands | 200 OK (WebFetch) (added 2026-11-24) | `gh stack` commands (init, add, submit, push, sync, rebase, checkout, link, view, merge, unstack), cascading rebase, force-with-lease pushes, conflict handling |
| https://git-scm.com/docs/git-rebase | 200 OK (WebFetch) (added 2026-11-24) | `--onto` semantics and examples, `--update-refs` and the worktree caveat, already-applied commit dropping; the squash-merge transplant is flagged as extrapolation |
| https://git-scm.com/docs/githooks | 200 OK (WebFetch) (added 2026-11-24) | pre-push arguments, stdin format, abort on non-zero, `core.hooksPath`, hooks are local |
| https://git-scm.com/docs/git-worktree | 200 OK (WebFetch) (added 2026-11-24) | add/list/remove/prune/repair/lock, one-branch-one-worktree guard, shared vs per-worktree state, submodule caveat wording |
| Third-party skills on stacked-PR landing and pre-push checks, and a third-party worktree skill, read locally | Local files, read for ideas only (added 2026-11-24) | Third-party skill read for ideas, no text reused (licenses not confirmed): hard-stop-if-unsupported, never infer stack order from branch names, smallest-covering-check selection, no duplicate pre-push runs |

Not read from source: the exact GitHub CLI minimum version (taken from a search summary), `git diff A...B` and `git rebase --exec` (standard Git knowledge). The GitHub stack feature's preview status is inferred, not stated on the page.
