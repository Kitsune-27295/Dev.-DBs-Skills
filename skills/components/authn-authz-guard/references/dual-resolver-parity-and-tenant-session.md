# Dual-Resolver Parity and Tenant Session Hygiene

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html · https://www.postgresql.org/docs/current/ddl-rowsecurity.html · https://www.postgresql.org/docs/current/sql-set.html · https://www.postgresql.org/docs/current/functions-admin.html · https://www.postgresql.org/docs/current/sql-discard.html · https://learn.microsoft.com/en-us/sql/relational-databases/security/row-level-security · https://learn.microsoft.com/en-us/sql/t-sql/functions/session-context-transact-sql · https://docs.sqlalchemy.org/en/20/core/pooling.html · Last verified 2026-11-27

Method abstracted from two internal procedures (an access-control change checklist and a database-session checklist); no internal names are reused. The pool and RLS claims below were checked against the vendor pages above; the decision-order list is a design pattern, not a standard.

## Part 1. Dual-resolver parity

### The problem
Some systems decide "may this subject do this action?" in two places: a web edge (for example a backend-for-frontend) and a backend service, often in two languages. If the two copies drift, one side admits what the other denies, and the weaker side becomes the real policy. OWASP asks for permission validation on every request with a global, application-wide mechanism rather than per-handler checks; two resolvers are acceptable only if they are provably one policy.

### Four anchors that keep two copies one policy
1. **One catalog.** A single data file maps each route (method plus path) to a (module, action) pair. Both resolvers read it; neither hard-codes a route. A route absent from the catalog answers "not found", so a new route that "does not exist" is the signal that the catalog entry was forgotten.
2. **A fixed decision order, written down once.** Both sides evaluate the same ordered steps and stop at the first verdict. A typical order (a pattern, adapt it to your product):

| Step | Question | Verdict if it fails |
|---|---|---|
| 1 | Is the module in the catalog? | not found (hides existence) |
| 2 | Global kill-switch on? | not found |
| 3 | Is the tenant entitled to the module? (an exception row may only remove access, never grant it) | forbidden |
| 4 | Is the account active? | deny, before any bypass |
| 5 | Is the caller the operator tenant (the only bypass, confirmed in the database and logged)? | allow |
| 6 | Is the tenant suspended and the action a write? | deny, after the bypass decision |
| 7 | Resolve effective roles, including time-boxed elevations | no role: deny |
| 8 | Any role grants the action? | allow; otherwise deny (fail closed) |

Order is semantics: moving "account active" after the bypass, or adding an early "is operator" shortcut, silently grants access to deactivated accounts. The order in which data is read need not equal the order of decisions, but a test that fakes the data layer by call order must follow the reads.
3. **A pure function mirrored in both languages, proven by a shared case file.** Any step that is pure logic (the entitlement check is the classic one) is written twice and fed the same JSON file of cases (inputs and expected verdicts) from both test suites. A case added to the file fails whichever side disagrees. Mirror only pure functions; anything that reads state stays behind a data port.
4. **Database row-level security as the floor.** If both resolvers are wrong or bypassed, the database still refuses cross-tenant rows (Part 2). Parity tests prove the application layer; RLS limits the damage of a gap.

### 404 versus 403
Use "not found" for an unknown or switched-off module (it hides that the module exists) and "forbidden" for a known module the caller lacks. Never simplify one into the other, and keep both sides identical; a divergence leaks existence on one path. This is a design choice consistent with OWASP's advice to fail safely and uniformly, not a normative rule.

### Change procedure
1. Catalog first. 2. Edit both resolvers in the same change; a diff touching one resolver is a divergence. 3. Keep permissions out of the token (identity and tenant only), so a revocation takes effect on the next request. 4. For time-boxed elevations test the exact expiry boundary and the timezone. 5. If the change is tenancy-shaped, add or extend the RLS policy. 6. Record every bypass in an application log (not in an append-only business audit table, which serves a different reader).

### Proof
The negative test is the one that counts: a caller without the role gets the right status, and a caller of tenant B cannot read tenant A's row. Add a source-order test that pins the denials in sequence, and a "every declared permission is enforced" test that fails when the catalog and the guard disagree.

```ts
// shared cases, executed by both test suites
for (const c of cases) {          // {tenant, module, plan, override, expected}
  expect(isEntitled(c.tenant, c.module, c.plan, c.override)).toBe(c.expected)
}
```

## Part 2. Tenant session and RLS

### How the database enforces it
PostgreSQL row security: a table with row security enabled and no policy is default-deny; policies attach per command and role; superusers and roles with the BYPASSRLS attribute always bypass it, and table owners bypass it unless the table uses FORCE ROW LEVEL SECURITY. Referential-integrity checks and TRUNCATE are not subject to it. SQL Server row-level security works through a security policy applying filter predicates (hide rows) and block predicates (reject writes), and the policy applies to dbo, db_owner and table owners too; an application that connects as one database user can set the tenant in SESSION_CONTEXT and let the predicate read it; the page notes the `read_only` flag keeps the value fixed until the connection returns to the pool. In both cases the policy is only as good as the per-connection context it reads.

### The leak: context outlives the request
Session state (a session variable, SQL Server SESSION_CONTEXT) belongs to the database session, and connections are pooled. If the context is not removed before the connection returns to the pool, the next borrower inherits the previous tenant and reads their rows.
- Wrap every tenant query in one context manager that sets the context, commits or rolls back, and clears the context in `finally`.
- Scope the value to the transaction when the engine allows: in PostgreSQL, `SET LOCAL` (or `set_config(..., true)`) lasts only until the end of the current transaction, so a commit or rollback ends it; plain `SET` persists for the session. `DISCARD ALL` (resets all session state; cannot run inside a transaction block) or `RESET` can clear session state when a pool hands a connection back.
- A pool's reset-on-return step (SQLAlchemy rolls back the DBAPI connection on return) removes transactional state, locks and uncommitted data, and the docs say session-level state such as temporary tables and prepared statements may persist; a custom session variable is not mentioned, so do not rely on the default reset for tenant context (inference; verify with your driver, or run a backend-specific reset from the pool reset event).
- Never open a raw session for tenant data, hold one across an await point or thread, or cache a connection outside the manager.
- A background job has no request tenant: set the context explicitly per tenant and clear it between tenants.

### Two accounts, no shortcuts
| Account | Subject to RLS | Allowed use |
|---|---|---|
| runtime account | yes | everything at runtime |
| exempt account | no (or only on a few tables) | lookups that occur before a tenant exists (resolving an API key or login to a tenant), global catalogs without a tenant column, schema reflection |

- Use the exempt account in one named module only; any use elsewhere is suspect by construction.
- Never switch account to make a query pass: if a read fails under the runtime account, the tenant context is wrong. Fix the context.
- Global-catalog reads through the exempt account must not touch tenant-scoped tables.
- The exempt account can also be an application-level pattern with a bypass role; either way keep its use rare and logged.

### Limits
A leaked context cannot be detected at runtime by the application; only review and RLS tests catch it. Write a test that borrows a connection after a tenant request and asserts the context is empty.

## How an agent should apply this
- When an access rule lives in two languages, require one catalog, one written decision order, one pure function per mirrored step and one shared case file; reject a change that edits a single side.
- Review the decision order itself: bypasses and suspensions must sit where the written order puts them.
- Check that RLS exists as the floor and that the tenant context is set per transaction and cleared on return to the pool.
- Reject any query that "fixes" a denied read by changing account or role.
- Ask for the negative tests (other role, other tenant, expired elevation, borrowed-connection context) before approving.
