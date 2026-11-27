# Hard Tells, Counted Signals, Masking and Exemptions

Sources: https://docs.vale.sh/ · https://docs.vale.sh/topics/styles · https://github.com/DavidAnson/markdownlint · https://developers.google.com/style/highlights · https://developers.google.com/style/tone · Last verified 2026-11-24

## 1. How prose linters organize checks

Vale is the closest public model of a text gate. Its checks ("extension points") show which kinds of test exist:

| Vale check | Meaning | Use in a text gate |
|---|---|---|
| `existence` | report a pattern that is present | hard tells |
| `substitution` | report a pattern and carry its replacement | "use X instead of Y" (term lists) |
| `occurrence` | count a pattern; report too few or too many | counted signals, sentence or heading length caps |
| `repetition` | a pattern repeats | duplicated words |
| `consistency` | a file uses two forms of one thing | "e-mail" and "email" in one document |
| `capitalization` | text not cased as required | heading case |
| `metric`, `readability` | formula or grade over a block | rarely worth it for agent output |

A Vale rule has four decisions: what to check, where to look (`scope`: sentence, heading, whole text), the message, and an optional action. Severity is `suggestion`, `warning` or `error`, and only errors set a failing exit code. Block and inline code are ignored by default. markdownlint, for Markdown structure, has numbered rules, per-rule configuration (`false` disables, `"warning"` and `"error"` set severity), and inline HTML comments that switch rules off for a line, a block or a file, with an option to ignore inline comments entirely.

Lesson for a custom gate: you may not need to build one. If the patterns are expressible as existence, substitution and occurrence rules over Markdown, a configured Vale or markdownlint run is the gate and your work is the rule list and the wiring. Write a custom script when you need patterns tied to agent behavior, multi-surface input (commit messages, tool payloads) or fewer dependencies.

## 2. Where pattern ideas come from

Use your own recurring failures first. Public style guides help you state the rewrite. The Google developer documentation style guide is a guideline set, not a rule set (its own wording), and gives several mechanical candidates:

- sentence case for titles and headings,
- second person and active voice,
- serial commas,
- descriptive link text instead of "click here",
- warnings against wording that suggests a task is trivial in procedures,
- no pre-announcing features in documentation.

Of these, heading case, link text and "click here" are good gate material; voice and tone are mostly reader judgment (the guide itself says to depart from guidelines when that makes the content better). Treat style guide items as candidates to test against your samples, not as a list to import.

## 3. Choosing hard tells

A hard tell fails the whole text on one hit, so it must meet all of these:

1. It has appeared repeatedly in your real outputs.
2. A reviewer would change it every time.
3. You can state the fix in one line.
4. The pattern can be anchored tightly (line start, word boundary, fixed phrase).

Typical categories (examples are generic and yours to adapt):

| Category | Why it is safe to hard-fail | Anchor |
|---|---|---|
| Decorative marks in structure | emoji at the start of a heading; a title that is a slogan | `^#+\s*<emoji>` |
| Filler openers | "Great question", "Certainly!" as the first words | `^(great question|certainly)\b` |
| Pre-announcement | "It is worth noting that", "Let me explain" before the content | fixed phrases |
| Recap closers | a last paragraph starting "In conclusion," | final paragraph + opener |
| Rhetorical headings | headings that are questions or slogans where the guide requires nouns | heading line only |
| Placeholder text | `TODO`, `lorem ipsum`, `<fill in>` in a deliverable | fixed tokens |

Keep the hard list short (5 to 15 patterns). A long list grows false positives faster than it catches problems.

## 4. Choosing counted signals

Counted signals are words that are decoration at volume but fine once. Examples: "robust", "seamless", "leverage", "streamline", "powerful", "cutting-edge". Mechanics:

- Count whole-word matches over the masked text of one document.
- Fail at a threshold, usually 3, taken from your clean samples. Report the count and the words.
- Per-document counting is crude on very long files; normalize (hits per 1,000 words) if documents vary in length by an order of magnitude.
- A single use passes. The human test: remove the adjective; if the reader would act the same, it was decoration, otherwise it carried meaning.
- Allow the term of art: "robust statistics", "seamless tube". Provide an allowlist the gate consults.

## 5. Masking details (the common bug source)

Order matters: mask fenced blocks first, then inline code, then quotes, so a backtick inside a quote or a quote inside code does not confuse the next step.

- Fences: lazy match from the opening fence to the next fence; handle `~~~` too if you use it.
- Inline code: a single-backtick span on one line.
- Quotes: double quotes and curly quotes on one line. Do not treat apostrophes (`it's`) or single quotes as quotation marks.
- Replace with spaces and keep every newline so line numbers in reports stay correct.
- Front matter: mask or skip when it holds `description:` strings you do not author as prose.
- Commit messages: drop lines starting with `#` before scanning; ignore trailers such as `Co-Authored-By:` when they match a pattern.
- Do not mask so aggressively that real text escapes: a long quoted paragraph is still the author's voice. Cap quote masking to one line if abuse appears.

## 6. Exemptions and overrides

- An exhibit marker with a mandatory reason (`gate-ok: <reason>`) in the file lets a document show a tell in its own voice. A bare marker is ignored.
- The marker is for exhibits, not for getting past a disagreement. If the gate is wrong, fix the pattern list in the same change and record why.
- markdownlint's per-rule inline comments are the same idea at finer grain; a per-line, per-rule marker is safer than a whole-file switch because it leaves other checks active.
- Review the markers: a file with many exemptions is a sign that a pattern is wrong.

## 7. Calibrating thresholds and measuring the gate

- Run the gate in report-only mode on 20 to 50 historical outputs. Count hits per pattern.
- For each pattern record true positives (a reviewer would change it) and false positives. Drop patterns below roughly even precision (your call, an inference not a standard).
- Keep a fixtures folder: one file per hard tell that must fail, a clean file that must pass, a file that quotes tells inside code and quotes that must pass, and an exhibit file with a reasoned marker.
- Re-run the calibration after any pattern change.

## How an agent should apply this

- Collect real samples before writing a single pattern; keep only patterns with repeat evidence.
- Express each pattern as an existence or occurrence check; if Vale or markdownlint already covers it, configure them instead of coding.
- Mask code and quotes with newline-preserving blanking, in the right order.
- Require a reason on every exemption marker and refuse to add markers to pass the gate.
- Report precision per pattern after a calibration run and delete weak patterns.
