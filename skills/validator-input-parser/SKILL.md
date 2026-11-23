---
name: validator-input-parser
description: "Validate and parse untrusted input at trust boundaries: parse-don't-validate at the edge, OWASP input validation (allowlists, syntactic vs semantic checks, size and depth limits, safe regex/ReDoS, file uploads, Host headers), schema-library usage, and the Notification pattern for collecting all errors instead of throwing on the first. Use when designing request/webhook/queue/CLI input handling, reviewing validation code, choosing where validation lives, or returning multi-error validation responses."
---

# Validator & Input Parser at Trust Boundaries

One idea: every byte that crosses a **trust boundary** is hostile until it has been size-limited, decoded once, **parsed into a stronger type**, checked syntactically and semantically against an **allowlist**, and its failures **collected** (not thrown one at a time) into a single error report; everything behind the boundary then works with already-proven data. Sources and claims: [references/sources.md](references/sources.md).

Boundary with neighbours: type-level modeling (Value Objects, sum types, `Result` pipelines, making illegal states unrepresentable) belongs to `defensive-domain-modeling`; this skill owns the **mechanics at the edge** (what to check, in which order, with which limits, and how to report). DTO-to-domain translation is `dto-mapper-anti-corruption-layer`; the final error envelope is `error-handling-problem-details`; domain value-object invariants are `value-objects-type-invariants`; authorization is `authn-authz-guard`; the trust principle itself is `never-trust-the-client`; broad security review is `security-audit`.

---

## 1. Where Validation Lives

| Boundary | Examples | Rule |
|---|---|---|
| External entry | HTTP body/query/headers, webhooks, CLI args, uploads | Always parse + validate at the adapter/controller edge |
| Internal-but-untrusted | Partner feeds, message queues, stored legacy rows | Treat as external when data crosses a trust boundary (OWASP pitfall) |
| Client UI | Browser form checks | Convenience only; never a control. Re-validate on the server |
| Domain core | Aggregates, services | Receives parsed types; does **not** re-check raw strings (no shotgun parsing) |

**Two-phase program shape:** phase 1 = parse/validate (failures are expected and reported); phase 2 = execution (few, genuinely exceptional failures). Never start acting on part of the input before the rest is proven valid. See [references/parse-dont-validate-at-the-edge.md](references/parse-dont-validate-at-the-edge.md).

## 2. The Pipeline (do it in this order)

1. **Authenticate/authorize first when cheap**, so anonymous callers cannot make you burn parse resources (authorization stays a separate control: a valid ID is not permission).
2. **Limit size** before buffering: max body bytes, max JSON nesting depth, max array length, max string length.
3. **Decode once** per the protocol (charset, URL/percent, base64); validate the representation that will actually be used; never decode again downstream.
4. **Parse structurally** with a maintained parser/schema library; unknown fields rejected or explicitly stripped; required fields explicit.
5. **Syntactic check:** type, format, length, range, allowed set.
6. **Semantic check:** does it make sense for this operation (end after start, quantity within stock, related fields consistent)?
7. **Collect** every error in a Notification; **reject** with one clear response; never continue with partial data.
8. **Produce a typed, immutable result** handed to the application layer.

## 3. OWASP Rules in Brief

| Rule | Do | Reject |
|---|---|---|
| Allowlist | Define what is valid; drop everything else | Denylists of "bad strings", stripping/"cleaning" characters |
| Syntax vs semantics | Both, plus cross-field consistency | Stopping at type checks (`parseInt` proves type, not value) |
| Per-type rules | Enums: exact membership. Numbers/dates: type, format, min/max. Strings: length + structure. Objects: allowed/required fields. Arrays: item count + every item | Validating only the outer object |
| Free text | Allow broad Unicode, limit length, one agreed encoding | Restricting names to `[A-Za-z]` (rejects real people) |
| Regex | Whole-value match, bounded input length, non-backtracking engine or timeout; test valid, invalid and near-match cases; timeout = failure | Unanchored patterns, nested quantifiers, unbounded input |
| Uploads | Treat filename and content-type as untrusted; validate after decoding; extension allowlist is not content proof | Trusting `Content-Type`; using filename in paths |
| Email | Maintained library for format; ownership by verification mail | Hand-rolled regex as proof of ownership |
| Host/forwarded headers | Build absolute URLs from config; allowlist hostnames (`ALLOWED_HOSTS` and equivalents); trust `X-Forwarded-*` only from your proxy | Reset links built from the `Host` header |
| Output | Validation is not output encoding or parameterized queries | "We validate, so no escaping needed" |
| Logging | Log failure + metadata, escape retained values | Logging full rejected bodies or secrets |

