---
name: model-effort-routing
description: "Find the most economical effective solution: pick the model tier and reasoning effort a task deserves, route and delegate to subagents, and cut token spend without under-powering consequential work. Covers triage, effort, orchestration, subagent model and effort per call, escalation, budget guards, cache cost and harness portability. Use when choosing model or effort, delegating to subagents, cutting token cost, designing routers, cascades or fallbacks, or writing skills and agents with model and effort headers."
---

# Model & Effort Routing

One idea: **use the cheapest model tier, lowest effort and simplest route that still passes a check you can name; escalate on evidence, never on size or gut feeling.** Sources and unadopted claims: [references/sources.md](references/sources.md). All rules live in this body because Antigravity reads only `name` and `description`; nothing depends on `model:`/`effort:` keys.

| Tier | Work | Illustrative mapping |
|---|---|---|
| `gather` | fetch, search, read-only lookup, count, trace | lightest model (Claude Haiku 5.x class) |
| `build` | generate, edit, translate, bulk mechanical work with tools | mid model (Sonnet 5.x class) |
| `reason` | review, audit, design, security, root cause, judging | strongest everyday model (Opus 5.x class) |
| `orchestrate` | coordinate agents, long unsupervised runs | top planner (Fable 5.x class); short list |
| `style` | output style only; never switches model or effort | inherit |

Prices and model names change within months: keep them in a dated config.

## 1. Prime rule

1. Start at the lowest rung (tier, effort, orchestration) whose result a **deterministic check** can verify: tests, schema, linter, executed command, exact lookup.
2. Escalate one step at a time, failed attempt attached, only after a classified substantive failure (section 6).
3. **Never over-spend** (no strong tier, high effort or fleet for a rename or lookup); **never silently downgrade** (say which model and effort ran and why).
4. Levers in order: context size and caching, effort, tier, orchestration shape.
5. **Cost never overrides correctness, safety or the safety floor** (section 2).

## 2. Optimization objective: the most economical effective solution

Compare 2-3 routes and take the **cheapest that clears the check**: (a) answer from what you know; (b) reuse a tool, file, cache or earlier result; (c) delegate bounded work to a lighter agent; (d) the strongest model. A route that cannot be verified is not cheap. **Stop as soon as the acceptance criteria pass.** Tactics: [token tactics](references/economical-route-and-token-tactics.md).

## 3. Triage by the WORST single dimension

The **highest** of four dimensions decides, not size: a 2000-record schema-checked extraction is `gather`/`build`; a three-line auth change is `reason`.
**Ambiguity** (goal, criteria, open decisions fixed?), **blast radius** (what breaks, reversible?), **verifiability** (cheap oracle?), **novelty** (known pattern or unfamiliar invariants?).

| Task profile | Tier | Effort | Orchestration |
|---|---|---|---|
| **Trivial**: question, rename, formatting, exact lookup | `gather` or session model if already cheap | low (medium if the lightest tier skips checks) | single call, inline |
| **Standard**: fixed spec, test-verifiable, known pattern | `build` | medium; high if long agentic runs stop early | chain or route; read-only `gather` fan-out for volume |
| **Complex**: ambiguity or novelty high, cross-module invariants | `reason` | high; `xhigh` only after measured gain | orchestrator-workers, independent checker, cheap gatherers |
| **Consequential**: destructive, irreversible, security, money, migration, weak oracle, public release | `reason` floor; `orchestrate` only long-horizon, with consent | high minimum | plan, execute, **independent same-floor review**, human gate |

**Safety floor:** the highest-risk factor wins; never average a destructive risk down for a small diff. Cheap generation needs strong verification: up-tier the checker, not the typist; the reviewer stays at the floor even if the implementer was down-routed. More model or effort never widens authority. A role spanning tiers is two roles.

## 4. Effort control

