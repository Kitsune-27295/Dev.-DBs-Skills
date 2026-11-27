# Sources for the c4-model-architecture skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Simon Brown, "The C4 model for visualizing software architecture", https://c4model.com/ | Official definition of the 5 pillars of C4: (1) **Hierarchical abstractions** (Person, Software System, Container, Component, Code), (2) **Hierarchical core diagrams** (System Context, Container, Component, Code), (3) **Supporting diagrams** (System Landscape, Dynamic, Deployment), (4) **Notation independent**, and (5) **Tooling independent**. |
| 2 | Simon Brown, "Introduction to the C4 model", https://c4model.com/introduction | Diagnosis of common ad-hoc "boxes and lines" diagramming problems (inconsistent/unexplained notation, ambiguous element meaning, missing or unlabelled relationships, generic labels like "business logic", missing technology choices, mixed abstraction levels, no clear zoom transition between diagrams); the **Google Maps metaphor** ("maps of your code" at progressive zoom levels); the Software Architecture Diagramming Maturity Model. |
| 3 | IcePanel / Simon Brown summary, "C4 model for software architecture", https://c4model.info/ | Concise definitions, audiences, and scopes for Person, System, Container ("independently deployable and runnable — not to be confused with Docker containers"), and Component; audience mapping per level (L1 for technical & non-technical business/product; L2 for technical product/architects/devs; L3/L4 for developers inside a container). |
| 4 | Dr. Milan Milanović, `architecture-docs` — "Software Architecture Documentation with arc42 and C4 Model", https://github.com/milanm/architecture-docs | Practical Docs-as-Code repository layout combining **C4 Model** diagrams (C1 Context, C2 Container, C3 Component via PlantUML/AsciiDoc) directly inside **arc42** sections (Section 3 Context & Scope -> C1; Section 5 Building Block View -> C2/C3; Section 6 Runtime View -> C4 Dynamic; Section 7 Deployment View -> C4 Deployment) and publishing automatically via GitHub Actions. |

## Notes on disagreements and nuances across sources

- **Do you need Level 3 (Component) and Level 4 (Code) diagrams?** Brown (Sources 1 & 2) and Milanović (Source 4) explicitly recommend **Level 1 (System Context)** and **Level 2 (Container)** for almost all systems, while advising teams to create Level 3 only when a container's internal structure is large/non-trivial, and to skip manual Level 4 diagrams altogether in favor of IDE/automated generation because code-level diagrams rot immediately.
