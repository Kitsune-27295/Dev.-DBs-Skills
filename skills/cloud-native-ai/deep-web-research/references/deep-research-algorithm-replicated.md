# Deep Research Algorithm: Replicated and Refined

Sources: Firecrawl repository snapshot (AGPL-3.0), path apps/api/src/lib/deep-research/deep-research-service.ts (loop); path apps/api/src/lib/deep-research/research-manager.ts (state, query generation, analysis, final report); path apps/api/src/controllers/v1/deep-research.ts (parameters and limits); path apps/test-site/src/content/blog/open-researcher-interleaved-thinking.md (tool-using agent variant, read as a description only). Clean-room: behaviors paraphrased, no code or prompts copied (AGPL-3.0 vs MIT) · Last verified 2026-11-24

## Part 1: what the Firecrawl loop does (prose)

Inputs: a query, a maximum depth (default 7, allowed 1-12), a maximum number of URLs (default 20, up to 1000), a time limit in seconds (default 300, allowed 30-600), optional analysis instructions, optional agent instructions, and an output format (markdown report or JSON against a schema).

State kept: the current depth, the next topic to search, a set of seen URLs, a rolling list of findings (only the latest 50 are kept in memory), a list of sources, an activity log, a failed-analysis counter (stops at 3).

Each iteration:
1. Check the clock and the URL budget; stop if exhausted.
2. Generate a few search queries (the generator is asked for 3-5, only the first 3 are used). It is told to avoid repeats, use today's date, make the first query a short plain version of the topic, then go deep rather than wide, and build on earlier findings. Each query comes with a stated goal.
3. Run all queries in parallel. Each search also fetches page content (main content, markdown, short timeout, cached copies up to 4 hours old are acceptable).
4. Drop results with no URL or already seen; count each new URL against the budget; record title, description and icon as a source entry.
5. If nothing new, log it and loop again (the same depth counter has advanced).
6. Append each page's text to the findings, tagged with its URL.
7. Analysis step: a model is given the current topic, the minutes remaining and all findings, and returns gaps, next steps, a continue flag and an optional narrower next topic. If under a minute remains it is told to stop. If analysis fails, count a failure.
8. Stop if the analyzer says stop or reports no gaps; otherwise the next topic becomes the first gap.

Final synthesis: one larger-model call over all findings writes a markdown report (title first, sections, citations throughout, aim for several pages) or fills the JSON schema. Billing is one credit per URL analyzed, capped by the URL limit. Progress is reported as typed activities (search, analyze, synthesis) with status processing/complete/error and a depth number, plus a progress count of 5 steps per depth level.

Pseudo-steps:

```
while depth < maxDepth and urls < maxUrls and time left:
    queries = generate(topic, findings)[:3]
    pages   = parallel(search_and_read(q) for q in queries)
    new     = [p for p in pages if p.url not in seen]
    findings += new; sources += new
    verdict = analyze(findings, topic, time_left)
    if verdict.stop or no gaps: break
    topic = verdict.gaps[0]
final = write_report(query, findings)
```

Observations (our reading, marked as inference): the whole findings text goes into each analysis call, so quality degrades as pages pile up; nothing records which finding supports which claim; no source quality ranking; contradictions are left to the writer model; the topic narrows to the first gap only, so other gaps are dropped unless re-found; the source list reported to users is title/description/icon, not evidence.

## Part 2: our refined version for an agent with only native tools

### Roles
The agent itself is generator, reader, analyst and writer. It may fan out read-only subagents, one per sub-question, returning compact notes (cap each at ~300 words plus quotes).

### Step 0: frame (before any search)
Write the question, the decision it serves, scope, a budget (max pages, max waves, time), and 3-7 sub-questions. Decide the freshness need per sub-question.

### Step 1: query generation
Per sub-question produce 2-4 queries of distinct kinds: a plain keyword form, an exact-phrase or official-name form, a source-type form (documentation, specification, changelog, filing, paper), and one adversarial form (criticism, failure, limitations, "vs"). Add the current year only when recency matters. Keep a query log; never repeat one.

### Step 2: parallel fetch (wave)
Run the queries together, shortlist 3-6 URLs per wave by tier (below), dedupe by canonical URL, read them in parallel. Prefer reading primary sources over reading more search results.

### Step 3: per-source notes
For each page write a note: URL, tier, content date, fetched date, 3-8 atomic facts each with a quote or locator, and relevance to which sub-question. Discard page prose after noting; carry notes forward, not pages.

### Step 4: claim ledger
Update the claim ledger after every wave. Schema, statuses, the rule for when a claim counts as supported, and verification live in [claim-ledger-and-citation-validation.md](claim-ledger-and-citation-validation.md).

### Step 5: source tiers
Tier every source when you note it, using the definitions and the inheritance rule in [source-quality-gates-and-anti-seo.md](source-quality-gates-and-anti-seo.md).

### Step 6: gap analysis
After each wave list: claims still open, claims with a single source, sub-questions with no T1/T2, stale dates, and missing counter-evidence. Generate next-wave queries only from these gaps, not from the original topic again. Process all gaps by priority (Firecrawl follows only the first).

### Step 7: contradiction handling
Record the disagreement as `contested` in the ledger, seek one tie-breaker from the most primary source, and resolve or report it with the order of checks in [claim-ledger-and-citation-validation.md](claim-ledger-and-citation-validation.md). Never average or silently pick.

### Step 8: stop rule
Apply the stop rules and sizing in [budget-and-stopping-rules.md](budget-and-stopping-rules.md) after every wave, and say which clause fired. If two consecutive waves fail to fetch usable pages, switch tier first, per [tool-selection-and-fallback-ladder.md](tool-selection-and-fallback-ladder.md).

### Step 9: final synthesis
Lead with the answer and confidence; then findings grouped by sub-question, each claim with inline citation (URL, date), a contested-claims section, limits (blocked pages, undated sources), and a source list with tiers and fetch dates. Report which backend produced each source. Fabricated or unread sources are forbidden; unread means not cited.

## Improvements over the original, summarized

| Original | Refinement |
|---|---|
| findings are raw page text, last 50 kept | atomic notes with quotes, durable ledger |
| sources are title/description | tiered, dated, backend-tagged sources |
| first gap only | prioritized gap queue |
| stop on depth, URLs, time or model opinion | evidence-based stop rule plus budget |
| report written from raw text | report written from ledger, contradictions explicit |
| all fetched text trusted | page text quarantined as data |

## How an agent should apply this

- Write the frame and sub-questions first; do not start with an open-ended search.
- Keep the ledger as the single source of truth and write the report from it, not from memory of pages.
- Run waves of parallel reads, then analyze gaps; spend budget on primary sources.
- Apply the stop rule explicitly and say which clause fired.
- Report contested and unverified claims openly, with dates.
