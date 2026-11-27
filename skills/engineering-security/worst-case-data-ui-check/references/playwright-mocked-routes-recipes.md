# Playwright Mocked Routes Recipes

Sources: https://playwright.dev/docs/mock, https://playwright.dev/docs/network, https://playwright.dev/docs/emulation · Last verified 2026-11-24

How to feed a screen worst-case data without touching its markup or its backend. Playwright's mocking page says requests a page makes, including XHR and fetch, can be tracked, modified and mocked, over HTTP and HTTPS. Code below is the author's own illustration built from the calls shown on those pages; adapt the URL pattern to the product's API.

## The calls this skill relies on

| Need | Call | Basis |
|---|---|---|
| Replace an API response | `page.route(pattern, route => route.fulfill({ json }))` | mock page: the real API is never called |
| Patch a real response | `const response = await route.fetch(); await route.fulfill({ response, json })` | mock page: "modify API responses" |
| Fail a request | `route.abort()` | network page: abort requests |
| Let other requests through | `route.continue()` | network page |
| Replay recorded traffic | `page.routeFromHAR(path, { url, update: false })` | mock page: HAR files; replay matches URL and method strictly |
| Register before use | call `page.route` before `page.goto` | mock page example |
| Viewport and device | `page.setViewportSize(...)`, device registry | emulation page |
| Locale, time zone, color scheme | `locale` and `timezoneId` options, `colorScheme` option, `page.emulateMedia()` | emulation page |

## Recipe 1: one fixture per case

```ts
import { test, expect } from '@playwright/test';
import worst from './fixtures/list-worst-case.json';   // typed with the API's own type

test('list with worst-case rows', async ({ page }) => {
  await page.route('**/api/items*', route => route.fulfill({ json: worst }));
  await page.goto('/items');
  await page.screenshot({ path: 'out/list-worst.png', fullPage: true });
});
```

## Recipe 2: empty, one, many

```ts
for (const [name, items] of [['empty', []], ['one', [row(1)]], ['many', Array.from({ length: 1500 }, (_, i) => row(i))]] as const) {
  test(`list: ${name}`, async ({ page }) => {
    await page.route('**/api/items*', route => route.fulfill({ json: { items } }));
    await page.goto('/items');
    await page.screenshot({ path: `out/list-${name}.png` });
  });
}
```

## Recipe 3: slow, failed and partial responses (own)

```ts
// slow: delay, then answer
await page.route('**/api/items*', async route => {
  await new Promise(r => setTimeout(r, 5000));
  await route.fulfill({ json: { items: [] } });
});

// failed network
await page.route('**/api/items*', route => route.abort());

// server error with a long problem-details message (shape owned by error-handling-problem-details)
await page.route('**/api/items*', route => route.fulfill({
  status: 503,
  contentType: 'application/problem+json',
  body: JSON.stringify({ type: 'about:blank', title: 'Service unavailable', status: 503, detail: 'x'.repeat(600) }),
}));

// partial data: valid response with optional properties removed
await page.route('**/api/items*', async route => {
  const response = await route.fetch();
  const json = await response.json();
  json.items.forEach((it: any) => { delete it.email; it.score = null; });
  await route.fulfill({ response, json });
});
```

Check for each: a visible loading state, a readable error that does not leak the raw body, no stuck spinner after the failure, and no crash on absent properties.

## Recipe 4: environment variations

```ts
await page.setViewportSize({ width: 320, height: 640 });
await page.emulateMedia({ colorScheme: 'dark' });
await page.evaluate(() => { document.documentElement.dir = 'rtl'; });        // right-to-left pass
```

For a locale pass, set the `locale` option for the context (emulation page), and mock the translation resources the product loads, if any, with the longest strings.

## Recipe 5: assertions that find breaks (own)

```ts
// 1. no horizontal page scroll
const pageScrolls = await page.evaluate(() =>
  document.documentElement.scrollWidth > document.documentElement.clientWidth);
expect(pageScrolls, 'horizontal page scroll').toBe(false);

// 2. elements wider than their own box where overflow is not meant to scroll
const overflowing = await page.evaluate(() =>
  [...document.querySelectorAll<HTMLElement>('body *')]
    .filter(el => el.scrollWidth > el.clientWidth + 1 && getComputedStyle(el).overflowX === 'visible')
    .slice(0, 20)
    .map(el => el.tagName.toLowerCase() + (el.className ? '.' + String(el.className).split(' ')[0] : '')));
console.log('overflowing elements:', overflowing);

// 3. text that lost its height
const collapsed = await page.evaluate(() =>
  [...document.querySelectorAll<HTMLElement>('p, h1, h2, h3, li, td, button, a')]
    .filter(el => el.textContent?.trim() && el.getBoundingClientRect().height < 4).length);
expect(collapsed).toBe(0);
```

Treat the output as leads, not verdicts: some overflow is intended (scroll containers, visually hidden text). The screenshot and a look at the element decide.

## Where the files live

Specs, fixtures and screenshots are throwaway evidence. Keep them in a folder outside the product repository, or inside one the owner designated as disposable, and do not commit them unless asked. If the owner wants them kept as regression tests, hand the fixtures to `playwright-qa-orchestrator`, which owns committed tests.

## How an agent should apply this

- Mock at the network boundary only; never add a test switch to the product or change its markup.
- Type fixtures with the API's own types or schema so impossible data is rejected before the screen sees it.
- Register routes before navigation, and use the narrowest URL pattern that matches the API call so unrelated requests pass through.
- Run each state (empty, one, many, slow, failed, partial) as its own test with its own screenshot name; do not reuse one page across states.
- Report assertion output as leads and confirm each against a screenshot before calling it a finding.
- Say clearly when a state could not be mocked (for example server-sent events), and list it under "Not checked".
