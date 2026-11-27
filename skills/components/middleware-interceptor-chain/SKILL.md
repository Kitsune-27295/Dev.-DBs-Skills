---
name: middleware-interceptor-chain
description: "Order and write cross-cutting request pipelines: Chain of Responsibility (handlers that process, pass on or stop), Message Filter (drop unwanted messages) and the ASP.NET Core middleware pipeline (Use/Run/Map/UseWhen, next delegate, short-circuiting, the response-started rule, recommended order of exception handling, HTTPS, static files, routing, CORS, authentication, authorization, rate limiting, caching). Not for choosing a destination (`router-front-controller-routing`) or edge proxies (`api-gateway-reverse-proxy`). Use when adding logging, auth or validation steps to a request path, deciding middleware order, writing custom middleware or interceptors, or choosing chain vs decorator vs filter."
---

# Middleware & Interceptor Chain

One idea: **a pipeline is an ordered list of handlers sharing one interface; each one chooses to act, pass the request on, or stop it, and order is part of the behavior.** Use it for cross-cutting concerns that wrap every (or many) requests. Sources and claims: [references/sources.md](references/sources.md).

Boundaries: picking the destination is `router-front-controller-routing`. Edge concerns in a separate proxy tier (TLS termination, aggregation) are `api-gateway-reverse-proxy`. Data-flow stages that transform a stream of items, each stage a filter between pipes, are `pipes-and-filters-pattern`. Concern-specific logic belongs to its own skill: `authn-authz-guard`, `rate-limiter-throttler`, `validator-input-parser`, `error-handling-problem-details`, `caching-strategies`. Extensibility through plugins is `microkernel-plugin-architecture`.

---

## 1. Chain of Responsibility, Precisely

Intent (Refactoring.Guru): pass a request along a chain; each handler either processes it or forwards it.

| Part | Role |
|---|---|
| Handler interface | One method taking a request object |
| Base handler (optional) | Holds `next`, default forward behavior |
| Concrete handlers | Decide: process? pass on? stop? |
| Client | Assembles the chain (once, or from config/factory) |

Two flavors:
- **Pipeline flavor (middleware):** many handlers act, each may short-circuit.
- **Canonical flavor:** one handler (or none) ends the request; common in UI event bubbling.

Use when request types/sequences are not known up front, handlers must run in a specific order, or the handler set changes at run time. Avoid when exactly one fixed handler exists, or when a request must always be handled (a chain can end unhandled: define a terminal default).

CoR vs Decorator: both compose recursively, but CoR handlers may do unrelated work and stop the flow; decorators extend behavior while keeping the interface and cannot break the flow. CoR vs Command/Mediator/Observer: CoR walks potential receivers sequentially until one handles it.

## 2. Message Filter

A Message Filter is a router with a single output channel: matching messages pass, the rest are discarded (Enterprise Integration Patterns). The page says nothing more about discards, so this rule is ours: a filter that discards needs an auditable fate (count, sample or dead letter). Router comparison, broker bindings and destination choice are owned by `router-front-controller-routing`.

## 3. ASP.NET Core Pipeline Mechanics

- Each middleware chooses whether to call the next one and can run code **before and after** it.
- `app.Use(async (ctx, next) => { ...; await next(ctx); ... })` chains. `app.Run(...)` is terminal: no `next`; anything after the first `Run` never executes.
- `Map(path, branch)` branches by path prefix (matched segments move from `Path` to `PathBase`); `MapWhen(predicate, branch)` branches on any `HttpContext` predicate and does not rejoin; `UseWhen(predicate, branch)` rejoins the main pipeline unless the branch short-circuits.
- **Short-circuit** when work can end early (static files, health checks, rejected auth). Middleware earlier in the pipeline still runs its post-`next` code.
- **Never call `next` after the response has started**, and never modify status/headers then; check `Response.HasStarted`. Writing to the body after `next` can break `Content-Length` or corrupt the body.
- Request order is the registration order; the response unwinds in reverse.

```csharp
app.Use(async (ctx, next) => {
    var id = ctx.TraceIdentifier;           // before
    await next(ctx);
    // after: no header changes if ctx.Response.HasStarted
});
```

## 4. Ordering Rules (ASP.NET Core)

Recommended typical order:

1. Exception handling first (`UseExceptionHandler` in production; developer page in Development), so it catches errors from later stages. `UseHsts` follows.
2. Forwarded headers early so later middleware sees real scheme/host/client IP (can sit after diagnostics if desired).
3. `UseHttpsRedirection`
4. `UseStaticFiles` (short-circuits; serves public files with **no** authorization)
5. `UseRouting`
6. `UseRateLimiter` after routing if using endpoint-specific limits (global-only limiters may go before)
7. `UseRequestLocalization` before culture-sensitive middleware (after routing if route-data provider)
8. `UseCors`
9. `UseAuthentication`, then `UseAuthorization` (must follow CORS, authentication before authorization)
10. `UseSession` (after cookie policy, before MVC), then compression/caching per scenario
11. Endpoints (`MapRazorPages`, `MapControllers`...)

Hard constraints from the docs: `UseCors` before `UseAuthentication`/`UseAuthorization` and before `UseResponseCaching`; `UseRequestTimeouts` after exception handler and routing; output caching after routing, CORS, authentication, authorization; antiforgery after authentication/authorization, before endpoints. Caching vs compression order is scenario-specific (cache before compression may store several encodings). Authentication does not reject by itself; rejection happens at authorization/endpoint.

Details and the full table: [references/aspnetcore-middleware-pipeline-order.md](references/aspnetcore-middleware-pipeline-order.md).

## 5. Design Rules for Your Own Chains

1. **One concern per handler.** Logging, auth, validation each separate (SRP).
2. **Order is documented and tested.** Include an ordering test or startup assertion for security-critical pairs.
3. **Explicit terminal.** Chain ends in a handler that always responds (404/default).
4. **Short-circuit with a response, not silence.** Rejected requests get a status and body.
5. **No shared mutable state between handlers** except a request context object.
6. **Cheap rejections first** (but after the error handler): static files, health, rate limit global, then expensive work.
7. **Branch with `UseWhen`/`Map`** instead of `if (path...)` inside a handler.

## 6. Failure Modes

| Smell | Consequence | Fix |
|---|---|---|
| Auth after endpoint-serving middleware | Unprotected resources | Reorder; test |
| CORS after auth | Preflight rejected | Put CORS before auth |
| Static files assumed protected | Public leak | Serve protected files through endpoints |
| Exception handler not first | Errors in early middleware uncaught | Register first |
| `next` called after response started | Exception / corrupt body | Check `HasStarted` |
| Mega-middleware doing 5 things | Untestable, unreorderable | Split |
| Chain with no terminal | Hung or empty responses | Add terminal |

## Quick Decision Checklist

- [ ] Each handler has one concern and one reason to short-circuit?
- [ ] Exception handling is outermost; auth order (CORS, authn, authz) is correct?
- [ ] Rejected requests return an explicit response?
- [ ] Terminal handler exists?
- [ ] Order of caching, compression, rate limiting reasoned, not copied?
- [ ] No writes to the response after `next` once it may have started?
- [ ] Branching done with `Map`/`UseWhen`, not conditionals in handlers?
- [ ] Order checked against the docs for the project's target framework version?

## Deep references

- [Chain of Responsibility and Message Filter](references/chain-of-responsibility-and-message-filter.md) — when designing a handler chain or deciding filter vs router vs decorator.
- [ASP.NET Core middleware pipeline and order](references/aspnetcore-middleware-pipeline-order.md) — when ordering or writing middleware, or debugging order bugs.
