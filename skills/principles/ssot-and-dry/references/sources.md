# Sources — SSOT & DRY

Every URL below was checked during skill rebuild (2026-11-27).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [The Pragmatic Programmer, 20th Anniv. — The Evils of Duplication (sample chapter PDF)](https://media.pragprog.com/titles/tpp20/dry.pdf) | 200 OK, binary PDF (WebFetch could not decode it; the saved file was extracted locally with `pdftotext` and read; a publisher sample dated 2019 in its metadata) | DRY definition and Tip 15, acid test, why knowledge instability matters, the five duplication kinds, the age/quantity coincidence example, the `Line` length cache ("localize the impact"), Meyer's Uniform Access Principle, Tip 16, the Y2K-audit anecdote. |
| [Martin Fowler — BoundedContext](https://martinfowler.com/bliki/BoundedContext.html) | 200 OK (WebFetch); dated 15 Jan 2014 | Polysemes (meter, Customer, Product), the Evans quote on total unification, context maps, boundaries by human culture and technical representation, related reading. |

## Reading limits

- Only the sample chapter of the book was read, not the full book. Code samples in this skill's references are the author's own illustrations and were not run.
- Firecrawl has no credits, so WebFetch plus local PDF extraction was used.
- Recipes, detection heuristics and the parity-test idea are the author's inference, labeled as such in the files.

## Claims not adopted as fact

- "Shared kernel" as a pattern: a DDD term from Evans's book, not on the Fowler page; kept only as a labeled exception.
- Reading context boundaries off team ownership: an application, not a claim of the article.
- Numeric thresholds for when to deduplicate: owned by `pragmatic-solid-and-ssot` and `kiss-yagni-aha`.
