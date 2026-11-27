# Sources — Dependency Inversion, DI & Composition Root

Every URL below was checked during skill authoring (re-fetched 2026-11-27; first authored 2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Martin Fowler — Inversion of Control Containers and the Dependency Injection pattern](https://martinfowler.com/articles/injection.html) | 200 OK (WebFetch, 2026-11-27; Firecrawl has no credits) | MovieLister/MovieFinder example, naming of DI, constructor/setter/interface injection, Service Locator variants, locator vs injection comparison, constructor vs setter trade-offs, code vs configuration files, separation of configuration from use. |
| [Mark Seemann — Composition Root (2011)](https://blog.ploeh.dk/2011/07/28/CompositionRoot/) | 200 OK (WebFetch, 2026-11-27) | Definition, placement near entry point, per-framework entry points, Pure DI vs container, Register-Resolve-Release, only applications have a root, libraries do not, comment-thread positions (one root per process, modules not self-registering, duplicated registrations). |
| [Mark Seemann — Service Locator is an Anti-Pattern (2010)](https://blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern/) | 200 OK (WebFetch, 2026-11-27) | OrderProcessor example, run-time `KeyNotFoundException`, hidden dependencies, breaking-change analysis, concrete vs abstract locator, constructor injection as remedy, later SOLID (2014) and encapsulation (2015) update notes, reader counterarguments. |

## Reading limits

Pages were read as small-model extractions, not line by line; wording is paraphrased. Fowler's article date and exact Spring/PicoContainer details were not re-checked. Detection table, migration steps and modern-framework entry points are the author's inference.

## Claims not adopted as fact

- "Support both constructor and setter when you build a container" (Fowler): not re-confirmed, removed.
- Fowler's remark on multiplying per-component config files, and the `internal`-hiding and shared-registration comment positions: not re-confirmed, removed.
- "Compose no later than the first request": inference.
