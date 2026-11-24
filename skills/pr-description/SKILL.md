---
name: pr-description
description: "Write or update a pull request description that a reviewer and a future maintainer can use without reading the whole diff: a Conventional Commits style title, motivation (the why, with linked issues), a summary of what changed split into interface changes and behavior changes, how it was tested with real evidence, risk, blast radius and rollback, reviewer guidance, size and splitting advice, and an AI-involvement disclosure line when the project requires one. Covers templates, draft PRs, keeping the text true after review rounds, and bad-description patterns. Instructions only: never publishes anything. Use when opening or drafting a pull request, writing or fixing a PR body or merge request text, filling a PR template, or when a PR is too large to describe."
---

# Pull Request Description

One idea: a pull request description is a **permanent public record** that answers two questions for people who have not seen your screen: *what is changing* and *why*. Everything else (evidence, risk, links) exists to let a reviewer decide quickly and a future reader trust or reverse the change. Sources and claims: [references/sources.md](references/sources.md).

Boundary: commit messages and commit splitting belong to `git-atomic-commits`; judging the change belongs to `code-review`; proof that the work is really done belongs to `verification-loop`; handling comments after the description is read belongs to `receiving-code-review`. This skill only drafts text. It never runs `gh pr create`, pushes, or posts anything unless the user explicitly asks for that exact action.

---

## 1. Title

- Form: `<type>[(scope)][!]: <imperative summary>` (Conventional Commits), unless the project's own template or contributing guide says otherwise.
- Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`. A `!` after the type or scope, or a `BREAKING CHANGE:` line in the body, marks a breaking change.
- Imperative mood, one idea, specific enough to stand alone in a history list: `fix(export): handle empty row list`, not `fix bug` or `Updates`.
- The title is what squash-merge usually turns into the commit subject, so write it as that.
- Details: [references/description-anatomy-and-title.md](references/description-anatomy-and-title.md).

---

## 2. Required Sections (adapt to the project template)

If the repository has a pull request template, **fill it and keep its headings**; add only what it lacks. Otherwise use this skeleton.

| Section | What it must say | Test |
|---|---|---|
| **Motivation** | The problem or goal in one or two sentences, why now, why this approach; linked issue(s) | Can a stranger tell why this exists without opening the diff? |
| **Changes** | What changed, grouped by idea, not by file; **Interface changes** and **Behavior changes** called out separately (section 3) | Does it describe the diff the reviewer will see, and nothing it does not do? |
| **Testing** | Commands run, results, scenarios covered, what was not tested (section 4) | Could a reviewer repeat it? Is there evidence for each claim? |
| **Risk and rollback** | Blast radius, one-way versus two-way, how to undo, deploy or migration order (section 5) | Would an on-call engineer know what to do? |
| **Reviewer guide** | Where to start, what is mechanical, what needs judgment, known gaps or follow-ups | Does it direct attention to the risky 20 percent? |
| **Links** | Issue keywords, design notes, related PRs, benchmarks | Does each link carry context if it later becomes inaccessible? |
| **AI involvement** (only if required) | One line or the project's format (section 7) | Matches the project's policy exactly |

Write for two readers: the reviewer today and the maintainer searching history in two years.

---

## 3. Interface Changes Versus Behavior Changes

Separate these two lists; reviewers handle them differently. "None" is a valid and useful answer.

| Kind | Includes | Reviewer question |
|---|---|---|
| **Interface** | Public functions and exports, CLI commands and flags, configuration keys, environment variables, API routes, schemas, file or protocol formats, event names | Who depends on this, and can they still work? |
| **Behavior** | Observable results: defaults, output, timing, performance, ordering, error messages, side effects, data written | What will users or systems notice? |

State only what the diff guarantees. A claim with no test or observation behind it goes under "not verified", not under "Changes". If a change affects existing tests or documented behavior, say why the expectation changed. Breaking changes: say so in the title or first lines, say who is affected, and point to the migration path (`parallel-change-expand-contract`).

---

## 4. Testing: Evidence, Not Assertion

"Tested locally" is not testing. Give:

1. **Commands** run (copyable) and their result (pass counts, exit status, a short output excerpt).
2. **Scenarios** covered, matching each item under Changes; for a bug fix, the failing test or reproduction **before** and the result **after**.
3. **Where** it ran (local, CI, which environment) and what was not run or could not be run, with the reason.
4. For visible changes: before and after screenshots, recordings or output. For performance: before and after numbers with conditions (machine, data size, runs).
5. For refactors with no behavior change: how that is shown (unchanged tests, snapshot comparison).

Use the same evidence discipline as `verification-loop`: list only checks that actually ran in this session; mark the rest "not run". Pick the right kind of test with `testing-pyramid-and-shapes`; do not paste whole logs, link or summarize them.

---

## 5. Risk, Blast Radius and Rollback

One short block, always present for anything beyond a trivial change:

- **Door:** one-way (data migration, public API, irreversible side effect) or two-way (revert restores the previous state).
- **Blast radius:** who or what is affected if this is wrong (one screen, one service, all tenants, stored data).
- **Rollback:** the exact action: revert the commit, flip a flag (`feature-flag-toggle-engine`), run a down-migration, redeploy a version. If a rollback is not possible, say so and what mitigates it.
- **Ordering and prerequisites:** migrations before code, config before deploy, backward compatibility window (`migrations-and-environments`, `parallel-change-expand-contract`).
- **Known weaknesses:** shortcomings of the chosen approach, stated plainly; hiding them costs trust.

A small PR is also cheaper to revert; see [references/size-splitting-and-ai-disclosure.md](references/size-splitting-and-ai-disclosure.md).

---

## 6. Size and Splitting

A reviewer is the scarce resource. One self-contained change per PR, with its own tests, that leaves the system working after merge.

- Rule of thumb from Google's guidance: about 100 lines is usually fine and about 1000 is usually too large; file count matters as well as line count. Treat these as soft heuristics, not rules.
- Separate refactors, mechanical renames, formatting and dependency bumps from behavior changes.
- If you cannot describe the PR in a short title and two sentences of motivation, it is probably two PRs.
- Split strategies (stacking, by layer, by feature slice, config separate from code) are in the size reference. Each split PR gets its **own** description covering only its own diff and naming its siblings.
- Large mechanical or generated changes can be acceptable when the reviewer's job is only to confirm; say what generated them and how to reproduce.

---

## 7. AI-Involvement Disclosure (only if the project requires it)

Check `CONTRIBUTING`, the PR template and `AGENTS.md`/`CLAUDE.md` first. If the project requires disclosure, follow **its** format exactly and be honest and specific; do not invent a format, and do not add a disclosure line where none is requested. A common generic form is one line naming the level of AI help and the stages it covered (for example design, implementation, testing, review) in the project's vocabulary. An agent must describe its own part truthfully, and the human author remains responsible for the content. See the size and disclosure reference for an example of a public specification.

---

## 8. Keep It True

- Re-read the description before requesting review and again after each review round; edit the sections that no longer match (`receiving-code-review`).
- Add new test evidence rather than overwriting old evidence silently.
- Mark the PR as draft while it is not ready for review; do not request review from owners until it is ready.
- Link issues with closing keywords only when the PR really resolves them (`Fixes #123`, `Closes owner/repo#45`); use "Refs" for context.

