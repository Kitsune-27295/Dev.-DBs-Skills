# BFF Trade-offs: Azure Architecture Center and microservices.io

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends · https://microservices.io/patterns/apigateway.html · Last verified 2026-11-23

## Forces (Richardson)

Fine-grained service APIs do not match client needs; desktop and mobile need different data; mobile networks tolerate few round trips while server-side code on a LAN can make many; instance locations change; service partitioning should be hidden; some services speak non-web protocols. Solution: a single entry point (API gateway) that proxies or fans out; the BFF variation is one gateway per client kind (web, mobile, third party). Benefits: insulation from partitioning, tailored API, fewer round trips, simpler clients, protocol translation. Drawbacks: another component to build/operate, an extra hop. Implementation: reactive/event-driven (Netty, Spring Reactor, Node.js). Netflix is a cited known use; the page also lists related patterns (API Composition, Circuit Breaker, discovery, Access Token).

## Considerations (Microsoft)

- More BFFs means more lifecycles, deployments, security needs; weigh cost.
- Re-check SLOs: an extra network hop adds latency.
- If interfaces make the same requests, consider consolidating; sharing one BFF across divergent clients complicates growth. Code duplication is a probable outcome; trade it against tailored experience.
- A BFF should hold only client-specific logic. Keep cross-cutting items (monitoring, authorization) elsewhere; the page points to Gatekeeping, Rate Limiting and Routing patterns.
- Frontend teams get autonomy over language, release cadence, prioritization.
- GraphQL with frontend-specific resolvers may make a BFF unnecessary; an API gateway plus microservices may also suffice.
- Not suitable when interfaces make same/similar requests, or only one interface exists.

## Workload view (pillars)

Reliability: faults isolated per client. Security: per-client authorization, smaller API surface, limited lateral movement. Performance: tune per client constraints.

## Reference topology (Microsoft example)

Clients -> API gateway (JWT validation, monitoring, request caching, routing) -> per-client BFF (serverless functions) -> microservices. Mobile BFF returns lightweight single pages and benefits from gateway cache; desktop BFF aggregates several pages per request. Entra ID issues tailored audience claims per client.

```text
mobile --\                      /-> mobile-bff  --\
          >-> gateway (authN,  <                   >-> services
desktop --/    cache, route)    \-> desktop-bff --/
```

## Gateway versus BFF decision

| Situation | Choice |
|---|---|
| One generic edge, similar clients | Single API gateway |
| Divergent clients, separate teams | Gateway for perimeter + BFF per experience |
| Client-driven data shape, GraphQL in place | Frontend-specific resolvers may replace BFF |

Boundary: routing, gateway offloading and reverse-proxy mechanics belong to the edge-routing skills; this file covers only how they interact with a BFF.

## How an agent should apply this

- Put cross-cutting concerns in a perimeter gateway/library; keep BFFs client-specific.
- Estimate the extra hop and operating cost before adding a BFF.
- Consider GraphQL or a plain gateway first when clients make near-identical requests.
- Isolate failure: one client's BFF outage must not affect another.
- Document the per-client differences that justify each BFF in an ADR.
