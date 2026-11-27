# RFC 9110: Intermediaries, Forwarding and Status Codes

Sources: https://httpwg.org/specs/rfc9110.html · https://www.rfc-editor.org/rfc/rfc7239.txt · https://www.rfc-editor.org/rfc/rfc6585.txt · Last verified 2026-11-27

The RFC 9110 body was downloaded as HTML, converted to text and searched for the cited clauses; wording below is paraphrase, with section numbers. Caching rules live in a separate spec and are only touched briefly.

## Intermediaries (3.7)

- Three common forms: proxy, gateway, tunnel. One intermediary may switch among them per request.
- Terms: upstream/downstream describe message flow; inbound (toward origin) and outbound (toward user agent) describe the request route.
- **Proxy:** forwarding agent chosen by the client, often via local config; used for security, annotation, shared caching.
- **Gateway (reverse proxy):** acts as origin server on its outbound connection and forwards inbound. Origin-server requirements apply on the outbound side; an HTTP-to-HTTP gateway talking to third-party servers must also meet user-agent requirements inbound.
- **Tunnel:** blind relay between two connections; not a party to HTTP while active; ends when both ends close (example: TLS through a firewall proxy).
- **Interception proxy:** not chosen by the client; redirects traffic. Network-level intermediaries below HTTP are indistinguishable from an on-path attacker and may violate HTTP semantics.
- Caches (3.8): a cache cannot be used while acting as a tunnel; cache behavior is defined in the separate caching spec.

## Routing inbound requests (7.1-7.4)

Target URI excludes the fragment; `Host` (or `:authority`) is required and, because it routes, is a target for poisoning attacks. Clients check a cache, then any configured proxy, then go to the origin. Origin servers MUST reject requests failing scheme requirements unless the connection is from a trusted gateway; a Host that differs from the connection's host or port is expected from a trusted gateway and otherwise may signal an attempt to bypass filters or poison a cache. 421 signals a misdirected request.

## Message forwarding (7.6)

- Intermediaries forward unrecognized elements, implement Connection handling (unless acting as a tunnel), MUST NOT forward a message to themselves without loop protection (recognize own names, aliases and literal IPs and answer directly), and cannot assume partial messages arrive incrementally.
- **Connection (7.6.1):** intermediaries MUST parse Connection, remove every field it names, then remove Connection itself or replace it with their own options. They SHOULD also remove known hop-by-hop fields whether or not listed: Proxy-Connection, Keep-Alive, TE, Transfer-Encoding, Upgrade (the list is "not limited to" these). Senders MUST NOT list end-to-end fields (Cache-Control) as connection options.
- **Max-Forwards (7.6.2):** for TRACE and OPTIONS. Zero means do not forward and respond as final recipient; otherwise forward the lesser of value minus one and your own maximum. Grammar: `1*DIGIT`.
- **Via (7.6.3):** a proxy MUST send Via in each message it forwards; an HTTP-to-HTTP gateway MUST send it in each inbound request and MAY in responses. An intermediary MAY combine an ordered run of members with identical received-protocol values and MUST NOT combine different ones; a sender SHOULD NOT combine unless all are under the same organizational control with hosts already pseudonymized. Hosts may be replaced by pseudonyms.
- **Upgrade (7.8):** a client may request a protocol switch; a 101 response must include Upgrade; 426 lists acceptable protocols; Upgrade cannot change the transport or move the connection.
- **CONNECT (9.3.6):** target is host:port (no default port); any 2xx switches to tunnel mode; 2xx must not carry Transfer-Encoding or Content-Length; not cacheable. Restrict to known ports; proxy auth may authorize it.

## Methods and retries (9.2, 18.2)

| Method | Safe | Idempotent | Note |
|---|---|---|---|
| GET, HEAD, OPTIONS, TRACE | yes | yes | read-only intent |
| PUT, DELETE | no | yes | repeated request has same intended effect |
| POST, CONNECT | no | no | not auto-retriable |

Rules (9.2.2): clients may auto-retry idempotent requests after a communication failure; SHOULD NOT auto-retry non-idempotent unless semantics are known idempotent or the original is known unapplied; **a proxy MUST NOT automatically retry non-idempotent requests**; a client SHOULD NOT automatically retry a failed automatic retry. Caching: GET, HEAD and POST defined; POST cacheable only with explicit freshness and matching Content-Location.

## Gateway-relevant status codes (15.x)

| Code | Definition (paraphrased) |
|---|---|
| 421 | Server cannot give an authoritative response for the target URI |
| 500 | Unexpected condition prevented fulfilling the request |
| 502 | Gateway/proxy got an invalid response from an inbound server |
| 503 | Temporary overload or scheduled maintenance; MAY send `Retry-After`; a server need not use 503 when overloaded (it may refuse the connection) |
| 504 | Gateway/proxy got no timely response from upstream |
| 307 / 308 | Temporary / permanent redirect, method must not change |
| 408 | Server did not receive a complete request in time |

429 is not in RFC 9110 (confirmed absent); it comes from RFC 6585 (rate limiting; the response MAY carry `Retry-After`) and is owned by `rate-limiter-throttler`. `Retry-After` grammar: HTTP-date or delay-seconds. `Forwarded` is defined by RFC 7239 (Standards Track, June 2014) to disclose information lost in proxying, such as the originating IP; `X-Forwarded-For` appears there only as an existing non-standard header. RFC 7239 warns that an address chain from before your proxy cannot be trusted and that unsecured proxy-to-endpoint links allow tampering. Neither header is in RFC 9110.

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