---

## 9. Bad Description Patterns

| Pattern | Problem | Fix |
|---|---|---|
| `Fix bug`, `Updates`, `WIP`, `Phase 1` | No what, no why | Specific title and motivation |
| File-by-file list | Repeats the diff | Group by idea |
| Marketing prose | Hides risk | Plain facts, risks named |
| "Tests pass" without detail | Unverifiable | Commands, counts, scenarios |
| Claims the diff does not support | Misleads reviewers | State what is guaranteed, list gaps |
| Description written once, never updated | Wrong after review | Section 8 |
| Secret or machine-local details (paths, tokens, internal hosts) in the text | Leak | Redact; use placeholders |
| Links only (no context) | Dead links later | Summarize the context in the text |

---

## Quick Decision Checklist

- [ ] Title is `type(scope): imperative summary`, specific, stands alone
- [ ] Motivation says why now and why this approach; issues linked with the right keyword
- [ ] Changes grouped by idea; interface and behavior changes listed separately (or "None")
- [ ] Testing lists commands, results, scenarios, and what was not run; evidence attached for visible or performance changes
- [ ] Door (one-way or two-way), blast radius and rollback are written down
- [ ] Reviewer guide points to what needs judgment and names follow-ups
- [ ] PR is one self-contained change; unrelated work split out
- [ ] AI disclosure follows the project's required format, only if required
- [ ] No secrets, personal paths or internal hostnames; nothing published without the user's request

## Deep references

- [Description anatomy and title](references/description-anatomy-and-title.md) — read when writing the title, the opening paragraph and the Motivation or Changes sections, or when fixing a vague description.
- [Evidence, risk and interface versus behavior](references/evidence-risk-and-interface-vs-behavior.md) — read when writing Testing, Risk and Rollback, or deciding what counts as an interface or a behavior change.
- [Size, splitting and AI disclosure](references/size-splitting-and-ai-disclosure.md) — read when a PR is large, when splitting or stacking changes, when drafting, or when the project requires an AI-involvement line.
