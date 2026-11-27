# Sources: Security Audit

Every URL below was re-fetched on 2026-11-27 with WebFetch. Last verified 2026-11-27.

| Source | Retrieved status | What it contributed |
|---|---|---|
| Video "Usou vibe coding? Ta correndo risco" (pt-BR, 2026), https://www.youtube.com/watch?v=6DJFl-g83dM | 200 OK, but only the title was readable; channel, date and duration not shown. Earlier read through a transcript capture | Origin of the five-class list, the tools list and the "list file by file, do not fix" review prompt |
| https://top10.owasp.org/2025/A01_2025-Broken_Access_Control (added 2026-11-27) | 200 OK via 308 redirect | Broken access control still #1 in the 2025 edition; IDOR named; SSRF folded in |
| https://top10.owasp.org/2021/A01_2021-Broken_Access_Control | 200 OK | 2021 rank #1; IDOR, parameter tampering, privilege elevation; deny by default; trusted server-side code only |
| https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization | 200 OK | API1:2023 BOLA; session-id comparison alone insufficient; random ids preferred |
| https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html | 200 OK | Scoped lookups, random ids only as defence in depth, two-user test |
| https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html | 200 OK | Deny by default, check every request, client checks never decide, CWE-639 |
| https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html | 200 OK | Per-context encoding, DOMPurify advice, React 19 note, CSP and Trusted Types, sinks, WAF remark |
| https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | 200 OK | Revoke, rotate, delete, record; history-rewrite caveat; detection and CI practices |
| https://www.postgresql.org/docs/current/ddl-rowsecurity.html | 200 OK (PostgreSQL 19 documentation) | Default deny, USING vs WITH CHECK, owner and BYPASSRLS bypass, FORCE, permissive vs restrictive; does not cover views |
| https://supabase.com/docs/guides/database/postgres/row-level-security | 200 OK | Per-table enablement, default grants, 42501, secret key bypass, views and `security_invoker` |
| https://github.com/gitleaks/gitleaks | 200 OK | `git`, `dir`, `stdin`; `detect`/`protect` deprecated in v8.19.0; baseline; MIT; feature-complete, successor Betterleaks |
| https://www.zaproxy.org/docs/ | 200 OK (hub page) | ZAP by Checkmarx; scan modes not on this page |
| https://bandit.readthedocs.io/en/latest/ | 200 OK | Python AST-based security linter; Apache-2.0 |
| https://github.com/opengrep/opengrep | 200 OK | Fork of Semgrep v1.100.0, Semgrep-rule compatible, LGPL-2.1, not affiliated with Semgrep Inc. |
| https://www.veracode.com/resources/analyst-reports/2025-genai-code-security-report/ | 200 OK (landing page) | "Risky security flaws in 45% of tests"; no XSS mention |
| https://owasp.org/www-project-code-review-guide/ | 200 OK | Lab project, CC BY-SA 4.0; current version not stated |
| https://github.com/OWASP/www-project-code-review-guide | 200 OK | Archived read-only since 2025-04-11; README still describes 3.0 in progress |
| https://owasp.org/www-project-code-review-guide/assets/OWASP_Code_Review_Guide_v2.pdf | 308 to owasp.github.io; PDF fetched and text-extracted locally | Risk-based depth, the 3-line CSS vs authentication example, CSRF countermeasures that fail |
| Third-party plugin skill on diff scanning (earlier draft) | Not re-read | Third-party skill read for ideas, no text reused; license "Proprietary" |

## Reading limits

- WebFetch returns a model-written summary, not raw text; exact wording of cheat sheets was not compared.
- The v2 PDF was read as extracted text; its checks predate some current practice (password rules defer to `authn-authz-guard`). The 3.0 draft was not used.
- The video transcript was not re-fetched; chapter timestamps, quoted cases and statistics are second-hand.
- No scripts or data files exist in this skill. The report generator and SQL examples mentioned in references are illustrative and were not run.
- Veracode page is a landing page; the report itself was not read.

## Claims not adopted as fact

- Video figures ("83%" of leaks in Supabase projects, a CVE touching 170+ apps, "24 million secrets leaked in 2024"): not verified. The 45% figure is real on the vendor page but is not XSS-specific.
- The card-data, localStorage-admin, exposed-gateway-key and image-hiding-a-script cases: second-hand, no target shown.
- That row isolation is "off by default": a simplification. Docs say enable per table; enabled with no policy denies.
- Draft statements not confirmed on re-fetch and removed: that disabling RLS silently ignores policies; an event trigger to auto-enable RLS (Supabase); that an update needs a matching select policy; cookie attributes limiting XSS damage as an OWASP statement (kept as own note).
- OWASP Code Review Guide process steps (risk classification of the file list, introduced vs pre-existing findings, output shape) are this skill's synthesis.
- Auto-caption name errors in the capture ("Cloud Code", "Supas", "Gitliaks", "Open Grab") were corrected against real sources.
- ZAP maintainer: docs credit Checkmarx; do not repeat the video's non-profit foundation claim.
