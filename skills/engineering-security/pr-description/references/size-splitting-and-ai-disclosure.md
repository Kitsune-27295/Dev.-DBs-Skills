# Size, Splitting, Templates and AI Disclosure

Sources: https://google.github.io/eng-practices/review/developer/small-cls.html · https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository · https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates · https://ai-declaration.md/en/0.1.2/ · Last verified 2026-11-27

## What the sources say

**Google, small changes.** Small changes are reviewed faster and more thoroughly, waste less work if rejected, block less, and are simpler to roll back, because a large change is more likely to touch files that change before a revert. The right size is one self-contained change with its tests that leaves the system working; there are no hard rules, and the reviewer may reject a change for size alone. Trusted automatic refactoring can be larger. The numeric heuristics and the splitting strategies (stack, by reviewer group, horizontal, vertical, refactors apart) are owned by `git-atomic-commits`; this reference keeps only what a PR description adds.

**GitHub templates.** A pull request template (file `pull_request_template.md` in the root, `docs/` or `.github/`, or several under `PULL_REQUEST_TEMPLATE/`) pre-fills the pull request body; it takes effect when merged into the default branch. A template typically asks for a related issue, a description of changes and the people to mention. Draft pull requests cannot be merged and do not automatically request code owners; marking one ready for review requests them.

**AI-DECLARATION specification (0.1.2).** A public, machine-readable convention for stating AI involvement in a repository: a file with a version, a global level (which must be the highest level present), a required Notes section and optional per-process and per-component levels. Its levels, from least to most AI involvement, are `none`, `hint`, `assist`, `pair`, `copilot`, `auto`; processes not listed count as `none`; it can list processes (design, implementation, testing, documentation, review, deployment) with their own levels, and components (paths) with individual levels, plus a human-readable Notes section. It is one example of a disclosure scheme; projects define their own rules, and some require nothing at all. Third-party description guidelines read for ideas (no text reused) use a similar per-stage idea; their grading rules are project-specific and not reproduced here.

## Describing a split

Choose the split with `git-atomic-commits` (feature flag help: `feature-flag-toggle-engine`, `vertical-slice-architecture`). A generated or mechanical change stays one PR; say what produced it and how to reproduce. Then, for each resulting PR:

1. Is the order of merge written in the description ("depends on #1")?
2. Does it cover only its own diff against its base?
3. Are the sibling PRs linked so reviewers have context?

Atomic commits within a PR (`git-atomic-commits`) help reviewers read one PR commit by commit, but they do not replace splitting when the PR itself is too big.

## Draft and ready

Open as draft when: evidence is incomplete, the approach is a proposal, or CI is red for known reasons. Move to ready when: the description is complete and true, checks ran, and you want review. State the gap in the first lines of a draft ("Draft: benchmarks pending").

## Template use

- Keep the template's headings and order; fill each section or write "N/A" with a reason. Do not delete sections silently.
- If the template and this skill's sections overlap, the template wins on order and wording; this skill supplies the content standard.
- A single source for description rules is better than two: when the project has a written PR guide, link to it instead of re-stating it.

## AI-involvement line

- Only when required. Look in contributing guides, the PR template, repository agent-instruction files and release policy.
- Follow the project's format exactly (level names, stage names, badge or text).
- Describe the actual share and stages honestly: what the agent drafted, what a human decided, reviewed or rewrote. Do not inflate or minimize.
- The human author owns the content and replies to review; the disclosure does not move responsibility.
- Never put secrets, prompts or internal system details in the line.

Illustrative, generic example (not a mandated format):

```text
AI involvement: implementation and tests drafted by an AI agent; design chosen
and every change reviewed by the author; no AI-written review replies.
```

## Failure modes

- A thousand-line PR with a one-line description.
- Splits that cannot be merged independently, without saying the order.
- Draft status forgotten after the work is ready (or ready status while evidence is missing).
- A required disclosure omitted, or a disclosure line added where the project has none.

## How an agent should apply this

- Measure the diff (`git diff --stat` against the base) before writing; if it is large and mixed, propose a split to the user instead of describing a monolith.
- Put merge order and dependencies in each split PR's description.
- Open as draft when evidence is missing; say what is pending.
- Read the project's PR template and disclosure rules first; follow them verbatim.
- Draft the text only; never publish, push or edit a remote PR unless the user explicitly asks.
