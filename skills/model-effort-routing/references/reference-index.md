# Reference Index (model-effort-routing)

Sources: this skill's own reference files; each file lists its own sources · Last verified 2026-11-24

One owner per topic. `SKILL.md` keeps the core rules and links here for the full catalog; open only the file whose "read when" matches the question. Source statuses: [sources.md](sources.md).

## Patterns and orchestration

- [workflow-vs-agent-patterns.md](workflow-vs-agent-patterns.md): choosing a rung of the ladder; when evaluator loops or autonomy pay off.
- [complexity-triage-tiers.md](complexity-triage-tiers.md): scoring a task into a tier before acting.
- [orchestration-control-plane.md](orchestration-control-plane.md): who owns routing, state and retries in a multi-agent run.
- [multi-agent-topology-and-failure-modes.md](multi-agent-topology-and-failure-modes.md): topology choices, depth, failure patterns.

## Effort and caching

- [effort-levels-by-provider.md](effort-levels-by-provider.md): level names, defaults and mapping per vendor.
- [overthinking-and-token-ceilings.md](overthinking-and-token-ceilings.md): `max` vs `xhigh`, `max_tokens` sizing, truncated replies.
- [cache-and-mid-conversation-changes.md](cache-and-mid-conversation-changes.md): cache cost of effort or model changes mid-session.
- [portable-skill-frontmatter.md](portable-skill-frontmatter.md): which header keys each surface accepts.
- [measured-effort-evidence.md](measured-effort-evidence.md): the small measurements behind the effort rules.

## Routing and savings

- [economical-route-and-token-tactics.md](economical-route-and-token-tactics.md): choosing the cheapest sufficient route; token-saving tactics.
- [routing-strategies-in-production.md](routing-strategies-in-production.md): cascades, predictive routers, caps, router overhead.
- [tiered-work-split-and-pricing.md](tiered-work-split-and-pricing.md): work split across tiers and the price spread.
- [best-of-n-and-verifier-routing.md](best-of-n-and-verifier-routing.md): sampling plus a verifier.
- [confidence-based-escalation.md](confidence-based-escalation.md): which signals may trigger escalation.
- [claims-vs-evidence-on-savings.md](claims-vs-evidence-on-savings.md): evidence status table; how to quote a saving.

## Policies and delegation

- [tier-tables-compared.md](tier-tables-compared.md): tier tables from several public repos.
- [escalation-fallback-and-safety-floors.md](escalation-fallback-and-safety-floors.md): failure classes, ladder, floors, fallback disclosure.
- [quota-and-cost-guards.md](quota-and-cost-guards.md): ceilings, premium-tier consent, consultation budget, break-even.
- [delegation-brief-templates.md](delegation-brief-templates.md): standalone briefs and reviewer inputs.
- [work-weight-tier-table.md](work-weight-tier-table.md): tier to model and effort, the policy file and its check script.
- [agent-call-rules-and-enforcement-hook.md](agent-call-rules-and-enforcement-hook.md): per-call table, agent files, research caps, the guard hook.

## Harnesses

- [antigravity-skills-format-and-paths.md](antigravity-skills-format-and-paths.md): Antigravity skill format and install paths.
- [quota-aware-subagent-orchestration.md](quota-aware-subagent-orchestration.md): agent counts on quota-limited hosts.
- [complexity-assessment-and-delegation-triggers.md](complexity-assessment-and-delegation-triggers.md): when a task should be delegated.
- [phase-based-skill-routing.md](phase-based-skill-routing.md): routing by workflow phase.
- [cross-harness-portability-checklist.md](cross-harness-portability-checklist.md): per-harness facts and portability rules.
- [skill-header-limits-and-switch-cost.md](skill-header-limits-and-switch-cost.md): header scope limits and the cost of a model switch.

## Governance and audit

- [instruction-size-budget-and-safe-shortening.md](instruction-size-budget-and-safe-shortening.md): the 4 KB budget and the safe-shortening procedure.
- [measuring-and-auditing-model-usage.md](measuring-and-auditing-model-usage.md): launch report and periodic audit.
