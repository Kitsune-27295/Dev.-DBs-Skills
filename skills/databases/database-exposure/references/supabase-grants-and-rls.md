# Supabase access layers: grants, RLS and the default-grant change

Sources: Supabase changelog https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically; Wiz https://www.wiz.io/blog/exposed-moltbook-database-reveals-millions-of-api-keys; video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 06 24:10-26:37 · Last verified 2026-11-24

## Two separate layers

1. **Grants** decide whether a role (for example `anon` or `authenticated`) may touch a table at all. Postgres checks this first; a missing grant returns a permission-denied error (code 42501) before any row rule applies.
2. **Row-level security (RLS) policies** decide which rows that role sees or changes.

The changelog states the two are independent and RLS is unchanged by the new behavior. Safe exposure needs both: the minimum grants, plus policies that match the intended audience.

## The change

Until now every new table in the `public` schema was reachable through the Data API (REST and GraphQL) at creation. The new model needs an explicit grant. Timeline as read: available 28 April 2026 (new projects can opt out of auto-exposure), `pg_graphql` off by default 18 May, opt-out default for new projects from 30 May (gradual), applied to all existing projects on 30 October 2026. Existing tables keep their current grants; only new tables are affected. Direct connections with a connection string are not affected. The video's summary ("old tables stay as they were: open stays open, closed stays closed") matches.

```sql
-- table meant to be read and written by signed-in users, rows limited by policy
grant select, insert, update, delete on public.notes to authenticated;
alter table public.notes enable row level security;
create policy notes_owner on public.notes
  using (user_id = auth.uid()) with check (user_id = auth.uid());
-- no grant to anon unless the table is meant to be public
```
(Policy syntax is my own sketch of common usage; check the provider docs.)

## Why "the key is public" is not the problem

Wiz explains that Supabase client keys are designed to be public, but only safe when RLS policies exist. In Moltbook's case the key sat in client JavaScript and there were no policies, so it gave full read and write. Write access was treated as a bigger risk than reads. The lesson's separate rule is different: the service-role key and database password never go to the browser.

## Review checklist

- every table the public API sees: who can select, insert, update, delete;
- policies written `using (true)` or `with check (true)` open everything;
- tables with RLS switched off;
- grants broader than the app needs (the changelog says to grant only needed privileges and to treat `anon` and `authenticated` differently);
- tables that existed before 30 October 2026 keep their old grants: audit them, do not assume the new default protects them.

## How an agent should apply this

- For each public-schema table, report grants and RLS status in plain words (who can read, insert, update, delete).
- Treat a table with RLS off and a grant to `anon` or `authenticated` as high risk.
- When adding tables, add the grant and the policy in the same migration and test them against a non-production database.
- Never switch off an existing protection to make something work; fix one item at a time with the owner's OK.
- Confirm the state of the owner's project at the changelog's dates rather than assuming the new default applies.
