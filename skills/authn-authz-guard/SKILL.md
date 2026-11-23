---
name: authn-authz-guard
description: "Design and review authentication, session management, OAuth 2.0 / OIDC flows (RFC 9700 Security BCP, RFC 6749) and authorization decisions (RBAC, ABAC, ReBAC, IDOR, deny-by-default). Covers password and MFA rules, cookie and session lifecycle, PKCE, redirect URI matching, sender-constrained and audience-restricted tokens, refresh token rotation, and centralized permission checks. Use when building or reviewing login, sessions, tokens, SSO, API access control, roles/permissions, or when a finding mentions fixation, token leakage, broken access control or IDOR."
---

# AuthN & AuthZ Guard

One idea: **identity, session and permission decisions are three separate mechanisms, each enforced once, centrally, on the server, and denied by default.** Authentication proves who; the session or token carries that proof; authorization decides what that subject may do to this specific object on every request. Sources and retrieval status: [references/sources.md](references/sources.md).

Boundary: this skill owns identity, session, token and permission-decision mechanics. Generic threat review and secure-coding checklists belong to `security-audit`; "never accept client-supplied trust" belongs to `never-trust-the-client`; row-level database policies belong to `database-exposure`. Where requests are routed or gateways terminate TLS, see `api-gateway-reverse-proxy` and `middleware-interceptor-chain`; throttling belongs to `rate-limiter-throttler`; input shape checks to `validator-input-parser`; error body shape to `error-handling-problem-details`.

---

## 1. Separate the Three Questions

| Question | Mechanism | Owned by | Typical bug |
|---|---|---|---|
| Who is this? | Password/MFA/passkey, OIDC ID Token | Authentication | enumeration, weak reset, email-as-identity |
| Is this still them? | Session cookie or access token | Session / token layer | fixation, long-lived tokens, tokens in localStorage |
| May they do this to that object? | Policy decision (RBAC/ABAC/ReBAC) | Authorization | missing per-object check (IDOR), default allow |

Never let a signal (IP, device fingerprint, "remember me" cookie) stand in for the second question. Details: [authentication](references/authentication-and-credential-handling.md).

## 2. Authentication Rules

- Passwords: min 8 with MFA, 15 without; allow 64+ chars and any Unicode; no composition rules; no scheduled rotation; screen against breached lists; never truncate; constant-time comparison.
- Login, reset and registration respond identically (message, status, timing). Throttle per account, not per IP; keep recovery available during lockout.
- Prefer MFA or passkeys (WebAuthn) over inventing risk scoring. Security questions are not an authenticator.
- Sensitive changes (password, email, payment target) require re-authentication, then session rotation.
- Federation: OAuth is not login; use OIDC and validate `iss`, `aud`, signature, `exp`. Key accounts on `iss`+`sub`; never auto-link on email.

## 3. Session Rules

| Item | Rule |
|---|---|
| ID | CSPRNG, 64+ bits minimum (128 if self-made), opaque, generic cookie name |
| Cookie | `__Host-` prefix, `Secure`, `HttpOnly`, explicit `SameSite=Strict/Lax`, no `Domain` |
| Mode | Strict: accept only server-issued IDs |
| Renewal | New ID on login and every privilege change; old one destroyed |
| Timeouts | Server-side idle (2-5 min high value, 15-30 low) plus absolute (e.g. 4-8 h) |
| Logout | Destroy server state, revoke all rotated IDs, clear client, `Clear-Site-Data` |
| Storage | Never tokens in localStorage/sessionStorage; use HttpOnly cookies or a BFF (`bff-pattern`) |
| Logs | Salted hash of ID, never the raw value |

Cookies do not replace CSRF defenses; SameSite is defense in depth. Details: [session lifecycle](references/session-management-lifecycle.md).

## 4. OAuth 2.0 / OIDC Baseline (RFC 9700)

