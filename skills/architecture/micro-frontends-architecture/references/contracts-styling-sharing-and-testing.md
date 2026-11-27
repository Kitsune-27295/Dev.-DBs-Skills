# Micro Frontends: Styling, Shared Libraries, Communication, Backend and Testing

Sources: https://martinfowler.com/articles/micro-frontends.html · Last verified 2026-11-23

## Styling
Global CSS collides when teams write selectors independently. Options: a naming convention (BEM), preprocessor nesting, CSS Modules / CSS-in-JS, Shadow DOM. Any works if styles stay predictable when composed.

## Shared component libraries
Helpful for consistency, but premature extraction causes churn: build locally first, extract when the API is proven. Share primitives only, never domain logic. Use a custodian model: one owner guards quality, anyone may contribute.

## Communication
Keep it minimal. Options: custom events, container-supplied props/callbacks, URL routing. Each app may own its own store; avoid shared state. Routes and events are contracts and can be verified with consumer-driven contracts.

## Backend and auth
Prefer full-stack teams (UI to infrastructure). Give each micro frontend a BFF when feature work would otherwise queue behind other teams. The container usually owns authentication and passes the token down.

## Testing
Thorough unit tests per micro frontend; few functional tests that only prove the page assembles; contract tests instead of fragile shared integration environments.

## Example (pseudo-contract)
```
event "cart:item-added"  payload { sku, qty }     // owned by cart team, versioned
route  /restaurant/:id                            // owned by browse team
```

## How an agent should apply this
- Namespace CSS, events and storage keys by team from day one.
- Refuse a shared "common" package containing business logic; duplicate first.
- Define each cross-app event or route as a versioned contract with a consumer test.
- Keep auth in the container; add a BFF per app only when ownership requires it.
- Limit end-to-end tests to assembly smoke tests.
