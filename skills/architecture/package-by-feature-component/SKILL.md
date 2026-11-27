---
name: package-by-feature-component
description: "Organize or refactor folder, package and module structure so a change opens one place: replace horizontal Package by Layer (controllers/, services/, repositories/) with Package by Feature or Package by Component (one public interface per business capability, implementation hidden), and choose and enforce package-private or internal visibility with architecture tests. Use when a folder tree is grouped by technical layer and changes keep touching many folders, or when choosing between feature folders and components. Not for per-request slices with CQRS (use vertical-slice-architecture), repo names that announce the domain (use screaming-architecture), repository root layout (use repository-root-monorepo-architecture) or the Common Closure Principle itself (use single-responsibility-cohesion)."
---

# Package by Feature & Package by Component (vs. Package by Layer)

One idea: stop grouping files by technical stereotype (`controllers/`, `services/`, `repositories/`, `models/`), where every business change touches every folder and every type must be `public`; group by what changes together instead, either as **Package by Feature** (one folder per feature) or **Package by Component** (one coarse business capability with a single public interface and hidden internals). Sources and what was read: [references/sources.md](references/sources.md).

> **Scope boundary:** the Common Closure Principle (why co-changing code belongs together) is owned by `single-responsibility-cohesion`. Per-request slices and CQRS: `vertical-slice-architecture`. Names that announce the domain: `screaming-architecture`. Root layout and catch-all folders at repo level: `repository-root-monorepo-architecture`. Dependency direction: `clean-architecture`. This skill owns the choice between layer, feature and component, and how to enforce the boundary.

## 1. The three packaging styles

| Style | Top-level structure | Visibility of internals | Best fit |
|---|---|---|---|
| **Package by Layer** | `Web`, `Business`, `Data` (projects or folders) | Types must be `public` so layers can call each other | Avoid as the top-level split |
| **Package by Feature** | `orders/place-order/`, `policies/renew-policy/`, each holding command, handler, validator, repository, view model | Mostly feature-local; share little across features | Many small, independent features with little shared code |
| **Package by Component** | `orders/` exposes one public interface; services, repositories and entities stay internal; delivery (web, CLI) is separate and calls only the interface | Only the component interface is public | Clear business capabilities needing encapsulation or later extraction |

The author whose article this skill is built on (Jovanovic) recommends: start with components, and organize features inside each component. A component resembles a module in a modular monolith (`modular-monolith-architecture`).

## 2. Why Package by Layer fails

1. One feature spans several projects, so a change touches all of them (the co-change problem owned by `single-responsibility-cohesion`).
2. `public` types let any class bypass a layer: a controller can call a repository directly, which hides dependencies.
3. The folder tree shows plumbing, not what the application does.
4. Layers are a dependency-direction idea (`clean-architecture`), not a mandate to scatter one feature across projects.

## 3. Choose feature or component

- Choose **feature** folders when the endpoint maps almost 1:1 to a use case and features rarely share code.
- Choose **component** when a business capability has several entry points or needs a hard boundary; other code reaches its data only through the component interface.
- Default for a new codebase: components with feature folders inside (the article's recommendation, a judgment, not a rule).
- A tiny tool with 2 or 3 files stays flat (`repository-root-monorepo-architecture`).

## 4. Enforce the boundary (escalate only on failure)

1. **Visibility first:** make implementations `internal`/package-private/unexported (add `sealed` in C#), expose only the component interface. Language nuance: C# `internal` is scoped to an assembly, so inside one project it cannot stop every violation; Java package-private works per package.
2. **Architecture tests:** fail the build on a forbidden dependency (for example controllers may depend only on component interfaces). Tools and the general idea live with `clean-architecture` and `layered-n-tier-architecture`; add the test in the same change that introduces the component.
3. **Separate assembly/module per component:** strongest, but adds build complexity, slower IDE navigation and more deployable files; use only after a violation the first two steps could not stop.

Never widen visibility to make a test compile; test through the public interface. Mantra from the source: pragmatism beats purism. Detail: [references/enforcing-component-encapsulation.md](references/enforcing-component-encapsulation.md).

## 5. Refactoring order

1. Inventory the domain nouns and use-case verbs hidden in the layer folders.
2. Create one folder per capability, named for the business, not a framework.
3. Move one vertical slice at a time with its tests (`layered-refactor`): endpoint, handler, validator, DTOs, queries.
4. Tighten visibility right after each move.
5. Add the architecture test, then repeat.

## 6. Testing

- **Component:** black-box tests through the public interface, against a test database or in-memory adapter; internals refactor freely.
- **Feature:** a slice test (request to response plus state) co-located with the feature folder.

## Mistakes to catch

- **Fake package by feature:** `controllers/orders/` on top while `services/` and `models/` stay shared and public.
- **Everything still exported:** files moved into `orders/` but the repository re-exported so `shipping/` calls it directly.
- **Cross-feature imports:** `checkout/` importing private types from `cart/`; go through the owner's interface instead.
- **A catch-all folder reborn:** `common/` or `shared/` refilled; a type used by one feature belongs in it, a truly shared one gets a specific name.

## Quick Decision Checklist

- [ ] Is code grouped by what changes together, not by technical stereotype?
- [ ] Would a typical change open one folder?
- [ ] Did I choose feature or component on purpose (section 3)?
- [ ] Are implementations hidden and only the component interface public?
- [ ] Does a build-failing check guard the boundary?
- [ ] Do features reach each other only through a public interface?

## Deep references

- [Layer vs feature vs component trade-offs](references/layer-feature-component-trade-offs.md) - choosing the top-level packaging scheme
- [Enforcing component encapsulation](references/enforcing-component-encapsulation.md) - visibility, assemblies and architecture tests ladder
- [Trigger evals](references/trigger-evals.md) - should-trigger and near-miss prompts for the description
- [Sources](references/sources.md) - retrieved statuses, reading limits, claims not adopted
