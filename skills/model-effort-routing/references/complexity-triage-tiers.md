# Complexity Triage Tiers

Sources: https://github.com/machinedge/building-effective-agents/blob/main/building-effective-agents.md (read via raw.githubusercontent.com, first ~100k of 216k chars) · https://thinking.inc/en/blue-ocean/agentic/agent-orchestration-patterns/ · https://www.anthropic.com/research/building-effective-agents · Anthropic enterprise PDF · Last verified 2026-11-23

Caution: every number below is a **claim** from a third party or an illustrative heuristic, not a benchmark. The Anthropic sources give no multipliers except the PDF's "roughly 10-15x tokens" for multi-agent. Use the numbers to compare shapes, then measure your own.

## Tier ladder (machinedge guide, labelled illustrative by that guide)
| Tier | Shape | Claimed cost | Claimed latency | Predictability |
|---|---|---|---|---|
| 1 | Single LLM call | 1x | ~2s | high |
| 2 | Augmented LLM (retrieval/tools) | ~2x | ~5s | high |
| 3 | Workflow of chained calls | ~3-10x | ~15s | high |
| 4 | Constrained agent (guardrails, iteration cap) | ~10-50x | 1-5 min | low-medium |
| 5 | Autonomous agent | ~50-1000x | minutes-hours | low |
Rule stated there: each rung up must be justified by evaluation results.

Per-pattern table from the same guide (illustrative): chaining x3 steps 3-5x; 3-way parallel ~3x; routing + handler 2-3x; evaluator-optimizer 2 rounds 5-10x; typical agent 10-50x.

## Router-as-triage (thinking.inc, vendor blog; claims)
- A lightweight classifier on the smallest model that routes accurately; emits structured output `{route, confidence}`; below 0.8 confidence falls back to the most capable path.
- Claimed 0.5-2 s routing overhead, 30-60% saving vs sending all to the top model, 3-8% misroutes; alert if routing accuracy < 95%.
- Real workloads usually have 3-5 request types; a binary router forces specialists out of competence. An "overthinking router" costs as much as the specialist.
- Supervisor on the strongest model, specialists on mid/small models (their example: Opus supervisor, Sonnet/Haiku workers). Claimed supervisor overhead: +15-30% latency, +20-40% tokens; bottleneck above ~10 parallel agents.
- Evaluator loops: cap at ~3 rounds (claimed gains concentrate in first two), 5-8 numeric rubric dimensions.
- Start with a 3-4 stage pipeline, add router for diverse inputs, fan-out for independent work, supervisor last.

## Model-choice principle (Anthropic PDF, qualitative)
Balance capability, speed and cost: most capable model for multi-agent coding or complex financial analysis; lighter, faster model for high-volume tickets and form extraction. A premium model on a simple task is slower and costlier at scale. Anthropic's article gives the same example: easy questions to a small model, hard ones to a capable one.

## Triage decision procedure (derived; inference)
1. Can one call with retrieval/examples pass the eval? Stay at tier 1-2.
2. Are the steps known and stable? Tier 3 workflow; pick chain, parallel, or router.
3. Are only categories known? Route; give each category its cheapest adequate model/effort.
4. Is the step count unknown but the environment trusted and testable? Tier 4 agent with caps.
5. Autonomous (tier 5) only for high-value tasks, sandboxed, with kill criteria.
Escalation within a run: start cheap, escalate on low confidence, failed verification or retry limit (PDF's "single agent with multi-agent escalation").

## Pseudo-code
```
tier = classify(task)            # small model, returns {tier, confidence}
if confidence < 0.8: tier = max(tier, "capable")
result = run(tier, task)
if not verify(result): tier = next_tier(tier); retry once
```

## Failure modes
- Treating blog multipliers as budgets.
- Router more expensive than its savings (overthinking router).
- No fallback on low-confidence route, so misroutes are silent.
- Escalating by gut feeling instead of eval evidence.

## How an agent should apply this
- Default to the lowest tier whose eval passes; record why you escalated.
- Send routing to the cheapest capable model; send ambiguity to the stronger one.
- Treat all cost/latency multipliers as relative orders of magnitude only.
- Put a confidence threshold and a capable-model fallback on every router.
- Measure routing accuracy and cost per resolved task before expanding tiers.
