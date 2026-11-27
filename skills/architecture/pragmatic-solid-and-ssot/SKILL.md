---
name: pragmatic-solid-and-ssot
description: "One-page overview for applying SOLID without ceremony: what each principle actually asks for, the Liskov and Interface Segregation checks this pack keeps here, the no-ceremony test (no IFoo for a single implementation behind no I/O or test seam), and a pure core with thin I/O wrappers. Points to the owners of everything deeper: `ssot-and-dry` (DRY, Bounded Context limits), `kiss-yagni-aha` (Rule of Three, wrong abstraction), `single-responsibility-cohesion`, `open-closed-principle`, `dependency-inversion-composition-root`. Use when reviewing code for SOLID or interface overuse, checking whether a subtype or an interface fits its callers, or separating a pure core from I/O. Not for deciding whether to share or duplicate code (use `ssot-and-dry`) or when to abstract (use `kiss-yagni-aha`)."
---

# Pragmatic SOLID & Abstraction Discipline

One idea: treat every abstraction (shared helper, base class, `IFoo` interface) as carrying real coupling cost, and let each SOLID principle guide mid-level module structure instead of adding ceremony to trivial code. This is the overview; each principle's deep dive has one owner (see the Deep references). Sources and claims: [references/sources.md](references/sources.md).

## 1. DRY and its limit (pointer)

DRY means one authoritative representation of each piece of *knowledge* (the Pragmatic Programmer's wording), not removal of look-alike syntax; it applies inside a Bounded Context, and across contexts you keep local models and translate at the boundary. The acid test, the duplication kinds, coincidence tests and context-sharing rules live in `ssot-and-dry`; do not restate them here.

## 2. SOLID pragmatically (what each principle means)

Martin's *SOLID Relevance* (2020) argues the principles still guide how code is structured at module and component level; they are not a license for mechanical ceremony.

| Principle | Core rule | Misreading to reject |
|---|---|---|
| **S** Single Responsibility | Group code that changes for the same reason, separate what changes for different reasons; the reason traces to one stakeholder group (`single-responsibility-cohesion`) | "A class or function must do one tiny thing": over-fragmented pass-through helpers (`codebase-design`) |
| **O** Open-Closed | Change behavior by adding code behind a stable boundary instead of editing tested core policy (`open-closed-principle`) | Speculative plugin factories for one hard-coded implementation |
| **L** Liskov Substitution | Callers must not be confused by any implementation of an interface; it concerns subtyping, including duck-typed implied interfaces, not only inheritance. Smell: `instanceof` checks at call sites, `NotImplementedError` in an interface method, or a no-op override (Refused Bequest) | Treating a shared base class as proof of substitutability |
| **I** Interface Segregation | Keep interfaces small so clients do not depend on what they do not use; the cost is highest in statically typed, separately built code (an unused change can force a rebuild and redeploy) and lower, but not zero, in dynamic languages | Wrapping every concrete `UserService` in a 1-to-1 `IUserService` "for SOLID" |
| **D** Dependency Inversion | Source dependencies point at abstractions the policy owns, especially across architectural boundaries such as database or HTTP (`dependency-inversion-composition-root`, `clean-architecture`, `hexagonal-architecture`) | Inverting stable standard-library or pure value helpers |

**No-ceremony rule (this skill's own guidance; Martin's *Interface Considered Harmful* is a language-design dialogue about the Java and C# `interface` keyword and says nothing about single-implementation interfaces or test seams):** do not create an `IFoo` for a concrete `Foo` with one implementation that sits behind no I/O boundary or test seam. `codebase-design` puts it as: one adapter is a hypothetical seam, two adapters a real one. Where typing is structural or dynamic (TypeScript, Go, Python), a boundary can be a type alias, protocol or function type declared by the consumer when the second implementation appears.

## 3. Abstraction timing (pointer)

Do not extract on the second occurrence; check that the copies share an actor and a reason to change before unifying, and re-inline a shared helper that has grown mode flags. The Rule of Three, the Wrong Abstraction and AHA, with recovery steps, live in `kiss-yagni-aha`; the four costs of building ahead are in `yagni-evolutionary-architecture`.

## 4. KISS, pure core and thin I/O wrappers

From the Harvard Kempner handbook's design chapter, plus this skill's wording where marked:

- **KISS:** the simplest construct that works: plain functions and data containers, deep inheritance avoided (the page does not name "composition over inheritance"; that phrase is this skill's wording). Ordering lives in `kiss-yagni-aha`.
- **Pure core, thin shell:** keep calculation pure (deterministic, no I/O, no hidden global state) and push file, network, logging and retries to a thin outer wrapper, with dependencies injected so tests can substitute doubles (`tdd`, `codebase-design`).
- **Specific errors *(skill wording: the page asks for clear, specific error messages; it does not say "fail fast")*:** validate external input at the boundary (`defensive-domain-modeling`) and raise errors that name the offending value, instead of swallowing exceptions or returning ambiguous defaults.

## Quick Decision Checklist

1. Do these two blocks answer to the same rule and actor, or only look alike? If alike only, or in different contexts, keep them separate (`ssot-and-dry`).
2. Are there fewer than three real callers, or do callers already pass mode flags? If so, duplicate cleanly or re-inline; defer unifying (`kiss-yagni-aha`).
3. Does this interface separate policy from a varying I/O dependency or test seam with two or more implementations? If it is 1-to-1 ceremony around pure code, delete the indirection.
4. Does any implementation make callers branch on its type or throw "not supported"? If so, the abstraction breaks Liskov: fix the contract, not the callers.
5. Can the logic move into a pure function with a thin I/O caller? If so, separate policy from side effects.

## Deep references

- [Martin SOLID primary-source notes](references/martin-solid-primary-source-notes.md) — read to cite SRP, OCP, LSP, ISP or DIP accurately and see where this skill's wording goes beyond the posts.
- [Interface Considered Harmful: careful reading](references/interface-considered-harmful-reading.md) — read before citing the article against `IFoo` boilerplate.
- [Harvard Kempner design principles notes](references/harvard-kempner-design-principles-notes.md) — read for pure-core, thin-adapter and layering guidance and what the page does not say.
- [Trigger evals](references/trigger-evals.md) — read when tuning the description.
- [Sources](references/sources.md) — retrieved statuses, reading limits, claims not adopted.
- Owners, not repeated here: `ssot-and-dry`, `kiss-yagni-aha`, `yagni-evolutionary-architecture`, `single-responsibility-cohesion`, `open-closed-principle`, `dependency-inversion-composition-root`.
