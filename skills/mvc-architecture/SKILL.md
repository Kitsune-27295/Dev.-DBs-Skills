---
name: mvc-architecture
description: Use when designing, reviewing, or refactoring a Model-View-Controller (MVC) application (server-rendered web MVC, rich-client MVC, or MVP/MVVM/Humble View derivatives) or untangling fat controllers, smart views, and anemic models. Gives the Separated Presentation rule, the responsibilities of Model, View, and Controller, testability via Humble View, and common mistakes.
---

# Model-View-Controller (MVC) Architecture

One idea: enforce **Separated Presentation** — divide user-interface interaction into three distinct roles so domain state and business rules (**Model**) remain completely ignorant of how they are displayed (**View**) and how user input arrives (**Controller**). Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Fowler & Reenskaug roles)

| Term | Meaning | Test sentence |
|---|---|---|
| Separated Presentation | the foundational principle: keep all domain logic in the Model and out of UI code | "can I test the business rule without instantiating a View or HTTP context?" |
| Domain Model | holds application data, state, and business invariants; completely independent of UI and transport | "imports zero view templates, DOM nodes, or HTTP request/response types" |
| Presentation Model / ViewModel | UI-specific state or formatted projection (e.g., sort order, highlight color, form state) that wraps or projects the Domain Model | "shapes data for a specific screen without polluting the domain" |
| View | renders the Model's data to the user (HTML template, JSON representation, GUI widget) | "displays state; never mutates business state or runs SQL" |
| Controller | receives user input (HTTP request, gesture, command), decides which Model operation to invoke, and selects or updates the View | "translates input into Model calls; contains no domain math" |
| Humble View | a view stripped of all decision logic so it barely needs testing, because an independently testable Presenter/Controller/ViewModel drives it | "if there is an `if` branch with business meaning, move it out of the View" |
| Observer Synchronization | in rich-client MVC, the View observes the Model (or Presentation Model) and refreshes when state changes; in Web MVC, each HTTP request-response cycle re-renders or returns the updated View | "how the View learns the Model changed" |

## Dependency and responsibility rules

1. **The Model knows neither View nor Controller:** The Model is the core of the application. It must never import controllers, views, HTML helpers, session objects, or UI components.
2. **Controllers coordinate, Models decide:** A Controller parses input, checks transport-level concerns, invokes a method on the Model (or application service), and picks the View. Business rules, state transitions, and persistence invariants belong in the Model layer.
3. **Views are read-only projections:** A View formats data handed to it. It must never execute database queries, mutate domain state, or compute business rules.
4. **Use a Presentation Model / ViewModel when screen state diverges from domain state:** Do not add UI-only flags (e.g., `isTabExpanded`, `redHighlightColor`) to Domain Model entities, and do not cram formatting logic into raw View templates. Put screen-specific adaptation in a ViewModel / Presenter.
5. **Keep Views Humble:** GUI and template rendering are awkward and slow to test. Push all branching, formatting, and state coordination into a plain-code object (Model, ViewModel, or Presenter) that runs in fast unit tests without a browser or template engine.

## Building order

1. **Model first (test-first):** Build and unit-test the Domain Model (data invariants and state transitions) with zero UI or HTTP dependencies.
2. **Define the View contract / ViewModel:** Specify the exact data shape the screen or response needs, separate from internal persistence tables.
3. **Write the thin Controller:** Map the incoming route/action and validated input parameters to a call on the Model, then map the result to the View/ViewModel.
4. **Implement the Humble View:** Bind the template or UI component strictly to the ViewModel properties with minimal display-only conditionals.

## Tests per role

| Role | Test | Uses |
|---|---|---|
| Domain Model | unit test (fast, majority of suite) | plain language objects, no HTTP/DOM/framework |
| Presentation Model / ViewModel | unit test | domain objects or simple fixtures (verifies formatting, UI flags, sorting) |
| Controller | route / action test | mocked or in-memory Model (verifies status codes, redirects, parameter binding) |
| Humble View | snapshot or minimal end-to-end smoke test | rendered HTML/DOM on 1-2 representative flows |

## When it earns its keep

- **Worth it:** Server-rendered web applications, REST/HTML hybrid apps, and desktop/client UIs where presentation changes frequently while domain rules must remain stable and unit-testable.
- **Not worth it:** Pure headless data pipelines with no presentation variation, or deeply interactive client SPAs where fine-grained widget state and domain rules outgrow classic MVC (evolve the UI side to MVVM / Flux / Component-Store and the backend side to `hexagonal-architecture` or `clean-architecture`).

## Mistakes to catch

- **Fat Controller / Skinny Model:** Writing 400-line controller actions full of validation, calculations, and ORM queries while the Model is just an anemic data bag. Move the domain behavior into the Model (or a dedicated domain/use-case service).
- **Smart View (SQL or business logic in templates):** Calling lazy-loaded ORM relations or calculating discounts/permissions inside JSX, Razor, Jinja, or Blade templates.
- **Coupling Domain Entities directly to Form Inputs (Mass Assignment):** Binding raw HTTP request bodies directly onto persistence models instead of validating through an input DTO or command object in the Controller.
- **Polluting the Domain Model with UI concerns:** Adding CSS class names, localized display strings, or pagination widget state to core domain entities instead of using a ViewModel / Presentation Model.

## Deep references

- [MVC lineage and Separated Presentation](references/mvc-lineage-and-separated-presentation.md) — read when checking the model/view/controller dependency direction or comparing GUI architecture styles.
- [Web MVC, SPAs and the two strands](references/web-mvc-spas-and-two-strands.md) — read when applying MVC to server-rendered pages or single-page apps.
- [MVP, Humble View and testability](references/mvp-humble-view-and-testability.md) — read when making a UI testable or choosing between presenter and presentation-model variants.
