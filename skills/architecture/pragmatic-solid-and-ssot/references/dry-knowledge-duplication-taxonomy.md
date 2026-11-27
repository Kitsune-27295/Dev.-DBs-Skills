# DRY as Knowledge Duplication: The Five Kinds and Their Remedies

Sources: https://media.pragprog.com/titles/tpp20/dry.pdf · Last verified 2026-11-23

The PDF is the excerpt "The Evils of Duplication" from *The Pragmatic Programmer*, 20th Anniversary Edition (Thomas and Hunt). It was read as extracted text (PDF text layer), not from a rendering.

## Definition and the acid test

The authors state DRY as: every piece of knowledge must have a single, unambiguous, authoritative representation within a system. They openly say the first edition explained it badly, so many readers took it to mean "do not copy-paste lines". They call that a tiny, trivial part of it. The acid test they give: when one facet of the system has to change, do you change it in several places and several formats (code plus docs, schema plus a struct that holds it)? If yes, it is not DRY. Their framing of why it matters: knowledge is unstable, and programmers are always in "maintenance mode", so every duplicate is a future contradiction. "It isn't a question of whether you'll remember: it's a question of when you'll forget" (paraphrase of the book's line).

## The kinds the chapter walks through

| Kind | Chapter example | Remedy given |
|---|---|---|
| Code | `print_balance` with copy-pasted negative-number handling, repeated field widths, repeated label format | Extract `format_amount`, then `print_line`/`report_line`; each fact (amount format, label format) lives once |
| Not-really-duplicate code | `validate_age` and `validate_quantity` with identical bodies | Leave alone: same code, different knowledge, "a coincidence, not a duplication" |
| Documentation | A comment restating the fee rules above the `fees` function | Rename to `calculate_account_fees` and let the code carry the rule; the comment only compensated for bad naming |
| Data | `Line` stores `start`, `end` and `length` | Make `length` computed; if cached for speed, hide it so only the class keeps it consistent |
| Representational | Your code mirrors an external API, schema, or error-code table | Mitigate, do not expect to remove: neutral API spec tooling, OpenAPI imports, generated containers from introspected schemas, or key/value maps plus a table-driven validator |
| Inter-developer | A state audit found 10,000+ programs, each with its own Social Security number validator | Communication, a "project librarian", a central place for utilities, reading each other's code; Tip 16: make it easier to reuse than to rewrite |

## Mechanics worth reusing

- **Localize deliberate violations.** When duplication is justified for performance (a cached derived value), confine it behind accessors so the outside world cannot see or break the invariant.
- **Uniform Access Principle (Meyer).** Services of a module should be reachable through one notation that does not reveal whether the value is stored or computed. Practical effect: you can later swap a stored field for a computed one (or the reverse) without touching callers.
- **Exposed data structures couple callers to the module's implementation**, so prefer accessor functions.
- **Implicit duplication hides in magic numbers.** The report example notes the separator width is tied to the amount width, yet is a different intent, so it is deliberately left separate. Ask "same intent or merely same number?" before unifying.

## Failure modes

- Merging coincidentally identical code (the age/quantity trap) and later splitting it with flag parameters.
- Treating DRY as a lint rule on token similarity, when the unit of analysis is a fact the business can change.
- Keeping explanatory comments that restate rules the code already expresses.
- Hand-copying external schemas instead of generating them, so every upstream change is a silent break.

## Decision rules

- Use when: two places must change together for the same business reason, or a doc/schema/type restates a rule that code owns.
- Avoid when: the only evidence is textual similarity; the two sites answer to different actors (see `references/sources.md` for the SRP link); or the duplication crosses a Bounded Context line (see `bounded-context-limits-on-sharing.md`).

## How an agent should apply this

- Before extracting, write one sentence naming the single fact being duplicated; if you cannot, it is not DRY.
- Search for representational duplication first (docs, schemas, DTOs, error tables, API clients) and generate or derive them from one source.
- Replace stored derived fields with computed ones, or confine the cache behind accessors.
- Delete comments that restate behavior; improve names instead.
- Leave `validateAge`-style lookalikes separate and note in review that this was a conscious decision.
