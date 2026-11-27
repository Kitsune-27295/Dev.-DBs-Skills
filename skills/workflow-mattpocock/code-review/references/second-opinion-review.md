# Second Opinion: A Reviewer on a Different Model

Sources: https://google.github.io/eng-practices/review/reviewer/ · https://google.github.io/eng-practices/review/reviewer/standard.html · https://google.github.io/eng-practices/review/reviewer/looking-for.html · a third-party MIT skill (cross-modal-review) read for ideas, no text reused · Last verified 2026-11-24

## When it earns its cost
A second reviewer on a different model roughly doubles review cost and adds latency, so spend it where a miss is expensive: security-sensitive changes (auth, trust boundaries, webhooks), wide diffs (many files or hundreds of lines), architecture changes, a problem that has churned through two or more iterations, and work about to run in bulk. Skip it for typo fixes, formatting and already-reviewed changes.

## How to run it
1. Capture the work: the diff and commit list from `git diff`, never a description from memory.
2. Capture the contract: the spec, ticket or the originating skill's promises. The reviewer grades against what was promised, not against taste.
3. Send diff, contract and the two-axis brief from `SKILL.md` to a reviewer on a different model, in a fresh context. A reviewer on the author's model shares the author's blind spots.
4. Compare: list findings both found, only the second found, only the first found. Agreement is signal, not permission; disagreement is the interesting part.
5. If the reviewer refuses the task, route to the next reviewer in your configured chain; if every reviewer refuses, tell the user. Never report a review that did not run as passed.
6. Findings are advisory until the user approves each one; nothing is auto-applied.

For a security-sensitive diff ask the reviewer for an adversarial pass (injection, races, auth bypass, data leaks) and a rough exploitability rating per finding.

## Anchor to a public standard
Google's reviewer guide frames the bar: approve once the change definitely improves overall code health even if it is not perfect, and look at design, functionality, complexity (watch for over-engineering) and tests. Use it to calibrate the second reviewer too: it should not block on taste, and should not wave through a net loss of code health.

## How an agent should apply this
- Offer a second opinion only for the cases above; name the added cost.
- Give the reviewer the contract and the diff, and use a different model.
- Report overlap and unique findings per reviewer; let the user decide.
