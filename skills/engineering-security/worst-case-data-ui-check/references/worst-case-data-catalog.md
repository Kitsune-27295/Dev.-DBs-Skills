# Worst-Case Data Catalog

Sources: https://www.w3.org/International/questions/qa-personal-names, https://www.w3.org/International/questions/qa-html-dir, https://www.w3.org/International/articles/inline-bidi-markup/, https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules, https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat · Last verified 2026-11-24

How to choose the hostile value for each kind of field. The rule is the same everywhere: the value must be something a real person, a real integration or a real translation could produce, or the actual limit in the schema. Anything marked "(own)" below is the author's judgment, not a quotation from a source.

## Strings

| Kind | Values to try | Why it matters |
|---|---|---|
| Long free text | 120 to 200 characters with spaces, accents and `&` | exposes wrapping versus truncation, and unescaped markup characters |
| Long single token | one 40-character word; an e-mail such as `first.last@some-very-long-department.example.com`; a URL with a long path; a host name near the DNS label limit | no break opportunity, so the text runs past its box |
| Very short | one letter; one character in a non-Latin script; a single emoji | avatars and initials logic, alignment, minimum-width columns |
| Empty versus missing | `""` and an absent property are two inputs (own) | a screen may show a blank gap for one and a placeholder for the other |
| Markup characters | `<b>x</b>`, `&amp;`, quotes, a very long string of `W` | proves text is rendered as text and measures the widest glyph (own) |
| Whitespace | leading and trailing spaces, a line break inside a single-line field | collapsed or preserved whitespace changes height |

Names deserve extra care. The W3C personal-names article describes names that do not follow a first-name/last-name split (a given name plus a patronymic, a family name written first, a single name) and warns that names can be much longer than the author's own, and that a four-character Japanese name needs about 12 bytes in UTF-8, so a byte-limited field truncates it. Worst cases to include (the first three paraphrase that article, the last is own): a single-word name, a name with a family name first, a very long full name, and a name that is only one letter.

## Numbers and measured values

| Case | Values | What to look for |
|---|---|---|
| Counts | 0, 1, 2, 5, 21, 1,284, 1,000,000 | plural labels, badge width, grouping separators |
| Missing versus zero | `null` ("not measured"), `0` (measured as zero), the string `"0"` | the UI must show three distinct answers; ownership of a wrong answer belongs to `cross-layer-value-trace` |
| Precision | a value with many decimals that the source published exactly | the screen must not round what the source did not round (own rule: display rounding is a product decision, state it) |
| Sign and size | a negative amount, the largest amount the field accepts, a currency without minor units | column width, sign placement, sort order |
| Formatting | the same number in two or three locales | decimal and grouping separators differ per locale; `Intl.NumberFormat` formats by locale and currency, so a hand-built string is a finding |

## Plurals

`Intl.PluralRules` returns one of `zero`, `one`, `two`, `few`, `many`, `other`. English uses two forms, Chinese one, Arabic six, per MDN. A label built as `count + " item" + (count === 1 ? "" : "s")` is correct only for languages with the English rule, and even in English it fails for words whose plural is not "s" (own example: "fish", "child"). Test the counts 0, 1, 2, 3, 5, 11, 21, 100 in the source language and, when other locales exist, in the one with the most forms.

## Collections

- Empty, one, two, and the largest realistic size (the order of thousands in a client-rendered table).
- Duplicates: two rows with the same label, to see whether keys, selection and tooltips still tell them apart.
- Last page of a paged list with a single row, and a page request past the end.
- A list whose first row is ordinary and whose 40th row is the hostile one (the long value must not hide below the fold).

## Time

Now, "just now", yesterday at 23:59 in one zone and 00:01 in another, two years ago, an absent date, a date at a daylight-saving transition, and a timestamp in the future (clock skew). The screen should show a stated fallback for an absent date, not "Invalid Date" or "NaN".

## Language and direction

- **Longest translation decides the width** (own, widely used practice): load the longest string of one key, then check buttons, tabs and table headers.
- **Right-to-left**: the W3C structural-markup article says to put `dir="rtl"` on the `html` element when the whole document is right-to-left, to use logical start and end values in CSS instead of left and right, and to use `dir="auto"` on elements that hold run-time text of unknown direction. Test a page-level rtl run (set `dir="rtl"` on the root) and a ltr page with one rtl value inside it.
- **Mixed direction**: the inline-markup article shows a rtl phrase containing a left-to-right fragment (such as `C++`) and recommends wrapping run-time text in an element with `dir="auto"` or a `bdi` element. Test `"title: <rtl phrase> 5 times"` to see punctuation and numbers jump (own phrasing of the symptom).
- **Combining characters and emoji sequences**: a name with decomposed accents or a family emoji must not be cut in the middle of a grapheme (own; relevant when truncating in script).

## Environment states

Loading (no data yet), slow (seconds), error with a long message, error with an empty message, partial data (some properties absent), a feature the viewer lacks (button hidden or disabled, not broken). Mock them as in `playwright-mocked-routes-recipes.md`.

## Example fixture row (own)

```json
{
  "id": "row-40",
  "name": "Bartholomew Fitzgerald-Montgomery & Sons Industrial Holdings (Northern Region) Ltd.",
  "email": "bartholomew.fitzgerald@northwind-industries-holdings.example.com",
  "initials": "B",
  "members": 1,
  "score": null,
  "balance": -1234567.891,
  "updatedAt": null
}
```

## How an agent should apply this

- Build the surface map first, then pick at least one hostile value per row of it; a field with no known limit gets the longest value you can justify and a **Fragile** finding.
- Keep `null`, `0`, `""` and an absent property as separate runs; report any place where they look the same.
- Include one right-to-left run and one longest-translation run even if the product ships one language today, and label them "future locale" in the report.
- Place the hostile row at position 1 and at position 40 in the same fixture so both the visible area and the scrolled area are tested.
- Never invent a limit; cite the schema or say "unbounded".
