# Dependency Injection Forms and Trade-offs

Sources: https://martinfowler.com/articles/injection.html · Last verified 2026-11-27

## The running problem

`MovieLister` returns films by director and needs a `MovieFinder` (single method `findAll()`). If the lister builds `ColonDelimitedMovieFinder("movies1.txt")` in its own constructor it is coupled to one storage format. Fowler's fix: treat the finder as a **plugin**, interface in the lister's world, implementation supplied from outside. He argues "Inversion of Control" is too broad (frameworks invert control in many ways) and names this specific kind **Dependency Injection**.

## The three forms

1. **Constructor injection** (PicoContainer in the article): `MovieLister(MovieFinder f)`; the finder itself takes its filename as a constructor `String`. Container configured with interface-to-implementation mappings and constants.
2. **Setter injection** (Spring): `setFinder(MovieFinder)` and `setFilename(String)`; wiring in XML beans, `ref` for objects, `value` for literals.
3. **Interface injection**: the dependency declares injection interfaces (`InjectFinder.injectFinder(...)`); an `Injector` interface wires targets; the container uses the declared interfaces. Avalon's `service(ServiceManager)` is a related locator-flavored case.

## Constructor vs setter (from the article)

| Aspect | Constructor | Setter |
|---|---|---|
| Valid object at creation | Yes, favored | No, can be half-configured |
| Immutability | Clear (no setter, no change) | Weaker |
| Many parameters | Hard | Easy |
| Primitive args (strings) | Positional meaning unclear | Named, clearer |
| Multiple construction routes | Awkward | Fine |
| Inheritance chains | Problematic | Fine |

Advice: begin with constructors; use setters when those problems bite; if a setter must only run at creation, name it `initFoo`. Interface injection is the most invasive: it needs many interfaces, so it is acceptable only for a small set a container requires (Avalon) and lightweight containers favor constructor and setter injection. Spring-style frameworks tend to prefer setters. (The earlier line "support both when building a container" was not re-confirmed on 2026-11-27 and is dropped.)

## Injection vs Service Locator, short form

Both break the concrete dependency; difference is *provided* vs *asked for*. Injection keeps the dependency on the container out of the component and exposes dependencies in the signature; the component cannot pull more services later. A locator makes every user depend on the locator, a problem for components shipped to unknown environments. Testing is not a discriminator; poor testability usually means poor design. See `service-locator-anti-pattern.md` for the stronger later critique.

## Configuration: code or files

- Files help when deployments differ; XML was typical.
- Code is clearer for simple apps and for conditional assembly (builder class).
- Provide a programmatic API first; layer file config on top.
- **Separate configuration from use** is the central principle, parallel to separating interface from implementation.

## Examples in modern shape (author's inference)

```ts
class Lister { constructor(private readonly finder: MovieFinder) {} }   // constructor
class Report { finder?: MovieFinder; initFinder(f: MovieFinder){ this.finder = f } } // optional setter
```
Functions: a closure or parameter is DI too: `makeLister(finder) => (director) => ...`.

## Failure modes

- Constructor with many parameters: usually mixed responsibilities (`single-responsibility-cohesion`), not a reason to switch to setters.
- Setter injection leaving fields null at use time.
- Interface per class with one implementation for "DI's sake" (`kiss-yagni-aha`).
- Container scattered across modules; configuration buried in components.

## Use when / avoid when

Use DI where a collaborator crosses an I/O boundary, has multiple implementations, or must be faked in tests. Avoid injecting pure helpers or value objects; just call them.

## How an agent should apply this

- Default to constructor injection with readonly fields.
- Switch to setters only for genuinely optional collaborators; assert completeness at start-up.
- Name the interface by the consumer's need and keep it small.
- Keep a programmatic wiring path even if a config file exists.
- Do not introduce a container for fewer than a handful of components; hand-wire.
