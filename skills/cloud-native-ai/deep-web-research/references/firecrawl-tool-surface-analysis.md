# Firecrawl Tool Surface Analysis

Sources: Firecrawl public documentation pages read 2026-11-27 (docs.firecrawl.dev: api-reference/endpoint/scrape, search, map, crawl-post; rate-limits; billing; features/interact, agent, extract, parse, monitoring; mcp-server and mcp-server/tools). Written in our own words; no code or prose copied · Last verified 2026-11-27

## Read this first: what decays

Tool names, defaults, limits, plan tiers and credit prices below are a dated snapshot (2026-11-27). Firecrawl renames and retires things: the extract endpoint is deprecated, a GitHub-only search category was removed, and older Spark model names now route to spark-2. Before relying on any number, read the live tool schema in the session and state the values you used. Here the numbers are for planning only.

Licensing: Firecrawl's server code is AGPL-3.0 and this pack is MIT. This file rests on the public documentation only. Facts from an earlier repository-snapshot draft that the docs do not confirm were dropped (see `sources.md`).

## Surface map (hosted MCP tool names)

| Tool | What it does | Key knobs and limits (docs, 2026-11-27) |
|---|---|---|
| `firecrawl_search` | Query to ranked results, optionally with page content | limit default 10, max 100 (per source type); sources web, images, news; categories developer, gov, research, pdf (developer and gov must be the only entry; a github category now returns 400); tbs time filter (qdr:h/d/w/m/y, custom range, sort by date); timeout default 60 s |
| `firecrawl_scrape` | One known URL to clean content or structured JSON | formats default markdown; onlyMainContent true; waitFor default 0, max 60 s; timeout default 60 s, max 300 s; maxAge default 2 days (capped at 7 days); proxy basic, enhanced or auto (default auto); actions exist, but the docs steer complex interaction to interact |
| `firecrawl_map` | List a site's URLs without reading them | limit default 5000, max 100000; sitemap include (default), only or skip; includeSubdomains true; optional search string ranks results |
| `firecrawl_crawl`, `firecrawl_check_crawl_status` | Many pages, asynchronous job, then poll | limit default 10000; includePaths and excludePaths (RE2-style regex, up to 1000 patterns); maxDiscoveryDepth; delay forces concurrency 1; ignoreRobotsTxt enterprise-only; allowExternalLinks false (one hop) |
| `firecrawl_agent`, `firecrawl_agent_status` | Autonomous multi-source gathering from a prompt, optional urls and schema | prompt max 10,000 chars; maxCredits default 2,500 (credit_limit_reached returns no data; failed runs not billed); 5 free runs per day; API results kept 24 h; about 150-200 rows per run |
| `firecrawl_interact`, `firecrawl_interact_stop` | Act on a live page after a scrape (click, type, paginate, run code) | prompt max 10,000 chars, code max 100,000; timeout default 30 s (1-300); session TTL default 10 min, inactivity 5 min; stop it explicitly |
| `firecrawl_parse` | Local file (PDF, Office, HTML, EPUB, CSV and more) to markdown or JSON | 50 MB per request; timeout default 30 s, max 300 s; PDF modes auto, fast, ocr; browser-only options unsupported |
| `firecrawl_monitor_*` | Scheduled re-checks of scrape, crawl or search targets | 1-50 targets per monitor; minimum interval 5 minutes; a goal turns on change judging; history 30 days by default (max 365) |
| `firecrawl_research_*`, `firecrawl_developer_search`, `firecrawl_gov_search` | Separate indexes: papers (search, inspect, read, related), developer content, statutes and opinions | account-gated; own per-minute and daily limits |
| `firecrawl_credit_usage`, `firecrawl_search_feedback`, `firecrawl_feedback` | Credit check and quality feedback | account-gated |

A client may expose only part of this list. The session used for this check showed search, scrape, map, crawl, agent, interact, parse, monitor, research and developer tools, plus an extract tool that the docs call deprecated, and no credit-usage or gov-search tool. List the tools you actually have; do not assume the table.

- Extract: deprecated, removal announced for 2026-12-10. Use scrape with a JSON format for one page, agent for multi-page or web-search extraction.
- Keyless use (no account) exposes only search, scrape and parse, within daily per-IP request and credit caps. The rest needs OAuth sign-in or an API key.

## Credits and rate limits

- Credits: scrape 1 per page; crawl 1 per page plus scrape-option costs; map 1 per call; search 2 per 10 results rounded up plus scraped content; JSON format +4 per page; enhanced proxy same as basic; PDF parse +1 per PDF page; interact 2 credits per session minute (code only) or 7 (with AI prompts); a scrape that returns a document is charged even for a 403 or 404.
- Monthly credits: Free 1,000 (no rollover), Hobby 5,000, Standard 100,000, Growth 500,000, Scale 1,000,000, Enterprise custom.
- Requests per minute per team, scrape/map/search: Free 10, Hobby 100, Standard 500, Growth 5,000, Scale 10,000. Crawl and agent: 2, 20, 100, 1,000, 2,000. Concurrent browsers: 2, 5, 25, 50, 100+. Extract shares agent limits; batch scrape shares crawl limits.
- A 429 covers per-minute limits, a full queue, the browser cap, index limits and keyless daily caps. The docs page read gives no status code for exhausted credits.

## Behaviors worth knowing

- Freshness is not liveness: maxAge bounds cache age, and a cached 200 does not prove the described item still exists. Force a live read for volatile facts and record the cache state.
- The search tbs filter narrows by time but does not verify a page's own date.
- Category filters narrow ordinary web results; paper, developer and government content live in separate index tools.
- Monitor judging weighs changes against your stated goal, so write the goal precisely.
- Crawl is costly and robots-bound: scope it with paths and a page cap, and justify it.

## Escalation order

1. scrape when the URL is known. 2. search for discovery. 3. map to find a page inside a known site. 4. interact only when scrape cannot reach the data. 5. a paper or developer index for literature and code questions. 6. agent only when the user accepts its variable cost (set maxCredits).

## Gaps Firecrawl leaves implicit (our refinements target these)

- No per-claim citation record; dates are scattered across metadata.
- No prompt-injection posture for fetched text.
- No evidence strength or contradiction tracking in agent output.

## How an agent should apply this

- List your live tools first, then map each needed operation to the narrowest tool.
- Never hard-code a default from this file; state the values you used from the live schema.
- Treat cache metadata and HTTP status as evidence about the fetch only, not about the claim.
- Classify failures by code or symptom, then follow `tool-selection-and-fallback-ladder.md`.
- Cap agent and crawl spend (maxCredits, limit) and report credits used.
