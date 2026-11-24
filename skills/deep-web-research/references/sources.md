# Sources — Deep Web Research

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Pack author's draft protocol (private notes; not a public URL) | read in full | the 4-phase skeleton: decompose with stop criterion and primary-evidence definition, parallel waves, verification triage, saved cited synthesis |
| https://www.aihero.dev/skills-research | 200 OK (WebFetch) | `/research` pattern: background agent reads primary sources, one Markdown file with linked claims; no stop rule; recursive-delegation bug |
| https://github.com/Weizhena/Deep-Research-skills | 200 OK; raw skill files read via GitHub raw | Outline/fields YAML, user confirmation, batched per-item agents, resume, `[uncertain]` tags (MIT) |
| https://medium.com/@skillselion/four-claude-code-deep-research-skills-compared-by-how-they-budget-cite-and-stop-2f51b42ee031 | Blocked: HTTP 403 | Nothing; not read, no content used |
| https://github.com/199-biotechnologies/claude-deep-research-skill | 200 OK; SKILL.md, reference, schemas, scripts read via raw | Modes, claimed caps, claim/evidence/source JSONL ledger, credibility weights, citation scripts (MIT) |
| https://github.com/robertnowell/deep-research | 200 OK; skill and reference files read via raw (SKILL.md under skills/deep-research/) | Source tiers, five hard gates, confidence labels, verifier prompt, NO_USEFUL_FINDINGS (MIT) |
| https://mcpmarket.com/tools/skills/deep-web-researcher | 200 OK via search-page discovery (/tools/skills/search?q=...); summary page only | Multi-wave parallel investigators, temporary Markdown memory, confidence per finding; no caps or stop rules shown; author doodledood |
| https://github.com/sanjay3290/ai-skills | 200 OK; skills/deep-research/SKILL.md read via raw | Delegates to Gemini Deep Research API; claimed 2-10 min, about $2-5; needs GEMINI_API_KEY (Apache-2.0) |
| https://skillselion.com/research-skills | 200 OK but no skill list (machine-access stub); llms-full.txt also fetched | Only generic top-installed skills; no research-specific ranking |
| Firecrawl repository snapshot (AGPL-3.0), local archive, read as text, nothing executed: README.md, AGENTS.md | read OK (README full; AGENTS partially relevant) | feature list, tool surface, robots/terms responsibility statement |
| Firecrawl repository snapshot (AGPL-3.0), path apps/api/src/controllers/v2/types.ts, scrape.ts, map.ts, search.ts, parse.ts | read OK (schemas, defaults, limits, error classes); full scrape/parse bodies skimmed by grep | defaults and limits for search, scrape, map, crawl, extract, agent, parse; error vocabulary |
| Firecrawl repository snapshot (AGPL-3.0), path apps/api/src/lib/deep-research/ (service, manager) and controllers/v1/deep-research.ts | read OK in full (deep-research-redis.ts not read) | deep research loop, parameters, stop conditions, state, reporting |
| Firecrawl repository snapshot (AGPL-3.0), path apps/api/src/lib/generate-llmstxt/generate-llmstxt-service.ts | read OK via targeted grep | llms.txt generation: batches of 10, short title/description, cap 5000 |
| Firecrawl repository snapshot (AGPL-3.0), path apps/api/src/lib/scrape-interact/browser-agent.ts, services/monitoring/types.ts, judgeChange.ts | read OK (partial: first ~200 lines / grep) | interact limits (25 steps), monitor targets and fail-open judge |
| Firecrawl repository snapshot (AGPL-3.0), path skills/firecrawl-build*/ (endpoint-selection, scrape, search, interact, freshness-and-liveness) | read OK | escalation order, freshness vs liveness, index vs category filters |
| Firecrawl repository snapshot (AGPL-3.0), paths firecrawl-cli, firecrawl-cli-skills, firecrawl-skills, firecrawl-workflows | read OK but README stubs only (pointers to external repos) | nothing beyond pointers |
| Firecrawl repository snapshot (AGPL-3.0), path apps/api/openapi.json and apps/api/src/lib/extract/ | NOT read (openapi.json 476 KB skipped; extract only prompt file skimmed) | none |

## Licensing and clean-room note

Firecrawl is AGPL-3.0; this pack is MIT. The Firecrawl material was read as untrusted text and nothing was executed. Only concepts and observable behaviors (what each tool does, its knobs, defaults and limits, its loop structure) were taken and rewritten in our own words, then redesigned into a tool-agnostic contract. No Firecrawl code, prompt text or documentation prose is copied; defaults quoted in `firecrawl-tool-surface-analysis.md` come from one snapshot and must be checked against the live tool. The public research skills read are MIT (Weizhena, 199-biotechnologies, robertnowell) or Apache-2.0 (sanjay3290); their methods are paraphrased and attributed, not copied.

## Reading limits

- The Medium comparison article returned HTTP 403 and was not read; no content from it is used.
- The MCP Market page showed a summary only, so its stop rules and confidence scale are unknown.
- The skillselion page was a machine-access stub with no research-specific skill list.
- Firecrawl: `apps/api/openapi.json` was skipped (476 KB); `apps/api/src/lib/extract/` and `deep-research-redis.ts` were not read; the cli, skills and workflows folders held pointer stubs; several controller bodies were skimmed by targeted search, not read in full.
- Pages were read at one point in time; repositories and vendor tools change.

## Claims not adopted as fact

- All run times, token costs and prices (199-biotechnologies minutes per mode, the 2-10 min and about $2-5 per run for the Gemini-delegating skill) are claims by those repositories, never measured by us.
- The 199-biotechnologies credibility weights and domain lists are a crude prior, not a validated model.
- Agent and source counts per depth mode in the public skills are their design choices; our caps in `SKILL.md` are starting values to calibrate.
- The robertnowell tiers and confidence labels are adopted as working rules, not proven thresholds; the "under about 10% new claims" diminishing-returns heuristic is our own inference.
- The aihero recursive-delegation bug is reported by its author; we guard against it but did not reproduce it.
- Firecrawl defaults (limits, timeouts, step caps) reflect one snapshot.
