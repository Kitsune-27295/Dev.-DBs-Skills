# Sources — Pragmatic SOLID & Abstraction Discipline

Every URL below was checked during skill authoring (2026-11-27), read with WebFetch.

| Source | Retrieved status | What it contributed to `SKILL.md` |
|---|---|---|
| [The Pragmatic Programmer, 20th Anniversary Edition, "The Evils of Duplication" (PDF excerpt)](https://media.pragprog.com/titles/tpp20/dry.pdf) | 200 OK; body text readable only after local PDF text extraction, WebFetch alone returned binary | DRY as a single, unambiguous, authoritative representation of knowledge; the acid test (one change, several places and formats); duplication of intent, not only of code; Uniform Access (Meyer) via accessors. |
| [Martin Fowler, Bounded Context](https://martinfowler.com/bliki/BoundedContext.html) | 200 OK, dated 15 Jan 2014 | Terms differ across contexts; Evans: total unification of a large domain model is not feasible or cost-effective; contexts keep their own models and map between them. (Used by the pointer in section 1; the deep treatment is in `ssot-and-dry`.) |
| [Robert C. Martin, SOLID Relevance](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html) | 200 OK | What each principle means; ISP matters most in statically typed, separately built code; LSP concerns subtyping including duck typing; thesis that "just be simple" needs principles. |
| [Robert C. Martin, The Single Responsibility Principle](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html) | 200 OK on the author's slug (`SingleReponsibilityPrinciple`, missing "s"); the correctly spelled slug was not retried this time | "One and only one reason to change", explained through the people who ask for changes; Parnas and Dijkstra lineage. |
| [Robert C. Martin, The Open Closed Principle](https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html) | 200 OK | Meyer's version versus Martin's restatement; plugin architectures; dependencies across a boundary point toward the core. |
| [Robert C. Martin, Interface Considered Harmful](https://blog.cleancoder.com/uncle-bob/2015/01/08/InterfaceConsideredHarmful.html) | 200 OK, dated 8 Jan 2015 | A Socratic dialogue about the `interface` keyword (abstract class vs interface, the diamond problem, Observer); it never discusses single-implementation interfaces or test doubles. |
| [Harvard Kempner Institute, Software Design Principles](https://handbook.eng.kempnerinstitute.harvard.edu/s2_swe_for_research/software_design_principles.html) | 200 OK, sections 6.1 to 6.13 | KISS, pure core with thin I/O wrapper, dependency injection, Open/Closed, functions and dataclasses over deep inheritance, specific error messages, layers. |

## Reading limits
- Pages were read through WebFetch summaries, not word for word; quotes are kept short.
- Rows removed on 2026-11-27: Fowler's Yagni and RuleOfThree pages, Metz's Wrong Abstraction and Dodds's AHA. The skill no longer restates their content; the owner is `kiss-yagni-aha` (its sources file records their statuses, including the 404 for the Rule of Three page).
- No scripts, SQL or data files exist in this skill.

## Claims not adopted as fact
- "Imposed, inadvertent and inter-developer duplication" (the old row): that is the first-edition taxonomy; the 20th-edition excerpt names interdeveloper duplication and accessors, and the full list is kept in `ssot-and-dry`.
- Martin argues against single-implementation `IFoo`/`Foo` pairs: the article does not; the no-ceremony rule is this skill's own, supported by `codebase-design`.
- The handbook names "composition over inheritance" or "fail fast": it names neither.
- "SRP means responsible to one actor": the 2014 post says "one reason to change", explained by people; the actor phrasing is a later formulation and is not used.
