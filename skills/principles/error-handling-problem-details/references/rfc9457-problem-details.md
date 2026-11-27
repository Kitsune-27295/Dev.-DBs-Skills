# RFC 9457 Problem Details for HTTP APIs

Sources: https://www.rfc-editor.org/rfc/rfc9457.html · Last verified 2026-11-27

## Scope

Published July 2023 (Proposed Standard); obsoletes RFC 7807. Defines a machine-readable error body so APIs need not invent their own. JSON form `application/problem+json` (the canonical model, a JSON object); XML form `application/problem+xml`. A server may send these types even if the client did not list them in `Accept`.

## Standard members (members with a wrong-typed value are ignored)

| Member | Semantics |
|---|---|
| `type` | URI reference identifying the problem type; absent means `about:blank`. Consumers SHOULD NOT automatically dereference it. Absolute URIs recommended. Ideally resolves to human documentation |
| `status` | The HTTP status code number; advisory only; generators must send the same code on the wire. Intermediaries may change the real status, so generic HTTP software generally ignores this member |
| `title` | Short summary of the problem **type**; SHOULD NOT change across occurrences except for localization |
| `detail` | Explanation specific to **this occurrence**, aimed at helping the client fix the problem; helps the client correct the problem (not a debugging aid); consumers SHOULD NOT parse it |
| `instance` | URI reference for the occurrence; may or may not be dereferenceable |

`about:blank` adds no semantics beyond the HTTP status; its title should match the standard status phrase.

## Extension members

- A problem type may define extra members (the RFC's examples: `balance` and `accounts` for an out-of-credit problem; an `errors` array for validation where each entry carries a JSON Pointer to the field).
- Clients must ignore extensions they do not recognize; this gives forward compatibility.
- Naming advice (SHOULD-level in the RFC): start with a letter, only letters/digits/underscore, at least three characters. XML extension names must be valid XML Names.

## Defining a problem type (checklist)

1. Type URI (under your control, documented, ideally resolving to HTML).
2. Short title.
3. The HTTP status code to use.
4. Extension members and their types.
5. Optional: whether `Retry-After` applies.
6. Reuse a registered type when one fits; the registry ("HTTP Problem Types", policy Specification Required) contains only `about:blank`; vendor/application/deployment-specific types cannot be registered.

## Usage rules

- Fits 4xx and 5xx best; may accompany any status. If the response *is* a resource representation, the application's own format may be better.
- Problem details are **not a debugging tool**; truly generic conditions are better expressed as plain status codes; do not replace existing domain-specific error formats without reason.
- **Multiple problems**: when types differ, return the most relevant or urgent one. Generic "batch/multiple errors" problem types are discouraged because they map poorly to HTTP semantics. Several occurrences of the *same* type are conveyed through an extension (e.g. an `errors` array on a validation type).
- Security considerations: vet all details, avoid stack dumps and implementation internals.

## Design patterns (own synthesis)

```json
{ "type": "https://api.example.com/problems/out-of-credit",
  "title": "You do not have enough credit.",
  "status": 403,
  "detail": "Your balance is 30, but the cost is 50.",
  "instance": "/account/12345/msgs/abc",
  "balance": 30 }
```

- Keep **one type per client-actionable decision**: clients branch on `type`, never on `title` or `detail`.
- Do not put secrets or other users' data in `detail` or extensions even if "helpful" (balance of own account is fine; another tenant's id is not).
- Use `instance` as a correlation URI (trace id) so support can find the log entry.
- Document each `type` in a page; list its status, extensions and remediation.
- Validation failures: one type, an `errors` extension with JSON Pointer + message per field; accumulate all failures.
- Keep the Problem type list under version control and in the OpenAPI/contract (`arc42-api-contracts-architecture`).

## Anti-patterns

- `type` with a relative or changing URI per release.
- Clients parsing `detail` text.
- `status` in body differing from the HTTP status.
- Returning 200 with a problem body.
- Putting stack traces in `detail`.
- Inventing a "multiple errors" generic type that hides distinct statuses.
- Unbounded extension members that expose internals.

## How an agent should apply this

- Emit `application/problem+json` with stable absolute `type` URIs, constant `title`, matching `status`.
- Put occurrence data in `detail` and typed extensions, never debugging data.
- For validation, use one type with an `errors` extension containing JSON Pointers.
- Maintain a catalog of problem types and reference it from the API contract.
- Make clients ignore unknown extension members and never parse `detail`.
- Review every `detail`/extension for leakage (see the OWASP reference).
