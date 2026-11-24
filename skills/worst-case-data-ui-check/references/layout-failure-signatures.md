# Layout Failure Signatures

Sources: https://developer.mozilla.org/en-US/docs/Web/CSS/overflow-wrap, https://developer.mozilla.org/en-US/docs/Web/CSS/min-width, https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values, https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/CSS_layout/Responsive_Design · Last verified 2026-11-24

What a break looks like, why it happens, and the usual fix to put in the report. The checker reports; it does not apply the fix. Rows marked "(own)" are the author's synthesis from common practice rather than a statement on the cited page.

## The mechanism behind most overflow

For a block box, `min-width: auto` resolves to 0. For flex and grid items it does not: MDN states that the automatic minimum is, in most cases, the item's **min-content** size, with an exception when the item is a scroll container. A flex child that holds a long unbreakable string therefore refuses to shrink below the width of that string, and the row overflows its parent. That one rule explains the first four rows below.

`overflow-wrap` has three values on MDN: `normal` (break only at normal break points), `break-word` and `anywhere`. Both of the latter break an unbreakable run only when nothing else fits. The difference that matters here: with `anywhere` the soft wrap opportunities **are** counted when the browser computes min-content sizes, with `break-word` they are **not**. So `overflow-wrap: anywhere` can unblock a flex child; `break-word` alone often cannot, unless the child also has `min-width: 0`.

## Signatures

| What you see | Likely cause | Usual fix to suggest |
|---|---|---|
| Text overflows its card instead of wrapping or truncating, page scrolls sideways | flex or grid child with `min-width: auto` holds a long token | `min-width: 0` on the text column; in grid, `minmax(0, 1fr)` for the track (own) |
| An e-mail or URL runs past the edge | no break opportunity inside the token | `overflow-wrap: anywhere` on that element |
| Trailing action (menu button, badge) pushed off-screen | the middle column took all the space | `min-width: 0` on the middle, a fixed size that does not shrink on the action (own) |
| Avatar or icon squashed into an oval | a flex child with a fixed width is allowed to shrink | stop it shrinking (`flex-shrink: 0`) (own) |
| Ellipsis with no way to read the full value | truncation with no alternative | show the full value on focus or activation, or in a detail view; WCAG 1.4.4 notes truncation is acceptable only if the full content is available on focus or activation and the user is told so |
| "1 members", "0 member", "2 file(s)" | hard-coded plural | `Intl.PluralRules` categories or one message per plural form |
| `NaN`, `undefined`, `Invalid Date` on screen | null or missing value fed to a formatter | guard the value and show a stated fallback; decide what "not measured" looks like |
| `1284` instead of `1,284`, or wrong separators in another locale | raw number rendered | `Intl.NumberFormat` with the user's locale (own) |
| Numbers jitter, columns misalign | proportional digits | tabular figures (`font-variant-numeric: tabular-nums`) (own) |
| Layout mirrored wrongly, icons or padding on the wrong side in right-to-left | physical `left` and `right` in CSS | logical properties (`margin-inline-start`, `padding-inline-end`, `inset-inline-start`); MDN explains that the start of a line is not always the left side |
| Punctuation or numbers jump around in mixed text | run-time text of unknown direction in a fixed-direction container | `dir="auto"` or a `bdi` wrapper (W3C inline-markup article) |
| Two-dimensional scroll at 320 px | fixed widths, wide tables, min-width on containers | make the layout reflow; data tables may keep two-dimensional scroll but not each cell's text (WCAG 1.4.10) |
| 1,000 rows stutter or freeze | every row rendered | paginate or virtualize, and say which in the decisions list (own) |
| Text clipped or overlapping after text-spacing override | fixed heights and `overflow: hidden` on text containers | let height grow with content (WCAG 1.4.12 intent) |
| Content hidden behind a sticky header or footer at zoom | fixed-position bars take a large share of a small viewport | allow them to collapse or scroll (own) |

## Responsive background

MDN's responsive-design article describes the goal as pages that render well on all screen sizes while staying usable, built on flexible layout tools (grid and flexbox) plus media queries, and notes that the viewport meta tag is needed for pages to display appropriately on mobile devices. For the checker this means a screen that ignores the viewport meta or relies on fixed pixel widths is a **Fragile** finding even if it looks fine at one size.

## How to detect instead of eyeball (own)

Run the three assertions of the recipes file at each viewport: no horizontal page scroll, no element whose `scrollWidth` exceeds its `clientWidth` where overflow is not intended, and no text container whose height collapsed. Screenshots then show the cause; the assertions prove presence or absence.

## How an agent should apply this

- Name the cause with one row of the table in each finding, and give the fix as a suggestion with the file and line when known; do not edit.
- When a flex or grid row overflows, check `min-width` on the item before anything else; it is the most common root cause.
- Mark truncation findings as design decisions unless the full value is unreachable, in which case the finding is **Broken**.
- For right-to-left or mixed-direction breaks, note whether physical properties or missing `dir` handling is the cause so the owner knows which of the two to fix.
- If a fix would change a shared component, say so in the report; the blast radius is the owner's call.
