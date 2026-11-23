# Claims vs Evidence on Routing Savings

Sources: https://ai.blocksize.hr/blog/en/ai-model-routing-cost-optimization-2026 · https://www.developersdigest.tech/blog/model-routing-strategies-cost-effective-coding-2026 · https://vercel.com/i/llm-routing-strategies · https://acceleraid.ai/en/blog/ai-models-2026-cost-vs-skills-comparison · https://www.microsoft.com/en-us/research/publication/best-route-adaptive-llm-routing-with-test-time-optimal-compute/ · Last verified 2026-11-23

Pages read through a WebFetch summarizer (Firecrawl out of credits), so every figure is second-hand. Confidence = my confidence that the number is a sound, generalizable fact: High / Medium / Low.

## 1. Table of numeric saving claims

| Claim | Claimed by | Basis shown | Confidence |
|---|---|---|---|
| 40-70% AI spend reduction at matched quality | Blocksize | headline; no method | Low |
| About 70% of requests handled as well by small/mid models | Blocksize | none | Low |
| 55/30/15 traffic split at 1x/5x/25x cost | Blocksize | labeled illustrative | Low |
| 10-30x per-token price gap frontier vs small | Blocksize | list prices | Medium (varies, check) |
| Solo dev 40-60% vs top model | DevelopersDigest | no method | Low |
| Small team 60-80% | DevelopersDigest | no method | Low |
| CI/CD 80-95% | DevelopersDigest | assumes mostly simple tasks | Low |
| Production agent platform 50-70% | DevelopersDigest | no method | Low |
| Enterprise fixed budget 40-50% | DevelopersDigest | no method | Low |
| Simple-task savings 90%+; router overhead under 1% | DevelopersDigest | assumes unsourced 70/20/10 mix, about $0.001 per classification | Low |
| About 45x/76x price spread top vs cheapest model | DevelopersDigest | arithmetic on list prices | Medium (prices stale quickly) |
| Caching: 80% saved on an agent run (90% cache hits) | ACCELERAID | worked example with stated prices | Medium (arithmetic sound; assumes hit rate) |
| Cache discount 90-97.5% | ACCELERAID | list prices | Medium |
| Agents use about 4x chat tokens, multi-agent about 15x | ACCELERAID (attributed) | not shown | Low |
| Up to 60% cost reduction, under 1% performance drop | BEST-Route paper (Microsoft Research, abstract) | peer-style research, authors' datasets | Medium (peak, "up to", not replicated here) |
| Stop at ensemble confidence, about half the inference cost | TUMIX via Awesome-Inference-Time-Scaling list | list description only | Low-Medium |
| MMLU +1.4 points from confidence-arbitrated layer routing | arXiv 2610.04751 abstract | paper; different technique | Medium, not applicable to model routing |
| Vercel: no savings percentages | Vercel | n/a | n/a: only advice to measure |

## 2. Internal inconsistencies noticed (reader summaries, then my arithmetic)

- Blocksize's own tier table (0.55x1 + 0.30x5 + 0.15x25 = 5.8 vs 25 all-frontier) implies about 77% savings, above its stated 40-70% range; the page does not reconcile them. Also its "about 70% handled by small/mid" differs from the 85% placed in small/mid tiers.
- DevelopersDigest: a code example uses a different price for one model than its own table; DeepSeek entries use off-peak only; the 10M-token threshold is "daily" in one place and "monthly" in another; its savings are not derivable from its tiers without extra assumptions.
- ACCELERAID: publication date inconsistent across metadata and byline; says it uses AI to write its articles.
- Vercel and ACCELERAID are selling a gateway and a platform; DevelopersDigest and Blocksize promote tooling or services.

## 3. Why the claimed numbers differ so much

Savings = (fraction of traffic moved) x (price gap) - (retries, escalations, router cost, quality losses). Each blog fixes an unmeasured traffic mix (often 70% easy), assumes zero quality loss, and uses a baseline of "always the top model", which few teams run. A team already using a mid-tier default sees far less. Vercel's guidance is the most defensible: measure the real share of traffic that moves.

## 4. Practical position

- Plan with ranges only after measuring: eval set, tier pass rates, escalation rate.
- A fair savings claim names the baseline, the mix, the quality metric, the escalation rate and the date of prices.
- The one paper-backed figure (up to 60%, under 1% loss) needs a verifier and a difficulty predictor; it is not what a keyword-rule router delivers.
- Largest dependable levers in the sources, in order of evidence strength: price arithmetic of tiers and caching (checkable), then verifier-gated cascades (paper), then percentages from blogs (unverified).

## How an agent should apply this

- Never repeat a blog percentage as a result; write "claimed by X" or compute from your own logs.
- When asked for expected savings, give a formula with the user's mix and prices, plus an explicit uncertainty note.
- Always state the baseline model the saving is measured against.
- Require an escalation rate and a quality metric next to any savings number.
- Re-check prices and dates; the sources themselves list multiple price changes within months.
