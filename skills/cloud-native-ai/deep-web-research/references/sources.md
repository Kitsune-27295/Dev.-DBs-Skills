# Sources — Deep Web Research

Every URL below was checked during skill authoring (2026-11-24) and re-checked on 2026-11-27 where the status column says so.

| Source | Retrieved status | What it contributed |
|---|---|---|
| Pack author's draft protocol (private notes; not a public URL) | read in full | the 4-phase skeleton: decompose with stop criterion and primary-evidence definition, parallel waves, verification triage, saved cited synthesis |
| https://www.aihero.dev/skills-research | 200 OK (WebFetch; re-read 2026-11-27) | `/research` pattern: background agent reads primary sources, one Markdown file with linked claims; no stop rule; recursive-delegation bug |
| https://github.com/Weizhena/Deep-Research-skills | 200 OK (README re-read 2026-11-27; MIT); raw skill files read via GitHub raw | Outline/fields YAML, user confirmation, batched per-item agents, resume, `[uncertain]` tags (MIT) |
| https://medium.com/@skillselion/four-claude-code-deep-research-skills-compared-by-how-they-budget-cite-and-stop-2f51b42ee031 | Blocked: HTTP 403 (again 2026-11-27) | Nothing; not read, no content used |
| https://github.com/199-biotechnologies/claude-deep-research-skill | 200 OK (README re-read 2026-11-27; MIT); SKILL.md, reference, schemas, scripts read via raw | Modes, claimed caps, claim/evidence/source JSONL ledger, credibility weights, citation scripts (MIT) |
| https://github.com/robertnowell/deep-research | 200 OK (README re-read 2026-11-27; MIT); skill and reference files read via raw (SKILL.md under skills/deep-research/) | Source tiers, five hard gates, confidence labels, verifier prompt, NO_USEFUL_FINDINGS (MIT) |
| https://mcpmarket.com/tools/skills/deep-web-researcher | 200 OK 2026-11-27 (direct fetch, summary); earlier via search-page discovery (/tools/skills/search?q=...); summary page only | Multi-wave parallel investigators, temporary Markdown memory, confidence per finding; no caps or stop rules shown; author doodledood |
| https://github.com/sanjay3290/ai-skills | 200 OK (README re-read 2026-11-27; Apache-2.0); skills/deep-research/SKILL.md read via raw | Delegates to Gemini Deep Research API; claimed 2-10 min, about $2-5; needs GEMINI_API_KEY (Apache-2.0) |
| https://skillselion.com/research-skills | 200 OK on 2026-11-24, NOT re-fetched 2026-11-27; but no skill list (machine-access stub); llms-full.txt also fetched | Only generic top-installed skills; no research-specific ranking |
| https://docs.firecrawl.dev/api-reference/endpoint/scrape, /search, /map, /crawl-post | 200 OK (WebFetch, 2026-11-27); scrape page read to 100,000 of 102,568 characters | current defaults and limits of scrape, search, map, crawl |
| https://docs.firecrawl.dev/rate-limits and /billing | 200 OK (2026-11-27) | plan rate limits, concurrent browsers, credit costs per operation, monthly credits; no status code for exhausted credits |
| https://docs.firecrawl.dev/features/interact, /agent, /extract, /parse, /monitoring | 200 OK (2026-11-27) | interact limits and billing, agent parameters and free runs, extract deprecation (removal 2026-12-10), parse limits, monitor targets and schedule |
| https://docs.firecrawl.dev/mcp-server and /mcp-server/tools | 200 OK (2026-11-27) | hosted tool names, keyless set (search, scrape, parse), OAuth and API-key endpoints |
| The Firecrawl tool list exposed in the audit session itself | observed 2026-11-27 | which tool names a real client shows (differs from the docs list: extract present, credit-usage and gov-search absent) |
| https://ifcncodeofprinciples.poynter.org/the-commitments | 200 OK (re-read 2026-11-27 via WebFetch; earlier curl, tags stripped; first 5,000 characters read) | sources principle: identify all significant evidence, prefer primary sources, check key elements against more than one named source, disclose source interests (added 2026-11-24) |
| https://www.gradeworkinggroup.org/ | 200 OK (re-read 2026-11-27 via WebFetch; earlier curl, tags stripped) | certainty graded per outcome in categories (high, moderate, low, very low) (added 2026-11-24) |
| https://training.cochrane.org/handbook/current/chapter-14 | 301 to https://www.cochrane.org/authors/handbooks-and-manuals/handbook/current/chapter-14, which returned 200 (2026-11-27); first 100,000 characters read through a summarizing fetch | cited only as the Cochrane home of GRADE-based summary of findings (added 2026-11-24) |
| Third-party MIT skills fact-check, research-compendium, brain-ingest-gate; vault-template research-with-provenance | read in full or in large part | Third-party skill read for ideas, no text reused (MIT): six confidence levels, producer is not verifier, delivery block, archive then summarize 1:1 then synthesize, local-first stop (added 2026-11-24) |

## Licensing and clean-room note

Firecrawl's server code is AGPL-3.0; this pack is MIT. The 2026-11-27 rebuild uses only Firecrawl's public documentation pages (read as untrusted text, own words, nothing copied). An earlier draft read a local repository snapshot; its facts that the public docs do not confirm were removed: the deep-research loop parameters (depth 7, URL 20, time 300 s), llms.txt generation, the interact 25-step cap and 40k-character snapshot, the monitor judge fail-open default, scrape's silent timeout raises, the 10-URL extract cap and the stealth proxy tier. The public research skills read are MIT (Weizhena, 199-biotechnologies, robertnowell) or Apache-2.0 (sanjay3290); their methods are paraphrased and attributed, not copied.

## Reading limits

- Not reached on 2026-11-27: the skillselion directory page; the repository files behind the research skills (SKILL.md, schemas, scripts: only READMEs were re-read, so the JSONL-ledger and credibility-weight details rest on the 2026-11-24 reading); the last 2,568 characters of the scrape reference page; Firecrawl error catalog, batch-scrape, search-operator and webhook pages; the 99-page remainder of the Cochrane chapter.
- The Medium comparison article returned HTTP 403 and was not read; no content from it is used.
- The MCP Market page gives a summary only: its stop rules and confidence scale are unknown.
- The aihero page summary was re-read; its fix claims are the author's.
- Fetches went through a summarizing tool, so numbers were taken from its extraction of each page, not from raw HTML.
- No scripts, SQL or data files exist in this skill.
- Pages were read at one point in time; Firecrawl docs change often.

## Claims not adopted as fact

- All run times, token costs and prices of other repositories (199-biotechnologies minutes per mode; the 2-10 min and about $2-5 per run of the Gemini-delegating skill) are their claims, never measured by us.
- The 199-biotechnologies credibility weights and domain lists are a crude prior, not a validated model.
- Agent and source counts per depth mode in the public skills are their design choices; our caps in `SKILL.md` are starting values to calibrate.
- The robertnowell tiers and confidence labels are adopted as working rules, not proven thresholds; the "under about 10% new claims" diminishing-returns heuristic is our own inference.
- The aihero recursive-delegation bug is reported by its author; we guard against it but did not reproduce it.
- Firecrawl numbers (defaults, limits, credits, plan tiers, free-run counts) are a dated snapshot and must be re-read from the live tool.
- A 402 status for exhausted Firecrawl credits is not confirmed by the docs read; not adopted.
- IFCN: only the sources commitment was used. GRADE: the page lists categories and domains but not how they combine; our six-level scale is a working mapping to our five labels, not an IFCN or GRADE scale.
