# The Composition Root

Sources: https://blog.ploeh.dk/2011/07/28/CompositionRoot/ · https://martinfowler.com/articles/injection.html · Last verified 2026-11-27

## Definition (Seemann, 2011)

Application code receives dependencies through constructors but never composes them. A **Composition Root** is a preferably unique location where modules are composed, as close as possible to the application's entry point, where the whole object graph is finally assembled.

Entry points named in the article: `Main` for console apps, `global.asax` plus a custom controller factory for ASP.NET MVC, `Application.OnStartup` for WPF, a custom `ServiceHostFactory` for WCF. (Modern equivalents, inference: framework bootstrap/`main`, a factory registered with the web framework, `create_app()`.)

## Principles from the article

- It is **application infrastructure**: only applications have one; libraries and frameworks should not.
- Implement it with **Pure DI** (hand wiring, "Poor Man's DI") or a **DI Container**.
- A container is referenced only from the root; the **Register-Resolve-Release** pattern is applied entirely inside it.

## Positions from the discussion thread (author's secondary source)

| Topic | Position |
|---|---|
| One root per process | Enough regardless of app complexity; composing earlier only limits options |
| Modules registering own types | Couples modules to the container and each other; configure modules from the root, or scan an add-in folder by convention |
| Libraries / SDKs | No root; be DI-friendly and optionally offer Facades to keep the learning curve gentle |
| Service Locator inside the root | Acceptable; anti-pattern only when application code queries it |

## Anatomy

```
entry point
  load config
  build leaf adapters  (db, http client, clock)
  build services       (take adapters via constructor)
  build the top object (controller/router/CLI)
  run
```
Dependencies flow leaves to top; no class in the graph reaches back to the root.

Per-request lifetimes (inference): the web framework calls a factory in the root once per request; the factory builds the per-request subgraph and releases it.

## Pure DI vs container

| Aspect | Pure DI | Container |
|---|---|---|
| Visibility | Compile-time checked, explicit | Convention/reflection, runtime errors |
| Boilerplate | Grows with app | Lower |
| Lifetime mgmt | Manual | Built in |
| Start with | Yes, up to a handful of services | When wiring becomes unwieldy |

Either way the *shape* is identical: only the root knows concrete types.

## Failure modes

- Container injected into classes (that is Service Locator).
- Composition scattered in `__init__`/static initializers.
- Several roots drifting apart for the same process.
- Library composing its own defaults and forcing them on apps.
- Root growing business logic; it should only construct and connect.

## Use when / avoid when

Always have one root for an application. Avoid a root in reusable libraries; export constructors/factories instead.

## How an agent should apply this

- Locate the entry point; place or find the wiring there; do not add `new Adapter()` elsewhere.
- Grep for container imports outside the root and move them in.
- In libraries, accept dependencies via parameters and provide an optional factory for common defaults.
- Keep the root declarative and test it with one smoke test that builds the full graph.
- Prefer Pure DI until the wiring is clearly painful; then adopt a container confined to the root.
- Combine with `hexagonal-architecture`: the root is where adapters meet ports.
