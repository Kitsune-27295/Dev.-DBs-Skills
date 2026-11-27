# XSS and Output Encoding Checks

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html · Last verified 2026-11-27

Depth for class 5 of `security-audit`. Fix patterns generally live in `never-trust-the-client`.

## The core idea

Cross-site scripting happens when text a user controls is interpreted by the browser as markup or code. Typical impact (the source video's account, not independently verified here) is session theft or a redirect to a fake payment page for everyone who opens the page. OWASP's cheat sheet stresses coverage: one unprotected path is enough, and no single control suffices.

## Sinks to hunt (and the safer alternative)

| Context | Risky | Safer |
|---|---|---|
| HTML body | `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `[innerHTML]`, `document.write` | `textContent`, `insertAdjacentText`, `createTextNode`, framework default interpolation |
| Attributes | unquoted values, event-handler attributes built from input, `srcdoc` | quoted attribute set with fixed names; `addEventListener` with trusted handlers |
| URL attributes | user value in `href`/`src` (`javascript:`) | allowlist `http`/`https`, validate before render |
| JavaScript | `eval`, `new Function`, string timers, input placed in script blocks | no dynamic code; pass data as JSON |
| CSS | input in style text | set a fixed property from an allowlisted value |
| Markdown/rich text | markdown rendered to HTML without sanitizing | sanitizer library after rendering, no edits after |
| Server output | e-mail HTML, templates with auto-escape off, raw responses | escaping templates, context-aware encoder |

OWASP notes React 19 blocks `javascript:` in `href`/`src` yet says that is not a substitute for application-level URL validation.

## Sanitize versus encode

- Encode when data must appear as text: the encoder must match the output context (HTML, attribute, JavaScript, URL component). Generic escaping is not enough in script contexts.
- Sanitize only when users legitimately author HTML. OWASP recommends a maintained library such as DOMPurify, no mutation afterwards, and regular updates because bypasses surface over time.
- Defence in depth: a Content Security Policy (customized per application) and Trusted Types (`require-trusted-types-for 'script'`, which needs policies that validate or sanitize) reduce impact but are not the primary fix. OWASP says WAFs cannot reliably block all XSS and may miss DOM-based XSS, so they do not replace contextual encoding. Cookie attributes limit damage but do not stop script execution (own note).

## Features that are XSS in disguise

- Admin or settings fields that accept raw HTML or script and render it site-wide.
- Upload endpoints that trust file extension or declared type (own checklist, not from the OWASP page read). Check content validation, served content type, storage location (separate origin or forced download), and that SVG or HTML uploads are not served inline.
- Rich "bio" or comment fields with markdown.

## Verification steps

1. Grep for the sinks above; list each with file:line.
2. Trace the value backwards: constant, escaped, sanitized, or user-controlled? Note storage hops (stored XSS comes back from the database).
3. Check that a sanitizer exists in dependencies and is called at the point of rendering, not only on one form.
4. For uploads, read the handler: type allowlist, size cap, content sniffing, filename handling, where served.
5. Confirm session cookies are not readable by script and that the app has a CSP; record as strengths or hardening, not as the fix.

## Example

```
// finding: stored XSS
profile.bio  --(saved as-is)-->  DB  -->  <div dangerouslySetInnerHTML={{__html: bio}}/>
// fix direction: render bio as text, or sanitize on render with an allowlist
```

## False positives

- `innerHTML` assigned a constant string or a value from a sanitizer immediately before.
- Template engines that auto-escape (verify the setting; raw/unsafe helpers disable it).
- Server-only values never influenced by users (confirm by tracing).

## The video's statistic

The presenter cites a share of AI-generated code with this flaw; the vendor page it appears to come from says AI-generated code introduced risky flaws in 45% of tests and does not mention XSS (re-checked 2026-11-27). Do not repeat it as an XSS-specific rate (see `sources.md`).

## How an agent should apply this

- Report a sink only when a user-controlled source reaches it; state the path.
- Classify uploads and admin raw-HTML fields as high-risk by default and read their handlers.
- Recommend encode-by-default, sanitize-when-needed, CSP as extra.
- Note the sanitizer library and version found, or its absence.
- Do not execute payloads against production; reasoning from code is enough for the report.
