# Session Management Lifecycle

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html · Last verified 2026-11-23

## Core idea
After login, the session ID is as powerful as the credential. Targeted attacks hit one privileged user; generic attacks hit anyone. Every control below shrinks the chance of guessing, stealing, fixing or replaying that ID.

## Session ID properties
- At least 64 bits of CSPRNG entropy (sheet's example: ~585 years to guess at 10,000 guesses/s against 100,000 live sessions). Prefer the framework generator; if self-made, 128+ bits.
- Length is not entropy: a fixed half of a 16-hex ID leaves about 32 bits.
- Opaque: no PII or role data inside; keep state server-side.
- Rename framework-default cookie names (`JSESSIONID`, `PHPSESSID`, ...) to avoid fingerprinting.
- Storage option: split a public identifier from a secret verifier (128-160+ bits); store the identifier and SHA-256 of the verifier; compare in constant time. Protects against read-only store disclosure, not against stolen cookies.

## Cookie attributes
`Secure`, `HttpOnly`, explicit `SameSite` (`Strict` preferred, `Lax` acceptable; never `None` without `Secure`), prefix `__Host-` (forces Secure, no Domain, Path=/). Omit `Domain`, narrow `Path`. HttpOnly does not stop CSRF; SameSite complements, not replaces, CSRF tokens.
```
Set-Cookie: __Host-SessionID=<opaque>; Secure; HttpOnly; SameSite=Strict; Path=/
```
Use cookies only; refuse IDs in URLs, forms or custom headers. Use HTTPS for the whole session plus HSTS; never move a session between HTTP and HTTPS.

## Client storage
Never keep session IDs, JWTs or refresh tokens in localStorage or sessionStorage (XSS reads them). Web Workers do not defend against XSS. Prefer HttpOnly cookies or a backend-for-frontend holding tokens.

## Lifecycle rules
1. **Strict mode:** accept only server-issued IDs; on an unknown ID, issue a fresh one and alert.
2. **Validate format** of incoming IDs (they are untrusted input).
3. **Renew on privilege change** (login, password change, role elevation) and destroy the old ID; use a different cookie name pre/post authentication.
4. **Timeouts, server enforced:** idle 2-5 min (high value) or 15-30 min (low risk); absolute e.g. 4-8 h; optional renewal timeout with a short grace for the old ID.
5. **Logout:** clear client cookie AND destroy server session; revoke every ID of the logical session, including rotated ones in grace; in-flight renewals must not mint new valid IDs. Send `Clear-Site-Data: "cache", "cookies", "storage"` and `Cache-Control: no-store` on sensitive responses.
6. **Detection:** alert on many invalid IDs, ID presented by another user, IP/User-Agent drift (signals, not proofs, because of NAT and proxies). Log lifecycle events with a salted hash of the ID, never the raw ID.
7. **Concurrency:** decide explicitly; if restricted, end the older session or ask; let users list and kill their sessions.

## Anti-patterns
Pre-auth cookie trusted after login; ID in URL; relying on `beforeunload` to log out; client timers as the only timeout; WAF as a substitute for fixing the app (acceptable only as a stopgap).

## How an agent should apply this
- Check cookie flags, prefix, ID entropy source and rotation on login in code review.
- Grep for tokens in localStorage/sessionStorage and for session IDs in URLs or logs.
- Verify timeouts are enforced server-side and logout invalidates server state.
- Recommend BFF or HttpOnly cookies for SPAs instead of browser-stored tokens.
- Add tests: fixation (ID changes after login), logout revokes all IDs, expired session rejected.
