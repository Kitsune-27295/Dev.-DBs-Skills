# Sources — Router: HTTP, Message & UI Routing

Every URL below was checked during skill authoring (2026-11-27; the first draft was dated 2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://martinfowler.com/eaaCatalog/frontController.html | 200 OK (WebFetch, 2026-11-27) | Definition, single handler, decorators, dispatch to commands; points to PoEAA chapter 14. No code, no drawbacks, no Page Controller comparison |
| https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageRoutingIntro.html | 200 OK (WebFetch, 2026-11-27) | Router taxonomy, consumed/published/stateful table, Dynamic Router, composed routers, router versus filter trade-off |
| https://www.enterpriseintegrationpatterns.com/patterns/messaging/ContentBasedRouter.html | 200 OK (WebFetch, 2026-11-27) | Problem, solution, rules-engine evolution, Apache Camel `choice()` example, related-pattern list |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-routing | 200 OK (WebFetch, 2026-11-27); ms.date 2022-08-29, updated 2026-11-19 | Three scenarios, Layer-7 routing, considerations, when not to use, global versus regional, Nginx example |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-offloading | 200 OK (WebFetch, 2026-11-27) (added 2026-11-27) | Not-suitable case: routing rules that couple backend changes to gateway changes |
| https://developer.mozilla.org/en-us/docs/Web/API/History_API/Working_with_the_History_API | 200 OK (WebFetch, 2026-11-27) | pushState and replaceState arguments, popstate, initial-entry state, creatures example |

## Reading limits

- All pages were read through a summarizing fetch tool; wording in the references is paraphrase.
- The MDN guide does not say how `state` is serialized, whether `pushState` ever fires `popstate`, or anything about scroll restoration or the Navigation API.

## Claims not adopted as fact

- Named frameworks (ASP.NET Core endpoint routing, Spring `DispatcherServlet`, Express, Rails) implementing Front Controller: no framework page was read; removed.
- RabbitMQ direct exchanges implementing filter-per-subscriber with binding keys: not on the EIP pages read; removed.
- That a server must return the app shell for deep links, stateful routers needing timeouts, and a router growing into a god object: own inference, labeled as such in the text.
