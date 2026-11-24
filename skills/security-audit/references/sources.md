# Sources — Security Audit

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Usou vibe coding? Tá correndo risco" (channel mano deyvin, published 2026-08-10, ~18 min, pt-BR), https://www.youtube.com/watch?v=6DJFl-g83dM | Not fetched from the web; read through a transcript/summary capture (auto-captions). Chapters: 0:00 intro, 1:23 classic mistakes, 4:05 database protection off by default, 8:03 IDOR, 12:56 auditing yourself | The five classes (database without row isolation ~3:00-5:00; front-end-decided permissions ~5:00-7:00; IDOR ~8:00-9:30; exposed keys incl. git history and front-end bundle ~9:30-11:30; unhandled input/XSS ~11:30-12:50), the free tools list (~13:00-14:30, Gitleaks, Bandit, OpenGrep, ZAP) and the "list file by file, line by line, do not fix" review prompt (~14:30-15:30) |
| Transcript/summary capture of the video (private notes; not a public URL) | Read locally | Chapter timestamps, the wording of the prompt, the cases the presenter cites |
| https://top10.owasp.org/2021/A01_2021-Broken_Access_Control (from owasp.org/Top10/..., 308 redirect) | Read OK via redirect | Access control ranked first in the 2021 list; IDOR, client-side tampering, privilege elevation; "server-side only" principle |
| https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization (from owasp.org/API-Security/..., 308 redirect) | Read OK via redirect | IDOR in API terms (API1:2023 BOLA); session-id comparison alone is insufficient |
| https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html | Read OK | Scoped lookups, random ids only as defence in depth, two-user test plan |
| https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html | Read OK | Check on every request, deny by default, never rely on client-side checks |
| https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html | Read OK | Sinks, context encoding, sanitizer advice, CSP as extra layer, URL allowlist |
| https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html | Read OK | Revoke-rotate-delete-log response, history rewrite caveat, detection in pre-commit, CI practices |
| https://www.postgresql.org/docs/current/ddl-rowsecurity.html | Read OK | Row security mechanics: default deny, USING vs WITH CHECK, owner/BYPASSRLS bypass, FORCE |
| https://supabase.com/docs/guides/database/postgres/row-level-security | Read OK | Per-table enablement, grants before policies, secret key bypass, views and security_invoker |
| https://github.com/gitleaks/gitleaks | Read OK | Commands for history scans, baseline, MIT license, feature-complete notice |
| https://www.zaproxy.org/docs/ | Read OK (hub page only) | Confirms the tool and its current maintainer; scan modes not documented on that page |
| https://bandit.readthedocs.io/en/latest/ | Read OK | Python static analyzer scope |
| https://github.com/opengrep/opengrep | Read OK | Fork of Semgrep, LGPL-2.1, rules-compatible |
| https://www.veracode.com/resources/analyst-reports/2025-genai-code-security-report/ | Read OK (landing page) | Checks the "about 45%" figure |
| https://owasp.org/www-project-code-review-guide/ (added 2026-11-24) | 200 OK; landing page only, no chapter content | Project status (lab project, CC BY-SA 4.0) |
| https://github.com/OWASP/www-project-code-review-guide (added 2026-11-24) | 200 OK; repository layout and raw files read | Version 3.0 is a short work-in-progress draft; repository archived and read-only since April 2025 |
| https://owasp.org/www-project-code-review-guide/assets/OWASP_Code_Review_Guide_v2.pdf (added 2026-11-24) | 200 OK (PDF, text extracted locally) | Risk-based review depth, preparation, design questions, access-control, authentication, CSRF, redirect, component and concurrency checks used in the diff review mode |
| Local plugin skill on diff security scanning (added 2026-11-24) | Third-party skill read for ideas (title and description only), no text reused; plugin license visible as "Proprietary" | Only confirmed that a diff mode was missing |

## Claims and caveats

- **Diff review mode (added 2026-11-24):** the checks come from the OWASP Code Review Guide 2.0 PDF, which predates some current practice (for example its password-complexity advice); the reference defers to `authn-authz-guard` there. The process steps (risk classification of the file list, reading around the diff, introduced versus pre-existing findings, output shape) are this skill's own synthesis.

- **Auto-caption errors in the capture:** the transcript misspells several names. Corrected against real sources: "Cloud Code" = Claude Code; "Supas/Super base" = Supabase; "OASP/OAP" = OWASP; "Gitliaks" = Gitleaks; "Open Grab" = OpenGrep; "Srap" = Semgrep; "Vera Code" = Veracode; "RER/Riter" and the two presenter-referenced channel names are garbled and deliberately not repeated here. One phrase attributed to a scammer ("Git Gnó") is unintelligible; it may refer to Git history or a scanner, so it was not used.
- **Cases are second-hand:** the card-data, localStorage-admin and exposed-gateway-key cases come from another channel; targets are not shown and no case was independently verified. They illustrate patterns only.
- **Video figures are the video's claims, not verified here:** "83% of leaks" in Supabase projects, a CVE touching 170+ apps, "24 million secrets leaked in 2024", and the 45% figure. Only the 45% was cross-checked: the vendor page says risky flaws appeared in 45% of tests for AI-generated code and does not mention XSS, so the video's phrasing (a flaw of this specific kind) is looser than the source.
- **Row-isolation "off by default":** the official docs say it must be enabled per table and that enabled-without-policy denies access. The slogan is a simplification.
- **OWASP IDOR ranking:** the video says it is number one in the OWASP API list; confirmed as API1:2023 (BOLA). The general web list ranks broken access control first in 2021.
- **Discrepancies vs SKILL.md:**
  1. Tools table lists OWASP ZAP without a maintainer note; the current ZAP docs credit Checkmarx, while the video says a non-profit foundation. Harmless for the audit, but do not repeat the foundation claim. (resolved 2026-11-24: SKILL.md never made the foundation claim or cited the 45%/83%/170/24 million figures; no change needed)
  2. Gitleaks row has no command; real docs use `gitleaks git` for history, and note feature-complete status with a successor project. (resolved 2026-11-24: SKILL.md table now names `gitleaks git`, with `detect` only for older versions)
  3. SKILL.md does not mention that views can bypass row security, that the table owner bypasses it unless forced, or that an enabled table with no policy denies; these are covered in the tenant-isolation reference. (resolved 2026-11-24: the isolation class now states all three)
  4. SKILL.md says IDs "sequential make it trivial"; OWASP adds that random ids are only defence in depth and never replace the ownership check. (resolved 2026-11-24: IDOR class now says random ids are defense in depth)
  5. SKILL.md's wording "an image hiding a script stole an admin session" is the presenter's second-hand case, not a verified incident. (resolved 2026-11-24: SKILL.md now attributes it to the source video)
