# OWASP Leak-Safe Error Handling

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html · https://www.rfc-editor.org/rfc/rfc9457.html · Last verified 2026-11-27

## Why it matters (cheat sheet)

Error handling is part of application security. Attackers begin with reconnaissance for server, framework and library names/versions; unhandled errors hand that over. The sheet's examples: a Java error page with a full stack trace plus framework/server versions; a database warning exposing the install path and the failing query.

## The objective

- Configure a **global error handler** in runtime configuration (or in code where more efficient).
- Unexpected error -> **generic** response to the client, **details logged server-side**.
- Cover failure modes thoroughly; use 5xx only for requests the application cannot fulfill; never put implementation details in responses.
- Use the problem-details format (RFC 7807 cited in the body, RFC 9457 in references). The sheet assumes an API-only backend; logging itself is in a separate Logging Cheat Sheet.

## Per-stack patterns the sheet shows

| Stack | Mechanism |
|---|---|
| Java servlet | Global `<error-page>` for `java.lang.Exception` routed to an error page that logs, sets status 500 and an `X-ERROR` header, outputs generic JSON |
| Spring MVC / Boot | `@RestControllerAdvice` class with an `@ExceptionHandler(Exception)` returning a `ProblemDetail` (status 500, generic detail); Spring 6 supports RFC 7807-based problem details |
| ASP.NET Core | anonymous error controller accepting all verbs, reading `IExceptionHandlerFeature`, logging, returning generic JSON 500; developer exception page only in Development, otherwise `UseExceptionHandler` and generic `UseStatusCodePages` |
| ASP.NET Web API (.NET Framework) | `ExceptionLogger` + `ExceptionHandler` returning generic JSON 500, registered through `config.Services.Replace`; `customErrors` set to `RemoteOnly` with a default redirect |

Status rules (appendix): 4xx for client-caused errors (unauthorized access, oversized body, misbehaving client); 5xx for unforeseen server bugs; monitor 5xx rates because they often signal the application failing on certain inputs; status definitions in RFC 9110 section 15.

Not on the page (re-checked 2026-11-27): user enumeration, a dedicated "what not to leak" list or testing section (testing is referenced to the OWASP WSTG improper-error-handling guide). The checklist below is **own synthesis** from the page's context plus RFC 9457's security notes.

## Leak checklist (own synthesis)

Never return in a body or header: stack traces; exception class names or messages from libraries; SQL or ORM errors; file-system paths; internal hostnames/IPs; framework or server versions (also `Server`/`X-Powered-By` headers); raw upstream error bodies; other users' identifiers; secrets or tokens; validation messages that echo unsanitized input back into HTML (output-encode).

Always provide: a stable generic title, a correlation id (in `instance` or a response header), and a way for support to find the matching log line.

## Pattern: single global handler

```ts
app.use((err, req, res, _next) => {
  const id = crypto.randomUUID();
  logger.error({ id, err, path: req.path, user: req.user?.id });   // full detail, server side only
  res.status(500).type("application/problem+json").json({
    type: "about:blank", title: "Internal Server Error", status: 500, instance: `urn:uuid:${id}`
  });
});
```

Rules: handler is last in the chain (`middleware-interceptor-chain`); it must itself be exception-safe; it redacts sensitive fields before logging (`security-audit` for secret scrubbing); typed domain errors are mapped before reaching it, so only the unexpected arrives.

## Testing (own synthesis)

- Contract test: cause a thrown exception in a test route; assert generic body, status 500, no stack/path/version strings, correlation id present, log line exists.
- Send malformed JSON, oversized bodies, unsupported media type, invalid path parameters; assert 4xx problem details, not framework default pages.
- Scan responses for patterns (`at com.`, `Traceback`, `/var/`, `C:\`, `SELECT `).
- Confirm development error pages are disabled in the production profile.
- Alert on 5xx rate.

## Anti-patterns

- Returning `exception.getMessage()` to the client.
- Per-controller try/catch that logs and returns different shapes.
- 200 OK with an error payload.
- Verbose errors toggled by a header or query parameter the client controls.
- Different error text for "user not found" vs "wrong password" (enumeration).
- Logging full request bodies containing secrets.

## How an agent should apply this

- Verify a global handler exists, is last, and returns problem-details with a generic body.
- Grep handlers and filters for places that serialize exceptions into responses; remove them.
- Check production profile disables debug/developer error pages.
- Add a leak-pattern test and a 5xx-rate alert.
- Hand authentication-enumeration questions to `authn-authz-guard`, deeper audit to `security-audit`.
