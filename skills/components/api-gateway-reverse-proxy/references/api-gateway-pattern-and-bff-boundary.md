# API Gateway Pattern and the BFF Boundary

Sources: https://microservices.io/patterns/apigateway.html · Last verified 2026-11-23

## Context and problem

An online store's product page needs data from several microservices (product info, pricing, orders, inventory, reviews) and must serve browsers, mobile web, native apps and third-party REST clients. Problem: how do clients reach individual services?

Forces (from the page):
- Service APIs are finer-grained than clients need, so clients would call many.
- Different clients need different data (desktop richer than mobile).
- Mobile networks are slower, so native clients can afford few requests; server-side web apps can make many.
- Instance locations change dynamically; service partitioning should be hidden.
- Some services speak protocols that are not web-friendly.

## Solution

An API gateway is the single entry point for all clients. It either proxies a request to a service or fans it out to several. It may expose a different API per client (Netflix uses client-specific adapter code) and can handle security such as authorization checks.

**Variation, Backends for Frontends:** one gateway per client kind (web, mobile, third party).

## Results

Benefits: clients insulated from partitioning and instance locations; per-client API; fewer round trips (essential for mobile); simpler clients; translation from a public protocol to internal ones.

Drawbacks: one more component to build, deploy and manage; an extra network hop (the page calls it usually insignificant). Under high load, event-driven or reactive implementations are preferred (Netty, Spring Reactor, Node.js named).

Related patterns on the page: microservice architecture, client/server-side discovery (routing), access tokens, circuit breaker, API Composition.

## Boundary rules (mix of source and my inference)

| Question | Answer |
|---|---|
| Is it a gateway concern? | Routing to services, offloaded edge functions, thin fan-out |
| Is it a BFF concern? | Shape of the response for one client kind, client-specific composition |
| Is it a service concern? | Domain rules, data ownership |

Inferred: a single shared gateway with per-client adapter code is a BFF in disguise; once client teams need independent release cadence, split it. Cross-link: `bff-pattern` for the BFF design, `router-front-controller-routing` for the routing decision, `microservices-architecture` for decomposition.

## Failure modes

- Shared gateway becomes a bottleneck team and a monolith of adapter code.
- Gateway invoked synchronously for every service with no resilience policies.
- One gateway for internal service-to-service traffic too (inferred): adds hop and coupling where a mesh or direct calls fit better.

## How an agent should apply this

- Justify a gateway by naming the forces that apply (many services, mobile chattiness, hidden partitioning); skip it for one or two services.
- Keep the gateway generic and push per-client shaping to BFFs when clients diverge.
- Pair with discovery, circuit breakers and token-based identity propagation.
- Build it on a non-blocking stack when load is high.
- Treat the extra hop and component as a cost to monitor, not to ignore.
