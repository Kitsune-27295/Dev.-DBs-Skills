---
name: router-front-controller-routing
description: "Design routing as its own concern: Front Controller (single entry point dispatching to commands/handlers), content-based and message routing (EIP Content-Based Router, Message Filter, Dynamic Router, Recipient List, Routing Slip), gateway routing as a Layer-7 pattern (path/header/version/region), and client-side routing with the History API (pushState, replaceState, popstate). Use when deciding how a request or message finds its destination, building a router table, adding versioned or canary routes, writing an SPA router, or choosing between one router and many filters. Not for edge concerns (TLS, auth, rate limits) or cross-cutting pipelines."
---

# Router: HTTP, Message & UI Routing

One idea: **routing is the single decision "where does this go?"** made from request or message data (path, header, content, version, state). A router chooses a destination and nothing else; it does not authenticate, throttle, transform or aggregate. Keep that decision in one place, driven by a table that is easy to change. Sources and claims: [references/sources.md](references/sources.md).

Boundaries: edge concerns around the router (TLS termination, offloading, aggregation, reverse-proxy semantics) belong to `api-gateway-reverse-proxy`. Ordered cross-cutting steps (logging, auth, compression) belong to `middleware-interceptor-chain`. Per-client API shaping belongs to `bff-pattern`. Sequential filter stages on a data flow belong to `pipes-and-filters-pattern`.

---

## 1. Four Routers, One Decision

| Router | Input it inspects | Destination | Typical home |
|---|---|---|---|
| **Front Controller** | Any web request | A command/handler object | Web framework, app server |
| **Gateway routing (L7)** | IP, port, header, URL path | A service, instance, or version | Reverse proxy / gateway |
| **Content-Based Router (EIP)** | Message body or header fields | One of N output channels | Message broker, integration layer |
| **Client-side router** | `location` / URL path | A view and its state | Browser (SPA) |

Pick by where the decision is made, not by technology. The same table (`/orders/* -> orders-service`) can live in a gateway, a front controller or an SPA router; each is a different place that decision is evaluated.

## 2. Front Controller

A Front Controller is one handler that receives **every** request, runs the shared processing, then dispatches to a command object that does the request-specific work (Fowler, PoEAA ch. 14).

Rules:
1. All requests enter through one handler. No second entry point that skips the shared logic.
2. Shared concerns that must apply to every request (security, i18n, view selection) live in the controller, or in decorators around it so they can change at run time.
3. Request-specific behavior lives in command objects. The controller maps request to command and calls it.
4. The controller stays thin. If it grows business rules it has become a god object.

Reject: copy-pasted security checks in every page controller; a "front controller" that also contains domain logic; hidden bypass routes (static handlers that skip the shared stage without being declared).

Frameworks already implement this (ASP.NET Core endpoint routing, Spring `DispatcherServlet`, Express app, Rails router). Do not write your own unless you are building such a framework; configure the existing one.

## 3. Message Routing (EIP)

A Message Router decouples the message source from its final destination. The choice among them:

| Pattern | Consumes -> publishes | Stateful? | Use when |
|---|---|---|---|
| Content-Based Router | 1 -> 1 | mostly no | Destination depends on message data (e.g. item type picks inventory system) |
| Message Filter | 1 -> 0 or 1 | mostly no | Drop what a consumer does not want |
| Recipient List | 1 -> many | no | Sender controls the recipients |
| Splitter | 1 -> many | no | Message holds a list to route separately |
| Aggregator / Resequencer | many -> 1 / many | yes | Recombine or reorder (needs buffering) |
| Dynamic Router | 1 -> 1 | rule state | Routing rules change via control messages |
| Routing Slip / Process Manager | sequential path | slip or manager | Fixed or flexible multi-step path |

Core trade-off: a **Content-Based Router** is predictive, centralized and must know every destination; an array of **Message Filters** on a publish-subscribe channel is reactive, so no component knows all destinations. Prefer the router when you want control and one place to audit; prefer filters when new consumers should join without touching a central component.

Keep the router's rules as data (a table or rules engine) so adding a destination is a config change. Always give unmatched messages a defined outcome (a default channel or an invalid-message/dead-letter channel); never drop silently.

## 4. Gateway Routing

Place one Layer-7 gateway in front of services and route on IP, port, header or URL (Azure Architecture Center). It covers three cases:

- **Many services, one endpoint:** clients call one address; services can be split, merged or replaced behind it.
- **Many instances:** instance count changes are hidden; route to healthy nodes, possibly across regions.
- **Many versions:** run v1 and v1.1 side by side, shift traffic by config, roll back by config.

Cautions: the gateway is a single point of failure and a possible bottleneck (scale it, load-test it); lock backends so they are reachable only through the gateway; skip the pattern for one or two services. Routing rules must not encode service business logic, or every backend change forces a gateway deploy. Edge behaviors beyond the routing decision: `api-gateway-reverse-proxy`.

## 5. Client-Side Routing (History API)

An SPA changes the DOM without a page load, so the browser's Back button would skip app states. Fix with the History API:

1. On load, `history.replaceState(initialState, "", location.href)` so the first entry can be restored.
2. On in-app navigation: render, then `history.pushState(state, "", newUrl)`.
3. On `popstate` (Back/Forward), render from `event.state`.

Constraints: `state` must be serializable; pass `""` as the unused title argument; the URL must be same-origin. `pushState` does not fire `popstate` itself. Also configure the server to return the app shell for deep links (inferred; the MDN guide does not cover it), otherwise a refresh on `/orders/7` 404s.

## 6. Failure Modes

| Smell | Consequence | Fix |
|---|---|---|
| Router also validates, enriches, authorizes | Router becomes a monolith | Move to middleware / validator skills |
| Routing table scattered across services | Contradictory rules | One authoritative table |
| No default route | Silent drops or 404 storms | Explicit default or dead-letter |
| Version routing hardcoded in code | Rollouts need deploys | Route by config at gateway |
| SPA without `replaceState` on first entry | Back returns to blank/stateless entry | Seed initial state |

## Quick Decision Checklist

- [ ] Is exactly one component responsible for choosing the destination?
- [ ] Is the routing table data, not scattered `if` chains?
- [ ] Is there a defined outcome for unmatched input?
- [ ] Are shared concerns in the front controller or `middleware-interceptor-chain`, not duplicated per handler?
- [ ] Are backends unreachable except through the router/gateway?
- [ ] Router vs filters chosen deliberately (control vs decoupling)?
- [ ] SPA seeds initial history state and handles `popstate`?

## Deep references

- [Front Controller and gateway routing](references/front-controller-and-gateway-routing.md) — when designing a single entry point or L7 version/instance routing.
- [EIP message routing patterns](references/eip-message-routing-patterns.md) — when choosing between Content-Based Router, filters, Recipient List, Routing Slip.
- [Client-side routing with the History API](references/client-side-history-routing.md) — when building or debugging an SPA router.
