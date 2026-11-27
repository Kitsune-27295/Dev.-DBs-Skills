# Sources — Open-Closed Principle & Strategy

Every URL below was checked during skill rebuild (2026-11-27).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Robert C. Martin — The Open Closed Principle (2014)](https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html) | 200 OK (WebFetch); dated 12 May 2014 | Meyer's 1988 origin and what open/closed mean, why Martin calls it dated, "extend without modifying", shotgun surgery contrast, IDE/plugin evidence, inverted dependencies across boundaries, the plugin-architecture conclusion. It does not mention a "polymorphic OCP". |
| [Refactoring.Guru — Strategy](https://refactoring.guru/design-patterns/strategy) | 200 OK (WebFetch) | Intent, navigator problem, participants, applicability, implementation steps, pros and cons, relations with Bridge, State, Command, Decorator, Template Method. |
| [Wikipedia — Open-closed principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle) (added 2026-11-27) | 200 OK (WebFetch); secondary source | Distinction between Meyer's inheritance-based reading and the 1990s "polymorphic" reading built on abstract interfaces; the page itself flags unsourced statements. |

## Reading limits

- Firecrawl has no credits; WebFetch summaries were used, not raw HTML. The Meyer book and Martin's 1996 article were not read.
- Python and TypeScript samples in the references are the author's illustrations and were not run.
- Recipes, thresholds, the map-of-functions shortcut and the expression-problem remark are the author's inference.

## Claims not adopted as fact

- That Martin's 1996 article introduced the polymorphic reading: stated by Wikipedia, not verified in a primary source.
- Any claim that OCP means inheritance: Martin's page ties it to dependency management, not to inheritance.
- The airport analogy and the Add/Subtract/Multiply pseudocode from the earlier draft: not re-confirmed on the Strategy page, removed.
