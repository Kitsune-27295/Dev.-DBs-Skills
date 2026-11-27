# Sources — KISS, YAGNI & AHA

Every URL below was checked during skill authoring (re-fetched 2026-11-27; first authored 2026-11-23).

Note: Firecrawl had no credits on the verification date, so pages were read through WebFetch (page converted to markdown and extracted by a small model with a detailed-extraction prompt). Facts below are from those extractions; wording is paraphrased.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://martinfowler.com/bliki/Yagni.html | 200 OK (WebFetch, 2026-11-27) | Origin (Beck/Hendrickson, C3), "presumptive feature", four costs (only referenced, not redone), three classes of presumptive features, Kohavi one-third statistic, small-scale yagni (regex, fields), imagine-the-refactoring technique, cheap preparations, yagni depends on malleability practices |
| https://martinfowler.com/bliki/RuleOfThree.html | 404 Not Found (re-checked 2026-11-27, still 404) | Nothing read. The Rule of Three is therefore described only as well-established background knowledge (not read from source); no Fowler/Don Roberts attribution is asserted from a page read. Dodds' article names it only implicitly via the WET rule of thumb |
| https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction | 200 OK (WebFetch, 2026-11-27) | The six-step formation sequence, sunk cost explanation, three-step recovery (inline, keep what each caller needs, delete the rest), "duplication is far cheaper than the wrong abstraction", "fastest way forward is back" |
| https://kentcdodds.com/blog/aha-programming | 200 OK (WebFetch, 2026-11-27) | AHA definition (Cher Scarlett's acronym), WET (Conlin Durbin), DRY quote, three experience examples (copy-paste x8, AngularJS pseudo-inheritance, jsinspect; corrected from four), rules of thumb |

## Reading limits

Pages were read as small-model extractions, not line by line; wording is paraphrased. The Fowler Rule of Three page was never read. No scripts in this skill.

## Claims not adopted as fact

- Rule of Three attribution and wording (page 404): background knowledge only.
- That callers "often turn out quite different" after inlining, and the observe-then-re-extract steps: this skill's advice, not confirmed on the Metz page.
- Fowler's "availability bias" remark on yagni failures: not re-confirmed, removed.
- The KISS construct ordering (SKILL.md section 2) and the detection list: own synthesis.
