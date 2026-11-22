# Sources — Defensive Domain Modeling & Type-Safe Flows

Every URL below was retrieved and verified on 2026-11-22.

| Source | Retrieved status | What it contributed to `SKILL.md` |
|---|---|---|
| [Alexis King — Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) | 200 OK | Parsers vs. validators, eliminating shotgun parsing, avoiding boolean blindness, pushing parsing to system boundaries, and preserving type proofs. |
| [Scott Wlaschin — Designing with Types: Making Illegal States Unrepresentable](https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/) | 200 OK | Algebraic/sum types, single-case constrained wrappers, and handling legacy invalid records without weakening core domain invariants. |
| [Martin Fowler — ValueObject](https://martinfowler.com/bliki/ValueObject.html) | 200 OK | Structural equality vs. reference identity, mandatory immutability, preventing aliasing bugs, and replacing Primitive Obsession. |
| [Martin Fowler — TellDontAsk](https://martinfowler.com/bliki/TellDontAsk.html) | 200 OK | Co-locating data and invariant-preserving behavior while explicitly rejecting "Getter Eradicator" extremes on reads/Value Objects. |
| [Karl Lieberherr & Ian Holland — Law of Demeter (General Formulation)](https://www2.ccs.neu.edu/research/demeter/demeter-method/LawOfDemeter/general-formulation.html) | 200 OK | Canonical four permitted receivers inside method `M` of object `O` (self, parameters, locally created objects, direct components). |
| [C2 Wiki — Law of Demeter](https://wiki.c2.com/?LawOfDemeter) | 200 OK | Practical distinction between "Train Wreck" coupling chains and legitimate fluency over Value Objects, collections, and factories (Nat Pryce). |
| [Martin Fowler — CommandQuerySeparation](https://martinfowler.com/bliki/CommandQuerySeparation.html) | 200 OK | Method-level separation of side-effect-free Queries from state-changing Commands (and Meyer's canonical `pop()` caveat). |
| [Martin Fowler / Refactoring Catalog — Replace Nested Conditional with Guard Clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html) | 200 OK | Early-return Guard Clauses to flatten edge conditions and isolate the main happy path. |
| [Scott Wlaschin — Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/) | 200 OK | Two-track `Result`/`Switch` mental model (`bind`, `map`, `tee`, `tryCatch`, `doubleMap`, and parallel `plus` validation) + explicit warning against overusing ROP in trivial helpers. |
| [Scott Wlaschin — A Recipe for a Functional App (Part 2)](https://fsharpforfunandprofit.com/posts/recipe-part2/) | 200 OK | End-to-end boundary pipeline composition: input validation (`plus`), DB/IO wrapping, domain switch, and HTTP error mapping (`doubleMap`). |
| [swlaschin/railway-oriented-programming-example](https://github.com/swlaschin/railway-oriented-programming-example) | 200 OK | Reference code structure comparing imperative exceptions vs. two-track `Result` pipelines. |
