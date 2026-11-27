# Zoom, Reflow and Text-Only Checks

Sources: https://www.w3.org/WAI/WCAG22/Understanding/reflow.html, https://www.w3.org/WAI/WCAG22/Understanding/text-spacing.html, https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html, https://playwright.dev/docs/emulation · Last verified 2026-11-24

Three WCAG 2.2 success criteria define the environment passes of this skill. This skill runs them against worst-case data to find breaks; conformance judgments and the wider audit belong to `a11y-audit`.

## What each criterion says (paraphrased from the Understanding pages)

**1.4.10 Reflow (AA).** Vertical-scrolling content must be presentable without loss of information or functionality and without two-dimensional scrolling at a width equivalent to **320 CSS pixels**; horizontal-scrolling content at a height equivalent to **256 CSS pixels**. Note 1 on the page says 320 CSS px equals a 1280 px wide viewport at 400% zoom. Content that needs a two-dimensional layout (images such as maps and diagrams, video, games, presentations, data tables as a whole, interfaces that must keep toolbars in view) is excepted, but the page stresses that each table cell's content still has to meet the criterion. Responsive rearranging (stacking into one column, collapsing navigation behind a button) is not a loss of content so long as everything stays reachable.

**1.4.4 Resize text (AA).** Except captions and images of text, text can be resized without assistive technology **up to 200%** without loss of content or functionality. The page says scaling is mainly the browser's job (zoom, magnification, text-only resizing), and the author's job is not to prevent it. A label control too narrow for its content may truncate if the full content is available on focus or after activation and the user is told in some way other than the truncation itself.

**1.4.12 Text spacing (AA).** No loss of content or functionality when a user sets all of: line height at least **1.5** times the font size, spacing after paragraphs at least **2** times, letter spacing at least **0.12** times, word spacing at least **0.16** times, changing no other property. The page notes the values are not required styling; they are the floor a user override must survive, and authors are encouraged to allow spacing beyond them. Scripts that do not use some of these properties are excepted for those properties.

## Passes to run, in order

1. **Baseline** at the widest layout the product supports. Take the screenshot first, so every later break has a reference.
2. **320 CSS px wide** (for example 320 by 640). Check no horizontal page scroll and that every control of the worst-case rows is reachable.
3. **200% zoom** (browser zoom). Playwright runs a fixed device pixel ratio per context, so emulate zoom by halving the viewport (a 1280 px viewport at 200% behaves like 640 px) and, for 400%, a 320 px viewport (own approximation of Note 1; a real browser zoom check by hand is better when the owner can do it).
4. **Text-only zoom** (own approximation): raise the root font size to 200% and leave the viewport alone, which mimics text-only resizing where the browser offers it. Layouts with pixel-fixed boxes break here first.
5. **Text spacing override**: inject the four properties at the criterion's values (recipe below) and compare with the baseline for clipped, overlapping or vanished text.
6. **Right-to-left and dark mode** (see the catalog and the recipes file).
7. **Keyboard**: with the worst-case rows loaded, tab through the screen. Every action on a long row must be reachable; focus must stay visible and not be hidden under a sticky bar; truncated text must show its full value on focus or activation. Deeper keyboard and focus-order testing belongs to `a11y-audit`.

## Text spacing recipe (own, using the values above)

```ts
await page.addStyleTag({
  content: `
    * { line-height: 1.5 !important; letter-spacing: 0.12em !important; word-spacing: 0.16em !important; }
    p { margin-bottom: 2em !important; }
  `,
});
```

`!important` is deliberate: the criterion is about user overrides beating authored styles. Remove the style tag between passes, or use a fresh page.

## Text-only zoom recipe (own)

```ts
await page.addStyleTag({ content: 'html { font-size: 200% !important; }' });
```

This only changes layouts whose sizes derive from the root font size (`rem`, `em`). If nothing changes, the screen uses pixel sizes for text, which is itself a **Fragile** finding: the browser's text-size setting will not reach it.

## Reading the results

| Symptom | Finding |
|---|---|
| Horizontal page scroll at 320 px in ordinary content | **Broken** (reflow), unless the content is a data table or other excepted two-dimensional content |
| A cell inside a wide table needs sideways scrolling to read its text | **Broken** (reflow still applies to cell content) |
| Text clipped or overlapping under spacing overrides | **Broken** if content is lost, **Ugly** if still readable |
| Truncated label with no way to read it | **Broken** under resize text unless full content is available on focus or activation |
| Looks fine at 200% page zoom but not with text-only zoom | **Fragile**: text size is pinned in pixels |
| Control unreachable by keyboard in a long row | **Broken**; hand to `a11y-audit` for the full keyboard review |

## How an agent should apply this

- Run the baseline first and keep its screenshot; label every later screenshot with viewport, zoom mode and data case.
- Use the numbers from the criteria (320, 256, 200%, 1.5, 2, 0.12, 0.16) literally in the report so the owner can reproduce them.
- State clearly that Playwright emulations of zoom are approximations; recommend one manual browser-zoom pass for anything reported **Broken**.
- Do not claim WCAG conformance from this check; report breaks and refer conformance to `a11y-audit`.
- Treat the two-dimensional-layout exceptions as decisions for the owner when unsure, not as automatic passes.
