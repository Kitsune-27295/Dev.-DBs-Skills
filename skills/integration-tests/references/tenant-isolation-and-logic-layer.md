# The tenant-isolation negative test and logic in the right layer

Sources: https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization · https://www.postgresql.org/docs/current/ddl-rowsecurity.html · https://martinfowler.com/bliki/PresentationDomainDataLayering.html · Last verified 2026-11-24 · Two lessons taken from an internal project skill (method only)

## The negative cross-tenant test

A positive test shows that user A can read A's data. It cannot show that B cannot. Write the negative one for every route that takes an identifier or reads tenant data: authenticate as tenant B, request tenant A's object, and assert that the answer is "not found" or "forbidden" and that no data comes back.

OWASP calls the underlying flaw broken object level authorization: the API accepts an object id from the client without checking that the caller may act on that object. Its testing advice is to write tests of the authorization mechanism and not deploy changes that fail them; it also says random ids supplement but do not replace checks.

```ts
it('when tenant B asks for tenant A order, returns not found and no data', async () => {
  const order = await createOrder(tenantA)
  const res = await get(`/orders/${order.id}`, asTenant(tenantB))
  expect(res.status).toBe(404)
  expect(res.body).not.toHaveProperty('total')
})
```

Also test writes: B updating or deleting A's row must change nothing (count the rows after). If the database enforces row-level security, run the test through the same role the application uses: the PostgreSQL documentation says table owners and `BYPASSRLS` roles skip policies, so a test run as the owner passes for the wrong reason. Policy design stays in `database-exposure`; the real, non-production test database rule stays in `SKILL.md`.

## If you need the database to test arithmetic, the logic is in the wrong layer

Totals, discounts, tax, state transitions and similar rules are pure computations. If the only way to test one is to start a database, the rule is entangled with data access. Move it into a function that takes values and returns values, and test it directly, fast and with many cases. Fowler's layering note makes the same point: keep domain logic apart from data access so it can be tested without the database, using doubles for the data layer where needed. Then keep few integration tests for the wiring and the policies, which only a real database can prove (`testing-pyramid-and-shapes`).

## How an agent should apply this

- For each route with an id parameter, add a test where another tenant requests it, for reads and for writes.
- Run authorization tests under the application's own database role, not the owner.
- When a test needs a database only to check a calculation, propose extracting the calculation and write the unit test; ask before moving code.
- Keep the golden rule: never delete or loosen a test to make it pass.
