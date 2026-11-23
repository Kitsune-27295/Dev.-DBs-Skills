---
name: bff-pattern
description: Use when designing, reviewing, or refactoring a Backend for Frontend (BFF) or API Gateway layer in front of downstream services — tailoring an edge API per client experience (Desktop Web, Mobile iOS/Android, Voice/IoT, Third-Party API), aggregating chatty microservice calls, and aligning BFF ownership with the frontend team. Gives Sam Newman's BFF rules, BFF vs General-Purpose API Gateway distinction, team ownership invariants, and common mistakes.
---

# BFF (Backend for Frontend) Pattern

One idea: instead of forcing every client (desktop web, mobile iOS/Android, smart TV, third-party partner) through a single **General-Purpose API Backend** that becomes a bloated, political bottleneck, deploy **one tightly coupled Edge Backend per user experience (a BFF)** owned by the **same team that builds that frontend**. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Sam Newman & Chris Richardson)

| Term | Meaning | Test sentence |
|---|---|---|
| BFF (Backend for Frontend) | a single-purpose server-side edge API tailored exclusively to one specific frontend experience or client class | "serves one UI experience and is owned by that UI's team" |
| General-Purpose API Gateway | a single shared entry point handling cross-cutting perimeter concerns (TLS termination, routing, rate limiting, auth verification) for all traffic | "handles transport perimeter plumbing, never UI-specific payload aggregation" |
| API Composition / Aggregation | the BFF calling 2-5 downstream domain services in parallel, joining/filtering the data, and returning one screen-shaped payload to the client | "saves a mobile client from making 6 separate cellular round-trips" |
| Experience Boundary | the rule for deciding how many BFFs to run: group by **user experience and team ownership** (e.g., one Mobile BFF for iOS+Android if one mobile team builds the same UX; separate iOS and Android BFFs if separate autonomous teams own them) | "Conway's Law applied to the server edge" |
| Downstream Domain Service | an internal business-capability service (`OrderService`, `CatalogService`) consumed by one or more BFFs | "owns domain invariants and persistent state; ignorant of screen layout" |

## Core architectural rules and invariants

1. **One BFF per user experience, owned by the frontend team:** A BFF is part of the client application, just running on the server. The team building the frontend must own, change, and deploy its BFF in lockstep with the UI without waiting on a separate backend platform team.
2. **A BFF contains presentation adaptation and aggregation only — zero core domain state or business rules:** Never put authoritative domain logic (pricing rules, inventory deduction, persistent business records) inside a BFF. If a business rule is needed by both Web and Mobile, it belongs in a downstream Domain Service, never duplicated across BFFs.
3. **Separate Perimeter Concerns from BFF UI Concerns:** Do not re-implement TLS termination, WAF, DDoS protection, global rate limiting, or raw OAuth token validation inside every BFF. Keep an upstream infrastructure reverse proxy / routing gateway (or sidecar/middleware library) for perimeter security, and keep the BFF focused on client-specific aggregation and payload shaping.
4. **Resilience against partial downstream failure:** When a BFF aggregates calls to 5 downstream services (e.g., Product Info, Pricing, Inventory, Reviews, Recommendations), use parallel non-blocking fan-out with strict timeouts, circuit breakers, and **graceful degradation** (if `RecommendationsService` times out, return the product page without recommendations rather than failing the whole screen with `500`).
5. **Accept small presentation duplication across BFFs over premature coupling:** If two BFFs both format a date or stitch two downstream responses similarly, resist the urge to merge them back into a single "Shared BFF" — merging re-creates the exact cross-team coupling and deployment bottleneck the BFF pattern exists to eliminate.

## Building order

1. **Confirm you actually need a BFF:** If your application has only **one** UI (e.g., a single web app) talking to a single backend, a BFF adds zero value. Introduce a BFF only when multiple distinct client experiences or fine-grained downstream microservices exist.
2. **Align BFF boundaries with frontend teams (Conway's Law):** Draw one BFF boundary per autonomous UI team / experience.
3. **Define screen-focused contracts test-first:** Let the UI team design the exact payload shape (REST endpoints or a scoped GraphQL schema) that minimizes client round-trips and battery/bandwidth usage.
4. **Implement parallel downstream composition with fallbacks:** Fan out requests to downstream domain services concurrently with explicit timeouts, bulkheads, and partial-response fallbacks.
5. **Deploy independently per client lifecycle:** Version or evolve the BFF endpoints to match its paired mobile/web release cadence.

## Testing strategy

| Layer | Test | Uses |
|---|---|---|
| BFF Aggregation & Fallback logic | unit / component test | stubbed downstream HTTP/gRPC responses (verifies happy path aggregation + partial degradation when a non-critical service times out) |
| BFF <-> Downstream Services | Consumer-Driven Contract test (e.g., Pact) | authored by the BFF team and run in the downstream service's CI pipeline |
| Frontend <-> BFF | UI + BFF integration test | owned by the same frontend team; can test UI against its paired BFF in-process or in one repo |

## When it earns its keep

- **Worth it:** Multi-experience systems (Desktop Web + Native Mobile + TV/Wearables + External Partner API) consuming multiple fine-grained downstream microservices, where mobile bandwidth/latency limits require server-side call aggregation and autonomous frontend teams need to ship UI+API changes without cross-team bottlenecks.
- **Not worth it:** Single-UI applications, monoliths where the backend already serves one frontend directly, or systems where different clients consume the exact same payload shape and are maintained by a single small full-stack team.

## Mistakes to catch

- **The "One Giant BFF / Smart API Gateway" Anti-Pattern:** Putting UI-specific aggregation for Web, iOS, Android, and Partners inside one monolithic API Gateway managed by a central team — turning the gateway into a deployment bottleneck and single point of organizational friction.
- **Putting core domain business logic or a primary database inside a BFF:** Making the Mobile BFF compute discounts or write directly to the orders database, causing Web and Mobile to diverge on business rules.
- **Serializing downstream calls (`await A; await B; await C`):** Calling 4 independent downstream microservices sequentially instead of concurrently (`Promise.all` / `Task.WhenAll`), summing their latencies on every request.
- **All-or-nothing cascading failure:** Letting a timeout in a secondary downstream service (`Reviews` or `AvatarService`) crash the entire BFF response instead of degrading gracefully.
- **Sharing a heavy "BFF Common Business Library" that forces lockstep deployments:** Coupling all BFFs back together through a shared library that requires every BFF to redeploy simultaneously.

## Deep references

- [Newman: ownership, count, aggregation](references/newman-bff-ownership-and-aggregation.md) — read when deciding how many BFFs, who owns them, and how to aggregate
- [Azure and microservices.io trade-offs](references/azure-and-microservices-io-considerations.md) — read when weighing BFF vs gateway vs GraphQL and cross-cutting concerns
