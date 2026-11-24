---
name: never-trust-the-client
description: Use to move business rules from the browser or app to the server and to lock down what the client can see or hold, when a price, discount, permission, admin role or plan limit is computed in the front end, when secrets may ship in client bundles, or when database access policies (row-level security) look loose. Report first, then one fix at a time with the owner's OK.
---

# Never trust the client

"Client" means the browser, the app, everything that runs on the user's side. The user controls it: opens DevTools, changes a price from 79 to 1, calls the API directly. Client-side validation is for experience; **the server decides**. Run the application as if the front end did not exist. Detection of these flaws across a whole codebase is `security-audit`; this skill is the remediation. Safety rules: `fundamentals-audit`.

## Steps (report first, then fix)

1. **Business rules in the client.** List every price, discount, shipping, permission, admin role, plan limit or validation that exists only on the client. Move each to the server (API route, server action, edge function), which recomputes everything and ignores values sent by the client. Done when no decision depends on a client-supplied value.
2. **Secrets.** Search client code and every variable that reaches the browser (`NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_` or the framework's equivalent: a prefixed variable is public even if nothing was hardcoded). Classify each one:
   - **public by design:** a database publishable or anon key, a payment publishable key;
   - **secret:** `service_role` or secret keys, payment gateway tokens, LLM provider keys (OpenAI, Anthropic and similar, which bots reportedly hunt because leaked paid keys can be resold).
   Every secret leaves the client and moves to the server. List which ones must be **rotated** because they were already published.
3. **Access policies** (a database exposed through an API, for example Supabase): find the loose ones with `database-exposure` (table-by-table review, permissive rules, service key). The fix is minimal policies: each user reaches only their own rows; sensitive fields (payment status, role, balance) change only through the server.
4. **Ownership on every read and by-id access.** A listing such as "my orders" filters by the authenticated user in the query itself (`WHERE owner = :user`), so a missing authentication check fails with an error and never leaks other people's rows. Every fetch, change or delete of one object by id checks that it belongs to the caller (the IDOR fix); consider rate limits against id enumeration.
5. **Input is hostile.** Validate, sanitize and limit everything the user sends; escape output where it becomes HTML; check type and content of uploads; never render raw user HTML or script.
6. **Report:** finding, risk (high, medium, low), file and line, proposed fix.

## Rules

- First pass is the report alone: nothing is altered.
- Then apply fixes **one at a time**, policies in their own migration, and wait for approval on each. Read the report before approving; do not say yes to everything.
- Never switch off an existing protection to "make it work".
- No prompt fixes everything: the owner knows the intended behavior, the agent does not.
- Policy and RLS tests only count against a real database (local or a dedicated test project), never production; see `integration-tests`.

## Deep references

- [Sources](references/sources.md) — provenance, unverified statistics and which steps are the skill author's additions
- [Server-side checks and key classification](references/server-side-checks-and-key-classification.md) — when classifying keys or deciding what moves server-side
