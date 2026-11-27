# OAuth 2.0 Core Mechanics (RFC 6749)

Sources: https://datatracker.ietf.org/doc/html/rfc6749 · Last verified 2026-11-23

Read in two chunks covering roles through security considerations (section 10). Where RFC 6749 differs from RFC 9700, RFC 9700 wins (implicit and password grants are now discouraged or prohibited).

## Roles
Resource owner (grants access), resource server (hosts data, accepts access tokens), client (acts on the owner's behalf), authorization server (authenticates owner, obtains consent, issues tokens). Client types: confidential (can hold a secret) vs public (browser/native apps). A `client_id` is not a secret.

## Endpoints
- **Authorization endpoint:** user-facing, TLS, GET required (POST optional), no fragment in URI, ignore unknown params.
- **Token endpoint:** POST only, TLS, client authentication (HTTP Basic preferred over body parameters).
- **Redirection endpoint:** absolute URI, no fragment; register it (mandatory for public/implicit clients); on mismatch do NOT auto-redirect.
- **Scope:** space-delimited, case-sensitive; server may grant less and must report the granted scope.

## Grants
| Grant | Use | Today |
|---|---|---|
| Authorization code | user present, web/native | the default, always with PKCE (RFC 9700); code single-use, short-lived (~10 min suggested) |
| Implicit | token in fragment | avoid (RFC 9700) |
| Password | username/password to token endpoint | do not use |
| Client credentials | machine-to-machine, confidential clients only | fine; no refresh token |
| Extension (URI `grant_type`) | e.g. SAML bearer assertion | case by case |

Key params: `response_type`, `client_id`, `redirect_uri` (must be identical at token step), `scope`, `state` (CSRF binding), `code`, `grant_type`.

## Token responses and errors
Success (200 JSON): `access_token`, `token_type`, recommended `expires_in`, optional `refresh_token`, `scope` if changed. Responses MUST carry `Cache-Control: no-store`. Errors default 400: `invalid_request`, `invalid_client` (401 plus `WWW-Authenticate` if Authorization header used), `invalid_grant`, `unauthorized_client`, `unsupported_grant_type`, `invalid_scope`. Authorization-endpoint errors return by redirect: `access_denied`, `unsupported_response_type`, `server_error`, `temporarily_unavailable`.

## Refresh
`grant_type=refresh_token`; scope cannot exceed original; confidential clients authenticate; token bound to its client; server may rotate (client discards old). Refresh tokens go only to the AS, never to resource servers.

## Security considerations (section 10, condensed)
Authenticate clients where possible, otherwise rely on registered redirect URIs; tokens/codes only over TLS; guessing probability at most 2^-128 (2^-160 preferred); codes single-use and revoke derived tokens on replay; require matching `redirect_uri` at exchange; protect redirect endpoint and authorization endpoint from CSRF (`state`); use external browser for native apps (clickjacking/phishing); validate `state` and `redirect_uri` as untrusted input; no open redirectors; refresh token rotation recommended; never put secrets in `state` or `scope`.

## Failure modes
Treating OAuth as login (it is delegated authorization; use OIDC); trusting a bearer token without audience check; storing refresh tokens in browsers; skipping `state`.

## How an agent should apply this
- Map any OAuth flow to its role and endpoint so findings name the exact party at fault.
- Pick the grant: user present then code+PKCE; service then client credentials; reject password and implicit.
- Verify token endpoint behavior: no-store, correct error codes, client auth, redirect match.
- Pair every finding with the RFC 9700 requirement in `oauth-security-bcp-rfc9700.md`.
