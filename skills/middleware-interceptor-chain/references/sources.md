# Sources — Middleware & Interceptor Chain

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://refactoring.guru/design-patterns/chain-of-responsibility | 200 OK (WebFetch; Firecrawl was rate-limited) | Intent, problem, structure, applicability, implementation steps, pros/cons, relations |
| https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageFilter.html | 404 (slug wrong) | Nothing |
| https://www.enterpriseintegrationpatterns.com/patterns/messaging/Filter.html | 200 OK, canonical variant used | Message Filter problem, solution, RabbitMQ binding-key example, related patterns. Page itself does not describe special cases, stateful filters or discard handling |
| https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/ | 200 OK (WebFetch; large page saved and read in parts; .NET 11 default moniker, includes older-version blocks) | Pipeline mechanics, Run/Use/Map/MapWhen/UseWhen, short-circuit, HasStarted rule, recommended order, built-in middleware order table |
