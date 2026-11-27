# Authentication and Credential Handling

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html · Last verified 2026-11-23

## Definitions
Authentication (AuthN) verifies that a subject is who it claims to be. A digital identity is a unique representation of a subject in one service; identity proofing (KYC-style) is a separate step that binds it to a real person. The session that follows login is covered in `session-management-lifecycle.md`.

## Credential rules (per the cheat sheet, aligned to NIST SP 800-63B)
| Topic | Rule |
|---|---|
| User IDs | Generate randomly, never sequential. Allow email as username only if verified at sign-up. |
| Min length | 8 chars with MFA, 15 chars without MFA. |
| Max length | At least 64 chars; protect the hash step against long-input DoS. Never truncate silently. |
| Composition | Accept all Unicode and spaces; no mandatory upper/digit/symbol rules. |
| Screening | Check against breached/common-password lists (Pwned Passwords API or offline copy, SecLists). |
| Rotation | Only on suspected compromise or authenticator change, not on a calendar. |
| Comparison | Use the framework verify function; if hand-rolled: bounded input, typed operands, constant time. |
| Security questions | Do not use for authentication or re-authentication. |

## Flows that need extra care
- **Change password:** require an authenticated session AND the current password (blocks abuse of an unattended session).
- **Sensitive actions** (email change, new shipping address, adding trusted device): require re-authentication; after it, rotate/invalidate session tokens.
- **Email change:** with MFA, verify via MFA, store the new address as pending, send time-limited nonce links to both old (notification) and new (confirmation) addresses. Without MFA, require the current password and add a third nonce step.
- **Enumeration resistance:** identical message, status code and timing for login, reset and registration. Avoid early return for unknown users; always spend the hash time. Cost: usability, mitigated with CAPTCHA and throttling.

## Automated attack defenses
Distinguish brute force (many passwords, one account), credential stuffing (breached pairs), spraying (one password, many accounts). Layer: MFA first (the sheet cites a claim that it stops 99.9% of compromises); throttle per account, not per IP; tune threshold, window, duration; exponential back-off starting near one second; keep password recovery usable while locked so attackers cannot lock out victims at scale; CAPTCHA only as defense in depth. Log all failures and lockouts and alert near real time.

## Federation and passwordless
- OAuth 2.0/2.1 is authorization, not authentication. OIDC adds authentication through a signed ID Token: validate `iss`, `aud`, signature (JWKS) and `exp`.
- Identify a federated user by `iss` + `sub`, never `sub` alone, never by email. Do not auto-link accounts on matching email. Linking/unlinking needs a fresh authenticated session, notifies the user, and unlinking must actually cut access.
- SAML for enterprise SSO; FIDO2/WebAuthn passkeys are phishing-resistant because keys are origin-bound. Do not assume keys are hardware-backed without attestation.
- Adaptive/risk-based auth: device, IP and location are risk signals, never a substitute for a valid session. Define the score-to-action map (allow, CAPTCHA, step-up, block, revoke).

## Failure modes
Per-IP lockout only; distinct errors for "user not found"; email used as identity key in federation; periodic forced rotation producing weak passwords; client-only password rules.

## How an agent should apply this
- Review login/reset/registration for uniform responses, constant-time compare and per-account throttling.
- Reject composition rules and forced rotation; require length and breach screening instead.
- Require re-auth plus session rotation before email/password/payment-detail changes.
- In OIDC code, verify `iss`/`aud`/signature/`exp` and key accounts on `iss`+`sub`.
- Recommend MFA or passkeys before inventing custom risk logic.
