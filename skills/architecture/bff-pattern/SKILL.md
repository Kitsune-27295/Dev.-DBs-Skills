---
name: bff-pattern
description: "Decide whether and how to split a Backend for Frontend (BFF): one client-specific edge backend per user experience (web, mobile, third party), owned by the team that builds that UI, doing screen-shaped aggregation and no domain rules. Covers how many BFFs to run, Newman versus Microsoft versus Richardson trade-offs, GraphQL or a plain gateway as alternatives, and mistakes (giant shared BFF, domain logic in a BFF). Not for the shared edge entry doing TLS, auth, throttling and retries (api-gateway-reverse-proxy) or the destination decision (router-front-controller-routing). Use when each client type needs a different API shape, a shared general-purpose backend is a release bottleneck for frontend teams, or a BFF route must narrow a backend response."
---

# BFF (Backend for Frontend) Pattern

One idea: instead of sending every client through one **general-purpose API backend** that becomes a release bottleneck, give each user experience its own server-side edge service, **maintained by the team that builds that UI**. Sources, retrieved statuses and unconfirmed claims: [references/sources.md](references/sources.md).

Boundaries: the shared edge (TLS, auth, throttling, offloading, generic aggregation, RFC 9110 proxy rules) is `api-gateway-reverse-proxy`. Choosing a destination is `router-front-controller-routing`. Retry, breaker and bulkhead mechanics are `circuit-breaker-retry-telemetry`. Authorization decisions are `authn-authz-guard`. Service decomposition is `microservices-architecture`.

## 1. Vocabulary

| Term | Meaning |
|---|---|
| BFF | A single-purpose server-side service for one user experience, typically maintained by the same team as that UI (Newman). Newman splits the app into a client outside the perimeter and a BFF inside it. |
| General-purpose API backend | The shared backend that accumulates features for every client, becomes one deployable many apps depend on, and often gets its own team (the problem Newman and Microsoft describe). |
| API gateway | One shared entry point that proxies or fans out to services (Richardson). The BFF variation is one gateway per client kind: web, mobile, third party. |
| Aggregation (API Composition) | The BFF calls several downstream services and returns one screen-shaped payload, so a high-latency client makes fewer round trips. |

## 2. Rules

1. **One BFF per user experience, owned by the UI team.** The UI team controls language, release cadence and prioritization (Microsoft). Newman prefers one BFF per client type, but notes a team can share one across similar clients (SoundCloud shared one for iOS and Android listener apps) and credits Gleadow's "one experience, one BFF". Count BFFs by experience and team divergence, not device count.
2. **Presentation adaptation and aggregation only.** A BFF holds client-specific logic for one experience (Microsoft). Business rules, authoritative state and pricing stay in domain services; a rule both clients need lives there once.
3. **Cross-cutting concerns are a placement decision, not a given.** Microsoft's reference topology keeps token validation, monitoring and request caching in an API gateway in front of per-client BFFs and says to handle gatekeeping, rate limiting and routing separately. Newman is undecided: an upstream proxy adds latency and deployment complexity, in-BFF handling is self-contained, shared libraries couple. Decide once, write it in an ADR, and keep per-client authorization in the BFF (Microsoft's security pillar).
4. **Aggregate in parallel and decide partial failure per screen.** Newman's wishlist question: if Inventory is down, is it better to drop the stock indicator than fail the page? The BFF decides, and the client must render partial payloads. Mechanics: `api-gateway-reverse-proxy` (aggregation) and `circuit-breaker-retry-telemetry`.
5. **Accept some duplication across BFFs.** Newman tolerates duplication across services more than in-process, uses "third time" before abstracting, and lists a shared library (cheap, couples), a new domain-modeled service, or moving aggregation downstream as options. Microsoft agrees duplication is probable and a trade for tailored experience.

## 3. Decide whether you need one

1. **Count experiences.** One UI against one backend: no BFF (Microsoft: not suitable when only one interface exists or interfaces make the same or similar requests). Desktop web often needs none either; it can need one for server-side rendering or caching of aggregated responses (Newman).
2. **Check the alternatives first.** Microsoft: GraphQL with frontend-specific resolvers may remove the need; an API gateway plus microservices may be enough.
3. **Price it.** More BFFs mean more lifecycles, deployments and security surface, plus one extra network hop to check against your SLOs (Microsoft). Richardson lists the extra component and hop as the gateway family's drawbacks.
4. **Third parties.** A dedicated BFF avoids keeping old versions of a general API alive for a few slow-moving integrators (Newman).
5. **Ownership.** Ask who owns the frontend. Newman: the case is stronger when UI and service teams are separate, and reconsider if deploying extra services is very costly.

## 4. Building order

1. Draw one boundary per autonomous UI team or experience.
2. Let the UI team define the screen-shaped contract (REST endpoints or a scoped GraphQL schema).
3. Fan out to downstream services concurrently with explicit timeouts and a written partial-versus-fail rule per endpoint.
4. Deploy on the paired client's release cadence.
5. Narrow every backend payload to what the screen renders; example: [references/route-handler-narrowing-example.md](references/route-handler-narrowing-example.md).

## 5. Mistakes to catch

- **One giant "smart gateway" doing per-client shaping for every client**, run by a central team: the bottleneck the pattern exists to remove.
- **Domain rules or a primary database in a BFF**, so web and mobile diverge on business behavior.
- **Merging BFFs back into one shared BFF** for tiny duplication; Microsoft warns divergent clients make a shared BFF hard to grow.
- **Sequential downstream calls** where calls are independent, or **one secondary failure failing the whole screen** (rule 4).
- **Treating an upstream failure as an empty 200** in a route handler (see the example reference).

## Quick Decision Checklist

- [ ] More than one distinct client experience, or a shared backend that blocks UI teams?
- [ ] GraphQL resolvers or a plain gateway ruled out for a stated reason?
- [ ] One BFF per experience, owned by the UI team?
- [ ] No domain rules or primary database in the BFF?
- [ ] Perimeter placement (gateway versus in-BFF) decided and recorded?
- [ ] Parallel downstream calls with timeouts and a per-screen partial-failure rule?
- [ ] Extra hop and operating cost checked against SLOs?

## Deep references

- [references/newman-bff-ownership-and-aggregation.md](references/newman-bff-ownership-and-aggregation.md): read when deciding how many BFFs, who owns them, and how to handle aggregation and duplication.
- [references/azure-and-microservices-io-considerations.md](references/azure-and-microservices-io-considerations.md): read when weighing BFF versus gateway versus GraphQL, or sizing the cost.
- [references/route-handler-narrowing-example.md](references/route-handler-narrowing-example.md): read when writing a BFF route that validates input and narrows a backend response.
- [references/trigger-evals.md](references/trigger-evals.md): read when tuning this skill's description.
- [references/sources.md](references/sources.md): every URL with retrieved status, reading limits and claims not adopted.
