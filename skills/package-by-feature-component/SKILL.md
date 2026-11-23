---
name: package-by-feature-component
description: Use when organizing or refactoring folder, package, and module structures in a codebase — replacing horizontal Package by Layer (controllers/, services/, repositories/) with Package by Feature or Simon Brown's Package by Component, applying the Common Closure Principle (CCP), and enforcing package-private / internal encapsulation.
---

# Package by Feature & Package by Component (vs. Package by Layer)

One idea: stop grouping files by technical stereotype (`controllers/`, `services/`, `repositories/`, `models/`) where every business change touches every folder and every class must be `public`; instead, group code by **what changes together (Common Closure Principle)** using **Package by Feature** (one vertical slice / feature per folder) or **Package by Component** (cohesive business capability + its persistence encapsulated behind one public facade). Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary & The Three Packaging Styles (Simon Brown & Milan Jovanović)

| Packaging Style | Top-Level Folder Structure | Visibility of Internal Classes | Best Fit |
|---|---|---|---|
| **1. Package by Layer** (Traditional Horizontal) | `controllers/`, `services/`, `repositories/`, `models/` | Almost everything must be **`public`** so layers can call each other across folders/projects | Small CRUD apps where technical layers are tiny and rarely change independently |
| **2. Package by Feature** (Vertical Feature Folders) | `orders/place-order/`, `orders/cancel-order/`, `policies/renew-policy/` (each holds its controller/endpoint, handler, validator, DTO, and repo/query) | Everything inside a feature folder is **`internal` / package-private** except the endpoint/request entry point | Feature-rich applications, APIs, and `vertical-slice-architecture` systems |
| **3. Package by Component** (Simon Brown's Hybrid) | `orders/` (owns `OrdersComponent` public service + internal domain + internal data access), kept separate from a thin top-level `web/` UI/API driver | Web/UI calls **only** the component's public interface; the component's entities, services, and DB repositories are **`internal` / package-private** | Medium-to-large modular systems and `modular-monolith-architecture` where multiple UIs/drivers share cohesive domain components |

## Core architectural rules and invariants

1. **Apply the Common Closure Principle (CCP):** *"Gather into packages those classes that change for the same reasons and at the same times."* When a product manager asks for a change to **Policy Renewal**, you should open `features/policies/renew/` (or the `policies/` component), not hunt across 4 projects and 12 horizontal folders.
2. **Use Access Modifiers (`internal`, package-private, unexported) to enforce boundaries at compile time:**
   - The fatal flaw of **Package by Layer** is that placing `PolicyService` in `services/` and `PolicyRepository` in `repositories/` forces `PolicyRepository` to be `public` — meaning *any* controller or unrelated service in the entire codebase can import and bypass it.
   - When you **Package by Feature** or **Package by Component**, co-locating the business logic and data access inside the same package allows you to mark repositories, internal domain helpers, and DB entities **`internal` / package-private** so unauthorized cross-feature coupling is a **compiler error**, not just a code-review guideline.
3. **Layers are a dependency-direction concept, not a folder mandate:** As Jovanović highlights ("Clean Architecture: The Missing Chapter"), Uncle Bob's concentric circles (`clean-architecture`) define **which direction dependencies point**, not a requirement to scatter one feature across 4 separate `.csproj` / npm / Java packages. You can enforce inward dependency rules *inside* a feature or component package while keeping all files for that feature together.
4. **Choose Package by Feature vs. Package by Component based on UI/Driver coupling:**
   - Choose **Package by Feature** when the HTTP endpoint / UI route is tightly aligned 1:1 with the business use case (the feature folder contains the endpoint + handler + data access).
   - Choose **Package by Component** (Simon Brown) when the User Interface / HTTP delivery mechanism is separate from a coarse-grained business component (the component bundles business logic + persistence behind one public interface, and multiple drivers like Web, CLI, or GraphQL call that component).
5. **Delete catch-all horizontal dumping grounds (`utils/`, `helpers/`, `common/`, `shared/models/`):** If a class is used by only one feature, move it into that feature's folder and make it private. If it is genuinely shared by 3+ features, put it in a specifically named domain/technical package (e.g., `money/`, `clock/`, `auth-context/`).

## Refactoring order (From Package by Layer to Package by Feature/Component)

1. **Inventory the business capabilities / features:** List the actual domain nouns and use-case verbs hidden inside `controllers/`, `services/`, and `repositories/`.
2. **Create top-level domain/feature folders (`src/features/<domain>/<use-case>` or `src/modules/<component>`):** Name folders after business capabilities (`orders/`, `billing/`, `inventory/`), never after frameworks or technical stereotypes (`screaming-architecture`).
3. **Move one vertical slice at a time with its tests (`layered-refactor`):** Colocate the endpoint/controller, use-case handler, validator, DTOs, and persistence queries for that feature into its folder.
4. **Tighten visibility immediately after moving:** Change `public` repositories, entities, and internal helpers to `internal` / package-private / non-exported so only the feature entry point or component interface remains public.
5. **Add an import-boundary check in CI:** Forbid Feature A from importing internal files of Feature B (`eslint-plugin-boundaries`, `dependency-cruiser`, `ArchUnit`, `NetArchTest`).

## Testing strategy

| Packaging Approach | Primary Test Scope | Benefit |
|---|---|---|
| **Package by Component** | Component-level black-box test through the component's public interface (against a real test DB or in-memory adapter) | Internal classes (`internal` services & repositories) can be refactored freely without breaking tests coupled to private implementation details |
| **Package by Feature** | Vertical slice test (Request/Endpoint $\to$ Response + DB state assertion) co-located inside the feature folder (`place-order.test.ts`) | Deleting or changing a feature deletes/updates its test in the exact same folder |

## When it earns its keep

- **Worth it:** Almost any application with more than 3-4 domain concepts or more than 10 endpoints. Package by Feature and Package by Component scale cleanly from a single deployable monolith to a `modular-monolith-architecture` and allow extracting a microservice later by simply moving one self-contained folder.
- **Not worth it:** A tiny single-purpose microservice or CLI utility with only 2-3 files total (where a flat folder with no subdirectories is idiomatic; see `repository-root-monorepo-architecture`).

## Mistakes to catch

- **"Fake Package by Feature" (Horizontal layers at the root, feature folders only inside `controllers/`):** Putting `controllers/orders/` at the top while still keeping a monolithic shared `services/` and `models/` folder where everything is `public`. Move the whole vertical stack into `orders/`.
- **Leaving everything `public` / exported inside a feature folder:** Moving files into `features/orders/` but exporting the internal repository and DB row helpers from `index.ts` so `features/shipping/` still calls `OrderRepository` directly.
- **Cross-feature spaghetti imports:** `features/checkout/` importing private DTOs or handlers from `features/cart/`. Communicate across features only via a narrow public component facade or in-process domain events.

## Deep references

- [Layer vs feature vs component trade-offs](references/layer-feature-component-trade-offs.md) — choosing the top-level packaging scheme
- [Enforcing component encapsulation](references/enforcing-component-encapsulation.md) — internal, assemblies and architecture tests ladder
