# Keyboard, Focus and Semantics Checks

Sources: https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG/Keyboard · https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG/Text_labels_and_names · https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Accessibility/Tooling · https://www.w3.org/WAI/ARIA/apg/practices/read-me-first/ · https://playwright.dev/docs/aria-snapshots · https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html · Last verified 2026-11-24

Playwright call names below (`keyboard.press`, `toBeFocused`, `evaluate`) are standard Playwright API used from general knowledge; the pages above were read for the ARIA-snapshot shape only.

## 1. The accessibility tree is the ground truth

Browsers hand assistive technology a tree with name, description, role and state per node. What a screen reader or voice tool sees is this tree, not the pixels. Read it before testing interactions.

- Browser DevTools: the Accessibility panel shows the tree and the computed name for the selected node.
- Playwright: an ARIA snapshot returns the tree as YAML (role, optional quoted name, bracketed attributes such as `[level=1]` or `[checked]`, indentation for nesting). It is good evidence to paste into a finding.
- Source order matters because assistive tools follow it. Disable styles and read the page to see the sequence they get.

```ts
// Evidence: the tree under one region, as YAML text
const tree = await page.locator('main').ariaSnapshot();
// Regression guard: partial template, names matched exactly or by /regex/
await expect(page.locator('form')).toMatchAriaSnapshot(`
  - form "Sign in":
    - textbox "Email"
    - button "Sign in"
`);
```

## 2. Names, roles, states

| Element | Check | Typical failure |
|---|---|---|
| Form control | Visible `label` tied by `for`/`id` or by nesting; not placeholder-only (it vanishes while typing) | Name taken from placeholder or missing |
| Radio/checkbox group | `fieldset` with `legend` | Group question is plain text, unannounced |
| Button/link | Name from its text; icon-only ones have a name; link text makes sense out of context | "Click here", empty icon button |
| Image/SVG/canvas | Meaningful: describes function; decorative: empty `alt`; canvas/SVG: `role="img"` with a name | Filename as alt |
| Dialog | Named by its heading (`aria-labelledby`) or `aria-label` | Unnamed dialog |
| iframe | Has `title` | None |
| Custom toggle/disclosure | State exposed (`aria-expanded`, `aria-pressed`, `aria-checked`) and updated on interaction | Visual state changes, tree does not |

Label in name (2.5.3): the visible text must appear in the accessible name, otherwise a voice user who says what they see gets nothing. `aria-label="Submit order"` on a button showing "Buy now" is a failure.

Compare the tree to what is on screen for each control; the mismatch is the finding.

## 3. Keyboard pass, step by step

1. Reload; press Tab once. A skip link should be first or landmarks must exist (2.4.1). Activate it: focus lands at the main content.
2. Tab through everything. After each press, record the focused element. Order must follow meaning (2.4.3); no positive `tabindex` values (they reorder away from the visual order).
3. For each stop: a visible focus indicator (2.4.7), not clipped by overflow, and at least partly visible (2.4.11) with sticky header, banner and chat widget present. Test at a narrow viewport and with zoom, where overlap is worse.
4. Activate every control with Enter (links, buttons) and Space (buttons, checkboxes). A clickable `div` must be focusable and answer both keys.
5. Open each popup, menu, dialog, tooltip. Escape closes; focus returns to the trigger; a modal dialog keeps focus inside while open; focus can leave anything else (2.1.2).
6. Composite widgets (tabs, menus, grids, comboboxes): compare arrow-key, Home/End and Enter behavior with the matching APG pattern; they use one tab stop with arrows inside.
7. Check content that appears on hover or focus (1.4.13): can be dismissed, hovered over, and stays.
8. Check single-key shortcuts (2.1.4): can be disabled or remapped.

```ts
// Record the tab walk as evidence (ids, roles, names), not just pass/fail
const walk = [];
for (let i = 0; i < 40; i++) {
  await page.keyboard.press('Tab');
  walk.push(await page.evaluate(() => {
    const e = document.activeElement;
    return { tag: e?.tagName, id: e?.id, text: (e?.textContent || '').trim().slice(0, 40) };
  }));
}
```

A stuck walk (the same element repeated) is a trap candidate; a walk that skips a visible control is an operability finding. Use `await expect(locator).toBeFocused()` only for a regression check, after a manual pass has decided what should be focused.

## 4. ARIA misuse to look for

- A role without behavior: `role="button"` on a non-focusable `div`, or one that ignores Space.
- ARIA that overrides good native semantics, for example a role on a `table` or `ul` that removes its meaning.
- `aria-hidden="true"` on or around focusable content: users can focus something that does not exist in the tree.
- States out of sync with the UI (`aria-expanded="false"` while the panel is open).
- Names that restate the role ("button Submit button") or contradict the visible label.
- Required attributes or children missing for the role (axe covers many; verify the rest by hand).

The APG's own rule: no ARIA is better than bad ARIA, and a role is a promise to implement the keyboard behavior. It also warns that examples are written for the ARIA spec and recent browsers and that assistive-technology support must be tested.

## 5. Screen reader spot-check (when available)

One screen reader pass catches what the tree view hides. Use the reader you actually have (NVDA on Windows, VoiceOver on macOS and iOS are the common free ones); check that headings are navigable by key, links read sensibly out of context, form fields announce label and state, and a status message is announced without focus moving. Record the combination used; if none was used, the report says so.

## How an agent should apply this

- Start every audit by reading the tree for the flow's main region and by doing one full Tab walk, and save both as evidence.
- Record the focused element after every key press; a finding cites the step number.
- Report name/role/state defects with the visible label and the computed name side by side.
- When an agent cannot run a screen reader, label name/announcement findings "from the tree, not verified by a screen reader".
- Do not add or edit ARIA to fix findings unless asked; prefer recommending the native element.
