# ASP.NET Core Middleware Pipeline and Ordering

Sources: https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/ · Last verified 2026-11-27

Read from the current-version page (default .NET 11 moniker, page dated 2026-08; older monikers appear in the same file). Standalone Blazor WebAssembly apps have no server middleware pipeline.

Pipeline mechanics (Use, Run, short-circuit, response-started rule) are owned by section 3 of `SKILL.md`; the table below adds only what it omits.

## Branching

| Method | Predicate | Rejoins main pipeline? |
|---|---|---|
| `Map(path, ...)` | path prefix; matched segments move from `Path` to `PathBase` | no |
| `MapWhen(pred, ...)` | any `Func<HttpContext,bool>` | no |
| `UseWhen(pred, ...)` | any predicate | yes, unless the branch short-circuits or has terminal middleware |

`Map` can match multiple segments (`/map1/segment1`).

## Automatic middleware (WebApplication)

Developer exception page first in Development; `UseRouting` added if you did not and endpoints exist; `UseAuthentication`/`UseAuthorization` added after routing when the services are registered; endpoints at the end. Calling `UseCors` requires you to call authentication and authorization explicitly in the right order. To run middleware before route matching, call `UseRouting` yourself and place the middleware before it.

## Recommended order (typical Razor Pages / MVC app)

```csharp
if (app.Environment.IsDevelopment()) app.UseMigrationsEndPoint();
else { app.UseExceptionHandler("/Error"); app.UseHsts(); }
app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
// UseRateLimiter, UseRequestLocalization, UseCors
app.UseAuthentication();
app.UseAuthorization();
// UseSession, UseResponseCompression, UseResponseCaching
app.MapRazorPages();
```

## Built-in middleware placement notes (condensed)

| Middleware | Order note |
|---|---|
| Developer exception page / diagnostics | Before middleware that generate errors |
| Forwarded headers | Before middleware that consume scheme, host, client IP, method |
| HTTP/W3C logging | Beginning of pipeline |
| HTTPS redirection, URL rewrite | Before middleware that consume the URL |
| HSTS | After middleware that modify requests (forwarded headers, URL rewrite) |
| Static files | Terminal if a file matches; no authorization checks |
| Request decompression | Before middleware that read the body |
| Rate limiter | After `UseRouting` when endpoint-specific limits (`[EnableRateLimiting]`) are used; global-only can go before |
| Request localization | Before localization-sensitive middleware; after routing for route-data culture provider |
| CORS | Before auth and before response caching |
| Authentication / Authorization | Authz immediately after authn; terminal for OAuth callbacks |
| Antiforgery | After authn/authz, before endpoints |
| Request timeouts | After exception handler and routing |
| Output caching | After routing, CORS, authentication, authorization |
| Response caching | After CORS; needs client participation; not typically useful for UI apps |
| Session | Before middleware requiring it; after cookie policy |
| Endpoint routing / MVC | Terminal for matching routes |
| SPA fallback | Late, so other file/endpoint handlers win |
| WebSockets | Before middleware that accept WebSocket requests |

Caching vs compression: `UseResponseCaching()` then `UseResponseCompression()` can cache the compressed response (CPU saved) but may store several encodings (Gzip, Brotli). Static files placed before compression are not compressed by that middleware.

Authentication middleware authenticates but does not short-circuit unauthenticated requests; rejection happens at authorization after an endpoint is selected.

## Failure modes

- Reordering CORS, auth or caching by feel: breaks preflight or leaks cached private data.
- Assuming wwwroot files are protected.
- Writing headers after `next` returns.
- Placing a `Use` after a `Run` and expecting it to run.

## How an agent should apply this

- Start from the template order above; justify every deviation in a comment.
- Put exception handling outermost; forwarded headers before anything reading scheme/host/IP.
- Keep CORS before authn/authz and before response caching; authz right after authn.
- Use `UseWhen` for conditional steps that must rejoin; `Map` for mounted sub-apps.
- In custom middleware, guard post-`next` header writes with `HasStarted`.
- Verify the version: docs differ by moniker, so confirm against the project's target framework.
