# Sources — Value Objects & Type-Level Invariants

Every URL below was checked during skill authoring (2026-11-23).

Note: Firecrawl had no credits left on the authoring date, so pages were read through WebFetch (markdown conversion plus extraction by a small model). Content is paraphrased from those extractions.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://martinfowler.com/bliki/ValueObject.html | 200 OK (WebFetch) | Definition (equal by property values), equality in Clojure/Java/Ruby/JS, aliasing bug with dates, immutability via no setters / Object.freeze / copy-on-assign, contextual value vs reference (address), small-object guidance (phone number, money, range), DTO terminology clash, Range exercise |
| https://martinfowler.com/eaaCatalog/money.html | 200 OK (WebFetch) | Only a brief overview: money not first-class, currency mixing problem, rounding to smallest unit losing pennies, Money class as solution, pointer to PoEAA ch. 18. Allocation/minor-unit details are NOT on this page; they appear in the skill marked as background knowledge / own synthesis |
| https://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/ | 200 OK (WebFetch) | Contact example (email or postal or both), over-strict vs over-loose modeling, union redesign, helper functions returning option, update across three cases, warning on unsafe `.Value`, benefits (rule documented, compile-time breaks on rule change). The extraction did NOT contain the email-verified-flags example, so that one is presented as own illustration |
