# Source Quality Gates and Anti-SEO

Sources: https://github.com/robertnowell/deep-research · https://github.com/199-biotechnologies/claude-deep-research-skill · https://www.aihero.dev/skills-research · https://mcpmarket.com/tools/skills/deep-web-researcher · Last verified 2026-11-24

## Source tiers (robertnowell, MIT)
- Tier 1 primary: official docs, specs, standards bodies, peer-reviewed papers, filings, the author's own repo or announcement.
- Tier 2 curated secondary: edited major publications, established references with citations, peer-reviewed proceedings, analyst reports (note possible bias).
- Tier 3 community: blogs, forums, Stack Overflow, talks, newsletters, preprints. Good for leads, weak as sole evidence.
- Tier 4 unverifiable: anonymous social posts, AI-generated text without editing, SEO listicles, content farms, scraped aggregators, undated or unattributed pages. Should not support a key finding.

Inheritance rule: a Tier 3 page that cites a Tier 1 source gets Tier 1 for that specific claim only after you check the citation is accurate. Many Tier 3 pages never outweigh one Tier 1.

## Credibility scoring (199, claimed implementation)
Their evaluator combines four 0-100 components with weights: domain authority 35%, expertise 25%, recency 20%, neutrality 20%. Domains sit in fixed lists (high about 90, moderate about 70, free-blog hosts about 40, unknown about 55); recency steps down from 100 (under 3 months) to 30 (over 5 years); unknown date scores 50. Treat this as a crude prior: a domain list cannot judge a single page. Our inference: keep the dimensions (authority, expertise, recency, neutrality) but score qualitatively as high/medium/low with a reason.

## Red flags
- Circular citations (A cites B, B cites A, no primary evidence).
- "Updated for <year>" with no changelog or diff.
- Claims with no numbers, dates, names or method; "experts agree" with one source.
- AI citing AI, no primary anchor.
- Vendor research about its own product category (flag, do not discard).
- Survivorship: only successes cited.

## Anti-SEO and AI-content filters (practical)
- Prefer the owner of the fact: vendor docs for API behavior, the repo for code behavior, the standard for protocol rules.
- Distrust pages whose title is a ranking ("Top 10 ... 2026") unless they show method and dates.
- Check author, date, and a changelog; undated means Tier 4 for time-sensitive facts.
- Check independence: do two sources trace to the same origin? Count origins, not pages.
- Search results are leads, never evidence; open the page.
- Recency: ask the current date first (199 runs a date command) and never assume the year from memory.

## Paywalls and blocked pages
Classify and escalate per [tool-selection-and-fallback-ladder.md](tool-selection-and-fallback-ladder.md). A page you could not read is never cited and goes to the gaps list.

## Origin of the report gates
The five report gates are listed once, in `SKILL.md` section 8. They derive from robertnowell's hard gates (MIT): tiered citation per finding, every URL traceable to an agent's actual output, an explicit answered/partial/unanswerable status, a caveat when most sources are Tier 3/4, and disclosed failed angles with the queries tried. Our addition: used-versus-allowed budget and a tool tag per source.

## Example (own)
```
Claim: "Library X 4.2 dropped Node 16."
- docs changelog (T1, dated 2026-03) states it  -> keep, cite
- blog "X 4.2 guide 2026" (T3, undated) repeats it -> corroboration only
Result: Established if a second independent T1/T2 agrees; else Likely.
```

## How an agent should apply this
- Tag every source with a tier and reason when you log it, not at the end.
- Chase the primary source behind every secondary claim; stop at the first owner.
- Exclude Tier 4 from findings; mention it only in gaps.
- Run the five gates as a checklist before delivering.
- Report blocked pages with their real status instead of guessing.
