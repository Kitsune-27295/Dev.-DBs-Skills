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

## Added 2026-11-24

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.postgresql.org/docs/current/ddl-rowsecurity.html | 200 OK (curl, HTML stripped) | Default-deny, BYPASSRLS and owner bypass, FORCE ROW LEVEL SECURITY |
| https://www.postgresql.org/docs/current/sql-set.html | 200 OK | SET LOCAL lasts to end of transaction |
| https://www.postgresql.org/docs/current/functions-admin.html | 200 OK | set_config with is_local |
| https://www.postgresql.org/docs/current/sql-discard.html | 200 OK | DISCARD ALL resets session state |
| https://learn.microsoft.com/en-us/sql/relational-databases/security/row-level-security | 200 OK | Filter and block predicates, session-context pattern |
| https://learn.microsoft.com/en-us/sql/t-sql/functions/session-context-transact-sql | 200 OK | Session context is per connection |
| https://docs.sqlalchemy.org/en/20/core/pooling.html | 200 OK | Reset-on-return rolls back transactional state |
| https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html | 200 OK (re-read) | Validate permissions on every request, deny by default |
| Two internal procedures read for method only | local | Dual-resolver parity and tenant-session method; no names reused |
