# Sources — API Gateway & Reverse Proxy

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://httpwg.org/specs/rfc9110.html | 200 OK (WebFetch, read in 100 KB slices; ~627 KB total; slices 0-600K covered, final ~77 KB not read) | 3.6-3.8 intermediaries, 7.1-7.8 routing/forwarding/Connection/Max-Forwards/Via/Upgrade, 9.2 method properties, 9.3.6 CONNECT, 15.6.x status codes, 18.2 method table. Forwarded header (RFC 7239) is not in this RFC |
| https://microservices.io/patterns/apigateway.html | 200 OK (WebFetch) | Context, forces, solution, BFF variation, benefits/drawbacks, related patterns |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-offloading | 200 OK (WebFetch) | Offloaded capabilities, considerations (bypass, identity, TLS re-encryption, forwarded headers), when-not-to-use |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-aggregation | 200 OK (WebFetch) | Chattiness problem, considerations (timeouts, partial data, caching fallback), APIM example |
