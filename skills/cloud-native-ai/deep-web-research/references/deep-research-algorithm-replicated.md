# Deep Research Algorithm: Replicated and Refined

Sources: the public research skills listed in `research-skills-compared.md` (read 2026-11-27); the Firecrawl public docs index (docs.firecrawl.dev, 2026-11-27), which no longer documents a stand-alone deep-research endpoint; our own design. Last verified 2026-11-27

## Part 1: the generic loop (what vendor research loops do)

An earlier draft described one vendor's deep-research loop from a repository snapshot (depth, URL and time limits, a rolling findings list, an analyzer that names gaps). That behavior could not be re-confirmed against current public docs, so its numbers are not adopted (see `sources.md`). What generalizes, as our own pattern:

```
while sub-questions open and budget left:
    queries = generate(topic, findings)        # few, distinct, dated, broad then deep
    pages   = parallel(search_and_read(q))     # full pages, not snippets
    new     = pages not seen (dedupe by origin)
    findings += new
    verdict = analyze(findings, topic)         # gaps, single-source claims, stop flag
    if verdict.stop or no gaps: break
    topic = next named gap
final = write_report(from the ledger)
```

Weak points of the naive loop (our inference): all findings feed every analysis call, so quality degrades as pages pile up; nothing links a finding to a claim; no source ranking; contradictions are left to the writer; narrowing to the first gap drops the others; the source list holds titles, not evidence. Part 2 fixes these.

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
