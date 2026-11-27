# Sources — Middleware & Interceptor Chain

Every URL below was re-checked during the 2026-11-27 rebuild (earlier pass: 2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://refactoring.guru/design-patterns/chain-of-responsibility | 200 OK (WebFetch, 2026-11-27) | Intent, implementation steps, Decorator comparison, pros and cons |
| https://www.enterpriseintegrationpatterns.com/patterns/messaging/Filter.html | 200 OK (WebFetch, 2026-11-27) | Message Filter as a single-output router, RabbitMQ example, related patterns; discards mentioned only as "discarded" |
| https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageFilter.html | 404 on 2026-11-23 (wrong slug); not re-fetched | Nothing |
| https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/ | 200 OK (WebFetch, 2026-11-27; default moniker .NET 11, page dated 2026-08, updated 2026-11) | Run/Use/Map/MapWhen/UseWhen, HasStarted rule, recommended order, built-in order table, authentication does not short-circuit |

## Reading limits

Large page read through a saved copy with targeted searches, not every moniker block. No code was run.

## Claims not adopted as fact

- "Inject per-request services through the invoke method, not a singleton's constructor": not found on the page, removed.
- Discard handling and stateful filters for Message Filter: our reasoning, not the page's.
- Corrected 2026-11-27: the "Dead Letter Channel" relation was not on the EIP page; the page lists Event-Driven Consumer and Message Router instead.
