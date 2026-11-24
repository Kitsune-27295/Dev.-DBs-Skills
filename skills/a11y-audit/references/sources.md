# Sources — Accessibility Audit (`a11y-audit`)

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [WCAG 2.2 (W3C Recommendation)](https://www.w3.org/TR/WCAG22/) | 200 OK via fetch tool; page is about 270,000 characters, characters 0 to 200,000 read (all of principles 1 to 4 at A and AA); the final part (conformance and appendices) not read | The A and AA criteria list, wording of the new 2.2 criteria, 2.5.8 exceptions, 4.1.1 marked obsolete and removed |
| [Understanding WCAG 2.2 (index)](https://www.w3.org/WAI/WCAG22/Understanding/) | 200 OK | Understanding documents are informative, not normative; link pattern for per-criterion pages |
| [Understanding 2.5.8 Target Size (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html) | 200 OK | 24 CSS px rule, spacing circle, exceptions, test steps, common failures |
| [Understanding 2.4.11 Focus Not Obscured (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html) | 200 OK | "Entirely hidden" scope, sticky headers, banners and chat widgets, scroll padding |
| [Understanding 1.4.10 Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html) | 200 OK | 320 px and 256 px thresholds, exceptions, test steps |
| [Understanding 1.4.3 Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) | 200 OK | 4.5:1 and 3:1, exceptions, no rounding, states and placeholder |
| [Understanding 4.1.3 Status Messages](https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html) | 200 OK | What counts as a status message, roles, scope exclusions |
| [WAI preliminary review](https://www.w3.org/WAI/test-evaluate/preliminary/) | 200 OK | Quick check list and its stated limits; points to a full evaluation method |
| [WAI-ARIA Authoring Practices Guide (home)](https://www.w3.org/WAI/ARIA/apg/) | 200 OK | Purpose, patterns, practices |
| [APG read-me-first](https://www.w3.org/WAI/ARIA/apg/practices/read-me-first/) | 200 OK (extra page, linked from the APG) | "No ARIA is better than bad ARIA"; a role is a promise (keyboard behavior); support and testing caveats |
| [web.dev Learn Accessibility](https://web.dev/learn/accessibility) | 200 OK; the page is a single overview, not a course index | Audit methods (design, automated, manual, assistive technology), repeat audits, keyboard and focus testing statements |
| [axe-core rule descriptions](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md) | 200 OK | Rule list structure, tags, impact levels, WCAG 2.2 and AAA rules off by default, rule ids |
| [axe-core API](https://github.com/dequelabs/axe-core/blob/develop/doc/API.md) | 200 OK (extra page) | Result groups, `incomplete` meaning, `runOnly` tag behavior, iframes and shadow DOM, `resultTypes` |
| [Lighthouse accessibility scoring](https://developer.chrome.com/docs/lighthouse/accessibility/scoring) | 200 OK | Weighted average of binary audits, weights 3/7/10, manual and best-practice audits excluded |
| [Lighthouse accessibility overview](https://developer.chrome.com/docs/lighthouse/accessibility/) | 200 OK, but the fetch returned the same scoring content; no separate overview facts used | None beyond the scoring page |
| [Playwright accessibility testing](https://playwright.dev/docs/accessibility-testing) | 200 OK | `AxeBuilder`, `include`, `exclude`, `withTags`, `disableRules`, fingerprint snapshots, attachments, fixtures, statement that many issues need manual testing |
| [Playwright ARIA snapshots](https://playwright.dev/docs/aria-snapshots) | 200 OK (extra page) | Tree-as-YAML shape, partial matching, regex names, `ariaSnapshot()` |
| [MDN Keyboard (Understanding WCAG)](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG/Keyboard) | 200 OK | Native elements first, `tabindex` rules, custom clickable widgets, visible focus |
| [MDN Text labels and names](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG/Text_labels_and_names) | 200 OK | Label, fieldset/legend, `aria-label` vs `aria-labelledby`, images, iframes, page title |
| [MDN Understanding WCAG (index)](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG) | 200 OK; index page only, one-line summaries | Structure of the guides |
| [MDN Accessibility tooling](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Accessibility/Tooling) | 200 OK | Accessibility tree, tools named, screen reader basics, limits of automated tools |
| Third-party skill read for ideas, no text reused | Skipped on purpose; not opened | Nothing (clean-room: all text written from the public sources above) |

## Reading limits

- The fetch tool summarizes pages with a small model rather than returning raw text; quoted numbers (24 px, 320 px, 4.5:1) match the Understanding pages as summarized, and exact normative wording should be confirmed in the WCAG text before quoting it in a formal report.
- The final 70,000 characters of WCAG 2.2 (conformance requirements, glossary) were not read.
- Lighthouse CLI flags, `@axe-core/playwright` install names, Playwright keyboard calls and screen-reader key commands beyond MDN's are general knowledge, labeled as such in the reference files.
- Text spacing figures (1.4.12) were not shown in the page excerpt read and are marked for confirmation.

## Claims not adopted as fact

- web.dev's statement of a total of 78 success criteria for WCAG 2.2: this skill did not adopt it. The count of the 2.2 text read (new criteria added, 4.1.1 removed) suggests a different number; it is not needed, so no total is stated.
- Any percentage of issues that automated tools detect: no source read states one, so none is given.
- That a Lighthouse score of 100 means accessible: the scoring page does not say this, and this skill states the opposite reading as its own rule.
- Third-party blog numbers on audit coverage or cost: not used.
