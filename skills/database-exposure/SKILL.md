---
name: database-exposure
description: Use to find out whether an application's database is exposed and who can read or write each table - a database port open to the internet, keys, passwords or connection strings in client code or git history, tables the public API can see, permissive policies or rules (row-level security, Firebase rules, grants). Report first, then fix one item at a time. Run before launch and after any change to access rules.
---

# Database exposure (the open door)

A leak cannot be undone, so this check comes first. The database door stays closed, the service key stays out of the browser, and every table the public API can see has an access rule you can explain in plain words. Shared database rules and the run order: `database-audit`; the generic safety rules: `fundamentals-audit`.

## Steps (report first)

1. **Where does the database run, and does its port accept connections from outside?** VPS, managed Postgres, Supabase, Firebase or another. On a VPS read `listen_addresses`, `pg_hba.conf` and the firewall, and say exactly what is open (bound to every address, a rule that admits any host, a port reachable from the internet). Done when each opening is named with the file or setting that causes it.
2. **Secrets.** Search for service keys, database passwords and connection strings in client code, in public variables (`NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`) and in the git history: a deleted secret is still in the history. List the ones to **rotate** because they were already published. The service key is never in the browser.
3. **Table by table.** Every table the public API can see, and for each one, in plain words, who can read, insert, update and delete (row-level security, policies, grants, Firebase rules). Flag whatever opens everything: `using (true)`, `with check (true)`, `allow read, write: if true`, a table with security switched off, a role granted more than the app uses. On Supabase a new table must be granted explicitly to appear in the API: check that the grants match what you meant to expose.
4. **Report:** each finding, its risk (high, medium, low) and the proposed fix.

A part that does not apply (no database reachable through an API, no VPS) is reported as **not applicable**, never forced into findings.

## Fixes

- The first pass is the report alone: nothing is changed.
- Then fix them one at a time, each as its own migration, and wait for the owner's OK on every one. Warn before anything that could take the app down.
- Never disable an existing protection to make something work.
- Policy tests count only against a real database that is not production; see `integration-tests`. Moving business rules and secrets out of the client is `never-trust-the-client`.

## Evidence behind the lesson

UpGuard's blog reported 16,326 Supabase databases exposing readable tables, found by probing about 300,000 candidate domains for a `users` table. Supabase's changelog entry 45329 (28 April 2026) says new tables in the `public` schema need an explicit `grant` before the Data API sees them, rolled out by project age; confirm the state of your own project instead of assuming it.

Source: the handout of the second database lesson of mano deyvin (prompt "the open door").
