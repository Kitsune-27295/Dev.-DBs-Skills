---
name: api-gateway-reverse-proxy
description: "Design an API gateway / reverse proxy as the edge entry point: HTTP intermediary semantics from RFC 9110 (proxy vs gateway vs tunnel, Via, Max-Forwards, hop-by-hop Connection, 502/503/504, method safety and idempotency for retries), gateway offloading (TLS termination, auth, throttling, logging), gateway aggregation, and the boundary with BFF. Use when placing a gateway in front of services, deciding what to offload, adding aggregation, mapping upstream failures to status codes, preserving client context behind a proxy, or preventing gateway bypass. Not for the destination decision itself or in-process pipelines."
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

1. **Hop-by-hop vs end-to-end.** Remove header fields named in `Connection` and known hop-by-hop fields (`Keep-Alive`, `TE`, `Transfer-Encoding`) before forwarding. Never list end-to-end fields like `Cache-Control` as connection options.
2. **Via.** A proxy MUST add `Via` to forwarded messages; a gateway MUST add it to inbound requests. Only members with identical received-protocol values may be combined; hosts may be replaced by pseudonyms.
3. **Loops.** Never forward to yourself without loop detection; `Via` and `Max-Forwards` (TRACE/OPTIONS only) support it.
4. **Retries.** A proxy MUST NOT automatically retry non-idempotent requests. Safe: GET, HEAD, OPTIONS, TRACE. Idempotent: those plus PUT and DELETE. POST is neither.
5. **Client context.** Re-originating a connection loses client IP, scheme and host unless forwarded explicitly. Treat forwarded headers as untrusted unless set by your own gateway. (The `Forwarded`/`X-Forwarded-*` header formats are not in RFC 9110; see [references/rfc9110-intermediaries-and-status-codes.md](references/rfc9110-intermediaries-and-status-codes.md).)
6. **Misdirected requests.** Origin servers reject requests not meant for them (421), except from a trusted gateway.

## 3. Status Codes at the Edge

| Code | Gateway meaning | Use when |
|---|---|---|
| 502 Bad Gateway | Upstream returned an invalid response | Backend protocol violation, reset, garbage |
| 503 Service Unavailable | Temporary overload/maintenance; may send `Retry-After` | Shedding load, no healthy backend |
| 504 Gateway Timeout | No timely upstream response | Upstream exceeded the gateway deadline |
| 500 | Gateway's own unexpected error | Never to mask an upstream error |

Map failures precisely; "everything is 500" destroys retry decisions.

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
- Prefer a batch operation on one service over a gateway when the problem is chatty calls to a single service.

## 6. Gateway vs BFF Boundary

| | Shared API gateway | BFF |
|---|---|---|
| Serves | All clients | One client type (web, mobile, partner) |
| Owns | Edge concerns, routing, thin aggregation | Client-specific API shape and composition |
| Owned by | Platform/edge team | Client team |

If client-specific shaping starts accumulating in the shared gateway, split out a BFF (`bff-pattern`) and keep the gateway generic.

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
- [API gateway pattern and BFF boundary](references/api-gateway-pattern-and-bff-boundary.md) — when justifying a gateway, per-client variants, and its costs.
