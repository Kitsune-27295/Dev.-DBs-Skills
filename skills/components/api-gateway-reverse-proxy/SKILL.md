---
name: api-gateway-reverse-proxy
description: "Decide what an API gateway / reverse proxy should own at the edge and how it must behave as an HTTP intermediary: RFC 9110 roles (proxy, gateway, tunnel), Via, Max-Forwards, hop-by-hop Connection handling, loop protection, retry safety by method, 502/503/504 mapping, offloading (TLS, auth, throttling, logging), thin aggregation, bypass prevention and the boundary with BFF. Not for choosing the destination (router-front-controller-routing), per-client API shaping (bff-pattern) or in-process pipelines (middleware-interceptor-chain). Use when placing a gateway in front of services, deciding what to offload, adding aggregation, mapping upstream failures to status codes, preserving client context behind a proxy, or reviewing a custom proxy."
---

# API Gateway & Reverse Proxy

One idea: a gateway is the **edge entry point** that terminates client connections and speaks to backends on the client's behalf. It earns its place by owning *edge concerns* (TLS, authentication, throttling, logging, protocol translation, thin aggregation) once, so services do not each re-implement them. It must never own business logic. Sources and claims: [references/sources.md](references/sources.md).

Boundaries: the destination decision (path/header/version routing tables, Front Controller, EIP routers) is `router-front-controller-routing`. Ordered in-process cross-cutting steps are `middleware-interceptor-chain`. A gateway per client type with client-shaped APIs is `bff-pattern`. Rate limit algorithms are `rate-limiter-throttler`; token/policy logic is `authn-authz-guard`; failure handling inside calls is `circuit-breaker-retry-telemetry`; caching rules are `caching-strategies`; error body format is `error-handling-problem-details`. Service decomposition context: `microservices-architecture`.

---

## 1. What a Gateway Is in HTTP Terms (RFC 9110)

| Role | Defined by | Behavior |
|---|---|---|
| **Proxy** | Chosen by the client, usually via configuration | Forwards messages; used for security, annotation, shared caching |
| **Gateway / reverse proxy** | Chosen by the server side | Acts as an origin server toward the client, forwards inbound to other servers |
| **Tunnel** | CONNECT | Blind relay; not a party to HTTP once active; carries TLS |
| **Interception (transparent) proxy** | Not chosen by the client | Redirects traffic; avoid relying on it |

One intermediary can act as any of these per request. A gateway therefore has origin-server obligations toward clients and client obligations toward backends.

## 2. Forwarding Rules You Must Not Break

1. **Hop-by-hop vs end-to-end.** Intermediaries MUST parse `Connection`, remove each field it names, then remove `Connection` itself (or replace it with their own options). They SHOULD also strip known hop-by-hop fields even when unlisted (`Proxy-Connection`, `Keep-Alive`, `TE`, `Transfer-Encoding`, `Upgrade`). Never list end-to-end fields like `Cache-Control` as connection options.
2. **Via.** A proxy MUST add `Via` to every forwarded message; an HTTP-to-HTTP gateway MUST add it to inbound requests. Members with different received-protocol values MUST NOT be combined, and even identical ones SHOULD NOT be unless under one organization's control with hosts already pseudonymized.
3. **Loops.** An intermediary MUST NOT forward a message to itself unless protected from an infinite loop; recognize your own names and aliases and answer directly. `Via` helps detect loops; `Max-Forwards` applies to TRACE and OPTIONS only (zero means answer as final recipient).
4. **Retries.** A proxy MUST NOT automatically retry non-idempotent requests. Safe: GET, HEAD, OPTIONS, TRACE. Idempotent: those plus PUT and DELETE. POST is neither.
5. **Client context.** Re-originating a connection loses client IP, scheme and host unless forwarded explicitly. Treat forwarded headers as untrusted unless set by your own gateway (RFC 7239 itself warns an address chain before your proxy cannot be trusted). The `Forwarded` header is RFC 7239; `X-Forwarded-*` is not standardized there; neither is in RFC 9110 (details in [references/rfc9110-intermediaries-and-status-codes.md](references/rfc9110-intermediaries-and-status-codes.md)).
6. **Misdirected requests.** An origin server rejects a target URI it is not configured for with 421, and rejects scheme-requirement failures unless the connection is from a trusted gateway.

## 3. Status Codes at the Edge

