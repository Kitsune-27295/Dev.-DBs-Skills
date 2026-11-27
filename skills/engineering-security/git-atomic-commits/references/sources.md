# Sources — Git Atomic Commits, Messages & Safe History

Every URL below was checked during skill authoring (re-fetched 2026-11-27).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.conventionalcommits.org/en/v1.0.0/ | 200 OK (WebFetch, 2026-11-27; Firecrawl had no credits) | Header grammar, 16 rules, feat/fix/BREAKING CHANGE, `!`, footers, SemVer mapping, FAQ (multiple types, wrong type, reverts, treat early projects as released) |
| https://cbea.ms/git-commit/ | 200 OK (WebFetch, 2026-11-27) | Seven message rules, imperative test, 50/72 limits, why vs how |
| https://semver.org/ | 200 OK (WebFetch, 2026-11-27) | MAJOR/MINOR/PATCH rules, 0.y.z, pre-release/build metadata, deprecation and accidental-break FAQ |
| https://google.github.io/eng-practices/review/developer/small-cls.html | 200 OK (WebFetch, 2026-11-27) | Why small changes, size guidance, refactor/test separation, splitting strategies, keeping the build working, rejection for size |
| https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project | 200 OK (WebFetch, 2026-11-27) | Commit guidelines, `diff --check`, workflows, rebase plus force on topic branches |
| https://git-scm.com/book/en/v2/Git-Tools-Interactive-Staging | 200 OK (WebFetch, 2026-11-27) | `git add -i`, `add -p` hunk keys, reset/checkout patch modes |
| https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History | 200 OK (WebFetch, 2026-11-27) | amend, rebase -i commands, reorder/squash/split/drop, filter-branch caveat, recovery |
| https://git-scm.com/docs/SubmittingPatches | 200 OK (WebFetch, 2026-11-27) | Separate logical commits, message content, DCO sign-off, trailers, cover letter, iterating by replacement, `--pretty=reference` |
| https://git-scm.com/docs/git-push | 200 OK (WebFetch, 2026-11-27; whole page, fragment ignored) | `--force`, lease forms, `--force-if-includes`, background-fetch mitigations, `+refspec`, `receive.denyNonFastForwards` |
| https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | 200 OK (WebFetch, 2026-11-27) | Pre-commit detection, revoke/rotate/delete/log order, history squash caveat, Docker ENV/ARG, restart does not revoke |
| https://docs.github.com/en/pull-requests/get-started/about-stacked-prs | 200 OK (WebFetch, 2026-11-27) | Stack definition, same-repo requirement, no cross-fork or GitHub Desktop, bottom-up merge, retargeting, merge methods, protection inheritance |
| https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands | 200 OK (WebFetch, 2026-11-27) | `gh stack` commands, force-with-lease pushes, conflict handling, gh 2.0+ and Git 2.36+ requirement |
| https://git-scm.com/docs/git-rebase | 200 OK (WebFetch, 2026-11-27) | `--onto`, `--update-refs` worktree caveat, `--autosquash`/`--fixup`, `--exec`, dropped commits |
| https://git-scm.com/docs/githooks | 200 OK (WebFetch, 2026-11-27) | pre-push arguments and stdin, abort on non-zero, `core.hooksPath`, hooks are not versioned |
| https://git-scm.com/docs/git-worktree | 200 OK (WebFetch, 2026-11-27) | add/list/remove/prune/repair/lock, one-branch-one-worktree guard, shared vs per-worktree state, submodule wording |
| Third-party skills on stacked-PR landing, pre-push checks and worktrees, read locally | Local files, read for ideas only (2026-11-24) | Third-party skill read for ideas, no text reused (licenses not confirmed) |

## Reading limits

WebFetch returns model-condensed summaries, not raw pages; quotes are paraphrased. No scripts or data files exist in this skill. Command examples were not executed. Items labeled "inference" are the author's reasoning.

## Claims not adopted as fact

- Git project branch rule (`maint` for fixes, `master` for features): not re-confirmed on the fetched pages; removed.
- Angular origin of the common non-spec commit types: not on the spec page; stated as a convention only.
- `git stash save` deprecated since a given Git version: not on the book page; flagged as manual knowledge.
- `git filter-repo` usage, `git add -N`, `git diff A...B`, `git restore --staged`, pre-push `--no-verify`: not read from the fetched pages.
- Tags rejecting all updates and branches accepting only commits (push rules): not re-read; removed.
- GitHub stack feature preview status: inferred from a campaign tag; merge-commit shape (per PR or per group) not re-checked.
- Earlier "GitHub CLI 2.90" requirement: contradicted by the CLI reference (2.0 or later); corrected.
