# Tenant Isolation and RLS Checks

Sources: https://www.postgresql.org/docs/current/ddl-rowsecurity.html · https://supabase.com/docs/guides/database/postgres/row-level-security · https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html · Last verified 2026-11-27 (PostgreSQL page showed version 19 documentation)

This file covers class 1 of `security-audit` at the policy level: how row-level security (RLS) behaves, and what an auditor should confirm. Deployment exposure (ports, grants, roles, who can reach the API) belongs to `database-exposure`; the rule "enforce on the server" belongs to `never-trust-the-client`.

## Mechanics worth knowing (PostgreSQL docs)

- RLS is switched on per table, separately from ordinary `GRANT`s. Only the table owner turns it on or manages its policies.
- With RLS on and **no** policy, the default is deny: ordinary roles see and change no rows.
- Setting `row_security` to `off` does not bypass policies: it raises an error if a policy would filter any row, so omitted rows cannot go unnoticed.
- `USING` filters rows that already exist (select, update, delete). `WITH CHECK` validates rows being written (insert, update). If `WITH CHECK` is omitted, `USING` is reused for it.
- Several permissive policies combine with OR; restrictive ones combine with AND.
- Superusers and roles with `BYPASSRLS` skip RLS. The table owner skips it too unless `FORCE ROW LEVEL SECURITY` is set.
- Unique, primary-key and foreign-key checks bypass RLS, and `TRUNCATE` and `REFERENCES` are not governed by it.
- Policies that consult other tables can leak data under READ COMMITTED; the docs suggest `SELECT ... FOR SHARE`, security-definer functions or locking the referenced table.

## Mechanics worth knowing (Supabase docs)

- RLS must be enabled on each table in an exposed schema. New `public` tables on existing projects grant every privilege to the `anon`, `authenticated` and `service_role` API roles; adding policies does not remove those grants, so revoke and re-grant only what each role needs.
- RLS on with no policies: nothing is returned through the client key until policies exist.
- Grants are checked before policies; a missing grant fails with error `42501`.
- The privileged "secret" key bypasses RLS when the request carries no user token; keep it out of the browser.
- Views bypass RLS by default; on Postgres 15+ set `security_invoker = true` so the view follows the underlying tables' policies, on older versions revoke access from the API roles or keep the view in an unexposed schema.
- A `using` clause that filters rows out returns zero rows without an error; a missing grant or a `with check` violation raises `42501`.

## Audit procedure

1. Enumerate tables in every exposed schema (migrations, schema dump, or `pg_tables`/`pg_class` output if you are given read access).
2. For each: is RLS enabled; is it forced where the app connects as owner; which policies exist per command?
3. Read each policy expression. Typical defects: `USING (true)`, a policy for select only (writes unguarded), missing `WITH CHECK` on insert, tenant column compared to a client-supplied value, policy on the parent but none on a child table, a view over a protected table.
4. Check that the isolation key (user id or org id) is set on write from the session, never copied from the request body.
5. For apps not using RLS: confirm every listing, search, aggregate and export applies the tenant filter, ideally in one shared scope rather than per handler.

## Example: a hole that looks like a lock

```sql
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY notes_read ON notes FOR SELECT USING (true);   -- everyone reads everything
-- no INSERT/UPDATE policy: writes denied for ordinary roles, but reads are open
```
Correct shape: `FOR SELECT USING (owner_id = auth_user_id())` with matching write policies (names of the helper vary by platform; this is an illustration).

## False positives and caveats

- Public lookup tables with an intentional open read policy.
- A back-end that connects with a privileged role and filters in code: not an RLS finding, but then the code-level filter must be exhaustive (class 3 walk).
- The presenter's claim that this protection "comes off by default" is a simplification; the official docs say it must be enabled per table, and that enabled-without-policies denies. Report the actual state found, not the slogan.

## How an agent should apply this

- Report RLS state as a per-table matrix (enabled, forced, policies per command, verdict).
- Flag any `true` expression, missing `WITH CHECK`, and views over protected tables.
- Verify against the migrations that actually deploy, not a draft file.
- Never run the SQL against a live database; read-only inspection or reading migration files only.
- If the database is directly reachable from the browser, also load `database-exposure` for grants and key handling.
