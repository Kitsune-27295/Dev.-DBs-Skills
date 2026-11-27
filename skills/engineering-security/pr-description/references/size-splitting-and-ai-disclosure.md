# Size, Splitting, Templates and AI Disclosure

Sources: https://google.github.io/eng-practices/review/developer/small-cls.html · https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository · https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates · https://ai-declaration.md/en/0.1.2/ · Last verified 2026-11-24

## What the sources say

**Google, small changes.** Small changes are reviewed faster and more thoroughly, introduce fewer bugs, waste less work if rejected, merge more easily, are easier to design well, block less, and are simpler to roll back. The right size is one self-contained change: a minimal change addressing one thing, with its tests, understandable from the change, its description, the codebase or earlier reviewed changes, and leaving the system working. It should not be so small that its meaning is unclear (an added API should include a use). There are no hard rules: about 100 lines is usually reasonable and about 1000 usually too large, and the number of files counts too. Deleting a whole file counts as little, and trusted automatic refactoring can be larger. Reviewers may reject a change for size alone. Splitting strategies: stack changes on each other, split by files that need different reviewers (for example a protocol definition and its users, or code and the configuration that enables it), split horizontally by layer with stubs or shared definitions, split vertically by feature slice, or combine both. Keep refactorings apart from features and bug fixes, with tiny cleanups allowed. Keep related tests in the same change.

**GitHub templates.** A pull request template (file `pull_request_template.md` in the root, `docs/` or `.github/`, or several under `PULL_REQUEST_TEMPLATE/`) pre-fills the pull request body; it takes effect when merged into the default branch. A template typically asks for a related issue, a description of changes and the people to mention. Draft pull requests cannot be merged and do not automatically request code owners; marking one ready for review requests them.

**AI-DECLARATION specification (0.1.2).** A public, machine-readable convention for stating AI involvement in a repository. Its levels, from least to most AI involvement, are `none`, `hint`, `assist`, `pair`, `copilot`, `auto`; it can also list processes (design, implementation, testing, documentation, review, deployment) with their own levels, and components (paths) with individual levels, plus a human-readable Notes section. It is one example of a disclosure scheme; projects define their own rules, and some require nothing at all. Local third-party description guidelines read for ideas use a similar per-stage idea (breakdown, design, testing, implementation, review); their grading rules are project-specific and not reproduced here.

## Size and splitting decision

| Situation | Action |
|---|---|
| Feature touches data, API and UI | Split by layer or by slice; each PR works alone behind a flag if needed (`feature-flag-toggle-engine`, `vertical-slice-architecture`) |
| Refactor plus behavior change | Two PRs: refactor first, behavior second |
| Rename or move plus fix | Rename PR first, fix second |
| Generated or mechanical change | One PR; say what produced it and how to reproduce |
| Dependency bump plus code use | Bump separate unless the code cannot compile without it |
| Cannot summarize in a short title | Probably two or more PRs |

Splitting checklist:

1. Does each PR build, pass tests and leave the system consistent on its own?
2. Does each PR contain the tests for what it changes?
3. Is the order of merge written in each description ("depends on #1")?
4. Does each description cover only its own diff against its base?
5. Are the sibling PRs linked so reviewers have context?

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
