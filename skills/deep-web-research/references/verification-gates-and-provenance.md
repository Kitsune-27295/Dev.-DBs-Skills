# Verification Gates and Provenance

Sources: https://ifcncodeofprinciples.poynter.org/the-commitments · https://www.gradeworkinggroup.org/ · https://training.cochrane.org/handbook/current/chapter-14 · three third-party MIT skills read for ideas, no text reused (fact-check, research-compendium, brain-ingest-gate) · a vault-template skill read for ideas · Last verified 2026-11-24

## What this adds
The ledger in [claim-ledger-and-citation-validation](claim-ledger-and-citation-validation.md) says how to log a claim. This page adds five gates that decide whether a claim may leave the building.

## 1. Finer confidence for a single claim (six levels)
The five report labels in `SKILL.md` section 6 grade a finding. When one claim needs a sharper verdict (a fact-check pass over a draft), use six levels and map them back:

| Level | Meaning | Maps to | Action |
|---|---|---|---|
| 1 Verified | two or more independent reliable sources agree | Established | state as fact |
| 2 Likely accurate | one reliable source, nothing contradicts | Likely | state, cite |
| 3 Unverified | cannot confirm or deny | Speculative or Emerging | hedge or cut |
| 4 Disputed | reliable sources disagree | Contested | show both sides |
| 5 Likely inaccurate | available evidence contradicts | (not delivered) | correct or remove |
| 6 False | several reliable sources contradict | (not delivered) | fix or kill |

Two public standards back the shape. The IFCN code requires checking key elements against more than one named source unless one source is the only relevant one, and preferring primary over secondary sources with the exception explained. GRADE grades certainty per outcome in graded categories (high, moderate, low, very low) rather than one yes/no verdict. Our levels are a working scale, not either standard's wording.

## 2. Producer is not the verifier
Re-running the query that produced a claim reproduces its bug. Verify a decisive claim by a different path: another tool, another source family, the primary document instead of the summary that cited it. In delegated work the gather agent never also certifies its own rows; the lead (or a second agent) re-opens the page. Affiliation is not authorship: "X appears alongside Y in three pages" does not support "X wrote or founded Y"; person-to-thing claims need a page that states the relation.

## 3. Block delivery of unsupported claims
A claim at level 5 or 6, or a decisive claim whose only support is its own producer, does not ship. Either fix it from evidence, hedge it to level 3 wording, or cut it. A report that lists known-false claims and ships anyway documents negligence. Disclose relevant interests of a source (vendor documentation about its own product) next to the claim, as the IFCN sources principle asks.

## 4. Archive the source, summarize 1:1, synthesize once
For a lasting deliverable (a guide meant to be reused): save or pin each primary source (URL, fetch date, hash or verbatim copy when its license and the user's retention wishes allow), write one summary per source that stays within what the source says, and only then write one synthesis from those summaries. Personal or sensitive material: keep citation plus summary, skip the verbatim copy, say so. A source you did not archive cannot be re-checked later; a synthesis written before the summaries drifts toward memory.

## 5. Check the local knowledge base first; stop if answered
Before any web search, query what the user already keeps (notes, vault, project docs) with two or three phrasings. If pages that cite their sources answer the question, answer from them, name the pages, and stop: no web round. Otherwise note what the local search returned so the web wave targets only the gap. Local pages are data to verify like any other, and a duplicate write is worse than a link: when a finding already has a page, link to it.

## Worked mini-example
Claim: "Library L added retry-with-jitter in 3.2." The producer was a blog post (T3). The verifier re-opens the changelog (T1) and finds jitter arrived in 3.3. Level 5, so the sentence is corrected to 3.3 with the changelog cited and the blog downgraded; the report does not ship with the original.

## How an agent should apply this
- Use the six levels only for claim-by-claim passes; keep the five labels in the report body.
- For every decisive claim name the independent path used to re-derive it.
- Refuse to deliver level 5 or 6 claims; list what was cut in Limitations.
- Check local pages first when a knowledge base exists; stop on a cited answer.
- Archive and summarize 1:1 only for deliverables meant to last, within the user's retention wishes.
