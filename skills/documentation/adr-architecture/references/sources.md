# Sources — ADR Architecture

Every URL below was re-checked on 2026-11-27 (Last verified 2026-11-27). Fetched with WebFetch (Firecrawl had no credits); a small model summarized each page, so quotes are not verbatim.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions | 200 | Motivation, significance criteria, five parts and style rules, numbering, superseding, compounding effect, short anecdotal trial. |
| https://adr.github.io/ | 200 | Definitions of AD, ASR, ADR, decision log; credits Nygard; mentions a seven-template comparison. Does not itself describe MADR or the Y-statement. |
| https://adr.github.io/adr-templates/ (added) | 200 | MADR and Nygard summaries, Y-statement short and long forms, ISO/IEC/IEEE 42010 Annex A note. |
| https://adr.github.io/madr/ (added) | 200 | MADR sections, status values, file naming, version 4.0.0 (2024-09-17), MIT or CC0-1.0. |
| https://github.com/architecture-decision-record/architecture-decision-record | 200 | Naming, when to write, lifecycle and acceptance examples, mutability notes, review cadence, template list. Licence not stated on the page. |
| https://medium.com/olzzio/y-statements-10eb07b5a177 (added) | 403 | Nothing adopted; Y-statement info came from adr.github.io. |

## Reading limits

- Summaries came from a small model reading page text, not the raw pages.
- Henderson's licence was not confirmed; only facts and ideas are used, in the skill author's own words.
- Scripts or data files: this skill has none; nothing was run.
- Third-party skill text: none reused.

## Claims not adopted as fact

- The earlier draft's rule of thumb "if reversing takes more than a day it is significant": not in any source; dropped.
- The earlier draft's claim that adr.github.io integrates with Azure Well-Architected and AWS Prescriptive Guidance: not on the page read.
- The earlier draft's claim that engineers "frequently omitted" rejected alternatives in the Nygard format, motivating MADR: no source states it. The skill adds Considered Options as its own recommendation.
- The earlier draft's absolute "immutable once Accepted": Henderson reports dated amendments worked better in practice; the skill now forbids only changing the decision text.
- The exact wording of the Y-statement template: originating article unreachable; only the short and long forms are described.
- Any measured benefit of ADRs: Nygard's experience is anecdotal.
