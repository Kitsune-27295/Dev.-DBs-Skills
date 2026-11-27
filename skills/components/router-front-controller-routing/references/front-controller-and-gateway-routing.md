# Front Controller and Gateway Routing

Sources: https://martinfowler.com/eaaCatalog/frontController.html, https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-routing · Last verified 2026-11-23

## Front Controller: what it is

Fowler defines it as a controller that handles all requests for a web site. The problem it answers: in a complex site many input-handling tasks repeat per request (security, internationalization, choosing a view for certain users). If each page owns that logic it is duplicated and cannot be changed at run time.

Mechanics, as described on the page:
1. **Single entry point.** Every request goes through one handler.
2. **Common behavior in the handler.** It can be altered at run time by wrapping the handler in decorators.
3. **Dispatch.** After the common work, the handler hands off to a command object that performs the request-specific behavior.

The catalog page gives no code, no comparison with Page Controller and no drawbacks. The points below marked (inferred) are my own reasoning, not from the page.

## Forces and trade-offs

- Gain: one place for shared policy; changing it (add a check, reorder) touches one object.
- Cost (inferred): the single handler is a hot spot; a bug there affects every request, and it tempts teams to pile logic into it.
- Contrast (inferred): with per-page controllers, simple sites stay simpler; Front Controller pays off when shared per-request logic is non-trivial.

## Sketch

```
handle(request):
    ctx = commonPreprocessing(request)      # security, locale, view selection
    command = commandTable.lookup(request.route)  # data-driven table
    if command is None: return notFound()
    return command.execute(ctx)
```

The `commandTable` is the router. Keep it declarative; do not branch on URL strings inside `execute`.

## Gateway Routing (Azure pattern)

A gateway sits before applications, services or deployments and uses Layer-7 routing (IP, port, header, URL). Clients know one endpoint.

| Scenario | Without gateway | With gateway |
|---|---|---|
| Disparate services (search, cart, checkout...) | Client knows each endpoint, changes when services split | Only routing changes when services are consolidated, decomposed or replaced |
| Multiple instances | Client updated on each scale event | Registration complexity is hidden in the gateway |
| Multiple versions (blue/green) | Client updated for traffic shifts | Run versions in parallel, shift or revert via gateway config |

Global vs regional: the page contrasts Azure Front Door (global) with Application Gateway (regional). Use global when services span regions; use regional when you need fine control over balancing, for example between VMs.

Example shape (adapted from the page's Nginx sample): `location /app1 { proxy_pass http://10.0.3.10:80; }` repeated per path prefix.

## Failure modes

- Gateway as single point of failure or bottleneck: scale out, load-test to avoid cascading failure.
- Public gateway with publicly reachable backends: restrict backends to the gateway or a private network.
- Routing rules that couple to a service's internals: backend change forces gateway change.
- One or two services only: pattern is unnecessary overhead (the page says it may not be suitable).

## How an agent should apply this

- Give each system exactly one entry point for the concern "decide destination"; list any bypass explicitly.
- Express routes as a table or config, never as nested conditionals scattered across handlers.
- Put shared per-request policy in the front controller or a pipeline (`middleware-interceptor-chain`), request-specific logic in commands.
- For version rollouts, route by gateway config so rollback needs no client or service deploy.
- Do not add TLS, auth, aggregation here; hand those to `api-gateway-reverse-proxy`.
