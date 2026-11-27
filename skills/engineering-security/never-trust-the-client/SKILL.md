---
name: never-trust-the-client
description: "Move decisions that must be trusted from the browser or app to the server, and keep secrets out of what ships to the client: prices, discounts, permissions, admin roles and plan limits recomputed server-side, client-exposed variables classified public or secret, published secrets listed for rotation. Report first, then one fix at a time with the owner's OK. Use when a price, role, limit or other rule is computed or enforced only in the front end, or a secret may sit in a client bundle. Not for a read-only sweep of a whole codebase (use security-audit), table and policy exposure (use database-exposure), or login, session and per-object permission design (use authn-authz-guard)."
---

# Never trust the client

"Client" means the browser, the app, everything that runs on the user's side. The user controls it: opens DevTools, changes a price from 79 to 1, calls the API directly. Client-side checks are for experience; **the server decides** (OWASP Top 10 A01 says access checks belong in trusted server-side code because client checks and metadata can be altered). Run the application as if the front end did not exist. Finding these flaws across a codebase is `security-audit`; this skill is the remediation. Safety rules: `fundamentals-audit`.

## 1. Steps (report first, then fix)

1. **Business rules in the client.** List every price, discount, shipping, permission, admin role, plan limit or validation that exists only on the client. Move each to the server (API route, server action, edge function), which recomputes everything and ignores values the client sends. Done when no decision depends on a client-supplied value.
2. **Secrets.** Search client code and every variable that reaches the browser. A framework prefix makes a variable public even if nothing was hardcoded: `NEXT_PUBLIC_` values are inlined into the shipped JavaScript at build time, `VITE_` values are exposed to client code, and `EXPO_PUBLIC_` values are visible in the compiled app; each framework's docs say not to put secrets there. Classify each variable:
   - **public by design:** a database publishable (legacy `anon`) key or a payment publishable key, safe only because server-side rules limit what they can do;
   - **secret:** `service_role` or secret keys (these bypass row-level security), payment gateway tokens, LLM provider keys.
   Every secret leaves the client and moves to the server. List which ones must be **rotated** because they already shipped. Classification procedure for a new variable: `twelve-factor-cloud-native`.
3. **Access policies** (a database exposed through an API): find the loose ones with `database-exposure`. The fix is minimal policies where each user reaches only their own rows, and sensitive fields (payment status, role, balance) change only through the server.
4. **Ownership.** A listing such as "my orders" filters by the authenticated user in the query itself, so a missing authentication check fails with an error and never leaks other people's rows. Per-object checks, IDOR and deny-by-default: `authn-authz-guard`.
5. **Input is hostile.** Validate and limit what the client sends at the server edge (`validator-input-parser`); escape output where it becomes HTML; never render raw user HTML.
6. **Report:** finding, risk (high, medium, low), file and line, proposed fix.

## 2. Rules

- First pass is the report alone: nothing is altered.
- Then apply fixes **one at a time**, policies in their own migration, and wait for approval on each. Read the report before approving; do not say yes to everything.
- Never switch off an existing protection to "make it work".
- No prompt fixes everything: the owner knows the intended behavior, the agent does not.
- Policy tests only count against a real non-production database; see `integration-tests`.

## Quick Decision Checklist

- [ ] Did I do the report pass first, with nothing altered?
- [ ] Are prices, discounts, permissions and limits recomputed on the server, ignoring client-sent values?
- [ ] Is every browser-exposed variable classified public by design or secret, and the published secrets marked for rotation?
- [ ] Does every listing filter by the authenticated user in the query?
- [ ] Do access policies give each user only their own rows, in a separate migration?
- [ ] Am I applying fixes one at a time with approval, never switching off an existing protection?
- [ ] Do policy tests run against a real non-production database?

## Deep references

- [Sources](references/sources.md): checked pages, statuses, reading limits and claims not adopted
- [Server-side checks and key classification](references/server-side-checks-and-key-classification.md): framing, verified key facts and own examples (price recompute, rotation)
- [Trigger evals](references/trigger-evals.md): three should-trigger and three near-miss prompts
