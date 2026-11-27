# Tool Selection and Fallback Ladder

Sources: Firecrawl public docs read 2026-11-27 (rate-limits, billing, scrape, search, map, crawl, mcp-server pages), summarized in `firecrawl-tool-surface-analysis.md`; ladder design is our own. Clean-room, no code or prose copied · Last verified 2026-11-27

## The ladder

| Tier | Tool set | Use when | Strengths | Weaknesses |
|---|---|---|---|---|
| 1 | Firecrawl (MCP or CLI), only if present and credited; keyless access covers only search, scrape and parse | JS-heavy pages, many pages, structured output, PDFs, cached speed, interact | rendering, proxies, formats, map/crawl, paper and developer indexes | credits, rate limits, per-site blocks |
| 2 | Native WebSearch + WebFetch | tier 1 missing, exhausted or overkill; ordinary static pages | no setup, cheap, good summaries | summary instead of raw text, short cache, no crawl, no interaction, sometimes blocked |
| 3 | curl + pdftotext (plus public APIs, sitemaps, RSS) | tiers 1-2 failed on a page, PDFs, raw files, APIs | exact bytes, scriptable, no summarizer | no rendering, manual cleanup, you must be polite |

Rule: escalate per page, not per session. One blocked page does not demote the whole run, and one success does not promote it. Start each new URL at the cheapest tier that plausibly works, not at tier 1 by habit.

## Choosing the operation before the tool

| Situation | Choose | Why |
|---|---|---|
| You know the URL | read-page | search adds noise and cost |
| You know the site, not the page | map-site with a keyword (tier 1, needs an account) or site-restricted search | finds the page without reading the site |
| You need 1-5 specific facts | targeted search then read the best 2-4 pages | cheapest path |
| You need everything in one docs section | crawl-section with path scope and a page cap (tier 1), or hand-picked reads from its index page | crawl is high cost; justify it |
| Literature or code-behavior question | category/domain filtered search, paper or developer index, or primary repositories and issue trackers | primary evidence beats blogs |
| Data behind a form, tab or infinite scroll | interact (tier 1) or look for an API/RSS/print view | last resort, step capped |
| A local or downloaded PDF | parse-document | no network fetch |
| "Tell me when it changes" | monitor or a stored hash | recurring cost |

Prefer search for discovery, scrape for content, extract for shape; a crawl is justified only when the answer depends on coverage of a section, not on one page.

## Detecting a blocked, empty or misleading page

Treat a read as failed, not as evidence, when any is true:
- status 401, 403, 429, or a vendor error code naming a block or unsupported site;
- body shorter than about 300 characters for a page that should be long;
- body is mostly navigation, a cookie banner, a consent wall or "enable JavaScript" text;
- title or heading contains "access denied", "verify you are human", "sign in", "just a moment";
- final URL differs unexpectedly (login redirect, geo redirect, parked domain);
- text is repeated boilerplate identical across unrelated URLs of one host;
- a 200 page about a removed item (liveness is separate from fetch success).
Log the symptom word (`blocked`, `empty`, `wall`, `gone`, `redirected`) with the URL.

## Per-page escalation script

```
for each url:
  try cheapest plausible tier -> check detection list
  if failed and tier1 available -> retry once with render wait / live mode
  if failed -> alternate source (official mirror, docs repo, API, RSS, print view, archive copy)
  if failed -> tier3 raw fetch (PDFs and APIs always go here if tier2 garbled them)
  if still failed -> mark unreadable; do not cite; note the gap in the ledger
max 3 attempts per URL; max 1 retry per tier
```

## Credit-exhausted and rate-limit behavior

- A credit or quota message (the docs read give no status code for it, so go by the message text) means stop calling that tier for the rest of the session unless the user tops up; note it once, drop to tier 2, and tell the user what coverage was lost (rendering, crawl, interact).
- A 429 or "too many requests" means slow down: wait with doubling delay (for example 5 s, 15 s, 45 s), reduce parallelism to 1-2 on that host, honor any retry-after hint. After two backoffs switch tier or source for that host.
- Keep a per-host failure counter; after 3 failures stop touching that host and say so.
- Never rotate identities or hide the client to dodge limits.
- Keep an overall budget (pages, calls, minutes) and show it in the report: used versus allowed.

## Source log (mandatory)

Every source in notes and the final list carries a tool tag. Example rows:

```
S3 | https://example.org/spec | tier=T1 | tool=firecrawl-scrape(live) | fetched 2026-11-24 | ok
S4 | https://example.net/post | tier=T3 | tool=WebFetch | fetched 2026-11-24 | ok, summary only
S5 | https://example.org/paper.pdf | tier=T1 | tool=curl+pdftotext p.3-5 | ok
S6 | https://vendor.example/pricing | blocked(403) on WebFetch; alternate=official docs repo
```
Why: readers can weigh evidence (a summarizer-filtered fetch is weaker for exact quotes), and failures stay auditable.

## Mixed-tier hygiene

- Do not mix a cached tier-1 read and a live tier-2 read of the same URL without noting the dates.
- If two tiers return different text for one URL, trust the one with raw text, then re-check with a live fetch.
- When only a summarizing fetch is available, quote cautiously and mark quotes `via-summary`.

## How an agent should apply this

- Pick the operation (read, map, search, crawl, interact, parse) before choosing a tool.
- Check tier 1 availability and credit once at the start; do not assume it.
- Escalate or demote per URL with at most 3 attempts; record the symptom each time.
- On credit exhaustion stop that tier and disclose reduced coverage; on 429 back off and cut parallelism.
- Tag every source with the tool that produced it and keep the log in the final report.
- Prefer an official API, repository or primary document over fighting a blocked page.
