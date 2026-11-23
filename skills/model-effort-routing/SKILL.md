---
name: model-effort-routing
description: "Find the most economical effective solution: pick the model tier and reasoning effort a task deserves, route and delegate to subagents, and cut token spend without under-powering consequential work. Covers optimisation objective, triage by worst dimension, effort and overthinking, orchestration ladder, subagent model and effort per call, escalation and fallback, budget guards, cache cost of mid-conversation changes, and portability across Claude Code, Google Antigravity and other harnesses. Use when choosing model or effort, delegating to subagents, cutting token cost, setting effort mid-conversation, designing routers, cascades or fallbacks, or writing skills and agents with model and effort headers."
---

# Model & Effort Routing

One idea: **use the cheapest model tier, lowest effort and simplest route that still passes a check you can name; escalate on evidence, never on size or gut feeling.** Sources, statuses and unadopted claims: [references/sources.md](references/sources.md). All rules live in this body because Antigravity reads only `name` and `description`; nothing depends on `model:`/`effort:` keys.

| Tier | Work | Illustrative mapping (verify current vendor docs) |
|---|---|---|
| `gather` | fetch, search, read-only lookup, count, trace | lightest model (Claude Haiku 5.x class) |
| `build` | generate, edit, translate, bulk mechanical work with tools | mid model (Sonnet 5.x class) |
| `reason` | review, audit, design, security, root cause, judging | strongest everyday model (Opus 5.x class) |
| `orchestrate` | coordinate agents, long unsupervised runs | top planner (Fable 5.x class); short list |
| `style` | output style only; never switches model or effort | inherit |

Prices and model names change within months: keep them in a dated config, never in a rule.

## 1. Prime rule

1. Start at the lowest rung (tier, effort, orchestration) whose result a **deterministic check** can verify: tests, schema, linter, executed command, exact lookup.
2. Escalate one step at a time, failed attempt attached, only after a classified substantive failure (section 6).
3. **Never over-spend** (no strong tier, high effort or fleet for a rename or lookup); **never silently downgrade** (say which model and effort ran and why).
4. Levers in order: context size and caching, effort, tier, orchestration shape.
5. **Cost never overrides correctness, safety or the safety floor** (section 2).

## 2. Optimisation objective: the most economical effective solution

Pick the candidate that meets the acceptance criteria at the least cost. Three tests:
- **Effectiveness**: it really solves the stated problem.
- **Efficacy**: it reaches the goal reliably and verifiably (a check passes).
- **Efficiency**: fewest tokens, tool calls, latency and new dependencies.

Before acting, compare 2-3 routes and take the **cheapest that clears the check**: (a) answer directly from what you already know or have read; (b) reuse an existing tool, script, file, cache or earlier result; (c) delegate bounded work to a lighter agent; (d) use the strongest model. A route with no way to verify its result does not qualify as cheap. **Stop as soon as the acceptance criteria pass**; do not add polish, extra passes or a second opinion the stakes do not need.

Token-saving tactics:
- **Inspect before asking**: read the repo, config and logs before questioning the user; ask only for what cannot be found.
- **Targeted reads**: grep or glob, then read the needed lines, not whole files or the whole repo.
- **Reuse**: prior results, cached output, existing helpers; do not re-derive or re-fetch.
- **No repeated identical checks** and no redundant agents; one run of a check per unchanged input.
- **Minimal briefs** to subagents (section 5) and summaries back, not transcripts.

## 3. Triage by the WORST single dimension

Score four dimensions; the **highest** decides. Size does not: a 2000-record schema-checked extraction is `gather`/`build`; a three-line auth change is `reason`.
**Ambiguity** (goal, criteria, open decisions fixed?), **blast radius** (what breaks, reversible?), **verifiability** (cheap oracle?), **novelty** (known pattern or unfamiliar invariants?).

