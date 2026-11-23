# Newman's BFF: Ownership, Count, Aggregation, Duplication

Sources: https://samnewman.io/patterns/architectural/bff/ · Last verified 2026-11-23

## Problem and solution

A general-purpose API backend begins as a cheap way to add mobile to a desktop-web system. Clients differ (screen, battery, data, interactions), so the API accumulates features for every client, becomes a single deployable many apps depend on (release bottleneck), often gets its own team (coordination overhead), and drifts into generic middleware with no business-domain shape.

BFF: split the user-facing app into a client outside the perimeter and a server-side BFF inside it, built for one user experience and usually owned by the same team as the UI.

## How many BFFs

| Model | Example | Note |
|---|---|---|
| Strict | REA: one BFF per client type (iOS, Android separate) | Easiest to reason about, most duplication |
| Shared | SoundCloud: one BFF per UI class (iOS+Android listener) | Newman is warier: shared BFFs bloat |
| Guideline | Stewart Gleadow: "one experience, one BFF" | Similar experiences may share, divergent ones should not |

Team boundary is the deciding force (Conway's Law; Pete Hodgson's observation). Newman adds that teams change more often than systems, so separate BFFs ease reassigning ownership.

## Aggregation and partial failure

One screen often needs several downstream calls (his wishlist example: Wishlist + Catalog + Inventory).
- Run independent calls in parallel; reactive/future libraries help mix parallel and sequential calls.
- Degrade gracefully: if Inventory is down, omit stock levels. The BFF decides; the client must render partial payloads.

```ts
// pseudo-code: BFF endpoint with partial failure
const [wish, stock] = await Promise.allSettled([wishlist(u), inventory(u)]);
return { items: wish.value, stock: stock.status === "fulfilled" ? stock.value : null };
```

## Duplication versus coupling

Across services Newman tolerates duplication more than in-process code because cross-service coupling hurts more. Options: shared library (cheap, couples), a new domain-modeled service, or push aggregation downstream. Rule of three before abstracting. Without BFFs the logic is duplicated across client platforms, where it is harder to spot (Hodgson).

## Desktop web and third parties

- Desktop web often needs no BFF (more bandwidth/power); it does when rendering much UI server-side or caching aggregated responses behind a reverse proxy.
- Third parties (partners, set-top boxes) are slow to change integrations; a dedicated BFF avoids keeping legacy general API versions alive for few consumers.

## Perimeter concerns

Newman is undecided on auth/logging inside the BFF: an upstream proxy (Nginx/Apache) adds latency and deployment complexity; in-BFF concerns keep it self-contained; shared libraries carry coupling. (Microsoft's page recommends handling these separately; see the second reference file.)

## When to use

Web-only: only if heavy server aggregation is needed. Mobile or third parties: consider one per party from the start. Stronger case when UI team and service teams are separate. Reconsider if deploying extra services is very costly.

## How an agent should apply this

- Ask who owns the frontend before proposing a BFF; ownership by the UI team is part of the pattern.
- Count BFFs by experience/team divergence, not by device count.
- Make aggregation parallel with explicit partial-failure contracts.
- Accept duplication across BFFs; extract only at the third repetition and prefer domain services over shared libs.
- Reject a BFF for a single UI with no aggregation need.
