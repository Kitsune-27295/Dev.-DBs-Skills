# WCAG 2.2 Criteria Map: How to Test Each One

Sources: https://www.w3.org/TR/WCAG22/ · https://www.w3.org/WAI/WCAG22/Understanding/ (target-size-minimum, focus-not-obscured-minimum, reflow, contrast-minimum, status-messages) · https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md · https://www.w3.org/WAI/test-evaluate/preliminary/ · Last verified 2026-11-27

How to read the map: "Manual" is a procedure a person can run in a browser; "axe" names rules seen on the axe-core rule list on the read date, or says "none" when no rule exists for the criterion in what was read. "Partial" means a tool can find a subset (for example presence, not quality). Version-sensitive: rule ids and default-on status change between axe-core releases; check the installed version.

WCAG 2.2 removed 4.1.1 Parsing (marked obsolete). Report on it only when the user's required standard is 2.0 or 2.1. Nine criteria are new in 2.2; at A or AA these are 2.4.11, 2.5.7, 2.5.8, 3.2.6, 3.3.7 and 3.3.8 (the AAA ones, 2.4.12, 2.4.13 and 3.3.9, are out of scope by default).

## Perceivable

| SC (level) | Manual test | Automation |
|---|---|---|
| 1.1.1 Non-text content (A) | Inspect each image, icon, canvas, SVG: does the name say what it does or shows? Decorative: empty `alt`. | image-alt, area-alt: presence only (partial) |
| 1.2.x Time-based media (A/AA) | Play it: captions exist and are accurate, audio description or media alternative present, live captions where live. | video-caption: partial |
| 1.3.1 Info and relationships (A) | Read the accessibility tree: headings, lists, tables, form groups, landmarks match what is shown. | aria-required-children and others: partial |
| 1.3.2 Meaningful sequence (A) | Disable styles; read in DOM order. | none |
| 1.3.3 Sensory characteristics (A) | Read instructions ("the green button", "on the right"): do they also name the control? | none |
| 1.3.4 Orientation (AA) | Rotate or emulate both orientations; content must not be locked. | none |
| 1.3.5 Identify input purpose (AA) | Personal-data fields carry the right `autocomplete` token. | autocomplete-valid: partial |
| 1.4.1 Use of color (A) | View in grayscale; links in text and error/required cues need a non-color cue. | link-in-text-block: partial |
| 1.4.2 Audio control (A) | Audio longer than 3 seconds that starts alone needs a stop or volume control. | no-autoplay-audio: partial |
| 1.4.3 Contrast minimum (AA) | 4.5:1 text, 3:1 large (18 pt, or 14 pt bold; about 24 px and 18.5 px). Use specified colors, no rounding (4.499 fails). Include hover, focus and placeholder states. Exempt: inactive controls, pure decoration, logotypes. | color-contrast: strong on solid backgrounds; images and gradients end up in `incomplete` |
| 1.4.4 Resize text (AA) | Zoom text to 200% without assistive technology; nothing lost. | meta-viewport (blocks zoom): partial |
| 1.4.5 Images of text (AA) | Look for text rendered as image. | none |
| 1.4.10 Reflow (AA) | Viewport 320 CSS px wide (400% on 1280) for vertical scrolling; 256 px tall for horizontal. One-direction scrolling only, except parts that need two dimensions (maps, data tables as a whole). Header, search and pagination must still reflow. | none |
| 1.4.11 Non-text contrast (AA) | 3:1 for control boundaries, icons, focus indicators and state indicators that carry meaning. | none |
| 1.4.12 Text spacing (AA) | Apply user spacing overrides (line height 1.5, paragraph spacing 2x, letter spacing 0.12 em, word spacing 0.16 em, as multiples of font size; confirmed in the WCAG 2.2 text) with a bookmarklet or style injection; nothing clipped. | none |
| 1.4.13 Hover or focus content (AA) | Popup is dismissible (Escape), hoverable, persistent until dismissed. | none |

## Operable

