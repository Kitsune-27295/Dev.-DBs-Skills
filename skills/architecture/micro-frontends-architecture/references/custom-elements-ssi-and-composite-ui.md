# Custom Elements, Server-Side Includes and Service-Shaped UI

Sources: https://micro-frontends.org/ · https://learn.microsoft.com/pt-br/dotnet/architecture/microservices/architect-microservice-container-applications/microservice-based-composite-ui-shape-layout (Portuguese machine translation, read; ms.date 2021, updated 2026-10-04) · Last verified 2026-11-27

## Geers' principles
Technology agnostic; isolate team code (no shared runtime or globals); team prefixes for CSS, events, storage, cookies; native browser features over custom APIs ("the DOM is the API"); resilient (progressive enhancement). The term first appeared in the ThoughtWorks Technology Radar at the end of 2016.

## Client-side composition with Custom Elements
- Tag name, attributes and events are the contract; implementation is hidden. Names need a dash; use `[team]-[feature]` so ownership shows in the DOM.
- Lifecycle callbacks (connected, attribute changed, disconnected) render, update and clean up.
- Parent to child: change attributes (preferred). Siblings: bubbling custom events caught on `window`, or the host relays via a method call (less desirable).
- Shadow DOM encapsulates markup and styles.
- "Framework anarchy": mixing stacks can help legacy migration, but Geers advises against it and recommends shared practices plus a pattern library.

## Server-side / universal rendering
Client-only rendering shows a blank page until JS loads. Each team serves its component as an HTTP endpoint (tag name as path, attributes as query); the web server (nginx with `ssi on` in the example) resolves Server Side Includes and routes by URL prefix to each team's server. Trade-off: the slowest fragment sets page time; cache, or load slow fragments in the browser.

## Layout shift
Late fragments push content around. Fixed container heights would couple team releases, so Geers prefers skeleton screens that reserve space. Choose server vs client composition by where the site sits between documents and apps.

## Microsoft's composite UI view
A monolithic client UI consuming microservices contrasts with a composite UI where services shape their own view models and client components register with an infrastructure service at startup; if a service changes shape, the UI follows. Each composing service resembles a small API gateway for one UI region. It is harder for native mobile; eShopOnContainers kept a monolithic UI because it is an introduction and its native mobile app (Xamarin, unsupported since May 2024) would complicate the client.

## How an agent should apply this
- Pick Custom Elements plus SSI for content-heavy or SEO-sensitive sites; run-time JS mounting for SPA-style apps.
- Always define element name, attributes and events as the public contract.
- Cache fragments and set timeouts so one slow team cannot block a page.
- Reserve space (skeletons) instead of coordinating fixed heights.
- Treat Microsoft's composite UI as the vertical-slice extreme; do not recommend it for native mobile without caveats.