| Task profile | Tier | Effort | Orchestration |
|---|---|---|---|
| **Trivial**: question, rename, formatting, exact lookup | `gather` or session model if already cheap | low (medium if the lightest tier skips checks) | single call, inline |
| **Standard**: fixed spec, test-verifiable, known pattern | `build` | medium; high if long agentic runs stop early | chain or route; read-only `gather` fan-out for volume |
| **Complex**: ambiguity or novelty high, cross-module invariants | `reason` | high; `xhigh` only after measured gain | orchestrator-workers, independent checker, cheap gatherers |
| **Consequential**: destructive, irreversible, security, money, migration, weak oracle, public release | `reason` floor; `orchestrate` only for long-horizon work with consent | high minimum | plan, execute, **independent same-floor review**, human gate |

**Safety floor:** the highest-risk factor wins; never average a destructive risk down because the diff is small. Cheap generation is fine only with strong verification: up-tier the checker, not the typist. The reviewer stays at the floor even if the implementer was down-routed. More model or effort never widens authority; permission failures go back to the supervisor. A role whose load spans tiers is two roles.

## 4. Effort control

- **Levels (Claude):** `low`, `medium`, `high`, `xhigh`, `max`; other vendors differ and are model-dependent. Map your tiers to the target model's accepted names. Default is `high` except Opus 5.5 and Haiku 5.5 (`medium`); set effort explicitly.
- Effort is a **behavioural signal, not a token budget**: it scales thinking, tool-call count and thoroughness.
- **Under-thinking:** one small measurement (five questions, one skill, Claude Code) saw skills skipped at `--effort low`; the lightest tier at `low` skips checks. If an agent ignores a skill or tool, raise effort first and test activation after lowering it.
- **Overthinking:** `max` gains little over `xhigh`, costs more, can overthink structured output. Use it only to measure a ceiling.
- **Change effort before tier.** Prompt phrases ("think hard") do nothing; effort is the control; control length in the prompt.
- **Ceilings:** thinking counts as billed output and against `max_tokens`. Size for thinking plus answer; a truncated or `incomplete` reply is a ceiling bug, not a retry. Cap agent loops (turns, budget).
- **Cache cost (vendor-documented):** a top-level effort change can invalidate the cached prefix and re-bill it at full input price. Use per-message effort (Claude beta, appended at the tail) or OpenAI `configuration_update` (GPT-6+) where supported; otherwise one effort per cached session, varied across workloads.

## 5. Orchestration ladder and delegation

Climb only on evidence: **single call** (optimise first) -> **chaining** (fixed subtasks) -> **routing** (known categories, reliable classifier) -> **parallelisation** (independent only; never parallel writers on shared files) -> **orchestrator-workers** (subtasks decided at runtime) -> **evaluator-optimizer** (checkable criteria, cap about 3 rounds) -> **autonomous agent** (open-ended, sandboxed). Multi-agent costs far more tokens: the vendor guide quotes roughly 10-15x, **a claim, not verified**; keep it for high-value independent breadth work, depth at two levels. Best-of-N needs a cheap trustworthy verifier.

Delegating:
1. **Break-even first**: delegate only for a named benefit (freed lead context, large output kept out, disjoint parallel work, verdict only); otherwise do it inline.
2. **Set `model` and `effort` on every built-in or untyped agent call**; omitted means the session model. Read-only search, lookup, trace -> lightest, low/medium; bulk mechanical edits -> mid, medium; review, audit, root cause, design, security -> strongest or inherit, high; planning -> inherit; fork -> inherits lead effort. Judge by what the agent does, not its name (reviewer = `reason`).
3. **Write scopes**: unique file ownership, worktrees for concurrent writers, read-only reviewers do not repair.
4. **Minimal standalone brief**: goal and the user's acceptance criteria, owned and forbidden paths, sourced facts, unknowns kept apart, commands already run, loop bounds, "if unsure, stop and report, never guess", proof of completion = quoted check output. Reviewers get requirements, change and raw evidence, never the implementer's conclusions.
5. Re-run the key check yourself; self-reports are not acceptance. Quota-limited hosts: cheap tier default, at most one mid-tier and one browser agent per mission.

## 6. Escalation, fallback, failure classification

| Class | Examples | Action |
|---|---|---|
| Environment | auth, permissions, sandbox, dependency, malformed input, broken fixture | repair, retry on the **same** allocation; never escalate, do not count |
| Scope change | requirement moved | re-triage from scratch |
| Substantive | wrong result, failed check, conceptual error | counts toward escalation |

