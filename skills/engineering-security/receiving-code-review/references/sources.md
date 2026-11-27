# Sources — Receiving Code Review

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://google.github.io/eng-practices/review/developer/handling-comments.html | 200 OK, read in full | Do not take it personally, fix the code before explaining, ask when unclear, collaborative disagreement, consensus first |
| https://google.github.io/eng-practices/review/developer/ | 200 OK | Index of the author's guide (descriptions, small changes, handling comments) |
| https://google.github.io/eng-practices/review/developer/small-cls.html | 200 OK, read in full | Keep refactors separate, one self-contained change, rollback and review-time benefits |
| https://google.github.io/eng-practices/review/reviewer/pushback.html | 200 OK, read in full | "Later cleanup" rarely happens, file and assign a bug, author may be right |
| https://conventionalcomments.org/ | 200 OK, read in full | Label and decoration grammar, blocking and non-blocking markers, machine-parseable format |
| https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/commenting-on-a-pull-request | 200 OK via redirect to `/en/pull-requests/how-tos/review-pull-requests/commenting-on-a-pull-request` | Thread replies, resolving conversations, out-of-scope issue, conversations menu |
| https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/incorporating-feedback-in-your-pull-request | 200 OK via redirect to `/en/pull-requests/how-tos/review-pull-requests/incorporating-feedback-in-your-pull-request` | Suggestion batches and single commit, co-authors, re-request review, out-of-scope issue |
| https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/reviewing-proposed-changes-in-a-pull-request | 200 OK via redirect to `/en/pull-requests/how-tos/review-pull-requests/reviewing-proposed-changes-in-a-pull-request` | Request changes semantics, stale approval dismissal, authors cannot self-approve |
| https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/re-requesting-a-review | 404 (old guessed path); re-request steps taken from the incorporating-feedback page instead | Nothing directly |
| Third-party skill read for ideas, no text reused (an MIT-licensed plugin skill with the same topic) | Read locally | Idea prompts only: verify before acting, no performative agreement, ask when unclear, prioritize fixes, push back with evidence, reply in thread. Everything here was rewritten from the public sources above and from own judgment |

## Reading limits

- GitHub pages were read as rendered text; UI labels may change.
- The Google pages describe Google's own process (called "CL"); the skill generalizes the advice to pull requests and patches.
- The exact behavior of approvals, stale-review dismissal and resolving conversations depends on each repository's settings and the platform plan.

## Claims not adopted as fact

- The idea that thanks or gratitude should always be omitted is a style choice of one local source, not a rule from the public sources; this skill only bans performative agreement before verification and filler.
- The ordering "blocking, then mechanical, then refactors" and the "unlabelled defect claims are blocking until verified" inference are own judgment, not quoted from any source.
