# Sources — Model & Effort Routing

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.anthropic.com/research/building-effective-agents | 200 OK (WebFetch) | Workflow vs agent definition; five workflow patterns, autonomous agents, simplicity/transparency/ACI principles, tool-design advice, model-tiering example in routing |
| https://resources.anthropic.com/hubfs/Building%20Effective%20AI%20Agents-%20Architecture%20Patterns%20and%20Implementation%20Frameworks.pdf | 200 OK (curl + pdftotext, 29 pages) | Single vs multi-agent, centralized vs decentralized, sequential/parallel/evaluator patterns, decision framework, hybrids, 10-15x token claim, 90.2% internal multi-agent claim |
| https://resources.anthropic.com/building-effective-ai-agents | 200 OK, gated landing page only (no guidance text) | Confirms the PDF's scope: architectures, patterns, decision framework, context management, Skills |
| https://thinking.inc/en/blue-ocean/agentic/agent-orchestration-patterns/ | 200 OK (WebFetch) | Six orchestration topologies, failure modes, router/confidence fallback, decision table, monitoring thresholds; vendor figures are claims |
| https://github.com/machinedge/building-effective-agents/blob/main/building-effective-agents.md | github.com page 503; read via raw.githubusercontent.com variant (first ~100k of 216k chars; no license visible) | Complexity ladder, cost/latency heuristics (illustrative), guardrail/stop rules, role taxonomy, protocol notes |
| https://www.kosmoy.com/resources/blog/what-is-ai-orchestration/ | 200 OK (WebFetch), vendor blog | Control-plane components (gateway, registry, sandbox), MCP/A2A governance argument, governance recommendations |
| https://developers.openai.com/api/docs/guides/reasoning | 200 OK (read via WebFetch summarizer; Firecrawl out of credits) | Effort values none..max (model-dependent), GPT-6 restrictions, medium defaults, max_output_tokens/25k reserve, reasoning-token billing, `configuration_update` (exists; GPT-6+) |
| https://reference.langchain.com/python/langchain-openai/chat_models/base/BaseChatOpenAI/reasoning_effort | 200 OK (WebFetch summarizer) | reasoning_effort values minimal/low/medium/high, default None; confirms `configuration_update` and cache-invalidation note |
| https://platform.claude.com/docs/en/build-with-claude/effort | 200 OK (WebFetch; read in full) | Exact levels, per-model availability and defaults (medium on Opus 5.5/Haiku 5.5, else high), thinking interplay, cache guidance |
| https://platform.claude.com/docs/en/build-with-claude/effort-per-message | 200 OK (extra page) | Per-message effort via system message + beta header, constraints, errors |
| https://code.claude.com/docs/en/model-config | 200 OK (extra page; first 100k of 134k chars read) | Claude Code effort levels, resolution order, persistence, ultrathink, skill/subagent effort scope |
| https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | 200 OK | name/description limits, 500-line body, progressive disclosure, test on Haiku/Sonnet/Opus |
| https://code.claude.com/docs/en/skills | 200 OK (first 100k of ~120k chars read) | Full frontmatter field table, scope/duration, 1,536-char listing cap, compaction budget, portability limits |
| https://code.claude.com/docs/pt/best-practices | 200 OK (Portuguese; read via saved output + grep) | Effort guidance, ultrathink, subagent cost, cache lifetime, think-hard phrases are plain text |
| https://blog.aifetchly.com/test-time-compute-scaling-modern-llm-reasoning-guide/ | 200 OK (secondary, low trust) | Claims on overthinking and 2048-token cap; numbers uncited, internally inconsistent |
| https://www.cubic.dev/blog/claude-code-skills | 200 OK (secondary, low trust) | Corroborates frontmatter fields and limits; vendor benchmark claims not used |
| https://neuraltrust.ai/blog/claude-code-skills | 200 OK (secondary, low trust) | Corroborates portability limits; security claims are vendor claims, not used as fact |
| https://www.zently.com.br/blog/melhores-skills-claude-code-2026-guia-completo | 200 OK (secondary, low trust) | Only name/description; no model/effort content; marketing numbers not used |
| https://ai.blocksize.hr/blog/en/ai-model-routing-cost-optimization-2026 | 200 OK via WebFetch summary (Firecrawl had no credits) | Cascade / predictive / semantic routing; illustrative 55/30/15 tier table; claimed 40-70% savings; never-fail-silently rule; router overhead and misrouting caveats |
| https://www.developersdigest.tech/blog/model-routing-strategies-cost-effective-coding-2026 | 200 OK via WebFetch summary | Four routing strategies, task-to-tier map, team-profile savings claims (unsourced), volume thresholds, when routing does not pay; internal inconsistencies |
| https://vercel.com/i/llm-routing-strategies | 200 OK via WebFetch summary | Six-strategy taxonomy, retries/fallbacks/circuit-breakers separation, budget-ceiling policies; vendor-authored; no savings figures |
| https://acceleraid.ai/en/blog/ai-models-2026-cost-vs-skills-comparison | 200 OK via WebFetch summary | Tiered pricing context, cost-per-task and agent token mechanics, caching arithmetic, three work-split rules; vendor blog |
| https://routllm.pro/docs | 200 OK via WebFetch summary | Gateway docs only: explicit model slugs, 5h/7d spend windows with HTTP 429; no automatic routing described |
| https://openreview.net/forum?id=tFBIbCVXkG | Blocked (browser-verification page; api2 also redirected); not read | Nothing; do not cite |
| https://www.microsoft.com/en-us/research/publication/best-route-adaptive-llm-routing-with-test-time-optimal-compute/ | 200 OK via WebFetch (abstract only) | BEST-Route (arXiv 2506.22716): route to (model, n samples); up to 60% cost cut with under 1% quality drop |
| https://arxiv.org/html/2610.04751v1 | 200 OK (exists) but off-topic: layer-level dynamic routing inside one model; first 100k of 130k chars read | Confidence-arbitrated compute selection; oracle gap (0.816 vs 0.712 MMLU); not model routing |
| https://github.com/ThreeSR/Awesome-Inference-Time-Scaling | 200 OK via WebFetch; first 200k of 300k chars read | Paper index only: CATTS-style "Agentic Test-Time Scaling for WebAgents", TUMIX, OptScale, PUMA, budget-aware tool use, verifier/selection papers; no routing entry in the part read |
| https://github.com/Getty/skills/blob/main/claude/model-routing/SKILL.md | 200 OK (raw.githubusercontent.com); repo has a LICENSE file (Artistic License 2.0) | Four-tier ladder, six difficulty dimensions (route by worst one, not size), sandwich pattern, escalate-with-failed-attempt rule, effort as second dial, role sizing, inherit-by-default |
| https://github.com/masskrdjn/claudeskills (quota-orchestrator SKILL.md, README.md, .claude/settings.json) | 200 OK via raw files; repo marked deprecated in favor of a successor repo; no LICENSE file found (404) | Role/model/effort table, root-only routing, delegation break-even, loop bounds, consultation budget, premium-model access check and consent rule, identity attestation, whole-job cost and complete-measurement gate |
| https://github.com/softspark/ai-toolkit/blob/main/app/skills/model-routing-patterns/SKILL.md | 200 OK (raw) | Policy-not-ratios stance, validation-based escalation, resilience fallback rules, cache effect of effort changes, Codex executor supervision, measurement fields |
| https://github.com/vishalsachdev/claude-skills (allocate-agent-models/SKILL.md) | 200 OK (raw); OpenAI-model scope only, says Anthropic routing is out of scope | Risk-factor classification, accuracy-first down-routing, environment vs substantive failure, 2-then-3 failure rule, fallback order, independent review, announcement record |
| https://github.com/skills-directory/skill-codex (plugins/skill-codex/skills/codex/SKILL.md) | 200 OK (raw) | External CLI delegation: model plus effort prompt, least-privilege sandbox, stdin and timeout gotchas, effort-based timeouts, treat the other model as a colleague |
| https://github.com/DeL-TaiseiOzaki/claude-code-orchestra/blob/main/.claude/skills/team-execute/SKILL.md | 200 OK (raw); repo has MIT LICENSE | Sonnet default, Opus escalation criteria, file-ownership preflight and reconcile, lead re-runs verify, no hook-enforced gates |
| https://github.com/pedrohcgs/claude-code-my-workflow/blob/main/.claude/rules/model-routing.md | 200 OK (raw); repo has MIT LICENSE | Per-agent tier map with 70/20/10 claim, effort-first lever, Fable kept out of the fleet, do-not-demote gates, challenger vs auditor tier rule |
| https://github.com/imbad0202/academic-research-skills (README.md plus shared/model_tiering.md, one extra page) | 200 OK (raw); CC BY-NC 4.0 | Opt-in economy and quality-boost tiering, relative tiers never hard-pinned, fail-open no-op notices, judgment vs execution classification, declared-vs-served model gap |
| https://github.com/owid/skills/blob/main/FAQ.md | 200 OK (raw); read in full | Only measurement found: at `--effort low` five skill-triggering questions got no skill call on Claude Code; authors state other agents are unmeasured |
| https://antigravity.google/docs/skills/ | 200 OK (via WebFetch; Firecrawl had 0 credits) | Official install paths (.agents/skills, ~/.gemini/config/skills, CLI extras), frontmatter = name + description only, no model/effort field, loading and /skills reload |
| https://codelabs.developers.google.com/getting-started-with-antigravity-skills | 200 OK (WebFetch) | Folder layout, description as trigger, 4 example skills, npx skills / agents-cli path caveats |
| https://github.com/sickn33/agentic-awesome-skills | 200 OK (WebFetch; first 100k of 158k chars read) | Per-harness install targets, bundles, AAS Core, licenses |
| https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/subagent-orchestrator/SKILL.md | github.com blob 503; read via raw.githubusercontent.com variant | 6-phase quota-aware orchestration, tier rules, guardrails |
| https://github.com/wahidzzz/antigravity-skill-orchestrator | 200 OK (WebFetch) | Complexity-assessment meta-skill concept; no thresholds shown |
| https://github.com/Sora-bluesky/antigravity-orchestra | 200 OK; docs/delegation-triggers.md 503, used .agents/rules/delegation-triggers.md via raw | Trigger-based delegation flow and keywords |
| https://github.com/rmyndharis/antigravity-skills | 200 OK (WebFetch) | Install paths, AG_SKILLS_DIR, validator rules, bundles |
| https://github.com/google-deepmind/science-skills | 200 OK (WebFetch) | Plugin vs custom path advice; no frontmatter/routing info |
| https://github.com/topics/antigravity-skills | 200 OK (WebFetch) | No true router listed; low value |
| https://github.com/haowjy/orchestrate | 200 OK (WebFetch) | Harness routing by model name, effort variant mapping, security warning |
| https://github.com/eric861129/Workflow-skill-router | 200 OK (WebFetch) | Phased routing, profile precedence, fail-closed boundaries |
| https://github.com/orchestra-research/AI-research-SKILLs | 200 OK (WebFetch) | Autoresearch phase router, installer behavior |
| https://github.com/tiagopgr/skills-ia | 200 OK (WebFetch) | Prompt library; no routing content |
| Local operating practice (private notes, summarized; not a public URL): tiering policy and tier tool (policy file + README) | Read locally | Five work-weight tiers (gather/build/reason/orchestrate/style) with model and effort and rationale; skill-to-tier mapping; check/apply tooling; five limits of skill header model/effort lines; illustrative prices (2026-11) |
| Local operating practice (private notes, summarized; not a public URL): token-cost discipline procedure | Read locally | Per-agent-call model/effort rules, research-skill caps, always-loaded size budget (~4 KB), safe-shortening procedure, subagent-model env var precedence change, measure-don't-assume baseline (6% named a model) |
| Local operating practice (private notes, summarized; not a public URL): pre-tool agent-model guard hook (skimmed) | Read locally | Fail-open guard that denies untyped/built-in agent launches lacking `model`; one-shot retry; guarded-type set |
| Local operating practice (private notes, summarized; not a public URL): agent-launch report script (skimmed) | Read locally | Transcript walk counting launches by type and model, de-duplication by call id, `--since` windows, named-share metric |
| https://antigravity.google/docs/models.md | 200 OK (WebFetch; /docs itself is a redirect stub) | Selector-based model choice, plan-dependent limits, scheduled removals (added 2026-11-24) |
| https://www.anthropic.com/engineering/multi-agent-research-system | 200 OK (WebFetch) | Brief contents, effort scaling, context isolation, poor-fit cases, token-cost claims (added 2026-11-24) |
| https://code.claude.com/docs/en/sub-agents | 200 OK (WebFetch, first 100k of 115k chars) | Fresh context, model resolution order, subagents vs main conversation, shared usage limits (added 2026-11-24) |
| https://www.anthropic.com/engineering/building-effective-agents | 200 OK (WebFetch) | Orchestrator-workers, parallelization, simplicity rule (added 2026-11-24) |
| Third-party skills read for ideas, no text reused (a built-in routing skill; two MIT plugin skills on subagent development and parallel dispatch; an MIT coordinator skill) | Read locally | Availability states, review order, ruling ledger, orchestrator plus wiki (added 2026-11-24) |