- 1st substantive failure: one tier up, failed attempt attached. 2nd: **fresh top-tier pass**, high effort, root cause before more edits. 3rd: stop, question the approach, **ask the user**. Same error twice with no new signal: no identical third attempt.
- Loop bound about 2-3 per role. One layer owns retries, or gateway x SDK x loop retries multiply (see `circuit-breaker-retry-telemetry`).
- **Checker floor:** challenger and auditor on different tiers; the implementer never approves its own work.
- **No silent fallback:** state model, effort, reason and changed verification; if the fallback breaches the floor (destructive, security, weak oracle), pause. Missing identity metadata means "not attested".
- **Confidence signals**, best first: deterministic checks, cross-sample agreement, judge scores, self-reported confidence (poorly calibrated). No cheap-first path without a detector; never gate irreversible actions on cheap-tier confidence.
- Disclose model, effort and reason for any non-default choice in one line.

## 7. Budget and cost guards

- **Ceilings** on spend, turns, wall-clock and `max_tokens`, enforced outside the model; decide whether a cap rejects or degrades.
- A premium tier that is "available" is not "authorised": ask once, naming the surcharge; never use it in headless runs without prior consent. Expensive advisors get a consultation budget (one initial call, two per standard task) and a compact envelope.
- **Research caps:** lightest tier, at most 3 researcher subagents (default 2), 3 sources per question, a second search only if the first is thin.
- **Instruction-size budget:** always-loaded files under about 4 KB; move rationale to linked pages, never delete a rule.
- **Caching and context size often beat tiering**: agents resend context each step, output and thinking cost several times input (see `caching-strategies`, `agent-skills-context-engineering`).
- A router or classifier is an extra call: add it only when measured savings exceed its cost. Saving = traffic moved x price gap - retries - escalations - router cost - quality loss, against a named baseline.

## 8. Harness portability

| Concern | Claude Code | Antigravity and others |
|---|---|---|
| Frontmatter read | `name`, `description` plus extensions (`model`, `effort`, `context`) | `name`, `description` only |
| Routing rules live in | optional header overlay | **Markdown body** and the tier table above |
| Header scope | `model:`/`effort:` last the **rest of the turn**, then revert | n/a |
| Precedence | effort env var outranks skill `effort:`; auto mode ignores unsupported models | model picker or host setting |
| Isolation | `context: fork` gives a subagent its own model/effort | the host's delegation tool only |

- A model switch is not free: caches are model-scoped, so a switch on large context re-reads it at **uncached** price. Down to the lightest tier is cheap; mid/strong/planner swaps on a short task can cost more than they save. Prefer a subagent or forked skill with an explicit model.
- A light-tier skill lowers the model for the rest of that turn. Header lines vanish on reinstall.
- API and claude.ai uploads reject non-portable keys; keep Claude Code extras in a separate copy. Effort flags differ: `--effort` (Claude), `model_reasoning_effort` (Codex), `--variant` (OpenCode). Test triggers in every target harness, headless modes separately; no permission-bypass flags outside a sandbox.

## 9. Enforcement and measurement

- Prose decays: add a **fail-open** pre-tool hook that denies a built-in or untyped agent launch with no `model`; never guard typed agents.
- **Measure launches, not intentions**: count agent launches by (type, model) from transcripts, de-duplicate by call id, compare date windows. One local baseline (one machine): 60 of 999 built-in launches (6%) named a model. It shows what was requested, not what ran.
- Before down-routing a task class, evaluate the exact model-and-effort pair on representative tasks; redo after model, tool or prompt changes.
- Close with Implemented / Validated / Partially validated / Blocked and the checks that ran.

### Evidence quality

| Status | Covers |
|---|---|
| Vendor-documented | effort levels and defaults, thinking counted in `max_tokens`, cache scoping, per-message effort, header scope |
| Measured (tiny n) | low effort suppressing skill use; the 6% baseline |
| Paper abstract | best-of-N routing "up to 60% cost, under 1% loss" (peak, unreplicated) |
| Claims / opinion | 70/20/10 splits, 40-95% savings, multiplier tables, per-agent tier maps, Fable price multiple (2x vs 2.5x across repos) |

