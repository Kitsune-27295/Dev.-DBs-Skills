# Sources for the screaming-architecture skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Robert C. Martin (Uncle Bob), "Screaming Architecture" (The Clean Code Blog, 2011-09-30), https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html | The building blueprint metaphor (a house blueprint screams **House**, a library blueprint screams **Library**); the core question: does your top-level directory structure scream **Health Care System / Accounting System / Inventory Management System**, or does it scream **Rails / Spring/Hibernate / ASP**?; Ivar Jacobson's principle (*Object-Oriented Software Engineering: A Use-Case Driven Approach*) that software architectures are structures that support the **use cases** of the system; deferring decisions about frameworks, databases, and web servers; **"The Web is a delivery mechanism"**, not an architecture; **"Frameworks are tools, not ways of life"** (keep frameworks at arm's length, view them skeptically); **Testable Architectures** (unit-testing all use cases in-situ without the web server running or the database connected). |

## Notes on disagreements and nuances across sources

- **Top-level Domain Slices vs. Top-level Concentric Layers (`domain/`, `application/`, `adapters/`):** In a single-context service, teams often place `domain/`, `application/` (use cases), and `adapters/` at the top level and organize *immediately inside* `domain/` and `application/` by business capability and use case name (`application/enroll-student/`, `application/grade-exam/`). In a multi-context system or `modular-monolith-architecture`, the top-level directories scream the Bounded Contexts (`src/enrollment/`, `src/grading/`, `src/billing/`) and each context keeps its use cases and adapters inside. Both satisfy Uncle Bob's rule as long as a reader opening the repository immediately sees the business domain and use cases rather than framework scaffolding.
