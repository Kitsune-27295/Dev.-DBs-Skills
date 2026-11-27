# Sources for the clean-architecture skill

Every URL below was re-fetched on 2026-11-27 with a page-reading tool (summaries, not raw text). Statements are in this pack's own words.

| # | Source | Retrieved status | What the skill takes from it |
|---|---|---|---|
| 1 | https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html | 200, read | Five properties, four circles, the Dependency Rule, control versus dependency direction via an output port and DIP, simple data across boundaries (entities and rows must not cross), circle count is schematic. |
| 2 | https://softengbook.org/articles/clean-architecture | 200, read | Goals (reusability, cohesion, technology independence, testability), layers with a university example, stability argument, mail-service inversion example, testing claim without evidence; "when not worthwhile" only posed as exercises. |
| 3 | https://learn.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures (en-us; the old pt-pt link was replaced) | 200, read (page dated 2026) | Application Core, Infrastructure, UI, composition root, compile-time versus runtime dependencies, unit versus integration testing, monolith versus microservices remarks. |
| 4 | https://github.com/jasontaylordev/cleanarchitecture | 200, read | Template versions, test libraries, database options, scaffold command. The src project list was not shown. |

## Reading limits
- Fetch tool summaries are paraphrases. The post's diagram (input port, interactor, presenter boxes) cannot be read as text.
- Source 4 is a moving repository page; versions were true on 2026-11-27 only.
- No scripts or data files in this skill; nothing to run.

## Claims not adopted as fact
- The earlier mapping of the circles to Domain, Application, Infrastructure and Web projects in Jason Taylor's template: the page did not list its projects, and the Microsoft guide points to a different template (ardalis). The mapping in the skill is the guide's Core, Infrastructure, UI.
- MediatR, AutoMapper, FluentValidation, Scalar, `ca-use-case`, Dev Container and `AGENTS.md` as template contents: not on the page read.
- The tests-per-circle table, "when it earns its keep" and the mistakes list: the skill's own judgment, not sourced claims.
- NetArchTest, ArchUnit and dependency-cruiser: named as tools only; not re-verified.

## Disagreements worth knowing
Martin's diagram has control flow through input port, interactor and output port to a presenter. Microsoft's guide and common templates let a handler return a response DTO to the controller. Both satisfy the rule while inner circles import nothing from outer ones.
