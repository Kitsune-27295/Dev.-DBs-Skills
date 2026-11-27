# Sources — Single Responsibility & Cohesion

Every URL below was checked during skill rebuild (2026-11-27).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Robert C. Martin — SRP, requested slug `.../2014/05/08/SingleResponsibilityPrinciple.html`](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleResponsibilityPrinciple.html) | **404 Not Found** (WebFetch) | Nothing; the slug does not exist. |
| [Robert C. Martin — SRP, canonical slug `.../2014/05/08/SingleReponsibilityPrinciple.html`](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html) ("Responsibility" misspelled in the URL) | **200 OK** (WebFetch); dated 8 May 2014 | Parnas 1972, Dijkstra two years later, Constantine's coupling/cohesion, "who is the program responsible to", bug fixes and refactorings do not count, the CFO/COO/CTO `Employee` example and its hyperbole footnote, the mechanic analogy, SQL-in-JSP and mixed-concern symptoms, the "vague feeling" about Meyer, the "gather things that change for the same reasons" restatement. It does NOT use the word "actor", Conway's law or Common Closure. |
| [Wikipedia — Single-responsibility principle](https://en.wikipedia.org/wiki/Single-responsibility_principle) (added 2026-11-27) | 200 OK (WebFetch); secondary source | The later "actor" formulation from *Clean Architecture* (the page cites 2018), the accountant/DBA example, SRP as based on cohesion. No mention of CCP. |
| [Wikipedia — Package principles](https://en.wikipedia.org/wiki/Package_principles) (added 2026-11-27) | 200 OK (WebFetch); secondary source | Confirms the principles exist and names Martin's 1996 "Granularity" article; gives no CCP statement. |
| [Martin Fowler — CommonClosurePrinciple](https://martinfowler.com/bliki/CommonClosurePrinciple.html) | **404 Not Found** (WebFetch); re-checked 2026-11-27 | Nothing. CCP material in `cohesion-and-common-closure.md` is labeled background knowledge. |
| [Parnas — On the Criteria To Be Used in Decomposing Systems into Modules (scan)](https://wstomv.win.tue.nl/edu/2ip30/references/criteria_for_modularization.pdf) | 301 to this URL, then 200 OK; scanned image PDF, **not readable** by WebFetch | Nothing; the Parnas claim is taken only as reported by Martin's article. |

## Reading limits

- Firecrawl has no credits; WebFetch summaries were used. Martin's *Clean Architecture*, his 1996 "Granularity" article and Parnas's paper were not read.
- Shell commands in the references are the author's own and were not run.
- Recipes, thresholds and the layered-vs-feature remarks are the author's inference.

## Claims not adopted as fact

- The exact wording of the Common Closure Principle and any exact quote of it: no readable primary source.
- That "actor" is Martin's 2014 wording: it is not on the 2014 page.
- The year of Dijkstra's paper: the page says only "two years later" than Parnas (1972).