| SC (level) | Manual test | Automation |
|---|---|---|
| 2.1.1 Keyboard (A) | Every function reachable and operable by keyboard. | frame-focusable-content: partial |
| 2.1.2 No keyboard trap (A) | Focus can always leave; dialogs trap only while open and Escape closes. | none |
| 2.1.4 Character key shortcuts (A) | Single-key shortcuts can be turned off, remapped, or work only on focus. | none |
| 2.2.1 Timing adjustable (A) | Time limits can be turned off, adjusted or extended. | meta-refresh: partial |
| 2.2.2 Pause, stop, hide (A) | Auto-moving or updating content has a control. | blink: partial |
| 2.3.1 Three flashes (A) | Nothing flashes more than 3 times per second above thresholds. | none |
| 2.4.1 Bypass blocks (A) | A skip link or landmarks; Tab first, press Enter, focus lands in main. | bypass: partial |
| 2.4.2 Page titled (A) | Title describes the page; changes on state change if the app is a SPA. | document-title: presence |
| 2.4.3 Focus order (A) | Tab order preserves meaning; no positive `tabindex`. | none |
| 2.4.4 Link purpose (A) | Link text or its context says where it goes; no bare "click here". | link-name: presence |
| 2.4.5 Multiple ways (AA) | More than one way to find a page (except steps of a process). | none |
| 2.4.6 Headings and labels (AA) | Headings and labels describe topic or purpose. | none |
| 2.4.7 Focus visible (AA) | A visible indicator on every focusable element in every state. | none reliable |
| 2.4.11 Focus not obscured, minimum (AA, new) | Fails only if author content fully covers the focused component. Tab through with sticky header, cookie banner, chat widget at several viewport sizes and zoom levels; scroll-padding is the usual fix. | none |
| 2.5.1 Pointer gestures (A) | Multi-point or path gestures have a single-pointer alternative. | none |
| 2.5.2 Pointer cancellation (A) | Action fires on release (up-event) or can be aborted. | none |
| 2.5.3 Label in name (A) | The accessible name contains the visible label text, for speech users. | label-content-name-mismatch: partial |
| 2.5.4 Motion actuation (A) | Shake or tilt functions have a UI alternative. | none |
| 2.5.7 Dragging movements (AA, new) | Anything done by dragging also works with single clicks/taps (arrows, move buttons). | none |
| 2.5.8 Target size minimum (AA, new) | Target is at least 24 by 24 CSS px, or a 24 px circle centered on it touches no other target or undersized circle (so 20 px buttons need a 4 px gap). Exceptions: equivalent control elsewhere on the page, inline in a sentence, unmodified user-agent control, essential. CSS pixels: browser zoom does not help. | target-size: off by default in the list read |

## Understandable and Robust

| SC (level) | Manual test | Automation |
|---|---|---|
| 3.1.1, 3.1.2 Language (A, AA) | `lang` on the root and on passages in another language. | html-has-lang, valid-lang: partial |
| 3.2.1, 3.2.2 On focus, on input (A) | Focusing or changing a field must not move you elsewhere unannounced. | none |
| 3.2.3, 3.2.4 Consistent navigation, identification (AA) | Compare several pages: same order, same names for the same function. | none |
| 3.2.6 Consistent help (A, new) | Help links/contact appear in the same relative place across pages. | none |
| 3.3.1 Error identification (A) | Trigger each error: text says which field and what is wrong; not by color alone. | none |
| 3.3.2 Labels or instructions (A) | Every input has a visible label or instruction. | label: presence |
| 3.3.3 Error suggestion (AA) | When a fix is known, it is offered. | none |
| 3.3.4 Error prevention, legal/financial/data (AA) | Reversible, checked, or confirmable before final submit. | none |
| 3.3.7 Redundant entry (A, new) | Within one process, data already given is prefilled or selectable. | none |
| 3.3.8 Accessible authentication, minimum (AA, new) | No memory or transcription test without an alternative: allow paste and password managers, offer an alternative to puzzles. | none |
| 4.1.2 Name, role, value (A) | Tree entry gives name and role for each control; state and value changes are exposed (expanded, checked, selected). | button-name, link-name, label, aria-allowed-attr, aria-hidden-body: partial |
| 4.1.3 Status messages (AA) | Trigger the change without moving focus (results count, "saved", cart update, progress); a screen reader announces it; markup uses `role="status"`, `role="alert"` or a live region. Dialogs that take focus and expand/collapse widgets are out of scope for this criterion (4.1.2 covers the latter); `role="log"` suits sequential updates. | none |

## How an agent should apply this

- Use the map as a checklist of tests, not as a list of rules to cite: report only criteria with an observed failure or a named untested area.
- For each criterion tied to a number (24 px, 320 px, 4.5:1, 3:1, 200%), record the measured value and the tool or method that produced it.
- Treat "partial" automation as a prompt to inspect the `incomplete` list and spot-check nodes by hand.
- Do not report 4.1.1 under 2.2, and label new 2.2 criteria so readers on a 2.1 target can filter them.
- Where a criterion is "none" for automation, the report's coverage statement must say how it was checked, or that it was not.
