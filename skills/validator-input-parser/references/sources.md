# Sources — Validator & Input Parser

Every URL below was checked during skill authoring (2026-11-23).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/ | 200 OK (read via WebFetch; Firecrawl had no credits) | Parser vs validator, shotgun parsing (LangSec), NonEmpty example, "push the burden of proof upward", two-phase program |
| https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html | 200 OK (WebFetch) | Syntactic vs semantic, allowlist, size/depth limits, decode once, JSON schema config, Unicode, regex, uploads, email, Host headers, pitfalls |
| https://martinfowler.com/articles/replaceThrowWithNotification.html | 200 OK (WebFetch) | Notification pattern, why not exceptions for validation, step-by-step refactoring, guard clauses |

Note: WebFetch returns a model-produced digest of each page, not raw text; details were kept only where the digest was explicit.