Write "claimed by X" for the last row; a fair savings figure names baseline, mix, quality metric, escalation rate and price date.

## Quick Decision Checklist

1. Worst dimension (ambiguity, blast radius, verifiability, novelty)? It picks the row.
2. Compared direct / reuse / lighter agent / frontier; took the cheapest that clears a check?
3. Deterministic check available? If not, raise the floor or add an independent reviewer.
4. Lowest effort that passes, set explicitly; read targeted, reused results, no repeated checks.
5. Delegating? Named benefit, explicit `model` + `effort`, minimal brief, unique write scope.
6. Consequential? `reason` floor, high effort, same-floor reviewer, human gate; cost does not override.
7. Failure classified? Environment never escalates; 1 up, 2 fresh top pass, 3 ask the user.
8. Mid-conversation model or effort change? Count the cache cost. Fallback or non-default choice? Disclose.
9. Stopped when criteria passed? Savings quoted only if measured.

## Boundaries

`agent-skills-context-engineering`: context shaping, not model choice. `agentic-rag-architecture`: retrieval design. `circuit-breaker-retry-telemetry`: breaker and retry mechanics; here only retry ownership. `rate-limiter-throttler`: traffic throttling; here quota-aware agent counts. `caching-strategies`: caching design; here only prompt-cache effects. `yagni-evolutionary-architecture`: no router or orchestrator before evidence. `architecture-decision-trees-tradeoffs`: general trade-offs. `code-review`: how to review; here the reviewer's tier. `implement`: ticket execution; here its workers' tier. `grilling`: clarify intent first when ambiguity is the worst dimension.

## Deep references

Sources and unreadable pages: [sources](references/sources.md).

- **Patterns and orchestration** (choose a rung, topology, control plane): [workflow vs agent](references/workflow-vs-agent-patterns.md) · [triage tiers](references/complexity-triage-tiers.md) · [control plane](references/orchestration-control-plane.md) · [topology and failures](references/multi-agent-topology-and-failure-modes.md)
- **Effort and caching** (levels, ceilings, mid-session changes): [levels by provider](references/effort-levels-by-provider.md) · [overthinking and ceilings](references/overthinking-and-token-ceilings.md) · [cache and mid-conversation changes](references/cache-and-mid-conversation-changes.md) · [portable frontmatter](references/portable-skill-frontmatter.md)
- **Routing and savings** (routers, cascades, what is claimed vs measured): [routing in production](references/routing-strategies-in-production.md) · [work split and pricing](references/tiered-work-split-and-pricing.md) · [best-of-N and verifier](references/best-of-n-and-verifier-routing.md) · [confidence-based escalation](references/confidence-based-escalation.md) · [claims vs evidence](references/claims-vs-evidence-on-savings.md) · [measured effort evidence](references/measured-effort-evidence.md)
- **Policies and delegation** (tier tables, floors, briefs, budgets): [tier tables compared](references/tier-tables-compared.md) · [escalation, fallback, floors](references/escalation-fallback-and-safety-floors.md) · [quota and cost guards](references/quota-and-cost-guards.md) · [delegation briefs](references/delegation-brief-templates.md) · [work-weight tier table](references/work-weight-tier-table.md) · [agent-call rules and hook](references/agent-call-rules-and-enforcement-hook.md)
- **Harnesses** (Antigravity, Claude Code, Codex, Gemini CLI): [Antigravity format and paths](references/antigravity-skills-format-and-paths.md) · [quota-aware subagents](references/quota-aware-subagent-orchestration.md) · [delegation triggers](references/complexity-assessment-and-delegation-triggers.md) · [phase-based routing](references/phase-based-skill-routing.md) · [portability checklist](references/cross-harness-portability-checklist.md) · [header limits and switch cost](references/skill-header-limits-and-switch-cost.md)
- **Governance and audit**: [instruction size budget](references/instruction-size-budget-and-safe-shortening.md) · [measuring model usage](references/measuring-and-auditing-model-usage.md)