1. Use authorization code + **PKCE (S256)**; PKCE is mandatory for public clients and recommended for confidential ones.
2. **Exact-match** redirect URIs; no wildcards, no `http` (except loopback), no open redirectors.
3. **No implicit grant, no password grant.** Client credentials only for machine-to-machine confidential clients.
4. CSRF: PKCE, `nonce` or bound one-time `state`. Multiple authorization servers: validate issuer (RFC 9207) to stop mix-up.
5. Tokens: short-lived, least scope, **audience-restricted** (every resource server checks `aud`), **sender-constrained** where possible (DPoP, mTLS). PAR for high-security deployments.
6. Refresh tokens for public clients: rotation with reuse detection or sender constraint; revoke on password change/logout.
7. Authorization server: never answer credential POSTs with 307 (use 303); CSP `frame-ancestors`; no CORS on the authorization endpoint; sanitize forwarded headers behind proxies.
8. Never put access tokens in URLs; use `form_post` or code flow.

Details: [RFC 9700](references/oauth-security-bcp-rfc9700.md), [RFC 6749 mechanics](references/oauth2-core-rfc6749-mechanics.md).

## 5. Authorization Rules

1. **Deny by default**; every grant is explicit and justifiable.
2. **Central enforcement** (middleware/filter/policy decision point) on every request; no per-handler remembered checks.
3. **Object-level check** for every identifier the client supplies (IDOR/CWE-639). Randomized IDs are not authorization.
4. Server-side only; client checks are UX.
5. Choose the model: RBAC for coarse gates, ABAC/ReBAC for object, tenant and context decisions (the OWASP sheet recommends ABAC/ReBAC for most apps). Beware role explosion.
6. Fail safely: one centralized failure path, generic 403/404, no internals, nothing half-applied.
7. Include static resources and storage buckets in policy.
8. Log every denial with subject, action, resource; test default-deny and cross-tenant negatives.

Details: [authorization models](references/authorization-models-and-enforcement.md).

## 6. Placement in the Architecture

- Authentication and coarse authorization at the edge or middleware; fine-grained, resource-aware decisions in the application/domain layer where the aggregate is loaded (`hexagonal-architecture`, `clean-architecture`). A gateway check alone does not protect internal callers.
- Services receive a verified principal (claims) from the edge, then still enforce their own object checks.
- Authorization policy is a port: domain asks `allows(subject, action, resource)`; adapters supply RBAC/ABAC/ReBAC.

## Reject on Sight

- "We check the role in the UI." / role strings compared in dozens of handlers.
- Session or JWT in localStorage; session ID in URL.
- Wildcard or prefix-matched redirect URIs; implicit or password grant.
- Bearer tokens accepted without audience check.
- Different errors for "no such user" and "wrong password".
- Email used as the primary federated identity key.
- Authorization defaulting to allow when a policy is missing.

## Quick Decision Checklist

- [ ] Is every route covered by central authN and a deny-by-default authZ policy?
- [ ] Does each object ID get an ownership/permission check?
- [ ] Are cookie flags, ID entropy, rotation on login, server-side timeouts and logout correct?
- [ ] OAuth: code+PKCE, exact redirect URIs, `aud` checks, no implicit/password, refresh rotation?
- [ ] Are failures uniform (no enumeration) and denials logged?
- [ ] Are negative tests present (other user, other tenant, expired/rotated session)?
- [ ] Did I avoid re-doing generic audit work that `security-audit` covers?

## Deep references

- [Authentication and credential handling](references/authentication-and-credential-handling.md) — passwords, MFA, reset, enumeration, federation account linking.
- [Session management lifecycle](references/session-management-lifecycle.md) — ID entropy, cookie attributes, renewal, timeouts, logout, detection.
- [Authorization models and enforcement](references/authorization-models-and-enforcement.md) — least privilege, deny-by-default, RBAC vs ABAC vs ReBAC, IDOR.
- [OAuth 2.0 Security BCP (RFC 9700)](references/oauth-security-bcp-rfc9700.md) — normative requirements and attack catalog.
- [OAuth 2.0 core mechanics (RFC 6749)](references/oauth2-core-rfc6749-mechanics.md) — roles, grants, endpoints, token responses, security considerations.
