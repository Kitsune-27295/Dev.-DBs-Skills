# Five Classes: Attack and Detection Patterns

Sources: https://top10.owasp.org/2021/A01_2021-Broken_Access_Control · https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization · https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html · https://cheatsheetseries.owasp.org/cheatsheets/Insecure_Direct_Object_Reference_Prevention_Cheat_Sheet.html · Last verified 2026-11-24

`SKILL.md` names the five classes and the audit rules. This file adds, per class, how the flaw shows up in generated code, a cheap way to confirm it, and what usually turns out to be a false positive. Boundary: fixing is `never-trust-the-client`; a database reachable over an API is `database-exposure`; ordering fixes against other concerns is `fundamentals-audit`; a full supply-chain or dependency deep dive is `oss-deep-audit`.

## Why the pattern repeats

A code generator follows the request literally. "Create the route that fetches an order by id" yields exactly that route; the ownership question is never asked unless the prompt asks it. The presenter's framing is that the model takes the easiest path (a hosted backend called straight from the browser, a sequential primary key, a client-side `if`), and nothing in the output warns that a door is open. Treat this as a plausible explanation, not a measurement (see `sources.md`).

## Class 1: data layer without isolation

- **Manifestation:** the browser talks to the database through a hosted API; tables exist but nothing limits which rows a caller may read. Or a server query like `SELECT * FROM invoices` that never mentions the tenant.
- **Verify in code:** list every table, then for each find the isolation mechanism (policy, tenant scope, `WHERE owner_id = :caller`). A table with none is a finding only if it is reachable by a non-privileged caller; confirm the reachability path first (client key in the bundle, public route).
- **False positives:** reference tables (countries, plans) that are meant to be public; tables only touched by a trusted back-end job; a policy that exists but is bypassed only for the service role by design.
- Depth: [tenant-isolation-and-rls-checks.md](tenant-isolation-and-rls-checks.md).

## Class 2: authorization decided in the client

- **Manifestation:** a role or `isAdmin` flag read from `localStorage`, a cookie value, a JWT payload decoded in the browser, or a response field the client trusts; UI components or routes hidden with `if (role === 'admin')`.
- **Verify in code:** grep the front end for role checks, then for each gate open the matching endpoint and look for the same privilege check there. The gate is harmless only when the server independently denies.
- **Test idea (on a running copy you own):** change the stored role value or the intercepted response field and reload; if more UI appears and the server still answers privileged calls, it is exploitable.
- **False positives:** purely cosmetic hiding where the endpoint is properly guarded. OWASP's authorization guidance says client checks may help usability but must never decide access.

## Class 3: IDOR / BOLA

- **Manifestation:** a handler reads an id from the path, query or body and loads the record with no comparison to the caller. Sequential ids make enumeration easy; missing rate limits make it cheap to script.
- **Verify in code:** for every handler touching an id, answer three questions: where does the caller identity come from (session, not request), is the lookup scoped by it, and does it hold for update, delete, export and nested resources?
- **Example of a safe shape (own pseudo-code):**
```
order = Orders.find(id=params.id, owner=session.user_id)   # scoped lookup
if not order: return 404                                    # same answer for missing and forbidden
```
- **False positives:** public objects; admin-only routes that already enforce the role (still check the role check exists); random ids do not make a missing check safe, only harder to guess.
- OWASP files this as the top API risk (API1:2023) and describes comparing only the session user id with the id parameter as insufficient on its own for object-level rules.

## Class 4: exposed keys

- **Manifestation:** literals in source, `.env` committed, compose/CI/chart defaults, secrets in the client build (every build-time client variable is public text).
- **Verify:** search the working tree and the full history; classify each hit as real, example placeholder, or public-by-design (a publishable client key). Real ones are revoked and rotated, not just removed.
- Depth: [secrets-in-git-history-and-rotation.md](secrets-in-git-history-and-rotation.md).

## Class 5: untrusted input rendered as code

- **Manifestation:** raw HTML sinks, unsanitized markdown, user-controlled URLs, admin "custom HTML" fields, uploads accepted without type checks.
- **Verify:** trace each sink back to its source; a sink fed only by constants is not a finding.
- Depth: [xss-and-output-encoding-checks.md](xss-and-output-encoding-checks.md).

## Coverage rule

OWASP's guidance repeats that one missed path is enough for an attacker. So the audit unit is "every handler", "every table", "every sink", not a sample. Record the denominator (for example 41 handlers, 41 inspected) in the report.

## How an agent should apply this

- Build an inventory first (tables, handlers, front-end gates, sinks, secret locations) and report coverage against it.
- For each class, state the confirmed reachability path before assigning severity; no path means "informational" or "not verified".
- Prefer reading the guard code over trusting names: a function called `checkOwner` may not compare anything.
- Log correct protections as strengths with `file:line`.
- Send class-specific depth to the sibling references and sibling skills instead of re-deriving it here.
