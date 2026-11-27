# Service Locator: Why It Is an Anti-Pattern

Sources: https://blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern/ · https://martinfowler.com/articles/injection.html · Last verified 2026-11-27

## Two positions to hold together

- **Fowler:** locator and injection both decouple. For application classes they are roughly equal, with a slight simplicity edge for the locator; for reusable components injection is preferred because every user of a locator-based component depends on that locator. He dislikes dynamic string-keyed locators because keys are implicit and hard to trace.
- **Seemann (2010):** Service Locator is an **anti-pattern**: it hides a class's dependencies, turning compile-time errors into run-time failures and making maintenance riskier. Later updates on the page: a 2014 note says it violates SOLID, a 2015 note says the fundamental problem is that it violates encapsulation.

Resolution (inference): use Seemann's stricter rule for application code you control; Fowler's tolerance explains why locators are common and why they appear in framework internals.

## The OrderProcessor case

`OrderProcessor` calls a static `Locator.Resolve<IOrderValidator>()` and `Locator.Resolve<IOrderShipper>()` in place of `new`. The locator is a static dictionary of factories.

Problems demonstrated:
1. **Usability:** the type has a default constructor, nothing signals requirements. Calling `Process` throws `KeyNotFoundException` because no validator was registered. You learn the requirement by reading source, decompiling, or documentation.
2. **Test friction (own inference from the static `Reset`):** the static store needs resets between tests. Fowler notes testing alone does not separate locator from injection.
3. **Maintenance:** adding a lookup of `IOrderCollector` compiles; it may fail tests or production depending on registration elsewhere. Deciding "is this a breaking change?" demands whole-app knowledge, the compiler cannot help.

Variants that do not fix it: a *concrete* locator (still a static store); an *abstract* locator injected through the constructor (exposes the dependency on the locator, not on the services, so failures stay at run time).

Remedy: **constructor injection** exposes requirements in the signature, so the compiler, IDE and container help consumers and maintainers.

## Counter-arguments in the comments and responses

| Objection | Response from the article's discussion |
|---|---|
| Service Locator has valid niche uses | Author replies that it is never appropriate and a better design can always replace it |
| Plugin architectures, legacy, SOA need it | For dynamic creation inject an Abstract Factory; framework-created objects (e.g. ASP.NET pages) can be Composition Roots |
| Legacy code cannot be changed at once | An Ambient Context is preferable to a locator as an interim step |

## Allowed uses (consolidated, partly inference)

| Place | Verdict |
|---|---|
| Inside the Composition Root | Fine |
| A framework hook that instantiates objects for you | Acceptable boundary; resolve once, pass explicitly inward |
| Business logic, domain, services | Reject |
| Dynamic plugin loading by key | Inject a factory/registry object whose interface names the product type |

## Migration recipe (author's inference)

1. Find calls: grep `Locator`, `resolve(`, `getService(`, `Container.`, static `Instance`.
2. For each class, list the services it resolves.
3. Add them as constructor parameters; keep the old lookup as a default only temporarily.
4. Wire them at the Composition Root; update callers.
5. Delete the default and the locator import; add a test that builds the class with fakes and no global state.
6. When the container type is no longer referenced outside the root, make that an architecture test.

```python
# before
class OrderProcessor:
    def process(self, o): Locator.get("validator").validate(o)
# after
class OrderProcessor:
    def __init__(self, validator, shipper): self._v, self._s = validator, shipper
```

## Failure modes

- Replacing a static locator with an injected `IServiceProvider`: same hidden dependencies (the article's abstract-locator case).
- Registering services in many modules so no single place shows the graph.
- Resolving lazily inside methods "to avoid cycles": mask a design cycle; break it with a smaller abstraction.

## How an agent should apply this

- Flag any non-root `resolve`/`get_service`/static lookup as a review finding with the OrderProcessor failure mode (hidden requirement, run-time error).
- Do not accept an injected container or provider as the fix.
- Use constructor parameters; if the list grows past about five or six, look at responsibilities (`single-responsibility-cohesion`).
- For dynamic creation use a narrow factory interface.
- For legacy, propose staged migration and name the temporary ambient/locator as such.
