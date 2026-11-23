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
