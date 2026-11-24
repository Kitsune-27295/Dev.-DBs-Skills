---
name: error-handling-problem-details
description: "Deep dive on error handling as a contract: error taxonomy (client vs server, expected vs unexpected), the HTTP error contract with RFC 9457 Problem Details (type/status/title/detail/instance, extension members, application/problem+json, validation errors, security), Result-vs-exceptions trade-offs, Railway-Oriented Programming composition (bind, map, tee, tryCatch, plus), and OWASP leak-safe handling (global handler, generic client message, detailed server log). Complements `defensive-domain-modeling` (domain modeling) and `circuit-breaker-retry-telemetry`. Use when designing an API error format, writing a global exception handler, choosing Result vs throw, composing fallible steps, or reviewing error responses for information leakage."
---

# Error Handling: Problem Details, Result Pipelines & Leak-Safe Responses

One idea: separate **what the machine and caller need** (stable, typed, documented error contract) from **what the operator needs** (full detail in server logs) and from **what the attacker must not get** (stack traces, paths, versions); and inside the code, make expected failures **values** that flow through composition, and unexpected failures **exceptions** caught once at a global boundary. Sources and fetch status: [references/sources.md](references/sources.md).

Boundaries (do not redo here): modeling domain types and parsing input live in `defensive-domain-modeling` and `value-objects-type-invariants`; the request validation step in `validator-input-parser`; retries, breakers and telemetry in `circuit-breaker-retry-telemetry`; authentication/authorization failures in `authn-authz-guard`; chain placement of the global handler in `middleware-interceptor-chain`; threat review in `security-audit` and `never-trust-the-client`.

---

## 1. Error taxonomy (decide the class first)

| Class | Example | Caller can fix? | Representation in code | HTTP |
|---|---|---|---|---|
| Validation / malformed input | Missing field, bad format | Yes | `Result` (parse step) | 400 / 422 |
| Domain rule rejection (expected) | Insufficient funds, slot taken | Yes (different request) | `Result` with typed error | 409 / 422 / 403 |
| Not found / conflict | Unknown id, version mismatch | Sometimes | `Result` or typed absence | 404 / 409 / 412 |
| AuthN / AuthZ | Bad token, forbidden | Yes (credentials) | `Result` at the guard | 401 / 403 |
| Transient dependency failure | Timeout, 503 upstream | Retry later | Exception -> mapped, retry policy | 502 / 503 / 504 |
| Bug / invariant broken (unexpected) | Null deref, impossible state | No | Exception, caught globally | 500 |

Rule: **expected** failures are part of the function's contract (return them); **unexpected** ones are not (throw, log, return a generic 500). Do not model bugs as typed errors and do not throw for ordinary business outcomes. Client-caused errors map to 4xx; server-side defects to 5xx, and 5xx rates are worth alerting on because they often mean the application fails on certain inputs.

## 2. The HTTP error contract: RFC 9457 Problem Details

Media types: `application/problem+json` (and `application/problem+xml`). A server may use them even if the client did not list them in `Accept`.

| Member | Meaning | Rule of thumb |
|---|---|---|
| `type` | URI reference naming the **problem type** | Absolute URI you control; stable; documented; defaults to `about:blank`; clients must not auto-dereference |
| `status` | HTTP status as a number | Advisory; must equal the real response status |
| `title` | Short human summary of the **type** | Same for every occurrence (except localization) |
| `detail` | Explanation of **this occurrence**, to help the client fix it | Not for debugging; do not parse it; never internals |
| `instance` | URI reference for this occurrence | Optional; correlates with logs (e.g. a trace id URI) |
| extensions | Extra members defined by the problem type | Names: start with a letter, letters/digits/underscore, 3+ chars; clients ignore unknown ones |

Example:

```http
HTTP/1.1 422 Unprocessable Content
Content-Type: application/problem+json

{ "type": "https://api.example.com/problems/validation-failed",
  "title": "Your request parameters didn't validate.",
  "status": 422,
  "instance": "/requests/7f3c9",
  "errors": [ { "pointer": "/items/0/qty", "detail": "must be >= 1" } ] }
```

Full field semantics, extension design, multiple-problem policy, registry and examples: [references/rfc9457-problem-details.md](references/rfc9457-problem-details.md).

## 3. Security: leak-safe errors (OWASP)

Attackers start with reconnaissance; error output that names the server, framework, library versions, install paths or query structure feeds it. Policy:

