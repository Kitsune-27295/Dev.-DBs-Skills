# OWASP Input Validation Rules

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html · Last verified 2026-11-27

## Purpose and limits

Validation confirms input meets application requirements before use; it reduces malformed data, invalid business operations and resource abuse. It is **not** the defense against injection or XSS: use parameterized queries and context-aware output encoding, and check authorization separately (a well-formed account ID does not grant access).

## Strategy

- **Syntactic:** expected type and format. **Semantic:** the value makes sense for the operation (booking end after start). Include consistency between related fields.
- **Allowlist** over denylist: define what is accepted, reject the rest. Blocking apostrophes rejects valid names and does not make queries safe. Free-form comments can allow broad Unicode and limit only length.

| Input kind | Rules |
|---|---|
| Fixed choices | Exact membership (including dropdown values; the client can send anything) |
| Numbers/dates | Type, format, min, max |
| Strings | Length limits, required structure |
| Objects | Allowed fields, required fields, null/missing handling |
| Arrays | Min/max count; validate every item including nested objects |

## Implementation details

- **Limit first:** request size limits before buffering; parser limits such as max nesting depth. A schema check after parsing cannot protect a parser that already exhausted resources.
- **Use maintained parsers,** handle parse failures, validate before business logic or storage; handle parser hardening for risky formats through the matching OWASP cheat sheets.
- **Type is not quantity:** converting text to an integer proves the type only.
- **Decode once, per protocol,** before field rules; validate the representation actually used; avoid downstream re-decoding, which can invalidate earlier checks.
- **Structured data:** use framework or schema validators. In JSON Schema, listing a property neither makes it required nor rejects unknown ones: configure `required` and additional properties explicitly. Apply to nested objects; set array item schemas and length limits. Reject clearly; do not proceed with partially validated data. Bind only intended fields (mass assignment).

## Unicode free text

Agree on one encoding across components and reject malformed input. Preserve legitimate punctuation and scripts. If comparison needs normalization, define one policy and apply it consistently before validation, storage and comparison; compatibility normalization can erase meaningful distinctions. Normalization is not sanitization or output encoding.

## Regular expressions

Use for simple structured fields. Match the **whole value** (`fullmatch`; anchors). Engines differ in character classes and newline handling. Bound input length before matching, avoid patterns prone to excessive backtracking, use a non-backtracking engine or a match timeout, and treat a timeout as validation failure. Test valid, invalid and near-match inputs (near-matches trigger the expensive paths). The cheat sheet does not use the term ReDoS; that label for the risk is common usage (our wording).

```py
import re
SKU = re.compile(r"[A-Z]{3}-\d{4}")          # simple, no nested quantifiers
def parse_sku(s: str):
    if len(s) > 8 or not SKU.fullmatch(s): return None
    return s
```

## Rich content, uploads, email, headers

- **Rich HTML:** use a maintained sanitizer library; regex and validation cannot replace it.
- **Uploads:** filename and content type are untrusted metadata; validate filenames after protocol decoding; an allowed extension does not prove safe content; follow File Upload and Path Traversal cheat sheets for content checks, size limits, storage, safe serving.
- **Email:** maintained library for formats your mail system supports; format validity does not prove mailbox ownership (use a verification flow).
- **Host and forwarded headers:** `Host` (`:authority` in HTTP/2-3), `Forwarded`, `X-Forwarded-*` are client-controlled unless your proxy sets them. Risks: password-reset links to an attacker domain, cache poisoning, reaching internal virtual hosts. Build absolute URLs from configuration; allowlist hostnames explicitly (Django `ALLOWED_HOSTS`, ASP.NET Core `AllowedHosts`, Rails `config.hosts`; never `*`); trust forwarded headers only from your proxies, and have the edge strip client-sent ones; give the proxy a default virtual host that does not serve the app.

## Pitfalls listed by OWASP

Client-only checks; trusting internal sources (APIs, partner feeds, queues, stored records); "cleaning" by removing characters; stopping at syntax or outer fields; assuming regex/normalization makes data safe; trusting upload metadata; logging rejected input verbatim (log failure and metadata, escape retained values for the log format to prevent log injection).

## How an agent should apply this

- Write per-field rules as an allowlist table (type, format, min/max, length, allowed set) before coding.
- Put body-size, depth, array and string limits at the gateway/framework layer and in the schema.
- Review every regex: anchored, length-bounded, simple, tested with near-misses, timeout handling.
- Replace any use of the `Host` header in generated URLs with a configured base URL.
- For uploads, check content, not just names; never feed filenames to filesystem paths unsanitized.
- Check that validation is accompanied by parameterization, output encoding and authorization, not substituted for them.
