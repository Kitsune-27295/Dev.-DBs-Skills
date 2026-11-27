# Description Anatomy and Title

Sources: https://google.github.io/eng-practices/review/developer/cl-descriptions.html · https://www.conventionalcommits.org/en/v1.0.0/ · https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/creating-a-pull-request · https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue · Last verified 2026-11-24

## What the sources say

**Google, writing good descriptions.** A description is a public record of a change and must say *what* is being changed (enough that a reader need not read the whole diff) and *why* (context the author had, decisions not visible in the code). It becomes permanent history that people will search later by faint memory, so important information belongs in the description, not only in the code. The first line is a short, standalone summary written as an order (imperative), followed by a blank line; it is what appears in history listings. The body fills in the problem, why this approach is best, shortcomings, and background such as bug numbers, benchmark results and design links. External links may become inaccessible, so include enough context in the text. Inadequate examples: "Fix bug", "Fix build", "Add patch", "Phase 1". Tags such as `[area]` are optional and should stay short in the first line. Generated descriptions should follow the same advice, and a description should be re-read before submitting because changes during review can make it stale.

**Conventional Commits 1.0.0.** Structure: `<type>[optional scope][!]: <description>`, optional body, optional footers. `fix` patches a bug (SemVer PATCH), `feat` adds a feature (MINOR), a `BREAKING CHANGE:` footer or `!` marks a breaking change (MAJOR) on any type. Other types such as `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` are allowed by convention and carry no SemVer effect unless breaking. A scope is a noun in parentheses. The description follows the colon and space.

**GitHub.** Creating a pull request asks for a title and a description; a draft can be opened instead. A pull request linked to an issue closes it on merge into the default branch when a keyword is used: `close(s/d)`, `fix(es/ed)`, `resolve(s/d)` followed by `#N`, or `owner/repo#N` for another repository; each issue needs its own keyword. Linking is also possible manually from the sidebar.

## Anatomy of a good description

```text
fix(export): handle empty row list

## Motivation
The nightly export crashed when a tenant had no rows (index error in
`write_header`). Support saw empty files for three tenants. Fixes #482.

## Changes
- `export()` returns a header-only file for an empty list (behavior).
- No interface changes.

## Testing
...
```

Reading order for the reviewer: title (what), motivation (why), changes (scope), testing (trust), risk (cost of being wrong).

## Title rules

| Rule | Why |
|---|---|
| Imperative, present tense ("add", "fix", "remove") | Matches history and release-note tooling |
| One idea and specific noun | Stands alone in a log |
| Type reflects the user-visible effect (`feat`, `fix`) | Drives version and changelog tools |
| `!` or `BREAKING CHANGE:` only for true breaks | Avoids alarming noise |
| Short; avoid long tag stacks | Clarity first |
| No ticket-only titles ("PROJ-123") | Meaningless without the tracker |

Own inference: when the project squash-merges, the PR title and the opening lines of the body become the permanent commit message, so write the first paragraph of the body as if it were the commit body (`git-atomic-commits` covers commit craft).

## The Motivation section

- State the problem, not the solution, first: who is affected, what happens, since when.
- Say why this approach over the obvious alternative in one sentence; mention a rejected option only if a reviewer would otherwise suggest it.
- Link the issue with a closing keyword if the PR resolves it, otherwise `Refs #N`; put the keyword on its own line so it is easy to find.
- Include benchmark or incident numbers only with their source.

## The Changes section

- Group by idea ("Validation moved to the boundary", "New retry policy") instead of by file.
- Call out what is deliberately not changed when a reviewer might expect it.
- Name shortcomings and follow-ups plainly.
- Keep it proportional: a three-line change deserves a three-line description, but never an empty one.

## Failure modes

- Title says what the branch is called, not what the change does.
- Body restates the diff.
- Why missing: reviewers guess intent.
- Links without context.
- A keyword that closes an issue the PR only partly fixes.

## How an agent should apply this

- Draft the title first in Conventional Commits form, then ask whether it would still make sense alone in a history list.
- Write Motivation before Changes; if you cannot write it, you do not yet know why the change exists. Ask the user.
- Describe only what the diff and the evidence support; list gaps as gaps.
- Use closing keywords only when the issue is fully resolved by this PR.
- Strip machine-specific paths, hostnames, tokens and personal data from any text before presenting the draft.
- Present the draft to the user; do not run `gh pr create` or edit a published PR without an explicit request.
