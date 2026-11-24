# Sources — Worst-Case Data UI Check

Every URL below was checked during skill authoring (2026-11-24).

Retrieval used `curl` with a browser-style user agent; the pages were converted to text and read. "200 OK" means the page returned its content and the relevant sections were read.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.w3.org/WAI/WCAG22/Understanding/reflow.html | 200 OK (success criterion, notes and intent read) | 320 CSS px and 256 CSS px thresholds, the 1280 px at 400% equivalence, two-dimensional exceptions, responsive rearranging is not loss of content |
| https://www.w3.org/WAI/WCAG22/Understanding/text-spacing.html | 200 OK (success criterion and intent read) | the four spacing values (1.5, 2, 0.12, 0.16), the "user override must not lose content" intent, script exceptions |
| https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html | 200 OK (success criterion and intent read) | 200% resize, text-only resizing named as a browser mechanism, truncation acceptable when full content is reachable on focus or activation |
| https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/CSS_layout/Responsive_Design | 200 OK (introduction and viewport section read) | responsive design goal, role of grid, flexbox and media queries, viewport meta |
| https://developer.mozilla.org/en-US/docs/Web/CSS/min-width | 200 OK (values section read) | `auto` resolves to min-content for flex and grid items, to 0 for block boxes |
| https://developer.mozilla.org/en-US/docs/Web/CSS/overflow-wrap | 200 OK (values read) | `anywhere` counts break opportunities in min-content sizing, `break-word` does not |
| https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values | 200 OK (introduction read) | start of a line is not always the left side; logical properties for right-to-left and vertical scripts |
| https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules | 200 OK (description read) | plural categories zero, one, two, few, many, other; English two forms, Chinese one, Arabic six |
| https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat | 200 OK (introduction and examples read) | locale-specific number and currency formatting examples |
| https://developer.mozilla.org/en-US/docs/Web/Localization | 404 (not found) | nothing; replaced by the logical-properties and Intl pages above |
| https://playwright.dev/docs/mock | 200 OK (read through WebSocket section) | `page.route`, `route.fulfill`, `route.fetch` patching, HAR replay and its strict matching |
| https://playwright.dev/docs/network | 200 OK (abort, continue, modify sections read) | `route.abort`, `route.continue`, request and response modification |
| https://playwright.dev/docs/emulation | 200 OK (devices, viewport, locale, color scheme read) | viewport, locale and time zone, color scheme and media emulation |
| https://www.w3.org/International/ | 200 OK (landing page; used for orientation only) | the W3C Internationalization Activity home; no technical claim relied on from it |
| https://www.w3.org/International/questions/qa-html-dir | 200 OK (quick answer read) | `dir="rtl"` on `html`, logical start and end properties, `dir="auto"` for run-time text |
| https://www.w3.org/International/articles/inline-bidi-markup/ | 200 OK (quick answer read) | wrapping opposite-direction phrases, `dir="auto"` and `bdi` for unknown-direction run-time text |
| https://www.w3.org/International/questions/qa-personal-names | 200 OK (introduction and form-design implications read) | names that do not split as first and last, long names, no byte limits on name fields |
| Third-party skill read for ideas, no text reused (MIT license visible) | read locally | the idea of stress-testing a screen with realistic worst-case data and a report-only output; no wording, tables or examples were copied |

## Reading limits

- The long WCAG and W3C pages were read for their criterion text, intent and quick answers, not every example and technique.
- Playwright pages were read as of the version live on 2026-11-24; the version number is not stated on those pages.
- Browser behavior (for example how zoom or text-only zoom changes layout) was not exercised in this authoring session; the zoom and text-only recipes are the author's approximations and say so.

## Claims not adopted as fact

- Fixes such as `flex-shrink: 0`, tabular figures and virtualization thresholds are common practice marked "(own)" in the references, not statements from the cited pages.
- No claim is made that passing these checks means WCAG conformance; conformance is out of scope (see `a11y-audit`).
- Playwright's `route.abort()` accepts an optional error code in its API reference; that page was not read, so the recipes use the no-argument form shown in the network guide.
