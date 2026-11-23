# Commit Message Craft

Sources: https://cbea.ms/git-commit/ · https://git-scm.com/docs/SubmittingPatches · https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project · Last verified 2026-11-23

## Why messages matter

A diff shows *what* changed; only the message can carry *why*. Tools such as `git log`, `shortlog`, `blame`, `revert`, `rebase` and `format-patch` surface the subject line, so a consistent log makes all of them useful and a sloppy one makes people stop reading history. Future maintainers (often you) pay the cost of re-deriving context.

## The seven rules (Beams), with the Git project's additions

1. Subject and body separated by a blank line (tools treat the first line as the title; trivial changes may have subject only).
2. Subject about 50 characters; 72 is the practical hard limit (GitHub truncates longer).
3. Capitalize the subject (Git's own project uses `area: lowercase text` instead; follow the repo).
4. No trailing period.
5. Imperative mood: "Remove deprecated methods". Test: "If applied, this commit will ___".
6. Wrap body at about 72 characters (Git does not wrap for you).
7. Body explains what and why, not how.

Git project body guidance (SubmittingPatches): describe the problem in present tense ("The code does X when given Y"), why the change is the right fix, alternatives considered and rejected, and how reviewer concerns were resolved. Be self-contained: summarize discussion instead of linking a thread.

## Anatomy of a good body

```
Retry idempotent reads on connection reset

Reads failed outright when the load balancer recycled a connection
mid-request, surfacing as 502s during every deploy.

Retry once, only for GET/HEAD, because replaying a write could
duplicate it. A longer backoff was rejected: deploy windows are
under two seconds.

Refs: #311
```

Paragraphs: (1) old behaviour and why it was wrong, (2) new behaviour and why this approach, (3) alternatives or limits. Footers last.

## Bad to better

| Bad | Problem | Better |
|---|---|---|
| `fixed stuff` | no content | `Fix off-by-one in pagination offset` |
| `Updated config.` | past tense, vague, period | `Raise upload limit to 25 MB` + why in body |
| `WIP` / `more changes` | unreviewable history | squash or reword before sharing |
| `Fix bug (see chat)` | external dependency | summarize the cause in the body |
| 90-char subject | truncated in tools | shorten; move detail to body |

## Trailers and footers

Git trailers: `Signed-off-by:` (DCO certification, `git commit -s`), `Reviewed-by:`, `Tested-by:`, `Reported-by:`, `Suggested-by:`, `Helped-by:`, `Co-authored-by:`, plus issue references (`Refs: #12`, `Closes #12`). Capitalize only the first letter of each token; keep one trailer per line in the last paragraph; your own `Signed-off-by:` goes last. Credit lines are always footers, never in the subject.

## Hard-to-summarize subjects

If you cannot summarize the commit in about 50 characters, it likely bundles several changes: split it (see `atomic-and-small-changes.md`). The Git project says the same of long descriptions.

## Referencing other commits

Use a short SHA with its subject and date, e.g. `git show -s --pretty=reference <sha>` produces `abc1234 (subject, 2026-01-02)`. Prefer this over a bare hash.

## Team conventions (inference from Beams' closing advice)

Agree on style (case, grammar), content (what body must contain) and metadata (issue references). Enforce with a commit-msg hook or CI lint only if the team opts in.

## How an agent should apply this

- Draft the subject last: summarize the staged diff, imperative, <=50 chars, no period; check it completes "If applied, this commit will ...".
- Write a body whenever the reason is not obvious from the diff: old behaviour, why wrong, why this fix, alternatives rejected.
- Put issue links and co-author/sign-off trailers in the footer, one per line, after a blank line.
- Never leave `WIP`, `fix`, `update` as the final message on a commit that will be shared; reword locally first (only if unpushed).
- Match the repo's existing capitalization and prefix style from `git log --oneline`.
- Do not put secrets, internal URLs or personal data in messages; messages are permanent and replicated.
