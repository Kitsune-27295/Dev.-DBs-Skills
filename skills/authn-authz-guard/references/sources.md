# Sources — AuthN & AuthZ Guard

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html | 200 OK (via WebFetch digest; Firecrawl had no credits) | Password length/screening rules, enumeration resistance, throttling, re-authentication, OIDC account linking, email-change flow |
| https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html | 200 OK (WebFetch digest) | ID entropy, cookie attributes and prefixes, lifecycle, timeouts, logout, detection, logging |
| https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html | 200 OK (WebFetch digest) | Least privilege, deny by default, per-request checks, RBAC/ABAC/ReBAC, IDOR, failure handling, testing |
| https://www.rfc-editor.org/info/rfc9700/ | Not fetched; RFC text variant used instead | Metadata page only; full text read from the variant below |
| https://www.rfc-editor.org/rfc/rfc9700.html | 200 OK (WebFetch, two chunks: offset 0 and 100000; part of section 4.10.3 not read) | Section 2 normative practices, section 4 attacks and mitigations |
| https://oauth.net/2/oauth-best-practice/ | 200 OK (WebFetch summary; short landing page) | Status of RFC 9700, headline recommendations (PKCE, exact redirect, PAR, DPoP/mTLS) |
| https://datatracker.ietf.org/doc/html/rfc6749 | 200 OK (WebFetch, two chunks; all targeted sections covered) | Roles, grants, endpoints, token/error responses, refresh, section 10 security considerations |

Note: all pages were read through WebFetch digests (a summarizing model), not raw markdown, because Firecrawl returned an insufficient-credits error. Treat exact numbers as digest-derived.