1. One **global error handler** configured in the runtime/framework, not per-endpoint try/catch.
2. On an unexpected error: **generic** response to the client, **full detail in the server log** (correlate by an id placed in `instance` or a header).
3. No stack traces, SQL, file paths, versions or internal hostnames in any response body or header; development-only diagnostic pages must be disabled outside development.
4. Use 5xx only for requests the application cannot fulfill; use 4xx for client-caused errors (oversized body, unauthorized, malformed).
5. Use the problem-details format for the generic body (the cheat sheet cites RFC 7807/9457).
6. Check `detail` and extension members against the leak list; RFC 9457 security notes say to vet all details and avoid stack dumps/internals.
7. Be careful with **enumeration**: uniform responses for "user exists" vs "does not exist" on login/reset (own inference, standard practice; verify against `authn-authz-guard`).

Per-stack handler patterns (Spring `@RestControllerAdvice` + `ProblemDetail`, ASP.NET Core `UseExceptionHandler`, Web API handlers) and a leak checklist: [references/owasp-leak-safe-handling.md](references/owasp-leak-safe-handling.md).

## 4. Result vs exceptions

| Aspect | `Result`/`Either` values | Exceptions |
|---|---|---|
| Visibility in signatures | Explicit, compiler-checked | Hidden (except checked exceptions) |
| Best for | Expected, recoverable domain/validation outcomes | Bugs, infrastructure faults, unrecoverable states |
| Composition | Needs adapters (bind/map) | Free (stack unwinding) |
| Performance | Cheap | Costly on hot paths in some runtimes |
| Pitfall | Pyramid of unwrap boilerplate; error type sprawl | Swallowed or leaked exceptions; control flow via catch |

Decision: return `Result` from **use-case/domain functions whose failure is part of the business**; let infrastructure exceptions propagate to the global handler, except where a boundary adapter deliberately converts a specific exception into a typed error (`tryCatch` idea). Never mix: a function should not both return `Err` and throw for the same class of failure.

## 5. Railway-Oriented Programming composition

Model each step as a **switch**: one input, a two-case output (success or failure). Failure is sticky: once on the failure track, later steps are skipped. Core adapters (from the series): `bind` runs the next switch on success only; `map` lifts a plain function; `tee` runs side-effect-only functions and passes input through; `tryCatch` converts exceptions into failures; `doubleMap` acts on both tracks (e.g. logging); `plus`/`&&&` runs validators in parallel and **accumulates** errors. The error type must be **the same all the way along**; map errors at stage boundaries. The author cautions against taking ROP to extremes (it is a template for consistency, not a mandate for every function).

Details, TypeScript implementation sketch, accumulating validation, mapping Result to Problem Details: [references/railway-result-composition.md](references/railway-result-composition.md).

Who owns recovery, what state survives a failure (none, basic, strong, no-throw guarantees), why logging is not recovery, typed failures and honest reporting of unknown outcomes: [references/recovery-ownership-and-guarantees.md](references/recovery-ownership-and-guarantees.md).

## 6. Mapping errors to the contract (single place)

Keep a **total mapping** `DomainError -> ProblemDetails` in one module (adapter layer), so each typed error has a status, a `type` URI, a title and allowed extensions:

```ts
const toProblem = (e: AppError): Problem => {
  switch (e.kind) {
    case "validation": return { type: P("validation-failed"), title: "Validation failed", status: 422, errors: e.fields };
    case "notFound":   return { type: P("not-found"), title: "Resource not found", status: 404 };
    case "conflict":   return { type: P("conflict"), title: "State conflict", status: 409 };
    default:           return assertNever(e);  // exhaustive: new error kinds break the build
  }
};
```

Unknown/unexpected exceptions go through the global handler to `{ type: "about:blank", title: "Internal Server Error", status: 500 }` plus `instance` for log correlation.

## Quick Decision Checklist

1. Classify each failure: expected (return) or unexpected (throw to the global handler).
2. Every error response uses one machine-readable format (`application/problem+json`) with stable `type` URIs.
3. `status` equals the HTTP status; `title` is constant per type; `detail` is occurrence-specific and safe.
4. Validation failures list all field errors (accumulate) with JSON Pointers.
5. No stack traces, paths, versions or SQL leave the server; diagnostics only in logs with a correlation id.
6. 4xx vs 5xx chosen by who can fix it; 5xx monitored.
7. One total mapping from typed errors to problem details; exhaustive matching.
8. ROP pipelines share one error type; exceptions become failures only at defined boundaries.

## Deep references

- [RFC 9457 Problem Details](references/rfc9457-problem-details.md) — when designing or reviewing an API error body, problem types, extensions or multiple errors.
- [OWASP leak-safe handling](references/owasp-leak-safe-handling.md) — when writing a global handler or auditing error responses for information leakage.
- [Railway Result composition](references/railway-result-composition.md) — when composing fallible steps, accumulating validation errors, or choosing Result vs exceptions.
- [Recovery ownership and guarantees](references/recovery-ownership-and-guarantees.md) — when deciding who recovers from a failure, which state guarantee holds, or how to report unknown outcomes.
- [Sources](references/sources.md) — fetch status per URL.
