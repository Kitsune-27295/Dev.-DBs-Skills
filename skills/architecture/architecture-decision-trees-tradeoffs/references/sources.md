# Sources for the architecture-decision-trees-tradeoffs skill

Every URL below was re-fetched on 2026-11-27 with a page-reading tool (summaries, not raw text). Statements are in this pack's own words.

| # | Source | Retrieved status | What the skill takes from it |
|---|---|---|---|
| 1 | https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/ | 200, read (page updated 2026-11) | Styles as constraints, the six-style table, microservice constraint example, selection advice, four cross-cutting challenges. |
| 2 | https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/technology-choices-overview | 200, read | Decision categories (compute, containers, hybrid, identity, storage, data stores, analytics, AI/ML, networking, integration, messaging, IoT) and AWS/GCP-to-Azure maps. |
| 3 | https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/compute-decision-tree | 200, read (page updated 2026-11) | Migrate versus build-new flowchart, lift and shift versus cloud optimized, hosting-model spectrum, tables for nodes, networking, team skills, scale limits, single-region platforms. |
| 4 | https://developertoarchitect.com/resources.html | 200, read | Characteristics worksheet, styles worksheet (star chart), patterns cross-reference, ADL; 20-minute rule is linked, not defined. |
| 5 | https://nealford.com/katas/ | 404 on 2026-11-27 (and its about page) | Nothing adopted from it now. |
| 6 | https://www.architecturalkatas.com/ (added 2026-11-27) | 200, read | Kata origin with Ted Neward, rationale, moderator and lead pages. |
| 7 | https://github.com/pkardas/notes/blob/master/books/fundamentals-of-architecture.md | 200, read twice with targeted questions | First law, characteristic criteria, quantum, fitness function, entity trap, stamp coupling, fallacies, decision anti-patterns, ADR sections, risk storming, sinkhole, service-based 4-12, SOA verdict. Third-party study notes, secondary. |

## Reading limits
- Fetch tool summaries are paraphrases of long pages; the Azure tables were read in full for the compute page only.
- Source 7 is a reader's notes, not the book. Its quotes are the notes' wording.
- Azure numbers are true on the read date; quotas change.
- No scripts or data files in this skill; nothing to run.

## Claims not adopted as fact
- "Second Law: why is more important than how": the notes as fetched attach a different sentence to the second law, so the skill keeps only "why over how" as a lesson.
- The Richards and Ford star ratings and the list of styles on the styles worksheet: the chart itself was not read.
- Kata group size (3-5), several groups per session, moderator draws a kata, peer voting: came from the dead katas page or the earlier notes read; not re-confirmed.
- Connascence kind ranking, quantum-and-shared-database rule, plug-in quantum, granularity advice, stamp-coupling mitigations, the 1 GB/s arithmetic, the notes' characteristic item lists and driver mapping, cache-type trade-offs, data-loss mitigations, correlation-ID advice and the risk-matrix scoring: not re-found in the 2026-11-27 pass; removed or marked as not re-read.
- The "10k+ users" figure for space-based architecture: unclear in the notes; removed.
- The 8 fallacies and "synchronous by default, asynchronous when necessary" are practitioner heuristics from a secondary source.
