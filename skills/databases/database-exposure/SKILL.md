---
name: database-exposure
description: Use when the question is whether an application's database is open to the wrong people - a port reachable from the internet, service keys or connection strings in client code or git history, tables the public API can read or write, permissive policies or rules (row-level security, grants, Firebase rules). Report first, then fix one item at a time. Run before launch and after any change to access rules. Not for moving business rules to the server (use never-trust-the-client) or a general security sweep (use security-audit).
---

# Database exposure (the open door)

A leak cannot be undone, so this check comes first. The database door stays closed, the service key stays out of the browser, and every table the public API can see has an access rule you can explain in plain words. Shared database rules and the run order: `database-audit`; the generic safety rules: `fundamentals-audit`. Sources, status and limits: [references/sources.md](references/sources.md).

## 1. Steps (report first)

1. **Where does the database run, and does its port accept connections from outside?** VPS, managed Postgres, Supabase, Firebase or another. On a VPS read `listen_addresses`, `pg_hba.conf` and the firewall, and say exactly what is open. PostgreSQL listens only on the loopback address by default, so an exposure is something someone configured: a server bound to every address, a `pg_hba.conf` line that admits `0.0.0.0/0`, or a `trust` method over TCP (it lets anyone who can connect log in as any role without a password). Done when each opening is named with the file or setting that causes it.
2. **Secrets.** Search for service keys, database passwords and connection strings in client code, in public variables (`NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`) and in git history: a deleted secret is still in the history. List the ones to **rotate** because they were already published. The service key is never in the browser; classifying and moving secrets is `never-trust-the-client`.
3. **Table by table.** Every table the public API can see, and for each one, in plain words, who can read, insert, update and delete. Flag whatever opens everything: `using (true)`, `with check (true)`, Firebase `allow read, write: if true`, a table with security switched off, a role granted more than the app uses. On Supabase read the grants as well as the policies (see the Supabase reference).
4. **Report:** each finding, its risk (high, medium, low) and the proposed fix.

A part that does not apply (no database reachable through an API, no VPS) is reported as **not applicable**, never forced into findings.

## 2. Fixes

- The first pass is the report alone: nothing is changed.
- Then fix them one at a time, each as its own migration, and wait for the owner's OK on every one. Warn before anything that could take the app down.
- Never disable an existing protection to make something work.
- Policy tests count only against a real database that is not production; see `integration-tests`. How row-level security behaves and what to confirm in it: `security-audit`.

## 3. Evidence behind the lesson

UpGuard's blog (23 September 2026) reported 16,326 Supabase databases exposing readable tables, found by probing about 300,000 candidate domains for a `users` table. Supabase's changelog entry 45329 shows a staged change: new public-schema tables need an explicit grant before the Data API sees them, opt-out from 28 April 2026, default for new projects from 30 May, all existing projects from 30 October 2026. Confirm the state of your own project instead of assuming it. Incident details and caveats are in the references.

Source: the handout of the second database lesson of mano deyvin (prompt "the open door").

## Quick Decision Checklist

- [ ] Did I name every opening of the database port, with the file or setting that causes it?
- [ ] Is the service key absent from client code, public variables and git history?
- [ ] Did I list secrets already published that must be rotated?
- [ ] Can I explain in plain words who can read, insert, update and delete in each table?
- [ ] Did I flag open rules such as using (true), allow read, write: if true or security switched off?
- [ ] Is this pass report-only, with each fix a separate migration awaiting the owner's OK?
- [ ] Am I avoiding disabling any existing protection just to make something work?

## Deep references

- [Sources and caveats](references/sources.md) — when you must check which claims were verified and which are the lesson's own
- [Supabase grants and RLS](references/supabase-grants-and-rls.md) — when you review per-table access or the default-grant change
- [Exposure incidents and lessons](references/exposure-incidents-and-lessons.md) — when you need factual, caveated evidence for the exposure checks
- [Trigger evals](references/trigger-evals.md) — when you tune this skill's description
