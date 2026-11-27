# "Interface Considered Harmful": A Careful Reading

Sources: https://blog.cleancoder.com/uncle-bob/2015/01/08/InterfaceConsideredHarmful.html · Last verified 2026-11-27

## What the article is

A Socratic dialogue (Jan 2015) in which Martin questions a defender of the Java/C# `interface` keyword until the defender concedes it is harmful. It is an argument about **language design**, not a style guide for writing `IFoo`/`Foo` pairs.

## The argument, step by step

1. An abstract class with a single abstract method and no state looks the same as an interface; the real differences are keyword-level and exist because the language bans multiple class inheritance.
2. The stated reason for the ban is the "deadly diamond": with `B`, `D1`, `D2` (both extending `B`) and `M` extending both, a private field `i` in `B` leaves it unclear whether `M` has one copy or two.
3. Martin counters that every Java class implicitly derives from `Object`, so the language would have a diamond everywhere, and that C++, Eiffel, Ruby and CLOS handle diamonds, so it is a solved problem.
4. His guess at motive: designers invented `interface` to sidestep solving multiple inheritance. (He admits it is a rude guess; it is opinion.)
5. Coupling through keywords: changing a type from class to interface forces every derivative from `extends` to `implements` (C#'s colon syntax avoids this).
6. Observer example: a `MyObservableWidget` that is both a `MyWidget` and a `Subject` cannot be written; the three workarounds are subclassing `Subject` in widgets (mixed concerns), copying `register`/`notify` (duplication), or delegation boilerplate (duplicated delegation). Conclusion: the language forces a choice between violating separation of concerns and duplicating code.

The article gives no list of cases where interfaces are justified and does not mention test seams or ports.

## What it does and does not support

| Claim | Supported by this article? |
|---|---|
| "Do not wrap every class in a 1-to-1 `IFoo`" | Not directly; this is the skill's own pragmatic rule (and `codebase-design`'s seam rule) |
| "The `interface` keyword forces premature class-vs-interface commitments that leak into every subtype" | Yes (point 5) |
| "Interfaces exist mainly to avoid multiple inheritance" | Martin's position, stated as such |
| "Abstraction boundaries are bad" | No; his OCP/DIP posts promote abstract policy boundaries |

So the safe citation is: Martin argues the keyword is a language workaround that couples subtypes to the supertype's kind; combine with SOLID Relevance (DIP/ISP still matter) to avoid the misreading "never abstract".

## Practical translation (my inference)

- Where the language has structural typing (TypeScript, Go) or duck typing (Python), a boundary can be a type alias, protocol or function type declared at the consumer, with no extra file and no `I` prefix.
- Where the language has only nominal interfaces (Java, C#), an interface is still the tool for a real seam: two implementations, or a test double at an I/O edge.
- Hiding a class behind an interface does not decouple callers from the class's behavior; it decouples compile-time dependency. If nothing varies, nothing was decoupled.

## Failure modes

- Interface-per-class "for SOLID" with a single implementation, doubling files and rename work.
- Fat interfaces that every mock must satisfy.
- Inheriting from a base class to get one method (the Observer trap) when delegation or a small function would do.

## How an agent should apply this

- Cite this article only for the keyword/coupling argument; cite `codebase-design` and the seam rule for "one adapter is hypothetical".
- Before adding an interface, name the second implementation or the test double that needs it; if none exists, use the concrete type.
- In structural-typing languages, declare the minimal shape at the consumer when the second implementation appears.
- Prefer composition/delegation (or a function parameter) over inheritance to reuse behavior like Observer registration.
- Do not remove existing interfaces that sit on real I/O boundaries just because of this article.