## Reading limits

- Most vendor and blog pages were read through WebFetch summarizers; Firecrawl had no credits, so wording is paraphrased second-hand and figures are second-hand.
- Several pages were read only in part (machinedge guide about 100k of 216k chars; Claude Code skills page about 100k of 120k; model-config 100k of 134k; arXiv 2610.04751 100k of 130k; Awesome-Inference-Time-Scaling 200k of 300k; agentic-awesome-skills 100k of 158k). The Microsoft BEST-Route page gave the abstract only.
- Unreadable or unusable: the OpenReview forum page (browser verification, not read); the gated Anthropic landing page (no guidance text); arXiv 2610.04751 exists but concerns layer routing inside one model, not model routing; github.com blob pages that returned 503 were read through raw.githubusercontent.com.
- Local operating-practice rows are private notes summarized without any public URL; their prices and baselines are dated and unmeasured beyond what each note states.

## Claims not adopted as fact

- Blog savings ranges (40-70%, 40-60% solo, 60-80% team, 80-95% CI/CD, 50-80% on a mechanical tier) and the 55/30/15 and 70/20/10 splits: unsupported or illustrative; the sources are inconsistent with their own tables.
- Router overhead figures (0.5-2 s, about $0.001 per classification, under 1% of cost), misroute rates and alert thresholds (95% routing, 5% handoff, 25% overhead): vendor suggestions, not benchmarks.
- Multiplier tables (agent about 4x, multi-agent about 15x or 10-15x tokens, 50-1000x autonomous): vendor or third-party claims; the 90.2% multi-agent figure is an internal vendor claim, not independently verified.
- BEST-Route "up to 60% cost reduction with under 1% drop": a peak abstract figure, not replicated here.
- Thinking cap near 2048 tokens (aifetchly blog): uncited, treated as a hypothesis only.
- Fable price multiple over Opus (2x in one repo, 2.5x in another): sources disagree; check the vendor price page.
- Per-agent tier maps and effort starting points from community repos: author opinion tied to their own workloads; none is a vendor recommendation.
- Local baseline (60 of 999 built-in launches named a model): one machine, one date; and documented skill-header behaviors were not locally measured.
