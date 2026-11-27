# HTTP Caching Semantics (RFC 9111)

Sources: https://httpwg.org/specs/rfc9111.html · https://www.rfc-editor.org/rfc/rfc5861.txt (stale-while-revalidate, stale-if-error) · https://www.rfc-editor.org/rfc/rfc8246.txt (immutable) · Last verified 2026-11-27

## Model

HTTP caching is optional but reuse is the default unless a rule or configuration blocks it. The cache key is at minimum request method plus target URI, extended by `Vary`-nominated request fields. A shared cache (CDN, reverse proxy) serves many users; a private cache (browser) serves one. Most rules exist to stop improper storage or reuse.

## Storing: when a response may be stored

A cache must not store a response unless: the method and final status are understood, `no-store` is absent, and for shared caches `private` is absent. It also needs explicit cacheability (`public`, `private` for private caches, `Expires`, `max-age`, `s-maxage` for shared, or a heuristically cacheable status). Separately, section 3.5 says a shared cache must not use a stored response to a request carrying `Authorization` unless the response has `must-revalidate`, `public`, or `s-maxage`; the rule is about reuse, not storage. The exact wording of the storage conditions was read through a summarizing fetch, so recheck section 3 before quoting it. Proxy-auth headers are never stored. 206 partials are stored only with Range support.

## Freshness

`response_is_fresh = freshness_lifetime > current_age`.

Freshness lifetime, first match wins: (1) `s-maxage` in a shared cache; (2) `max-age`; (3) `Expires` minus `Date`; (4) heuristic. Heuristics are only for responses without explicit freshness and are a permission (a cache MAY assign one); with `Last-Modified` the RFC calls about 10% of the time since modification a typical setting, not a requirement. Invalid freshness values should be treated as stale. `Expires` is ignored when `max-age` exists; invalid dates such as `0` mean already expired. `Pragma` is deprecated and `Warning` is obsoleted (sections 5.4 and 5.5), so ignore the `Warning` header that RFC 5861 still mentions.

Age calculation: `apparent_age = max(0, response_time - date)`; `corrected_age_value = age_header + (response_time - request_time)`; `corrected_initial_age = max(apparent_age, corrected_age_value)` (the conservative choice the RFC suggests for old caches; when every cache on the path is HTTP/1.1 or later, `corrected_age_value` MAY be used directly); `current_age = corrected_initial_age + (now - response_time)`. A cache serving without validation must send `Age: current_age`. Presence of `Age` means the origin did not generate it for this request.

## Cache-Control response directives (caches must obey)

| Directive | Effect |
|---|---|
| `max-age=N` | Stale after N seconds |
| `s-maxage=N` | Shared caches only; overrides max-age and Expires; incorporates the semantics of proxy-revalidate; permits shared reuse of Authorization responses |
| `no-cache` | Always validate with the origin before reuse (it still allows storing). With field names: those fields excluded or revalidated |
| `no-store` | Do not store any part of request or response |
| `private` | Shared caches must not store; private may. With field names: only those fields are private |
| `public` | May store even if otherwise prohibited; makes it heuristically cacheable |
| `must-revalidate` | Once stale, never reuse without successful validation; if disconnected, the cache must return an error (504 is a SHOULD, unless a more applicable status exists), not stale content |
| `proxy-revalidate` | must-revalidate for shared caches only |
| `must-understand` | Cache only if it understands the status code; pair with `no-store` as fallback |
| `no-transform` | Intermediaries must not alter content |

Unknown directives must be ignored. Directive names are case-insensitive. Request directives (`max-age`, `max-stale`, `min-fresh`, `no-cache`, `no-store`, `only-if-cached`) are advisory; `only-if-cached` yields a stored response or 504. Common confusion: `no-cache` does not mean "do not cache"; `no-store` does.

## Vary

A stored response with `Vary` can be reused without revalidation only if all nominated request fields match the original request (absent matches only absent). `Vary: *` never matches. Consequences: vary on `Accept-Encoding` is cheap; vary on `Cookie` or `Authorization` fragments the cache and can leak; a missing `Vary` for a content-negotiated resource causes wrong-variant serving (inference: the classic CDN bug).

## Serving stale

Not allowed under `no-cache`, `must-revalidate`, `proxy-revalidate`, or `s-maxage` (shared), unless disconnected or explicitly permitted (`max-stale`, extensions). RFC 9111 only cites extensions; RFC 5861 (Informational) defines them:

- `stale-while-revalidate=N`: serve stale up to N seconds past expiry while revalidating in the background. `max-age=600, stale-while-revalidate=30`. Revalidation only starts when a request arrives in the window, so sparse traffic still waits on the origin.
- `stale-if-error=N`: when a 500, 502, 503 or 504 would otherwise be returned, serve a stale response no more than N seconds stale. `max-age=600, stale-if-error=1200` means errors up to t=1800 s can be masked. It does not change freshness; the response should carry `Age`. It can appear in requests too. RFC 5861 is Informational and an independent submission, and it predates RFC 9111's obsoleting of `Warning`.
- `immutable` (RFC 8246, Standards Track): the origin will not change the response during its freshness lifetime, so clients should not revalidate it; it does not apply once the response is stale, and a forced reload can still override it.

## Validation

Conditional requests: send `If-None-Match` with the stored ETag (must, if present) and `If-Modified-Since` with `Last-Modified` (should). `If-None-Match` takes precedence. Origin replies: `304` updates stored headers (not `Content-Length`) and reuses the body; a full response replaces it; a 5xx may be treated as no response, allowing stale service where permitted. Strong validators are needed to match stored responses when freshening. After HEAD 200 with matching ETag/Last-Modified, update stored GET else treat as stale.

```http
HTTP/1.1 200 OK
Cache-Control: public, max-age=60, stale-while-revalidate=30, stale-if-error=600
ETag: "v42"
Vary: Accept-Encoding

GET /x  If-None-Match: "v42"   ->   304 Not Modified
```

## Invalidation

A cache must invalidate the target URI after any 2xx/3xx response to an unsafe method (POST, PUT, DELETE, unknown methods). It may also invalidate `Location` and `Content-Location` URIs if same-origin. This only covers caches the request passed through; it is not global consistency. For other caches use short lifetimes, versioned URLs (change URI on change), or CDN purge APIs (the last is outside the RFC).

## Security (section 7)

Cache poisoning (parsing differences between proxy and user agent), timing attacks that reveal browsing (mitigation: double keying, e.g. add the referring site to the key), and caching of sensitive data by mistake. `Set-Cookie` does not prevent caching; send explicit `Cache-Control`. `no-store` is not a reliable privacy mechanism.

## Recipes

- Fingerprinted static assets: `Cache-Control: public, max-age=31536000, immutable` (`immutable` is RFC 8246; the one-year value is a common convention, not a rule).
- Per-user API response: `Cache-Control: private, max-age=0, must-revalidate` plus ETag.
- Shared, tolerant of staleness: `public, s-maxage=60, stale-while-revalidate=30`.
- Never cacheable: `no-store`.

## How an agent should apply this

- Always send explicit `Cache-Control` plus a validator (ETag or Last-Modified) on cacheable GETs; never rely on heuristic freshness.
- Use `private` for anything user-specific and `public`/`s-maxage` only for data safe to share; check `Vary` for every negotiated header.
- Add `stale-while-revalidate`/`stale-if-error` only where staleness is tolerated, noting they are RFC 5861 extensions, not core RFC 9111.
- For writes, expect invalidation only of the target URI; plan versioned URLs or purge for related resources.
- Test with a shared cache in front (curl twice, inspect `Age`, `Vary`, `Cache-Control`).
