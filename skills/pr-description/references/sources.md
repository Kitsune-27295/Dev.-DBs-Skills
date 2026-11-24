# Sources — Pull Request Description

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://google.github.io/eng-practices/review/developer/cl-descriptions.html | 200 OK, read in full | What and why, first-line rule, body content, bad-description examples, tags, re-read before submit |
| https://google.github.io/eng-practices/review/developer/small-cls.html | 200 OK, read in full | Size heuristics, one self-contained change, splitting strategies, separate refactors, tests with code, rollback |
| https://google.github.io/eng-practices/review/developer/ | 200 OK | Index of the author's guide |
| https://www.conventionalcommits.org/en/v1.0.0/ | 200 OK, read in full | Title grammar, types, scope, `!` and BREAKING CHANGE, SemVer mapping |
| https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request | 200 OK via redirect to `/en/pull-requests/how-tos/create-pull-requests/creating-a-pull-request` | Title and description step, draft option |
| https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue | 200 OK | Closing keywords and syntax for same and other repositories |
| https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository | 200 OK | Template file locations, multiple templates, default-branch requirement |
| https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates | 200 OK | Template behavior, draft pull request semantics |
| https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests | 200 OK via redirect to `/en/pull-requests/reference/pull-requests` | Draft pull requests, code-owner review request on ready |
| https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/reviewing-proposed-changes-in-a-pull-request | 200 OK via redirect to `/en/pull-requests/how-tos/review-pull-requests/reviewing-proposed-changes-in-a-pull-request` | Approval dismissal on new commits, request-changes semantics |
| https://ai-declaration.md | 200 OK via redirect to `/en/0.1.2/` | Public example of an AI-involvement disclosure scheme: levels, processes, components |
| Third-party skills read for ideas, no text reused (an agent-orchestrator PR-description skill, a pull-request-body skill from a third-party skill collection, and a project-specific PR-description skill of unknown license) | Read locally | Idea prompts only: separate interface from behavior changes, evidence before and after, merge danger and reversibility, per-stage AI-usage disclosure, keep the description updated. All text here is original |

## Reading limits

- GitHub documentation pages were read as rendered text; labels and options may change over time.
- The Google pages describe a changelist workflow; the advice is generalized to pull requests.
- The size figures (about 100 and 1000 lines) are Google's stated rule of thumb, not a universal threshold.
- AI-DECLARATION was read at version 0.1.2 only; it is one scheme, and many projects require nothing or use their own format.

## Claims not adopted as fact

- The section layout (Motivation, Changes with interface and behavior split, Testing, Risk and rollback, Reviewer guide) is own synthesis, not an official standard.
- "One-way or two-way door" and "blast radius" are common engineering vocabulary used here as own framing, not quotes from a read source.
- No numeric claims from third-party skills (stage percentages, grading ranges) are adopted.
