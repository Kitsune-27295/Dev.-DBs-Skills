# Sources — API Gateway & Reverse Proxy

Every URL below was checked during skill authoring (2026-11-27; the first draft was dated 2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://httpwg.org/specs/rfc9110.html | 200 OK (curl, 2026-11-27, ~915 KB HTML; converted to text and searched for each cited clause) | 3.7 intermediaries, 7.4 misdirected requests, 7.6.1 Connection, 7.6.2 Max-Forwards, 7.6.3 Via, 9.2.2 idempotent methods and the proxy retry rule, 9.3.6 CONNECT, 15.5.20 and 15.6.3-15.6.5 status codes, Retry-After grammar. Confirmed absent: 429, Forwarded, X-Forwarded-* |
| https://www.rfc-editor.org/rfc/rfc7239.txt | 200 OK (curl, 2026-11-27) (added 2026-11-27) | `Forwarded` header definition and its trust warning |
| https://www.rfc-editor.org/rfc/rfc6585.txt | 200 OK (curl, 2026-11-27) (added 2026-11-27) | 429 Too Many Requests belongs to RFC 6585 |
| https://microservices.io/patterns/apigateway.html | 200 OK (WebFetch, 2026-11-27) | Benefits and drawbacks (extra component and hop), reactive implementation note; forces and the BFF variation live in `bff-pattern` |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-offloading | 200 OK (WebFetch, 2026-11-27); ms.date 2026-09-23 | Offloaded capabilities, considerations (bypass, identity, TLS re-encryption, forwarded headers, operations), when not to use, Azure mapping |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-aggregation | 200 OK (WebFetch, 2026-11-27); ms.date 2026-06-02 | Chattiness problem, considerations (timeouts, partial data, cache failover), API Management example, when not to use |
| https://learn.microsoft.com/en-us/azure/architecture/patterns/gateway-routing | 200 OK (WebFetch, 2026-11-27) (added 2026-11-27) | "One or two services" caution cited in section 6 |

## Reading limits

- RFC 9110 was searched by clause, not read end to end. CONNECT (9.3.6) was re-read in full; the Upgrade (7.8) row in the reference comes from the earlier read and only the 101-must-include-Upgrade statement was re-confirmed.
- Microsoft and Richardson pages were read through a summarizing fetch tool; wording is paraphrase.

## Claims not adopted as fact

- "Do not route internal service-to-service traffic through the gateway; a mesh or direct calls fit better": no source read; removed.
- That interception proxies should be avoided: the RFC only says they differ from client-chosen proxies and can violate HTTP semantics; the advice is own design.
- "Overwrite forwarded-client headers at the first trusted hop": own design, consistent with the RFC 7239 and Microsoft warnings, not stated by either.