| Code | Gateway meaning | Use when |
|---|---|---|
| 502 Bad Gateway | Upstream returned an invalid response | Backend protocol violation, reset, garbage |
| 503 Service Unavailable | Temporary overload/maintenance; MAY send `Retry-After` (servers need not use 503 when overloaded) | Shedding load, no healthy backend |
| 504 Gateway Timeout | No timely upstream response | Upstream exceeded the gateway deadline |
| 500 | Gateway's own unexpected error | Never to mask an upstream error |

Map failures precisely; "everything is 500" destroys retry decisions. 429 and its `Retry-After` belong to `rate-limiter-throttler`.

## 4. What to Offload (and What Not To)

Offload cross-cutting edge functions: client-facing TLS termination and cert management, authentication/token validation, throttling, request logging/monitoring, protocol translation, static old-to-new redirects, correlation-ID generation.

Rules:
- **No business logic in the gateway.** Redirects that depend on business state stay in the app.
- **Re-encrypt to backends.** Terminate TLS at the edge, then new TLS to backend; treat all networks as untrusted.
- **Prevent bypass.** Backends accept traffic only via the gateway or a private network; else offloaded auth/throttling is skippable.
- **Define identity propagation.** Decide whether backends authorize the original caller, the gateway identity, or both; authenticate the gateway to the backend separately.
- **Capacity for peaks**, graceful drain on instance removal, independent hardening and monitoring (the gateway is a high-value target).
- Skip offloading when it couples backend releases to gateway releases or the gateway team becomes a change bottleneck.

## 5. Aggregation

Use the gateway to collapse N client calls into one when clients are on high-latency networks or the screen needs data from several services.

- Call backends in parallel with async I/O, per-call timeouts, bulkheads, circuit breakers.
- Decide per operation: partial response (optional data missing) or fail the whole request (consistency required). Make it explicit.
- Propagate correlation IDs; monitor response sizes.
- Keep it **lightweight composition**. Complex domain logic or long orchestration goes in a dedicated aggregation service behind the gateway.
- Do not couple backends to each other through the gateway.
- Place the gateway near the backends and load-test it; consider cached data as a failover.
- Prefer a batch operation on one service over a gateway when the problem is chatty calls to a single service.

## 6. Gateway vs BFF Boundary, and When to Use a Gateway

A shared gateway stays generic (edge concerns, routing, thin aggregation). Per-client API shaping and client-team ownership go to `bff-pattern`, which owns the gateway-versus-BFF comparison and the forces behind it.

- Justify a gateway by naming the forces that apply (many services, chatty mobile clients, partitioning to hide); Microsoft's routing page says a simple app with one or two services may not need one.
- Count its cost: one more component to build, deploy and operate, plus an extra network hop to monitor.
- For high load Richardson suggests a non-blocking, event-driven implementation (Netty, Spring Reactor, Node.js).

## 7. Failure Modes

| Smell | Fix |
|---|---|
| Gateway grows domain rules | Move to services; keep gateway config-only |
| Single gateway instance | Run multiple, drain connections |
| Backends publicly reachable | Network-restrict to gateway |
| Retrying POST on 502/504 | Only retry idempotent methods or use idempotency keys |
| Trusting inbound `X-Forwarded-For` from clients | Overwrite at the first trusted hop |
| Aggregation in the gateway with no timeouts | Per-call deadlines + partial-response policy |

## Quick Decision Checklist

- [ ] Is the gateway limited to edge concerns and thin composition?
- [ ] Are backends unreachable except through the gateway?
- [ ] Does it add `Via`, strip hop-by-hop fields, and prevent loops?
- [ ] Are 502/503/504 used accurately, with `Retry-After` on 503 where useful?
- [ ] Are automatic retries limited to idempotent methods?
- [ ] Is TLS re-established to backends and client context forwarded safely?
- [ ] Do aggregation calls have timeouts, parallelism and a partial-failure policy?
- [ ] Is per-client shaping delegated to a BFF?

## Deep references

- [RFC 9110 intermediaries and status codes](references/rfc9110-intermediaries-and-status-codes.md) — when implementing proxy behavior, retries, or error mapping.
- [Gateway offloading and aggregation](references/gateway-offloading-and-aggregation.md) — when deciding what moves into the gateway and how to compose calls.
- [Trigger evals](references/trigger-evals.md) — when tuning this skill's description.
- [Sources](references/sources.md) — every URL with retrieved status, reading limits and claims not adopted.
