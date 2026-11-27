# Locators, Assertions and Auto-Waiting

Sources: https://playwright.dev/docs/locators · https://playwright.dev/docs/best-practices · https://playwright.dev/docs/test-assertions · https://playwright.dev/docs/actionability · https://playwright.dev/docs/api/class-page · https://playwright.dev/docs/api/class-testconfig · Last verified 2026-11-27

Doc version reflected: Playwright docs "stable", latest release listed as 1.65 (release-notes page, undated). `page.waitForTimeout` is marked "Added before v1.9" and Discouraged (re-read 2026-11-27).

## Locator priority

Mechanics behind rule LOC (the rule itself lives in the registry). The locators guide lists these built-ins, in this order: `getByRole` (accessible role plus name), `getByText`, `getByLabel`, `getByPlaceholder`, `getByAltText`, `getByTitle`, `getByTestId` (default attribute `data-testid`, configurable with `use: { testIdAttribute: 'data-pw' }`). Best practices says to prefer user-facing attributes over CSS/XPath, and codegen itself favors role, text and test-id. CSS and XPath still work through `page.locator()` but long `nth-child` or indexed XPath chains are called bad practice. Test-id is the fallback when no accessible handle exists.

## Strictness

Locators are strict: an action on a locator matching more than one element throws. Counting and list assertions work with several matches. `first()`, `last()`, `nth()` bypass strictness but the guide discourages them because the page can change underneath. Fix ambiguity by `filter({ hasText })`, `filter({ has: locator })`, chaining from a container, or `and()` / `or()`.

```ts
const row = page.getByRole('listitem').filter({ hasText: 'Product 2' });
await row.getByRole('button', { name: 'Add to cart' }).click();
await expect(page.getByRole('status')).toHaveText(/1 item/);
```

## Web-first assertions

Auto-retrying matchers (`toBeVisible`, `toHaveText`, `toHaveCount`, ...) re-check until true or timeout and must be awaited. Non-retrying ones (`toBe`, `toEqual`, `toContain`) check once, so applying them to page state read earlier (`await locator.isVisible()`, `textContent()`) is a flakiness source. Default assertion timeout is 5000 ms; default test timeout 30 s (class-testconfig).

- `expect.poll(fn, { timeout, intervals })`: retry a value-producing function (e.g. an API call) against a normal matcher; default timeout 5 s, intervals 100, 250, 500, 1000 ms.
- `expect(async () => {...}).toPass()`: retry a block until it stops throwing; its default timeout is 0, so pass one explicitly.
- `expect.soft`: record failure, keep running; the test still fails.
- Custom message as 2nd `expect` argument shows in reports.

```ts
await expect.poll(async () => {
  const r = await request.get('/api/orders/42');
  return (await r.json()).status;
}, { timeout: 15_000 }).toBe('shipped');
```

## Auto-waiting and actionability

Before an action Playwright waits for checks and fails with `TimeoutError` if they do not pass in time. Checks by action (actionability page): click/check/tap need visible, stable, receives-events, enabled (and not inert); hover/drag need visible, stable, receives-events; fill/clear need visible, enabled, editable; selectOption visible and enabled; `focus`, `press`, `setInputFiles`, `dispatchEvent` run no checks. `force: true` skips the non-essential checks; treat it as a smell.

## Why waitForTimeout is discouraged (verified)

The API page marks `page.waitForTimeout()` "Discouraged": tests that wait for time are inherently flaky, so use it only for debugging and prefer Locator actions, web assertions or signals like network events and visibility. The healer definition in the repo also bans `networkidle`-style waits (see agents file). A fixed sleep is either too short (flaky) or too long (slow).

## How an agent should apply this

- Apply LOC, WFA and NOSLEEP (registry) with the mechanics above; if CSS/XPath or `nth` is unavoidable, say why in a comment.
- Resolve strict-mode violations by narrowing the locator (`filter`, container chain), not by adding `.first()`.
- Never write `expect(await x.isVisible()).toBe(true)`: it is a one-shot check on state read earlier.
- Use `expect.poll` or `toPass` for async non-DOM conditions, with explicit timeouts.
- A weakened assertion or a larger timeout is never a repair (INTEG).
