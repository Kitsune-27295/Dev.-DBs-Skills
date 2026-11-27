# Newman's BFF: Ownership, Count, Aggregation, Duplication

Sources: https://samnewman.io/patterns/architectural/bff/ (page dated 2015-11-18) · Last verified 2026-11-27

## Problem and solution

A general-purpose API backend starts as a cheap way to add mobile to a desktop-web system. Clients differ (screen, battery, data, interactions), so the API accumulates features for every client, turns into one deployable many apps depend on, often gets its own team, and drifts toward generic middleware.

The BFF answer: split the user-facing app into a client outside the perimeter and a server-side BFF inside it, built for one user experience and typically maintained by the same team as the UI.

## How many BFFs

| Model | Example on the page | Note |
|---|---|---|
| One per client type | Newman's stated preference | Easiest to reason about; most duplication |
| Shared across similar clients | SoundCloud: one BFF for the iOS and Android listener apps | Allowed; the divergence of the experiences decides |
| Guideline | Stewart Gleadow: "one experience, one BFF" | Cited on the page |

Newman credits Pete Hodgson with the observation that BFFs work best aligned with team boundaries. Phil Calcado is credited with the name; SoundCloud and REA are named as places Newman has seen it.

## Aggregation and partial failure

One screen often needs several downstream calls (his wishlist example: Wishlist, Catalog, Inventory). The page poses the partial-failure case as a question: if only Inventory is down, would it be better to degrade the response by dropping the stock indicator? The decision and the contract with the client are your design.

```ts
// own sketch, not from the page: partial failure in a BFF endpoint
const [wish, stock] = await Promise.allSettled([wishlist(u), inventory(u)]);
if (wish.status === "rejected") throw wish.reason;        // required part
return { items: wish.value, stock: stock.status === "fulfilled" ? stock.value : null };
```

Timeouts, bulkheads and breakers around each call: `circuit-breaker-retry-telemetry`. Gateway-level aggregation mechanics: `api-gateway-reverse-proxy`.

## Duplication versus coupling

Newman applies the "third time" rule of thumb for creating an abstraction even at service level. Without BFFs, duplicated logic tends to end up in the clients, where it is harder to see (Hodgson).

## Desktop web and third parties

- Desktop web on capable devices can call downstream services directly; a BFF helps for server-side rendering or caching aggregated responses.
- Third-party examples on the page: royalty data, Facebook integration, set-top box streaming. A dedicated BFF spares you from keeping old general-API versions alive for slow-moving integrators.

## Perimeter concerns

Newman is undecided on auth and logging. He leans toward an upstream layer such as Nginx or Apache, while noting the latency cost can make a self-contained BFF attractive.

## When to use

Newman: a web-only app needs a BFF only with heavy server-side aggregation; for mobile or third parties consider one per party early. The full decision lives in the parent skill, section 3.

## How an agent should apply this

- Ask who owns the frontend before proposing a BFF.
- Count BFFs by experience and team divergence, not device count.
- Give every aggregated screen an explicit partial-failure contract.
- Do not extract shared code until the third repetition; prefer a domain service over a shared library.
