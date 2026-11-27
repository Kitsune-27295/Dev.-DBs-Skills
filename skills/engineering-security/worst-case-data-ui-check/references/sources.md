# Sources — Worst-Case Data UI Check

Every URL below was re-fetched during the rebuild on 2026-11-27 (WebFetch). "200 OK" means the page returned its content and the relevant sections were read; long pages were read in the first 100,000 characters.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.w3.org/WAI/WCAG22/Understanding/reflow.html | 200 OK, re-read | 320 CSS px width and 256 CSS px height, 1280 px at 400% (1024 px for height), two-dimensional exceptions, cell content still applies |
| https://www.w3.org/WAI/WCAG22/Understanding/text-spacing.html | 200 OK, re-read | The four values (1.5, 2, 0.12, 0.16), Level AA, script exceptions |
| https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html | 200 OK, re-read | 200% resize, text-only resize as one mechanism, truncation allowed if full content on focus or activation, failure F69 (corrected 2026-11-27) |
| https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/CSS_layout/Responsive_Design | 200 OK, re-read | Responsive design goal, flexbox and grid, viewport meta tag |
| https://developer.mozilla.org/en-US/docs/Web/CSS/min-width | 200 OK, first 100,000 characters | `auto` is 0 for block boxes; content-based for flex and grid items, with two zero cases (added) |
| https://developer.mozilla.org/en-US/docs/Web/CSS/overflow-wrap | 200 OK, first 100,000 characters | `anywhere` counts in min-content sizing, `break-word` does not |
| https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values | 200 OK, first 100,000 characters | Flow-relative properties for right-to-left and vertical scripts |
| https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules | 200 OK, re-read | Six plural tags; English two forms, Chinese one, Arabic six |
| https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat | 200 OK, re-read | Locale-specific number and currency output |
| https://playwright.dev/docs/mock | 200 OK, re-read | `page.route`, `route.fulfill`, `route.fetch` patching, HAR replay with strict matching, register before navigating |
| https://playwright.dev/docs/network | 200 OK, re-read | `route.abort`, `route.continue`, request and response modification |
| https://playwright.dev/docs/api/class-route | 200 OK, re-read (added 2026-11-27) | `route.abort(errorCode)` optional, default `failed`; `fulfill` options `path`, `json`, `status`, `contentType` |
| https://playwright.dev/docs/emulation | 200 OK, re-read | Viewport, locale, time zone, color scheme and reduced-motion emulation |
| https://www.w3.org/International/questions/qa-html-dir | 200 OK, re-read | `dir="rtl"` on `html`, logical start and end, `dir="auto"` for run-time text |
| https://www.w3.org/International/articles/inline-bidi-markup/ | 200 OK, re-read | Wrapping opposite-direction phrases; `dir="auto"` or `bdi` for unknown-direction text |
| https://www.w3.org/International/questions/qa-personal-names | 200 OK, re-read | Names that do not split first/last, long names, no byte limits, "Full name" fields |
| Third-party skill on stress-testing a screen with worst-case data (MIT license visible) | Read for ideas, no text reused | Report-only output idea |

Dropped: https://www.w3.org/International/ (it is the Internationalization news blog, orientation only, nothing relied on) and https://developer.mozilla.org/en-US/docs/Web/Localization (404).

## Reading limits

- Long WCAG, MDN and W3C pages were read for their criterion text, intent and quick answers, not every example or technique.
- Playwright pages reflect the version live on 2026-11-27; no version is stated on them.
- Browser behavior (zoom, text-only zoom, text-spacing overrides) was not exercised; the zoom and text-only recipes are approximations and say so. The code snippets in the recipes were not run.
- No scripts or data files exist in this skill other than inline snippets, which were not re-executed.

## Claims not adopted as fact

- Fixes such as `flex-shrink: 0`, tabular figures and virtualization thresholds are common practice marked "(own)" in the references, not statements from the cited pages.
- No claim is made that passing these checks means WCAG conformance (see `a11y-audit`).
- Default fraction digits and rounding behavior of `Intl.NumberFormat` came from the fetch tool's recall of the specification, not the MDN page, and are not used.
