# BFF Trade-offs: Azure Architecture Center and microservices.io

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/backends-for-frontends (ms.date 2025-03-19) · https://microservices.io/patterns/apigateway.html · Last verified 2026-11-27

## Forces (Richardson)

Fine-grained service APIs do not match client needs; a desktop product page is richer than a mobile one; mobile networks allow only a few requests while a server-side web app can make many; instance locations and service partitioning change and clients should not depend on them; some services use protocols that are not web-friendly.

Solution: an API gateway as the single entry point that proxies or fans out. The BFF variation gives each client kind its own gateway: web, mobile, third party. Benefits: shielded from partitioning, tailored API, fewer round trips, simpler clients, protocol translation. Drawbacks: one more component to build and run, and an extra hop (the author calls the latency usually insignificant). For high load he suggests an event-driven, reactive implementation (Netty, Spring Reactor, Node.js). Netflix is the cited known use. Related patterns he lists: API Composition, Circuit Breaker, discovery, Access Token.

## Considerations (Microsoft)

- More BFFs mean more lifecycles, deployments and security needs.
- Re-check service-level objectives: the extra hop adds latency.
- If interfaces make the same requests, consider one BFF; sharing one across divergent clients complicates growth. Duplication is probable; weigh it against a tailored experience.
- The BFF handles only client-specific logic for one experience. Cross-cutting items such as monitoring and authorization are abstracted; the page points to the Gatekeeping, Rate Limiting and Routing patterns.
- Frontend teams control language, release cadence, prioritization and feature integration.
- GraphQL with frontend-specific resolvers can remove the need for a BFF; an API gateway plus microservices may suffice.
- Not suitable when interfaces make the same or similar requests, or only one interface uses the backend.

Workload pillars: reliability (one client's outage does not affect another), security (per-client authorization, smaller API surface, less lateral movement), performance (tune per client).

## Reference topology (Microsoft example)

Clients, then Azure API Management as the perimeter (JWT validation, activity logs to Azure Monitor, request caching, routing), then one BFF per client as an Azure Function, then microservices. The mobile BFF returns a single lightweight page per call and benefits from the gateway cache; the desktop BFF aggregates several pages per request. Microsoft Entra ID issues audience claims per client.

```text
mobile --\                      /-> mobile-bff  --\
          >-> gateway (authN,  <                   >-> services
desktop --/    cache, route)    \-> desktop-bff --/
```

## How an agent should apply this

- Keep cross-cutting concerns in a perimeter gateway or library when you follow the Microsoft topology; record the choice in an ADR (Newman leaves it open).
- Estimate the extra hop and operating cost before adding a BFF.
- Try GraphQL resolvers or a plain gateway first when clients make near-identical requests.
- Isolate failure: one client's BFF outage must not affect another.
