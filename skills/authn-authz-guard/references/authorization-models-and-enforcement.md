# Authorization Models and Enforcement

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html · Last verified 2026-11-23

## What it is
Authorization decides whether an identified subject may perform an action on a resource. Broken Access Control ranked first in OWASP's 2021 Top 10. Horizontal escalation (reading a peer's data) is the most common form; vertical is reaching higher-privilege functions.

## Principles
1. **Least privilege**, horizontal and vertical. Design by listing user types, resources and operations, then justify each pair. Review periodically for privilege creep; adding permissions later is easier than revoking.
2. **Deny by default.** No matching rule means deny; every grant must be justifiable. Do not trust framework defaults, configure explicitly.
3. **Check every request, globally.** Use filters/middleware (servlet filters, Django middleware, .NET authorization filters, Laravel middleware) so no endpoint depends on a developer remembering a check. A check missing from one route is the whole vulnerability.
4. **Server-side only.** Client checks are UX. Enforce in the service, gateway or serverless function.
5. **Fail safely.** Handle every failed check centrally, return a plain 403/404, no internals in messages, no state left half-modified.
6. **Log decisions** consistently and centrally; too little hides attacks, too much leaks data and creates noise. Sync clocks.
7. **Distrust third-party authz code.** Define requirements first, test the configuration, scan dependencies, keep defense in depth.

## Model choice
| Model | Decides by | Strength | Weakness |
|---|---|---|---|
| RBAC | role membership | simple to start | role explosion, weak for object-level and multi-tenant rules, role lists in headers can overflow |
| ABAC (NIST SP 800-162) | subject, object, environment attributes vs policy | fine-grained, separates policy from enforcement | attribute hygiene, policy testing |
| ReBAC | relationship between user and resource | natural for ownership/sharing | needs a relationship store |
The sheet recommends ABAC or ReBAC for most applications; RBAC remains acceptable for coarse admin/user splits. Hybrid (roles for coarse gates, attributes/relationships for object checks) is the practical default (my inference).

## IDOR (CWE-639)
Exposing internal IDs (`acct_id=123`) lets users swap values. Randomizing IDs is not a fix. Mitigate by deriving the object from the authenticated principal, using indirect references, and checking access to the specific object on every request.
```
def get_invoice(user, invoice_id):
    inv = repo.find(invoice_id)
    if inv is None or not policy.allows(user, "read", inv):  # same response for both
        raise NotFound()
    return inv
```

## Static resources
Buckets and files need policies too; classify data; reuse the same access logic where possible.

## Testing
Test default-deny, fail-safe on errors, and ABAC rules as designed; add per-role/per-tenant negative tests. Automated tests catch the cheap bugs; keep manual pen-testing for chains.

## How an agent should apply this
- Find the central enforcement point; flag handlers that bypass it.
- For each route taking an ID, demand an object-level check, not just a login check.
- Replace "if role == X" sprawl with a policy function; prefer attributes/ownership for resource decisions.
- Confirm unmatched routes/permissions deny.
- Write negative tests: other user's ID, other tenant, missing permission.
