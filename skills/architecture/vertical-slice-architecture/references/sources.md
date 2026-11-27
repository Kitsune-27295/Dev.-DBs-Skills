# Sources for the vertical-slice-architecture skill

Last verified 2026-11-27. All pages re-fetched with WebFetch on that date; summaries are in our own words.

| # | Source | Status | What the skill takes from it |
|---|---|---|---|
| 1 | Jimmy Bogard, "Vertical Slice Architecture" (2018-04-19), https://www.jimmybogard.com/vertical-slice-architecture/ | Read, 200 OK | The coupling rule ("Minimize coupling between slices, and maximize coupling in a slice"); critique of layered, onion and clean architectures; per-request use cases; commands and queries (CQRS from the start); start with Transaction Script and refactor as smells appear; needs a team that can refactor; about 7 to 8 years of use. |
| 2 | Jimmy Bogard, ContosoUniversityDotNetCore-Pages, https://github.com/jbogard/contosoUniversityDotNetCore-Pages | Read, 200 OK | README lists vertical slice architecture, CQRS and MediatR, AutoMapper, FluentValidation, HtmlTags, EF Core on ASP.NET Core 10 Razor Pages; has an Aspire app host and an `IntegrationTests` project with CI. |
| 3 | Milan Jovanovic, "Vertical Slice Architecture in .NET" (hub page, published 2026-07-10, updated 2026-07-14), https://milanjovanovic.tech/blog/vertical-slice-architecture-dotnet | Read, 200 OK; hub page, not the full article | Slice structure by feature; cross-cutting policy in pipeline behaviors, decorators, endpoint filters or middleware; shared service layer as a coupling point; test through the public boundary against a real database; slices organize behavior while Clean Architecture governs dependency direction; duplication named as the common criticism. |
| 4 | drveillard/software-architecture, vertical-slice-architecture.md, https://github.com/drveillard/software-architecture/blob/main/docs/vertical-slice-architecture.md | Read, 200 OK; link list (about 50 articles, 10 videos, 18 samples, 1 book) with almost no prose | Only as a reading map; entries are titles, not verified claims. |

## Reading limits

- Source 3 links to articles on REPR and on where shared logic lives; they were not opened, so REPR and Carter details are not claimed.
- Source 2: the README does not show folder layout, test framework or how tests run.
- Source 1 has no comments section.

## Claims not adopted

- "Code sharing is coupling" attributed to Bogard's Q&A: not on the page. The idea (share only when it is the same domain concept) is kept as our heuristic, labeled as such.
- Testcontainers in the reference repo: not shown in the README. The real-database test advice rests on source 3.
- "Slices must never call another slice" and "zero repository mocks": our rules, not in the sources.
- REPR as Bogard and Jovanovic doctrine: only a link title was read; REPR is mentioned in the skill as a common endpoint shape, unverified.
- The "1,500 lines of duplicated rules" figure: invented, removed.
- The "3+ slices" extraction threshold: our rule of thumb.
