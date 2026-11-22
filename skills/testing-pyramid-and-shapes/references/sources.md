# Sources for the testing-pyramid-and-shapes skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Ham Vocke & Martin Fowler, "The Practical Test Pyramid" (2018), https://martinfowler.com/articles/practical-test-pyramid.html | Breakdown of the test pyramid: unit tests (solitary vs sociable), integration tests (database, service adapters), contract tests, UI tests, and exploratory testing; anti-patterns (ice cream cone, hourglass); speed vs cost trade-offs. |
| 2 | Martin Fowler, "On the Diverse And Fantastical Shapes of Testing" (2021), https://martinfowler.com/articles/2021-test-shapes.html | Comparison between the Pyramid, the Testing Trophy, and Spotify's Honeycomb; critique of definitions of "unit test"; Justin Searls's principle: focus on expressive, reliable tests with clear boundaries over rigid percentage debates. |
| 3 | Kent C. Dodds, "Write tests. Not too many. Mostly integration." (2018/2024), https://kentcdodds.com/blog/write-tests | Introduction of the Testing Trophy: Static analysis as the foundation, unit tests for pure functions, integration tests as the sweet spot for confidence vs effort, and end-to-end tests for critical business funnels. |
| 4 | Naina Garg, "The Test Pyramid Is Outdated — Here's What Replaced It" (2026), https://medium.com/@tonainagarg/the-test-pyramid-is-outdated-heres-what-replaced-it-f9795e5f2615 | Architectural shift away from monolith-centric test pyramids toward integration-heavy models (Testing Trophy, Spotify Honeycomb, and Risk-Based Testing); incident-history auditing to target boundary bugs (HTTP contracts, schemas, migrations); author adoption estimates marked as *claims*. |