Details and examples: [references/owasp-input-validation-rules.md](references/owasp-input-validation-rules.md).

## 4. Collect Errors: the Notification Pattern

Validation failure on external input is **expected**, not exceptional. Use a `Notification` (error collector) so the caller gets all problems in one round trip; throw only for programmer errors or when re-validating "should already be clean" data.

```ts
class Notification { errors: {field: string; code: string; message: string}[] = [];
  add(field: string, code: string, message: string) { this.errors.push({field, code, message}); }
  get hasErrors() { return this.errors.length > 0; } }

function validateBooking(raw: unknown): Notification {
  const n = new Notification(); const b = raw as Record<string, unknown>;
  const seats = b.numberOfSeats;
  if (typeof seats !== "number") n.add("numberOfSeats", "required", "must be a number");
  else if (seats < 1) n.add("numberOfSeats", "min", "must be at least 1");
  if (typeof b.date !== "string") { n.add("date", "required", "missing"); return n; } // guard: later checks need a date
  /* parse date, compare with today ... */
  return n;
}
```

Guard clauses stop checks that depend on a failed prerequisite. Combine with parsing: the final step turns a clean input into a typed object or returns the Notification (`Result<Parsed, Notification>`). See [references/notification-pattern-error-collection.md](references/notification-pattern-error-collection.md).

## 5. Schema Libraries: Usage Rules

- Prefer the platform's schema validator (JSON Schema, Zod/Valibot, Pydantic, Bean Validation, FluentValidation) over hand-written `if` chains; infer the static type **from** the schema so type and check cannot drift (single source of truth).
- Configure **explicitly**: required properties, `additionalProperties: false` (listing a property does not make it required and does not reject unknowns), array `maxItems`, string `maxLength`, nested schemas.
- Bind only intended fields to application objects (mass assignment).
- Keep business rules (date ordering, stock) beside structural ones but in a separate semantic step.
- Map library errors into your Notification/Problem Details shape once, in one adapter; do not leak library-specific messages.

## 6. Anti-Patterns

| Smell | Fix |
|---|---|
| `validateX(): void` / `isValid(): boolean` then raw value used | Return the parsed type or `Result` |
| Validation scattered across service methods (shotgun parsing) | Move to the edge, one parse step |
| Throw on first error | Collect in a Notification |
| Denylist, blacklist-of-characters sanitizing | Allowlist + context-appropriate output encoding |
| Regex on unbounded input | Length cap, anchored, safe engine/timeout |
| Client-only validation | Server re-validates |
| Config/DB/queue input trusted "because internal" | Validate at the trust boundary |
| Validation errors with stack traces | Stable codes + field paths via `error-handling-problem-details` |

## Quick Decision Checklist

- [ ] Limits (bytes, depth, length, items) enforced before parsing?
- [ ] Decoded exactly once, validated in its final representation?
- [ ] Allowlist per field; unknown fields rejected or explicitly dropped?
- [ ] Both syntactic and semantic (cross-field) checks?
- [ ] Errors collected, response returned once, no partial processing?
- [ ] Output is a typed object; domain code does no raw-string checks?
- [ ] Regex anchored, length-bounded, timeout/non-backtracking?
- [ ] Uploads: filename and content-type untrusted, content checked?
- [ ] Absolute URLs built from config, not the `Host` header?
- [ ] Server-side validation exists even when the client validates?

## Deep references

- [Parse, Don't Validate at the Edge](references/parse-dont-validate-at-the-edge.md) — when deciding where checks live, shotgun parsing, total functions, push-proof-upward rules
- [OWASP Input Validation Rules](references/owasp-input-validation-rules.md) — when writing or reviewing concrete validation rules, regex, uploads, headers, Unicode
- [Notification Pattern and Error Collection](references/notification-pattern-error-collection.md) — when returning multiple errors or refactoring throw-on-first validation
