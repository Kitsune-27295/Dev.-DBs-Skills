# Sources — Defensive Domain Modeling & Type-Safe Flows

Every URL below was re-checked on 2026-11-27 with WebFetch.

| Source | Retrieved status | What it contributed to `SKILL.md` |
|---|---|---|
| [Alexis King — Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) | 200 OK, claims confirmed | Parser vs validator, shotgun parsing (LangSec), head/NonEmpty, "push the burden of proof upward", authorization-before-parsing footnote. |
| [Scott Wlaschin — Designing with Types: Making Illegal States Unrepresentable](https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/) | 200 OK | Union-based illegal-state example, phrase credited to Yaron Minsky, validated `create` functions. It does not cover String50-style wrappers or legacy invalid records. |
| [Martin Fowler — ValueObject](https://martinfowler.com/bliki/ValueObject.html) | 200 OK | Equality by value, immutability, aliasing example, advice to replace common primitives. |
| [Martin Fowler — TellDontAsk](https://martinfowler.com/bliki/TellDontAsk.html) | 200 OK | Co-locating data and behavior; Fowler does not use the slogan himself; Getter Eradicator caveat. |
| [Lieberherr & Holland — Law of Demeter, general formulation](https://www2.ccs.neu.edu/research/demeter/demeter-method/LawOfDemeter/general-formulation.html) | 200 OK | Class form: own class, argument classes, immediate parts (stored or computed), created objects. Object form is only linked. |
| [C2 Wiki — Law of Demeter](https://wiki.c2.com/?LawOfDemeter) | 200 OK but unreadable (JavaScript-required shell) | Nothing. |
| [Martin Fowler — CommandQuerySeparation](https://martinfowler.com/bliki/CommandQuerySeparation.html) | 200 OK | Queries vs modifiers; `pop` exception. |
| [Refactoring Catalog — Replace Nested Conditional with Guard Clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html) | 200 OK | Code example only, almost no prose. |
| [Scott Wlaschin — Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/) | 200 OK | bind, Kleisli, map, tee, `&&&` parallel validation; "don't take it to extremes" warning. tryCatch, doubleMap and plus are not on this page. |
| [Scott Wlaschin — A Recipe for a Functional App (Part 2)](https://fsharpforfunandprofit.com/posts/recipe-part2/) | 200 OK | `plus`/`&&&` validation, `doubleMap`, `tee` + `tryCatch` around a database step. |

## Reading limits
Pages were summarized by a fetch tool, not read verbatim. TypeScript snippets are the skill's own.

## Claims not adopted as fact
- Nat Pryce's fluency/value-object exception to Demeter (C2 page unreadable): kept only as "common reading".
- Wrapping primitives as `String50`-style single-case types and the legacy-record state: not on the pages read; marked as own advice.
- The term "boolean blindness" and "primitive obsession" are not used on the cited King and Fowler pages.
