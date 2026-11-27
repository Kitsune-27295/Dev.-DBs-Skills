# Should This Be a New Page? Join Versus Split

Sources: https://diataxis.fr/start-here/ (re-read 2026-11-27, see `sources.md`) · Method adapted from a note-taking granularity skill (MIT) read 2026-11-24, generic part only · Last verified 2026-11-27

`SKILL.md` and [four-forms-map-and-compass.md](four-forms-map-and-compass.md) decide which quadrant a piece of content belongs to. This file decides an earlier question: whether the content deserves its own page at all. Page proliferation is a common failure when people adopt the four quadrants: four empty folders, then a thin page per idea.

## The one question

Before creating a page, ask: **would this page carry a thesis of its own, or would it merely index another page?** A thesis is something a reader could disagree with, or a fact other pages need to link to. If the page would only index another, do not create it: put the material as a section of the page that owns the subject.

## Default: do not create a new page

1. **Asymmetry.** Joining two pages later is cheap (paste, fix a few links). Splitting one later is expensive: every inbound link must be re-aimed at the right half. Waiting costs little; guessing wrong costs work.
2. **Structure by pressure, not anticipation.** A page made for content that has not arrived is a bet with immediate maintenance cost.
3. **Readers pay a budget.** Every extra page enlarges the navigation a reader (or a cold agent) must scan before reading anything.

This agrees with the Diataxis advice already in `SKILL.md`: work from the page you are editing, not from a pre-built skeleton.

## When a split is earned

Use a written signal, not a feeling: **other pages link to a section** (a deep link to an anchor) instead of the page. That is a caller saying it needs a part, not the whole. Two or more such callers, and the section wants its own page. In Diataxis terms, a second signal is quadrant contamination: a block that serves another quadrant (for example a 40-row parameter table inside a how-to) moves to the right quadrant, because the reader's need differs, not because the page is long.

Length and popularity are not signals. A reference page can be long and heavily linked because that is what reference is; splitting a uniform reference table destroys the property that makes it scannable.

## Folders

A new section or folder appears at about the third page of the same kind, not before and not by declaration.

## Where content goes instead of a new page (in order)

1. A section of the existing page that owns the subject.
2. A row or entry in the list or table that already owns that kind of fact (a decision log, a glossary, a changelog).
3. A line in the section's index page, if it is purely navigational.

## Example

Request: "Document the new `--dry-run` flag." Check: does it have a thesis of its own? No: it is one row of the CLI reference and one sentence in the deploy how-to. Add the row and the sentence. If three callers later link to a long "dry-run semantics" section, promote that section to an Explanation page and re-aim the links.

## How an agent should apply this

- Before adding a page, answer the thesis question and name the owning page for the material; default to adding a section there.
- Split only on a written signal (two or more deep links to a section, or quadrant contamination), never on length alone.
- When splitting, update every inbound link in the same change.
- Create a folder only for the third page of a kind.
