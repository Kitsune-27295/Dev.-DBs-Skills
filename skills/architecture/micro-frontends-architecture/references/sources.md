# Sources: Micro Frontends Architecture

Re-verified 2026-11-27 with WebFetch (Firecrawl unavailable). Summaries are in our own words.

| # | Source | Status | Contribution |
|---|---|---|---|
| 1 | Cam Jackson, "Micro Frontends", https://martinfowler.com/articles/micro-frontends.html | read 2026-11-27, OK; dated 19 June 2019 (series began 10 June) | five integration approaches and verdicts, shared state, CSS, shared libraries, BFF, auth, testing, AWS/Terraform example |
| 2 | Michael Geers, https://micro-frontends.org/ | read 2026-11-27, OK | five core ideas, Custom Elements as contract, team prefixes, SSI with nginx, framework anarchy, skeleton screens, ThoughtWorks radar end of 2016 |
| 3 | Microsoft Learn, composite UI based on microservices (pt-br), https://learn.microsoft.com/pt-br/dotnet/architecture/microservices/architect-microservice-container-applications/microservice-based-composite-ui-shape-layout | read 2026-11-27, OK; machine-translated, ms.date 2021, updated 2026-10-04 | monolithic vs composite UI, startup registration, API-gateway analogy, eShopOnContainers choice |

## Reading limits
Only these three pages were read; page 3 is a machine translation. The skill has no scripts or data files.

## Claims not adopted
- Corrected: "react and react-dom externalized, about half the bundle size". The article says they were about 50% of the bundle, not that externalizing saved that much.
- Removed (in no source read): Podium, Tailor, Module Federation, import maps, "4 megabytes", "90% of the structure at 10% of the cost", a "3+ teams" threshold, Core Web Vitals, Strangler Fig naming, "skeleton screens can flicker".
- The small-team advice is the skill's own inference and is labeled so.
