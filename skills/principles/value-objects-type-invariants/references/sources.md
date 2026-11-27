# Sources — Value Objects & Type-Level Invariants

Every URL below was checked during skill authoring (re-fetched 2026-11-27; first authored 2026-11-23).

Note: Firecrawl had no credits on the verification date, so pages were read through WebFetch (markdown conversion plus extraction by a small model). Content is paraphrased from those extractions.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://martinfowler.com/bliki/ValueObject.html | 200 OK (WebFetch, 2026-11-27) | Definition (equal by property values), equality in Clojure/Java/Ruby/JS, aliasing bug with dates, immutability via no setters / Object.freeze / copy-on-assign, contextual value vs reference (address), small-object guidance (phone number, money, range), DTO terminology clash, Range exercise |
| https://martinfowler.com/eaaCatalog/money.html | 200 OK (WebFetch, 2026-11-27) | Only a brief overview: money not first-class, currency mixing problem, rounding to smallest unit losing pennies, Money class as solution, pointer to PoEAA ch. 18. Allocation/minor-unit details are NOT on this page; they appear in the skill marked as background knowledge / own synthesis |
| https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/ | 200 OK (WebFetch, 2026-11-27) | Contact example (email or postal or both), over-strict vs over-loose modeling, union redesign, helper functions returning option, update across three cases, warning on unsafe `.Value`, benefits (rule documented, compile-time breaks on rule change). Re-checked 2026-11-27: the post has no verification-workflow example and no state machine (a later post in the series is named but unread), so the email-verified example is own illustration |

## Reading limits

Pages were read as small-model extractions, not line by line; wording is paraphrased. PoEAA chapter 18 was not read. No scripts in this skill.

## Claims not adopted as fact

- Allocation algorithm, minor-unit representation, currency scale table (JPY 0, EUR 2, KWD 3), rounding-mode advice: background knowledge or own synthesis, not from the Money catalog page.
- Range operations list and "value objects anchor simplifying refactorings": not re-confirmed on the ValueObject page.
- State-per-type as an operation-level extension: own extension beyond the F# post.
