---
name: dependency-inversion-composition-root
description: "Wire dependencies so business code never builds or looks up its collaborators: constructor vs setter vs interface injection, the Composition Root (one place near the entry point, Pure DI or a container confined to it), why Service Locator hides dependencies, and separating configuration from use. Architecture-level dependency direction lives in `clean-architecture` and `hexagonal-architecture`; the overview lives in `pragmatic-solid-and-ssot`. Use when wiring dependencies, removing `new` or static lookups from business code, choosing constructor or setter injection, deciding where a container may be referenced, or reviewing locator and container usage."
---

# Dependency Inversion, DI Forms & the Composition Root

One idea: **business code declares what it needs (an abstraction it owns) and receives it; exactly one place near the program entry point decides which concrete things to build and connects them.** Everything else never calls `new` on collaborators and never asks a registry for them. Sources and fetch outcomes: [references/sources.md](references/sources.md). Deep dive; the overview DIP row is in `pragmatic-solid-and-ssot`.

Boundaries with neighbors: the *architecture-level* rule (domain at the center, adapters outside, port ownership) is `clean-architecture` and `hexagonal-architecture`; *adding variants* behind the abstraction is `open-closed-principle`; *one fact, one home* is `ssot-and-dry`; *who owns what by change axis* is `single-responsibility-cohesion`; test shapes using fakes are `testing-pyramid-and-shapes`; avoid needless interfaces: `kiss-yagni-aha`.

---

## 1. Mechanics: from `new` inside to injected

Naive: `MovieLister` constructs `ColonDelimitedMovieFinder("movies1.txt")`, so the lister is welded to one storage and one file. Fix: the lister depends on a `MovieFinder` interface (the plugin seam), and *something else* supplies the implementation. Fowler named the specific technique **Dependency Injection** because "Inversion of Control" is too generic; the inversion is in how a plugin implementation gets located. Two families remove the weld: **injection** (provided to you) and **service locator** (you ask). Detail: [references/di-forms-and-tradeoffs.md](references/di-forms-and-tradeoffs.md).

## 2. Choosing the DI form

| Form | How | Choose when | Watch out |
|---|---|---|---|
| **Constructor** (default) | Dependencies as constructor parameters | Always first; object valid from birth; immutability obvious | Many params (a design smell: see `single-responsibility-cohesion`), positional primitives, multiple construction paths, inheritance chains |
| **Setter** | `setFinder(x)` after creation | Optional deps, many params, named values | Object can exist half-configured; name init-only setters clearly (`initFoo`) |
| **Interface** | Component implements `InjectFinder` etc. | Rarely; framework-driven | Invasive: many marker interfaces |

Recommendation (Fowler): start with constructor injection, move to setter only where constructor problems appear. The bigger principle is **separating configuration from use**.

## 3. The Composition Root

Definition (Seemann): a (preferably unique) place where modules are composed, **as close as possible to the entry point** (`main`, application startup, custom controller factory). Rules:

1. Only *applications* have a Composition Root; libraries and frameworks expose DI-friendly constructors/factories and let the app compose.
2. Pure DI (hand-written `new` wiring) or a DI Container both fit; a container is referenced **only** from the root, and its Register-Resolve-Release cycle happens entirely there.
3. One root per process, as close to the entry point as possible (the article says composing earlier only limits options; "no later than the first request" is this skill's inference).
4. Application classes never see the container.
5. Modules should not register themselves with a container (couples them to it and to each other); configure them from the root or discover them by convention there (author's comment replies).

```python
# main.py -- the only file that knows concrete types
def build_app(cfg):
    db = PostgresRepo(cfg.dsn)
    mailer = SmtpMailer(cfg.smtp)
    billing = BillingService(repo=db, notifier=mailer)   # constructor injection
    return Api(billing)
if __name__ == "__main__": build_app(load_config()).run()
```
Structure, per-framework entry points, multi-app and library cases: [references/composition-root.md](references/composition-root.md).

## 4. Service Locator

A locator is a registry (often static/singleton) classes query: `Locator.Resolve<IOrderValidator>()`. It decouples from implementations but **hides dependencies**: the constructor says nothing, so missing registrations fail at run time, adding a call can break production without a compile error, and judging whether a change is breaking requires understanding the whole app. Variants (concrete or abstract/injected locator) do not fix this. Fowler judged locator and injection roughly equivalent for *application* classes (slight simplicity edge to the locator) and injection better for *reusable components*; Seemann's position is harder: an anti-pattern (later also called a SOLID and encapsulation violation), acceptable only inside the Composition Root. Dynamic string-keyed locators are the worst (untraceable keys). Full comparison: [references/service-locator-anti-pattern.md](references/service-locator-anti-pattern.md).

**Rule for agents:** in application/business code, reject `Locator.get(...)`, `container.resolve(...)`, `ServiceProvider` parameters, and static singletons; require constructor parameters. Allowed: locator/container *inside* the Composition Root, framework-owned factories at true entry points, and (legacy, temporary) an ambient context as a stepping stone.

## 5. Configuration: code vs files

- Programmatic API first; file-based config is an optional layer on top.
- Config files suit many deployment environments; code suits simple apps or conditional assembly (a builder beats XML).
- Keep configuration (which implementation, which DSN) separate from the code that uses services.

## 6. DIP specifics: who owns the abstraction

Policy owns the interface (`PaymentGateway` defined in the domain, implemented in infrastructure). If the interface lives next to its implementation and mirrors its API, you have inverted nothing. Do not invert stable, pure things (standard library, value helpers). Architecture-level layout: `clean-architecture`, `hexagonal-architecture`.

## 7. Detection heuristics and review table

| Signal | Verdict |
|---|---|
| `new SomeAdapter()` in domain/service code | Move to root; inject |
| `Locator.get`, `container.resolve`, static `Instance` in business code | Service Locator: replace with constructor param |
| Container type imported outside the root | Leak; confine it |
| Constructor with 7+ params | Responsibilities mixed, not a DI problem |
| Interface per class with one implementation, no seam | Ceremony (`kiss-yagni-aha`) |
| Domain package imports ORM/HTTP SDK | Arrow wrong way |
| Tests need a global reset between cases | Hidden static state |
| Dependency registered in two places (root + module) | SSOT breach |

## Quick Decision Checklist

1. Does the class receive every collaborator through its constructor?
2. Is there exactly one Composition Root, near the entry point?
3. Is the container (if any) referenced only there?
4. Does the abstraction belong to the consumer, and is there a real seam (I/O, 2+ implementations, test double)?
5. Are optional/many dependencies handled by setters or a builder rather than a giant constructor?
6. Can you build the whole graph in a test without a container?

## Deep references

- [DI forms and trade-offs](references/di-forms-and-tradeoffs.md) — read when choosing constructor vs setter vs interface injection or code vs file configuration.
- [Composition Root](references/composition-root.md) — read when placing wiring code, using a container, or structuring libraries and multiple apps.
- [Service Locator anti-pattern](references/service-locator-anti-pattern.md) — read when reviewing locator/container use or migrating legacy lookups to injection.
- [Trigger evals](references/trigger-evals.md) — read when tuning this skill's description.
- [Sources](references/sources.md) — fetch status per URL, reading limits, claims not adopted.
