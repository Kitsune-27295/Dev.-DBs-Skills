# Routing Strategies in Production

Sources: https://vercel.com/i/llm-routing-strategies · https://ai.blocksize.hr/blog/en/ai-model-routing-cost-optimization-2026 · https://www.developersdigest.tech/blog/model-routing-strategies-cost-effective-coding-2026 · https://routllm.pro/docs · Last verified 2026-11-23

Reading note: pages were read through a WebFetch summarizer (Firecrawl had no credits), so wording is second-hand. Vercel sells a gateway, Blocksize and DevelopersDigest sell advice/tools: all are vendor-flavored.

## 1. The strategy menu

Vercel frames routing as "a layered control system", not one trick. Six strategies, with its qualitative overhead/quality ratings:

| Strategy | Signal used | Overhead | Quality control | Main weakness |
|---|---|---|---|---|
| Cost-based | static per-token price | low | none | blind to load, queueing, quality drift |
| Latency-based | recent p50/p90 per deployment | low-medium | none | history lags; a "fast" target slows once traffic shifts onto it |
| Semantic | embedding similarity to labeled prompts, or a trained classifier | medium-high | high | edge cases misclassify; needs a fallback |
| Fallback chain | error, context mismatch, outage | low | none | stacked retries can amplify an outage |
| Weighted load balancing | RPM/TPM limits, in-flight count | very low | none | optimizes throughput, not model fit |
| Budget ceiling | per-request or per-workflow spend cap | low | medium | downgrades later steps when budget is tight |

Blocksize names three decision patterns: cascade (cheap first, escalate if a check fails), predictive routing (small classifier picks before generation), and capability/semantic routing (code to the best coder, long documents to the best long-context model, bulk classification to a small self-hosted model). DevelopersDigest names four: task-complexity tags, cost-budget filter (cheapest model under a price cap; suited to CI and bulk), provider-level chain, and LLM-as-router (a cheap model labels the task simple/medium/complex/frontier).

## 2. Fallback chains: three separate mechanisms

Per Vercel: retries (same model group), fallbacks (next provider), and circuit breakers (decide whether either is attempted). Apply in that order, and coordinate across layers: gateway retry x SDK retry x agent-loop retry multiplies traffic during an incident. Inference from this: give exactly one layer ownership of retries.

```
chain = [primary, secondary_provider, cheaper_degraded_model]
for m in chain:
    if breaker.open(m): continue
    try: return call(m, retries=1, timeout=T)
    except (RateLimit, Timeout, 5xx): breaker.record(m); continue
raise AllProvidersFailed   # never fail silently to a weak model
```

Blocksize's rule: never let the cheap path fail silently; each routed request needs a detector (schema check, validator, confidence threshold, user signal) and a defined escalation.

## 3. Budget ceilings

Vercel describes two policies: pick the cheapest capable model under the cap, or assign tier by complexity and downgrade later workflow steps when the running total threatens the cap. Hard caps reject; soft caps degrade. RoutLLM (a gateway) shows the vendor-side version: rolling 5-hour and 7-day spend windows per plan, HTTP 429 with `retry-after` when exceeded. Its docs describe explicit model selection by slug, not automatic routing: treat it as a gateway, not as evidence for any router quality.

## 4. Router overhead and the "router vs big model" trade-off

- A classifier is an extra call: keep it tiny and fast or it eats the savings (Blocksize). DevelopersDigest claims about $0.001 per classification with a small model and under 1% of total cost at a 10:1 simple:complex mix; no token counts shown, so treat as unverified.
- Predictive routers avoid cascade double-inference but can send a hard task to a weak model: "a confident wrong answer at a discount" can cost more than paying full price.
- Vercel warns a router tuned to never regress quality may keep sending most traffic to the expensive model, erasing savings. Measure the real traffic share that moves.

## 5. Decision rules

- Use a single model when volume is low (DevelopersDigest suggests under about 10M tokens, though it states the unit inconsistently as daily and monthly), when all tasks are uniformly hard, or while prototyping.
- Many coding tools pin one model per session, which limits routing to subagent/delegation boundaries (DevelopersDigest names Claude Code, Cursor, Codex, Windsurf).
- Start with cost-based plus fallbacks; add semantic routing only when task fit measurably changes quality (Vercel).
- Put routing behind an abstraction so a model swap is a config change; prices and rankings churned several times within months in the sources' own histories.

## How an agent should apply this

- Build in this order: fallback chain with a single retry owner, cost/budget ceiling, then (only with eval data) a classifier or cascade.
- Define the failure detector before enabling any cheap-first path; no detector means no cheap-first.
- Track escalation rate, quality signal and spend together; a falling bill with rising complaints is a false win.
- Re-test routing with models from two vendors before production; outputs differ on some tasks.
- Keep budget caps explicit per workflow and decide up front: reject or degrade.
