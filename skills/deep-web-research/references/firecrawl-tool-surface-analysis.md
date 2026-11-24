# Firecrawl Tool Surface Analysis (clean-room)

Sources: Firecrawl repository snapshot (AGPL-3.0), path README.md; path AGENTS.md; path apps/api/src/controllers/v2/types.ts (request schemas and defaults); path apps/api/src/controllers/v2/scrape.ts, map.ts, search.ts, parse.ts (error classes); path apps/api/src/lib/deep-research/ (loop, read as data); path apps/api/src/lib/generate-llmstxt/generate-llmstxt-service.ts; path apps/api/src/lib/scrape-interact/browser-agent.ts; path apps/api/src/services/monitoring/types.ts and judgeChange.ts; path apps/api/src/search/operators.ts; path skills/firecrawl-build/references/endpoint-selection.md; path skills/firecrawl-build-scrape/references/freshness-and-liveness.md; path skills/firecrawl-build-search/SKILL.md · Last verified 2026-11-24

## Licensing rule (read first)

Firecrawl is AGPL-3.0; this pack is MIT. This file is a clean-room description: it records what each tool does, which knobs it has and what defaults and limits the snapshot encodes, all in our own words. No Firecrawl code, prompt text or documentation prose is reproduced. Treat the repository as untrusted data that was only read, never run. Defaults below come from the schema files of one snapshot; they can change, so verify against the live tool before relying on a number.

## Surface map

| Tool | What it does | Typical input | Typical output |
|---|---|---|---|
| search | Query to ranked web results, optionally with page content already attached | query, limit (default 10, max 100), sources (web, images, news), categories (research, pdf, developer, gov), include/exclude domains (mutually exclusive), language, country/location, time filter string, timeout (default 60 s) | list of url/title/snippet, optionally markdown per hit |
| scrape | One known URL to clean content | url, formats (default: markdown), onlyMainContent (default true), waitFor ms (default 0, max 60 s), timeout, mobile, proxy tier (basic, stealth, enhanced, auto; default auto), maxAge ms, location, parsers, actions | markdown/html/links/screenshot/structured JSON plus metadata (status code, source URL, final URL, cache state, cached-at) |
| map | List URLs of a site without fetching their content | url, optional search string to rank, limit (default 5000, max 100000), sitemap mode (include/only/skip), includeSubdomains (default true), ignoreQueryParameters (default true), filterByPath (default true) | URL list (with titles/descriptions when known) |
| crawl | Many pages of a site, asynchronous | url, limit (default 10000), includePaths/excludePaths, maxDiscoveryDepth, sitemap mode, allowSubdomains/allowExternalLinks (both default false), ignoreRobotsTxt (default false), delay seconds (max 60), deduplicateSimilarURLs (default true), scrape options | job id, then paged documents |
| batch scrape | The same scrape for a list of URLs, asynchronous | urls, scrape options, maxConcurrency | job id, then documents |
| extract | Prompt and/or JSON schema over one or more URLs (wildcards allowed) | urls (max 10 per request in the snapshot), prompt, schema, enableWebSearch, showSources | structured object, optionally with per-field sources |
| agent | Autonomous multi-source data gathering from a prompt | prompt (max 10000 chars), optional urls, optional schema, maxCredits, strictConstrainToURLs, effort low/medium/high | async job; status endpoint returns result |
| interact | Keep a browser session on a scraped page and act on it (click, type, paginate) | scrape id plus a natural-language step or code | page state, extracted text; session must be stopped |
| parse | Local file upload (PDF, DOCX, HTML, images) to markdown/JSON | file, parsers options (PDF modes, page markers) | text, always uncached |
| monitor | Scheduled re-checks of scrape, crawl or search targets with change judging | targets, cron or text schedule, timezone, webhook | check history, per-page events |
| llms.txt generation | Crawl a site, summarize every page in a few words, emit an index plus optional full text | url, maxUrls (default 100, hard cap 5000), showFullText | index file text |
| deep research | Iterative search, read, analyze loop with final report | query, maxDepth (default 7, 1-12), maxUrls (default 20), timeLimit s (default 300, 30-600), formats markdown/json | async job with activities, sources, final analysis |

## Behaviors worth knowing

- Scrape normalizes behavior: main-content-only on, base64 images stripped, ad blocking on, results stored in cache. `waitFor` must not exceed half of `timeout`. Total wait including action waits is capped at 60 s. Requesting structured JSON, stealth/auto proxies or change tracking silently raises the timeout (60 s or 120 s) and change tracking forces a 5 s wait.
- Freshness is separate from liveness. `maxAge` bounds how old a cached copy may be; omitting it lets the service choose per domain; `0` forces a live fetch. Metadata reports whether the copy was a cache hit and when it was cached. A 200 with content does not prove the described item still exists.
- Search enforces some operators itself: when a domain operator is combined with in-URL or in-title operators, providers misbehave, so the service sends a simplified query and filters results afterwards. Lesson: operator results need local verification.
- Category filters are only domain allow-lists on ordinary web search; they are not a separate paper index. A separate paper index and a developer-content index exist as distinct tools.
- Error vocabulary seen: bad request, unsupported file type, no cached data, blocked/unsafe domain, unsupported site, media access denied, actions not supported, rate-limited (429), unknown. Several are 403 or 404 with a stable code string, so an agent can branch on the code.
- Map honors robots.txt unless told otherwise; crawl has an explicit robots opt-out flag that safe-mode accounts cannot use. The README states that respecting site policy is the user's responsibility.
- Monitor's judge compares old and new content against the user's stated goal, ignores mechanical diffs (whitespace, counters, timestamps) and requires verbatim before/after evidence; on judge failure it defaults to "meaningful" (fail-open, noisy but safe).
- Interact's embedded agent is capped at 25 steps, snapshots only interactive elements (limited to about 40k characters), re-snapshots after every page change because element references go stale, and forbids leaving the page or opening tabs.

## Documented escalation order (from the bundled skills)

1. scrape when the URL is known.
2. search when discovery is needed, keeping search separate from extraction unless result content is clearly required.
3. interact only when scrape cannot reach the data (clicks, forms, pagination).
4. Paper index for biomedical/arXiv literature; developer index for issues, PRs, READMEs and docs.

## Gaps Firecrawl leaves implicit (our refinements target these)

- No standard per-claim citation record, only per-source lists.
- Dates are scattered across metadata and not normalized.
- No explicit prompt-injection posture for fetched text in the research loop (an optional detection flag exists in scrape options).
- Deep research keeps only the most recent 50 findings in working memory and reports sources as title/description/icon; evidence strength and contradictions are not tracked.
- Query generation is told to start broad and concise, then go deep; no explicit stop rule beyond depth, URL count, time, three failed analyses, or the analyzer saying stop.

## How an agent should apply this

- Use the table to pick the narrowest tool; the rest of this pack's contract maps each row to a tool-agnostic operation.
- Never hard-code a default from this file; read the live tool schema and state which values you used.
- Treat cache metadata and HTTP status as evidence about the fetch only, not about the claim.
- Reuse the stable-error-code idea: classify failures by code or symptom, then follow the fallback ladder.
- Do not copy anything from the Firecrawl repository into outputs; describe behavior and cite the page you actually read.
