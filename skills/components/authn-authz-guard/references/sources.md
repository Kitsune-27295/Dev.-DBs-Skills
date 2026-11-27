# Sources — AuthN & AuthZ Guard

Every URL below was re-fetched and re-read during the rebuild (2026-11-27). Earlier checks: 2026-11-23 and 2026-11-24.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html | 200 OK (WebFetch digest, 2026-11-27) | Password length and screening, enumeration resistance, throttling, re-authentication, OIDC account linking, email-change flow, passkeys |
| https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html | 200 OK (WebFetch digest, 2026-11-27) | ID entropy, cookie attributes and prefixes, lifecycle, timeouts, logout, detection, logging, identifier/verifier storage |
| https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html | 200 OK (WebFetch digest, 2026-11-27) | Least privilege, deny by default, per-request checks, RBAC/ABAC/ReBAC, IDOR, failure handling, testing |
| https://www.rfc-editor.org/rfc/rfc9700.html | 200 OK (WebFetch, two chunks; offset 0 and 100000; 4.11 and the end not read) | BCP 240, January 2025; section 2 requirements; attacks 4.1-4.10 and 4.12-4.17 |
| https://oauth.net/2/oauth-best-practice/ | 200 OK (WebFetch summary) | Headline recommendations (PKCE, exact redirect, PAR, DPoP/mTLS) |
| https://datatracker.ietf.org/doc/html/rfc6749 | 200 OK (WebFetch, two chunks; the first ended before section 10, the second covered it) | Roles, grants, code lifetime, section 10 security considerations, client credentials rules |
| https://www.postgresql.org/docs/current/ddl-rowsecurity.html | 200 OK (WebFetch) | Default-deny, BYPASSRLS and owner bypass, FORCE ROW LEVEL SECURITY |
| https://www.postgresql.org/docs/current/sql-set.html | 200 OK (WebFetch) | SET LOCAL lasts to end of transaction; plain SET lasts for the session |
| https://www.postgresql.org/docs/current/functions-admin.html | 200 OK (WebFetch) | set_config with is_local true |
| https://www.postgresql.org/docs/current/sql-discard.html | 200 OK (WebFetch; page was the PostgreSQL 19 docs) | DISCARD ALL resets session state, not inside a transaction block |
| https://learn.microsoft.com/en-us/sql/relational-databases/security/row-level-security | 200 OK (WebFetch; page dated 2025-09-11) | Filter and block predicates, applies to dbo, SESSION_CONTEXT middle-tier pattern, read_only |
| https://learn.microsoft.com/en-us/sql/t-sql/functions/session-context-transact-sql | 200 OK (WebFetch; page dated 2025-07-07) | SESSION_CONTEXT reads the current session's context |
| https://docs.sqlalchemy.org/en/20/core/pooling.html | 200 OK (WebFetch; last 14,727 characters not read) | Reset-on-return rolls back; session-level state may persist; reset event for deeper cleanup |
| Two internal procedures read for method only | local | Dual-resolver parity and tenant-session method; no names reused |

## Reading limits
- WebFetch returns model-produced digests, not raw text; treat exact numbers as digest-derived. Firecrawl had no credits.
- RFC 9700 section 4.11 and the tail of the page were not read; RFC 6749 endpoint rules, Basic-auth preference and token-endpoint error codes were last confirmed on 2026-11-23, not re-confirmed.
- The decision-order table and test names in the dual-resolver reference are a design pattern, not a source claim.
- No scripts or SQL files were run or edited; SQL snippets are illustrative and were not re-verified.

## Claims not adopted as fact
- The Microsoft figure that MFA stops 99.9% of compromises (quoted by the OWASP sheet) is reported as their claim only.
- oauth.net saying RFC 9700 is "incorporated into OAuth 2.1" is a site claim, not checked against the draft.
- "Publish RFC 8414 metadata" was dropped from the RFC 9700 table because the 2026-11-27 digest did not confirm it.
- Choosing DPoP for public clients and mTLS where certificates are manageable is the author's inference.
- That a pool's default reset does not clear a custom session variable is an inference from the pooling docs.
