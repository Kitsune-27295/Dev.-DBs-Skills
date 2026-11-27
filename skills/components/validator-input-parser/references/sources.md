# Sources — Validator & Input Parser

Every URL below was re-fetched and re-read during the rebuild (2026-11-27). Earlier check: 2026-11-23.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/ | 200 OK (WebFetch digest, 2026-11-27) | Parse into precise types, shotgun parsing, push proof to the edge (mechanics live in `defensive-domain-modeling`) |
| https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html | 200 OK (WebFetch digest, 2026-11-27) | Syntactic vs semantic, allowlist, size/depth limits, decode once, JSON schema configuration, Unicode, regex, uploads, email, Host headers, pitfalls, logging |
| https://martinfowler.com/articles/replaceThrowWithNotification.html | 200 OK (WebFetch digest, 2026-11-27; article dated 2014-12-09) | Notification pattern, expected vs exceptional failures, backward refactoring, guard clauses |

## Reading limits
- WebFetch returns a model-produced digest, not raw text; details were kept only where the digest was explicit. Firecrawl had no credits.
- No scripts or data files in this skill; the TypeScript and Python snippets are illustrative and were not run.

## Claims not adopted as fact
- Removed on 2026-11-27 because the digests did not confirm them: CWE-20 wording, RFC 8259 limits remark, UAX #15 citation, XXE/deserialization cheat sheet names, and Bean Validation or Spring `Errors` as Notification implementations.
- Refactoring step 5 (drop the throwing wrapper) and the `Result<Parsed, Notification>` shape are the author's extensions, labeled as such.
- The ReDoS label is common usage; the OWASP page describes the risk without that term.