- Effort is a **behavioral signal, not a token budget**; set it explicitly (defaults vary). **Change effort before tier**; "think hard" prompts do nothing; if an agent skips a skill or tool, raise effort first; `max` only to measure ceilings.
- **Two surfaces, two defaults, never copied across.** Agent call (isolated subagent): `low` gathering, `medium` bulk edits, `high` judging; omit effort only on a fork. Skill header (rest of the lead's turn): tier-table effort, `high` for `gather`, `build`, `reason`.
- Thinking counts against `max_tokens` (a truncated reply is a ceiling bug, not a retry); a top-level effort change can invalidate the cache. See [levels](references/effort-levels-by-provider.md), [ceilings](references/overthinking-and-token-ceilings.md), [cache](references/cache-and-mid-conversation-changes.md).

## 5. Orchestration ladder and delegation

Climb on evidence only: **single call** -> **chaining** -> **routing** -> **parallelization** (independent only; never parallel writers on shared files) -> **orchestrator-workers** -> **evaluator-optimizer** (checkable criteria, about 3 rounds) -> **autonomous agent** (sandboxed). Multi-agent costs roughly 10-15x tokens (vendor guide, **claim, not verified**): independent breadth work only. Best-of-N needs a cheap verifier.

1. **Break-even first**: delegate only for a named benefit (freed lead context, output kept out, disjoint parallel work, verdict only), else inline.
2. **Set `model` and `effort` on every built-in or untyped agent call** (omitted = session model): read-only search lightest/low-medium; bulk mechanical edits mid/medium; review, audit, root cause, design, security strongest or inherit/high; planning inherit. Judge by what it does, not its name. Table, definition files: [agent-call rules](references/agent-call-rules-and-enforcement-hook.md).
3. **Write scopes**: unique file ownership, worktrees for concurrent writers, read-only reviewers do not repair.
4. **Minimal standalone brief**: goal, acceptance criteria, scopes, sourced facts, unknowns apart, loop bounds, "if unsure, stop and report", quoted check output as proof. Reviewers get requirements, change and raw evidence, never conclusions ([templates](references/delegation-brief-templates.md)). Re-run the key check yourself; self-reports are not acceptance.

## 6. Escalation, fallback, failure classification

| Class | Examples | Action |
|---|---|---|
| Environment | auth, permissions, sandbox, dependency, broken fixture | repair, retry on the **same** allocation; never escalate, do not count |
| Scope change | requirement moved | re-triage |
| Substantive | wrong result, failed check, conceptual error | counts toward escalation |

- 1st substantive failure: one tier up, failed attempt attached. 2nd: **fresh top-tier pass**, high effort, root cause before more edits. 3rd: stop and **ask the user**. Same error twice with no new signal: no identical third attempt. Loop bound about 2-3 per role; one layer owns retries (`circuit-breaker-retry-telemetry`).
- **Checker floor:** challenger and auditor on different tiers; the implementer never approves its own work.
- **No silent fallback:** state model, effort, reason, changed verification; a fallback that breaches the floor pauses. Disclose non-default choices in one line.
- Never gate irreversible actions on cheap-tier confidence ([signals](references/confidence-based-escalation.md), [floors](references/escalation-fallback-and-safety-floors.md)).

## 7. Budget and cost guards

- **Ceilings** on spend, turns, wall-clock, `max_tokens`, enforced outside the model. "Available" premium is not "authorized": ask once, naming the surcharge; never headless without consent ([quota guards](references/quota-and-cost-guards.md)).
- **Research caps** (every research skill and copy): lightest tier, at most 3 researcher subagents (default 2), one search first and a second only if thin or contradictory, at most 3 sources per question, no extra round.
- **Instruction-size budget:** always-loaded files (including rule files without `paths:`) under about 4 KB; move rationale to linked pages, never delete a rule (section 10).
- Caching and context size often beat tiering. A router is an extra call: add it only when the measured saving (traffic moved x price gap - retries - escalations - router cost - quality loss) beats a named baseline.

## 8. Harness portability

Antigravity and others read only `name` and `description`; Claude Code adds `model`, `effort`, `context`. Header `model:`/`effort:` last the **rest of the turn**; an effort env var outranks them; caches are model-scoped, so a switch on large context re-reads it at **uncached** price: prefer a subagent or forked skill with an explicit model. Test triggers per harness (headless too); no permission-bypass flags outside a sandbox. See [checklist](references/cross-harness-portability-checklist.md), [header limits](references/skill-header-limits-and-switch-cost.md).

## 9. Enforcement and measurement

Prose decays: a **fail-open** pre-tool hook denies a built-in or untyped agent launch without `model`; never guard typed agents. **Measure launches, not intentions** (by type and model, de-duplicated, date windows; [measuring](references/measuring-and-auditing-model-usage.md)). Before down-routing a task class, evaluate the exact model-and-effort pair on representative tasks. Close with Implemented / Validated / Partially validated / Blocked plus the checks that ran.

### Evidence quality

Rank every figure: vendor-documented, measured (tiny n), paper abstract, claim ("claimed by X"); a savings figure names baseline, quality metric, escalation rate, price date ([table](references/claims-vs-evidence-on-savings.md)).

## 10. Maintaining the policy (files, mirrors, headers)

When an agent, skill or rule file is created, edited, installed or synced:

1. **One home for tiers:** one policy file, checked against every skill header by script; change a tier, not files; re-run after any reinstall.
2. **Shorten without breaking citations:** grep citations of headings and numbers first; compress in place, move full text to a linked page; re-run retrieval tests, never editing expected answers.
3. **Mirrors and templates:** edit every real copy, confirm with a diff; governed projects use their own mechanism.
4. **Sweep, then report:** only named projects; out-of-scope findings are reported, not edited.
5. **Order:** inventory -> scratch draft (size, diff) -> apply -> re-index -> tests and lint -> report.

## Quick Decision Checklist

1. Worst dimension picks the row.
2. Compared routes; took the cheapest passing a check?
3. No deterministic check? Raise the floor or add an independent reviewer.
4. Lowest effort that passes, set explicitly; targeted reads, no repeated checks.
5. Delegating? Named benefit, explicit `model` + `effort`, minimal brief, unique scope.
6. Consequential? `reason` floor, high effort, same-floor reviewer, human gate.
7. Failure classified? Environment never escalates; 1 up, 2 fresh top pass, 3 ask.
8. Mid-conversation model or effort change? Count the cache cost; disclose non-default choices.
9. Stopped when criteria passed? Savings quoted only if measured.
10. Editing an agent, skill or rule file? Policy tier, mirrors, citations, size (section 10).

## Core pair with `skill-orchestrator`

This skill and `skill-orchestrator` are the pack's two pillar skills and form one start-of-task protocol: `skill-orchestrator` (its single owner) decides which instructions and skills apply and in what order; this skill then decides model, effort and delegation. Karpathy-style rules for instruction files live in `skill-orchestrator` (section 5); its Simplicity First and Goal-Driven Execution map to the prime rule of section 1 here and are not restated.

## Boundaries

`agent-skills-context-engineering`: context shaping, not model choice. `agentic-rag-architecture`: retrieval design. `circuit-breaker-retry-telemetry`: breaker and retry mechanics; here only retry ownership. `rate-limiter-throttler`: traffic throttling; here quota-aware agent counts. `caching-strategies`: caching design; here only prompt-cache effects. `yagni-evolutionary-architecture`: no router or orchestrator before evidence. `architecture-decision-trees-tradeoffs`: general trade-offs. `code-review`: how to review; here the reviewer's tier. `implement`: ticket execution; here its workers' tier. `grilling`: clarify intent first when ambiguity is the worst dimension.

## Deep references

- [Reference index](references/reference-index.md) — every reference by topic, one when-to-read line each; start here.
- [Sources](references/sources.md) — statuses and unadopted claims.
- [Token tactics](references/economical-route-and-token-tactics.md) — section 2 tactics.
- [Agent-call rules](references/agent-call-rules-and-enforcement-hook.md), [work-weight tiers](references/work-weight-tier-table.md), [size budget](references/instruction-size-budget-and-safe-shortening.md) — owners of sections 5, 9, 10.
