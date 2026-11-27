# RFC 9110: Intermediaries, Forwarding and Status Codes

Sources: https://httpwg.org/specs/rfc9110.html · Last verified 2026-11-23

Read in slices through a summarizing fetch tool; wording below is paraphrase of those summaries, with section numbers as reported. Caching rules live in a separate spec and are only touched briefly.

## Intermediaries (3.7)

- Three common forms: proxy, gateway, tunnel. One intermediary may switch among them per request.
- Terms: upstream/downstream describe message flow; inbound (toward origin) and outbound (toward user agent) describe the request route.
- **Proxy:** forwarding agent chosen by the client, often via local config; used for security, annotation, shared caching.
- **Gateway (reverse proxy):** acts as origin server on its outbound connection and forwards inbound. Origin-server requirements apply on the outbound side; an HTTP-to-HTTP gateway talking to third-party servers must also meet user-agent requirements inbound.
- **Tunnel:** blind relay between two connections; not a party to HTTP while active; ends when both ends close (example: TLS through a firewall proxy).
- **Interception proxy:** not chosen by the client; redirects traffic. Network-level intermediaries below HTTP are indistinguishable from an on-path attacker and may violate HTTP semantics.
- Caches (3.8): a cache cannot be used while acting as a tunnel; cache behavior is defined in the separate caching spec.

## Routing inbound requests (7.1-7.4)

Target URI excludes the fragment; `Host` (or `:authority`) is required and, because it routes, is a target for poisoning attacks. Clients check a cache, then any configured proxy, then go to the origin. Origin servers must reject requests failing scheme requirements unless sent by a trusted gateway; 421 signals a misdirected request.

## Message forwarding (7.6)

- Intermediaries forward unrecognized elements, implement Connection handling, avoid forwarding to themselves without loop protection, and cannot assume partial messages arrive incrementally.
- **Connection (7.6.1):** remove fields named in Connection plus known hop-by-hop fields such as Keep-Alive, TE, Transfer-Encoding. Senders must not list end-to-end fields (Cache-Control) as connection options.
- **Max-Forwards (7.6.2):** for TRACE and OPTIONS. Zero means respond as final recipient; otherwise decrement and forward. Grammar: `1*DIGIT`.
- **Via (7.6.3):** proxies must add it; gateways must add it to inbound requests. Combine only members with identical received-protocol values; hosts may be pseudonyms (17.12 notes this protects sensitive machine names).
- **Upgrade (7.8):** a client may request a protocol switch; a 101 response must include Upgrade; 426 lists acceptable protocols; Upgrade cannot change the transport or move the connection.
- **CONNECT (9.3.6):** target is host:port (no default port); any 2xx switches to tunnel mode; 2xx must not carry Transfer-Encoding or Content-Length; not cacheable. Restrict to known ports; proxy auth may authorize it.

## Methods and retries (9.2, 18.2)

| Method | Safe | Idempotent | Note |
|---|---|---|---|
| GET, HEAD, OPTIONS, TRACE | yes | yes | read-only intent |
| PUT, DELETE | no | yes | repeated request has same intended effect |
| POST, CONNECT | no | no | not auto-retriable |

Rules: clients may auto-retry idempotent requests after a communication failure; should not auto-retry non-idempotent unless semantics are known idempotent or the original was verified unapplied; **proxies must not automatically retry non-idempotent requests**; do not retry a failed retry automatically. Caching: GET, HEAD and POST defined; POST cacheable only with explicit freshness and matching Content-Location.

## Gateway-relevant status codes (15.x)

| Code | Definition (paraphrased) |
|---|---|
| 421 | Server cannot give an authoritative response for the target URI |
| 500 | Unexpected condition prevented fulfilling the request |
| 502 | Gateway/proxy got an invalid response from an inbound server |
| 503 | Temporary overload or scheduled maintenance; may send `Retry-After` |
| 504 | Gateway/proxy got no timely response from upstream |
| 307 / 308 | Temporary / permanent redirect, method must not change |
| 408 | Server did not receive a complete request in time |

429 is not in RFC 9110 (it comes from an extension, RFC 6585). `Retry-After` grammar: HTTP-date or delay-seconds. `Forwarded` (RFC 7239) and `X-Forwarded-*` are not in this RFC (not read from source): use them per your proxy's docs and only trust values set by your own edge.

## Failure modes

- Forwarding hop-by-hop headers: connection-level state leaks to the next hop.
- Retrying POST through the proxy after 504: duplicate side effects.
- Returning 500 for upstream faults: clients cannot decide to retry.
- Open CONNECT: tunnel to arbitrary ports (SMTP etc.).
- Believing client-supplied Host or forwarded headers.

## How an agent should apply this

- Add `Via`, strip hop-by-hop fields, and implement loop detection in any custom proxy.
- Map: unusable upstream reply -> 502, deadline exceeded -> 504, no healthy backend/shedding -> 503 with `Retry-After`.
- Allow automatic retries only for GET/HEAD/OPTIONS/PUT/DELETE; require idempotency keys for POST.
- Allowlist CONNECT destinations or disable it.
- Overwrite forwarded-client headers at the first trusted hop; never forward them from the public internet.
