# Supabase access layers: grants, RLS and the default-grant change

Sources: Supabase changelog https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically; Supabase RLS guide https://supabase.com/docs/guides/database/postgres/row-level-security; Wiz https://www.wiz.io/blog/exposed-moltbook-database-reveals-millions-of-api-keys; Firebase https://firebase.google.com/docs/firestore/security/insecure-rules · Last verified 2026-11-27

## Two separate layers

Grants decide whether a role (for example `anon` or `authenticated`) may touch a table at all; row-level security (RLS) policies decide which rows. A missing grant fails with error 42501 before any policy runs. How RLS behaves and what an auditor confirms in it is owned by `security-audit` (its tenant-isolation reference); this file keeps what is specific to exposure: the grant side and the default change.

## The change (changelog, re-read 2026-11-27)

| Date (2026) | What happens |
|---|---|
| 28 April | Opt-out available: a new project can be created with new `public` tables not exposed to the Data API or GraphQL |
| 18 May | `pg_graphql` stops being enabled by default |
| 30 May | Not exposed by default for all new projects, rolled out gradually over a few weeks |
| 30 October | Applies to all existing projects |

Not affected: existing tables (they keep their grants), direct connections with a connection string, and the `auth`, `storage`, `realtime` and custom schemas. The page says the Security Advisor flags affected tables before 30 October. An existing project can opt in earlier with `alter default privileges ... revoke`, which changes only future objects. Because today is after 30 October, new tables in any project need an explicit grant; old tables are the ones to audit.

```sql
-- table meant to be read and written by signed-in users, rows limited by policy
grant select, insert, update, delete on public.notes to authenticated;
alter table public.notes enable row level security;
create policy notes_owner on public.notes to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
-- no grant to anon unless the table is meant to be public
```
(Own sketch; the changelog says to keep grants and policies in the same migration.)

## What the RLS guide adds for the review

- A table in an exposed schema without RLS is readable and writable by any role with a grant on it. With RLS on and no policy, the API returns nothing.
- Policies do not remove grants. On projects that granted the API roles everything by default, revoke and grant back only what each role needs.
- Always name the role with `to`: a policy without it applies to `public`, which includes `anon`. A policy `to anon using (true)` exposes every row to unauthenticated visitors.
- Anonymous sign-ins run as `authenticated`; do not treat that role as "known users".
- The secret (service) key bypasses RLS when the request carries no user token, and must never reach the browser or customers.

## Why "the key is public" is not the problem

Wiz explains that Supabase client keys are designed to be public, but only safe when RLS policies exist. In Moltbook's case the key sat in client JavaScript and there were no policies, so it gave unauthenticated read and write. The separate rule: the service key and the database password never go to the browser.

## Firebase

Firebase's page marks `allow read, write: if true` (under a match on every document) as not recommended: anyone who guesses the project ID could read, change or delete data. It suggests ownership checks on `request.auth.uid`, closed rules (`if false`) for server-only backends, and testing with the emulator or Rules Playground. Server client libraries bypass rules, so their access is governed by IAM. The page does not discuss time-limited test-mode rules, so this pack makes no claim about them.

## How an agent should apply this

- For each public-schema table, report grants and RLS status in plain words (who can read, insert, update, delete).
- Treat a table with RLS off and a grant to `anon` or `authenticated` as high risk.
- When adding tables, add the grant and the policy in the same migration and test them against a non-production database.
- Never switch off an existing protection to make something work; fix one item at a time with the owner's OK.
- Confirm the state of the owner's project at the changelog's dates rather than assuming the new default applies.
