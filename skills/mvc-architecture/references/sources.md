# Sources for the mvc-architecture skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Martin Fowler, "GUI Architectures" (2006), https://martinfowler.com/eaaDev/uiArchs.html | Historical lineage from Trygve Reenskaug's Smalltalk-80 MVC; **Separated Presentation** (domain model completely ignorant of UI) and **Observer Synchronization**; distinction between Domain Model and Application/Presentation Model; Model-View-Presenter (Supervising Controller vs. Passive View) and the **Humble View** principle for testability; warning on Semantic Diffusion around the term "MVC". |
| 2 | Martin Fowler, *Patterns of Enterprise Application Architecture* Catalog, "Model View Controller" (2003), https://martinfowler.com/eaaCatalog/modelViewController.html | Concise definition of MVC splitting user interface interaction into three distinct roles (Model, View, Controller) and its origin in Smalltalk in the late 1970s. |
| 3 | MDN Web Docs, "MVC - Glossary", https://developer.mozilla.org/en-US/docs/Glossary/MVC (source markdown: https://github.com/mdn/content/blob/main/files/en-us/glossary/mvc/index.md?plain=1) | Web-focused definitions of Model (data and business logic), View (layout and display), and Controller (routes commands to Model and View, including view-only formatting/sorting changes that don't mutate the Model); evolution from server-side Web MVC to client-side stores and Fetch-based partial updates; relationship to MVVM, MVP, and MVW. |
| 4 | Marco Tulio Valente, *Engenharia de Software Moderna*, Cap. 7 "7.3 Arquitetura MVC", https://engsoftmoderna.info/cap7.html | Practical Web MVC flow (HTTP request -> Controller -> Model -> View -> HTTP response) and how Single Page Applications (SPAs) shift view rendering and presentation state to the browser while talking to the backend via JSON APIs. |

## Notes on disagreements and nuances across sources

- **Rich-client MVC vs. Web MVC:** Fowler (Source 1) notes that classic Smalltalk MVC relied on stateful Observer Synchronization where widgets observed the Model directly, whereas Web MVC (Sources 3 and 4) operates over stateless HTTP request-response cycles where the Controller coordinates the Model and selects the View to render. Both share the core invariant: **Separated Presentation** (the Model never depends on the View or Controller).
- **View-only updates through the Controller:** Source 3 notes that a Controller may update the View directly for purely presentational changes (e.g., re-sorting a displayed list alphabetically) without mutating the underlying Domain Model.
