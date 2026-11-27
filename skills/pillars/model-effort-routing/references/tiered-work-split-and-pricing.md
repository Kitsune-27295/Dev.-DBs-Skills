# Tiered Work Split and Pricing Context

Sources: https://www.developersdigest.tech/blog/model-routing-strategies-cost-effective-coding-2026 · https://ai.blocksize.hr/blog/en/ai-model-routing-cost-optimization-2026 · https://acceleraid.ai/en/blog/ai-models-2026-cost-vs-skills-comparison · Last verified 2026-11-23

Reading note: read via a WebFetch summarizer; the pages are vendor/marketing blogs. Prices below are as those pages reported them, are volatile, and must be re-checked against the provider's own price page before use. The two price lists disagree with each other (different dates, different model generations), which itself shows how fast they go stale.

## 1. Tier tables as published

Blocksize (illustrative, no measured basis): trivial work (classify, extract, short rewrite) about 55% of calls to a small model at 1x; moderate (summaries, routine Q&A, drafts) about 30% to a mid model at about 5x; hard (multi-step reasoning, long code, judgment) about 15% to a frontier model at about 25x. Its charts are labeled illustrative.

DevelopersDigest (Aug 2026 prices): Frontier tier at $10/$50 and $4/$20 per MTok; High $5/$25; Mid $2/$10 to $3/$15; Low $0.20/$1.20 to $1/$5; Budget DeepSeek off-peak $0.22/$0.66 to $0.66/$1.98. Task mapping: simple (file reads, search, linting) to Low/Budget; medium (tests, refactors, handlers, style review) to Mid; complex (race conditions, schema design, core rewrites, planning) to High; frontier (novel algorithms, security audits, multi-agent coordination) to Frontier. It says the mapping is directional, from published benchmarks and experience, not controlled tests.

ACCELERAID (12 Nov 2026 list prices): Top $8-10 in / $40-50 out; Flagship $2-4 / $10-20; All-rounder $1-2 / $5-10; Budget $0.10 / $0.50. Its rules: use the flagship for visible output (decks, key documents, code), cheaper models for research, minutes and intermediate steps; reserve top models for long migrations, complex financial models and critical templates; collect raw data cheaply, pass only the reviewed structure up; turn on caching.

## 2. What is consistent across sources

- Work is split by task difficulty and by stakes of the output, not by user.
- Delegate gathering, listing, linting, triage and classification down; keep planning, design, security review and final synthesis up.
- Input price spread across tiers is roughly one to two orders of magnitude (Vercel: "an order of magnitude"; Blocksize: 10-30x per token between frontier and a capable small model; DevelopersDigest arithmetic: about 45x input / 76x output between its top and cheapest listed model).
- Output tokens cost several times input (ACCELERAID: about 5x at major providers), and thinking tokens are billed as output.

## 3. Cost mechanics that change the split

- Agents resend context each step (ACCELERAID: 20 steps at 50k context reads 1M input tokens), so cost scales with steps x context. ACCELERAID claims agents use about 4x chat tokens and multi-agent about 15x (third-party-attributed, unverified).
- Prompt caching on repeated context is a larger lever than model choice in ACCELERAID's worked example (a $468 agent run falling to about $83 at 90% cache hits, i.e. about 80%): their arithmetic, plausible given a 90-97.5% cache-read discount, but dependent on their price assumptions.
- Tokenizer differences change real cost: ACCELERAID says one vendor's newer tokenizer emits about 30% more tokens for the same text (unverified here).
- Peak/off-peak and batch pricing (DeepSeek peak doubling, batch/flex at half price per the sources) favor scheduling bulk work.
- Clearer briefs that reduce feedback rounds often save more than a cheaper model (ACCELERAID opinion).

## 4. Worked mini-example (our arithmetic, not from a source)

Per 100k input + 20k output with prices $4/$20 (flagship) vs $0.10/$0.50 (budget): flagship 0.4+0.4 = $0.80; budget 0.01+0.01 = $0.02. If 60% of calls are budget-suitable, 30% mid ($1/$5 -> $0.20), 10% flagship: 0.6x0.02+0.3x0.20+0.1x0.80 = $0.152, about 81% below all-flagship, before any failed-attempt retries or quality losses. Add retries: if 10% of budget calls escalate, add 0.06x0.80 = $0.048 -> $0.20, still about 75% lower. Real savings depend on the true mix.

## How an agent should apply this

- Classify steps (gather / transform / judge / final output) and map each to a tier; keep the table in config, not prose.
- Pull current prices from the provider at runtime or a dated config; never hard-code figures from blog posts.
- Optimize caching and context size before adding more tiers; they often dominate.
- Reserve the top tier for planning, review of cheap-tier output, and irreversible or security-relevant work.
- Budget with output and thinking tokens, not only input.
