# Sources — Dependency Inversion, DI & Composition Root

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Martin Fowler — Inversion of Control Containers and the Dependency Injection pattern](https://martinfowler.com/articles/injection.html) | 200 OK (WebFetch fallback; Firecrawl out of credits) | MovieLister/MovieFinder example, naming of DI, constructor/setter/interface injection, Service Locator variants, locator vs injection comparison, constructor vs setter trade-offs, code vs configuration files, separation of configuration from use. |
| [Mark Seemann — Composition Root (2011)](https://blog.ploeh.dk/2011/07/28/CompositionRoot/) | 200 OK (WebFetch fallback) | Definition, placement near entry point, per-framework entry points, Pure DI vs container, Register-Resolve-Release, only applications have a root, libraries do not, comment-thread positions (one root per process, modules not self-registering, duplicated registrations). |
| [Mark Seemann — Service Locator is an Anti-Pattern (2010)](https://blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern/) | 200 OK (WebFetch fallback) | OrderProcessor example, run-time `KeyNotFoundException`, hidden dependencies, breaking-change analysis, concrete vs abstract locator, constructor injection as remedy, later SOLID/encapsulation note, reader counterarguments. |

Notes: Firecrawl scraping failed in this run (credits exhausted, then rate-limited); WebFetch summaries were used, so wording is paraphrased. Guidance beyond these pages (detection table, migration steps) is the author's inference and is labeled.
