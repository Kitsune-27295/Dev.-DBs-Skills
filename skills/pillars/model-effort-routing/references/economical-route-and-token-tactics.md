# Economical Route and Token Tactics

Sources: local operating practice (private notes, summarized; not a public URL) · Last verified 2026-11-24

Owner of the detail behind `SKILL.md` section 2 (the optimization objective). The core rule stays in the body: take the cheapest route that clears a named check, and stop when the acceptance criteria pass.

## The three tests

- **Effectiveness**: the candidate really solves the stated problem.
- **Efficacy**: it reaches the goal reliably and verifiably (a check passes).
- **Efficiency**: fewest tokens, tool calls, latency and new dependencies.

## Route comparison

Before acting, compare 2-3 routes and take the cheapest that clears the check: (a) answer directly from what you already know or have read; (b) reuse an existing tool, script, file, cache or earlier result; (c) delegate bounded work to a lighter agent; (d) use the strongest model. A route with no way to verify its result does not qualify as cheap. Stop as soon as the acceptance criteria pass: no extra polish, extra passes or second opinion the stakes do not need.

## Token-saving tactics

- **Inspect before asking**: read the repo, config and logs before questioning the user; ask only for what cannot be found.
- **Targeted reads**: grep or glob, then read the needed lines, not whole files or the whole repo.
- **Reuse**: prior results, cached output, existing helpers; do not re-derive or re-fetch.
- **No repeated identical checks** and no redundant agents; one run of a check per unchanged input.
- **Minimal briefs** to subagents and summaries back, not transcripts (see delegation-brief-templates).
- **Caching and context size often beat tiering**: agents resend context each step, and output plus thinking cost several times input (see the `caching-strategies` and `agent-skills-context-engineering` skills).

## Failure modes

- Picking a route nobody can verify because it looks cheap.
- Adding a second opinion or polish pass after the check already passed.
- Re-reading whole files when a grep would locate the lines.

## How an agent should apply this

- List the 2-3 candidate routes in one line each before the first expensive step.
- Name the check that will accept the result; if none exists, raise the floor.
- Prefer reuse and targeted reads over delegation, and delegation over the strongest model, unless the triage row says otherwise.
- Stop at the first passing check.
