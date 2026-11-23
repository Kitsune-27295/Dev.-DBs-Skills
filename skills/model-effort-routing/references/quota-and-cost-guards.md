# Quota and Cost Guards

Sources: https://github.com/masskrdjn/claudeskills (.claude/skills/quota-orchestrator/SKILL.md, README.md, .claude/settings.json) · https://github.com/pedrohcgs/claude-code-my-workflow/blob/main/.claude/rules/model-routing.md · https://github.com/Getty/skills/blob/main/claude/model-routing/SKILL.md · https://github.com/softspark/ai-toolkit/blob/main/app/skills/model-routing-patterns/SKILL.md · https://github.com/imbad0202/academic-research-skills (shared/model_tiering.md) · https://github.com/skills-directory/skill-codex · Last verified 2026-11-23

Prices below are quoted as each repo dated them (October to November 2026); they change. Savings percentages are claims by the author named, not measurements of yours.

## 1. What masskrdjn's guard actually does (most developed example)

The repo is marked deprecated in favour of a successor repo (QuotaOrchestrator), but its skill is the most explicit cost-guard text found.

- **Objective order**: quality and relevance first, then total cost, then latency, under a constraint on access to the expensive tier. Never lower acceptance criteria to make a cheaper model viable.
- **Whole-job cost**: compare launch, context, execution, waiting, integration and rework across all agents including the root, weighted by input / cache / output prices. More tokens on a cheaper tier is a good trade while quality and latency hold. Without measurement, state an expected gain, not a demonstrated one.
- **Measurement gate**: an economic comparison requires a report with `Complete = true`; an incomplete run has the status "not observable" and must never feed a ratio, median or recommendation. Fewer than two complete runs means no economic comparison is possible. A project script reports tokens, duration and dollar cost by model, effort and role from transcripts, and flags unknown models or cache writes.
- **Delegation break-even**: do not spawn a child then wait if doing the small batch directly is cheaper; the named runner role needs a concrete announced benefit (root free while waiting, large output kept out of root context, or verdict-only) beyond a frozen tree, a 3-plus command or roughly 2-minute matrix, or disjoint parallel work.
- **Consultation budget** for the expensive advisor: zero by default, one initial call, at most two per standard task, announce remaining budget; a second call needs new facts or a surviving technical contradiction; beyond that ask for a new budget. Envelope about 60 lines (a goal, not a cap; never drop decisive evidence).
- **Top-tier access check** (masskrdjn, Claude Code specific): presume the premium model (Fable) unavailable by default; decide from `claude auth status --json` and `claude --version` in a fixed order (explicit `availableModels` setting wins; old CLI, not logged in, third-party provider, free plan each mean unavailable or undeterminable; API-key billing means full access; paid subscription plans mean available but likely billed as extra usage credits; unknown plan value: ask). **Available is not authorized**: ask once before the first premium call, naming plan and surcharge (the repo quotes 10/50 vs 4/20 USD per MTok, i.e. 2.5x Opus 5.5), record the answer in local settings. In non-interactive (`-p`) and SDK runs Claude Code charges without asking, so never escalate to the premium model there without prior explicit authorization.
- **Settings**: `effortLevel` plus per-model `modelSettings` in `.claude/settings.json`; plugin installs do not load that file, so copy the keys by hand.

## 2. Other repos' cost levers

| Source | Lever | Status |
|---|---|---|
| pedrohcgs | Effort before tier; `maxEffortLevel` caps every surface "on a fixed grant budget"; `workflowSizeGuideline` caps fan-out for repo-scale autonomous runs; drop effort, then tier, never the reverse | Author opinion; concrete flags are Claude Code settings, verify in current docs |
| pedrohcgs | "50-80% cost reduction with no quality loss on the mechanical tier" | Claim by the author; no data shown |
| pedrohcgs | Cache TTL change (5-min default; subscriptions get 1 hour, API keys opt in) makes multi-turn pipelines pricier | Author's account of a vendor change; verify in vendor docs |
| Getty | Sandwich: strong model writes the spec, cheap model runs volume, strong model verifies, so most tokens are cheap | Reasoning, no figures; price table Haiku 0.10/0.50, Sonnet 2/10, Opus 4/20, Fable 8/40 USD per MTok as of 2026-11 per the repo |
| ARS | Opt-in `ARS_MODEL_TIERING` (`economy`/`quality-boost`); cites an external write-up (Lance Martin, 2026-07-10) for an advisor-checkpoint setup reaching ~90% of frontier-solo quality at ~34% of tokens; the repo itself notes this came from ML-tuning tasks and may not transfer | Secondary claim, caveated by the repo; "delegation pays only when workers absorb enough tokens to offset handoff cost" |
| ARS | Repo estimates roughly US$3-7 for a full 15k-word pipeline at 2026-09 list prices | Author estimate |
| softspark | Refuses universal ratios and thresholds; "more agents do not inherently save tokens"; measure model ID, effort, policy version, attempts, latency, cache reads/writes and billable tokens, with held-out quality per task type | Method, not numbers |
| softspark | Changing top-level `output_config.effort` can invalidate prompt-cache blocks; sending the model default equals omitting it; a per-message update preserves the prefix | Cites vendor effort and caching docs; verify there |
| softspark | Add a classifier call only when measured routing savings exceed its own latency and token cost | Rule |
| skill-codex | Reasoning effort `ultra` adds automatic delegation and is "slowest and most expensive"; background timeouts scale with effort (low 150 s up to max/ultra 1800 s); an unsupported effort falls back to the model's highest and the user is told; default `high` | OpenAI Codex CLI, not Claude; the effort-to-timeout table is the author's own |

## 3. Where they disagree

- **Cost evidence**: masskrdjn and softspark refuse to cite savings without complete measurement; pedrohcgs and ARS publish ranges. Prefer the first stance when writing a rule an agent must obey.
- **Retry as a cost guard**: masskrdjn caps loops per role and bans identical retries; Vishal counts only substantive failures; softspark defers to the SDK's own retry policy. All three agree that unbounded loops are the real cost risk.
- **Fan-out**: pedrohcgs caps with a setting; masskrdjn requires break-even per delegation; orchestra just targets 5-6 tasks per teammate and warns that coordination can exceed benefit.

## How an agent should apply this

- Before delegating, write the one-line benefit (freed root, kept output out of context, verdict-only); if none applies, do it inline.
- Cap loops: a retry budget per role (about 2-3), no identical third attempt, and a consultation budget for the expensive advisor.
- Treat "available" premium access as not authorized; ask once, record the answer, and never escalate to it in headless runs without prior consent.
- Report savings only from complete measurements; otherwise label them expected.
- Change effort first, tier second, and remember an effort change can invalidate prompt caches.
