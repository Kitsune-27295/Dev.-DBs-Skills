# OAuth 2.0 Security Best Current Practice (RFC 9700)

Sources: https://www.rfc-editor.org/rfc/rfc9700.html · https://oauth.net/2/oauth-best-practice/ · Last verified 2026-11-27

RFC 9700 (BCP 240, published January 2025) updates RFC 6749, 6750 and 6819; oauth.net reports it as incorporated into OAuth 2.1 (site claim, not checked against the 2.1 draft). Attackers modeled: web attackers (A1), network attackers (A2), readers of authorization responses (A3) and requests (A4), holders of stolen access tokens (A5). Re-read 2026-11-27 through WebFetch digests: section 2 and 4.1-4.10 in the first 100,000 characters, 4.12-4.17 in the second chunk; section 4.11 and the end of the page were not read.

## Normative baseline (section 2)
| Area | Requirement |
|---|---|
| Redirect URI | Authorization server (AS) MUST exact-string match (loopback port may vary for native apps); no `http` except loopback; no open redirectors |
| Code grant | Public clients MUST use PKCE; confidential clients SHOULD. Prefer `S256`. Verifier/challenge unique per transaction |
| PKCE downgrade | AS MUST reject a `code_verifier` if no `code_challenge` was in the authorization request; advertise `code_challenge_methods_supported` |
| Implicit | SHOULD NOT use response types returning tokens in the front channel; use `code` |
| Password grant | MUST NOT be used |
| CSRF | PKCE, OIDC `nonce`, or one-time `state` bound to the user agent |
| Mix-up | Clients using multiple AS need a mix-up defense: validate issuer (RFC 9207 `iss` or ID Token `iss`); store issuer per request |
| Tokens | SHOULD be sender-constrained (mTLS RFC 8705 or DPoP RFC 9449), least-privilege and audience-restricted; resource servers MUST refuse tokens not meant for them. (`resource` RFC 8707 and `authorization_details` RFC 9396 as scoping tools: from the 2026-11-23 pass.) |
| Refresh tokens | Public clients: sender-constrain OR rotate with reuse detection |
| Client auth | Prefer asymmetric (`private_key_jwt`, mTLS) |
| CORS | Never on the authorization endpoint |

## Attacks and the defense that matters
- **Redirect URI validation (4.1):** wildcards and subdomain takeover leak codes; open redirectors plus fragment reattachment leak tokens. Fix: exact match, code flow.
- **Referer / history leakage (4.2, 4.3):** codes and `state` leak through Referer and history. Fix: Referrer-Policy (for example `no-referrer`), single-use codes, `form_post` response mode; never tokens in query strings.
- **Mix-up (4.4):** attacker AS tricks client into sending an honest AS's code. Fix: issuer identification; per-AS redirect URIs only as last resort.
- **Code injection (4.5) and PKCE downgrade (4.8):** stolen code replayed; PKCE blocks it, an OIDC `nonce` can stand in for confidential clients but does not protect public clients.
- **Token injection (4.6):** OIDC `at_hash` and `nonce` detect it; sender constraint stops direct use.
- **Leakage at the resource server (4.9, 4.10):** counterfeit or compromised RS. Fix: sender-constrained, audience-restricted tokens; RS treats tokens as secrets.
- **307 redirect (4.12):** AS MUST NOT use 307 for redirects of credential-bearing requests; SHOULD use 303.
- **Reverse proxies (4.13):** sanitize inbound forwarding headers before trusting client IP/certs.
- **Refresh tokens (4.14):** rotation: a reused old token signals theft, revoke the active one; MAY revoke on logout/password change; expire after inactivity.
- **Client impersonating resource owner (4.15):** do not let clients choose a `client_id`/`sub` confusable with a user; RS must tell user tokens from client tokens.
- **Clickjacking (4.16):** AS MUST prevent it and SHOULD use CSP level 2 or later (`frame-ancestors`).
- **postMessage (4.17):** exact origin match both ways, no `"*"`.

## Decision rules
oauth.net recommends PAR for high-security deployments and sender-constrained tokens (DPoP or mTLS) where possible. Choosing DPoP for public clients and mTLS where certificates are manageable is the author's inference. If an SPA must call APIs, prefer a BFF (see `session-management-lifecycle.md`).

## How an agent should apply this
- Audit OAuth config: exact redirect URIs, PKCE required, no implicit/password grants.
- Check for `state`/`nonce`/PKCE on every redirect flow and issuer validation with multiple AS.
- Require `aud` verification at every resource server and minimal scopes.
- Flag refresh tokens in public clients lacking rotation or DPoP.
- Flag 307 redirects after login and missing frame protection.
