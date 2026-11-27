# Sources — Memory Hygiene

Every URL below was re-fetched on 2026-11-27 (first checked 2026-11-24). Status is what the fetch tool returned.

Pages were read with a fetch tool that returns an extracted, summarized view of each page; where a page was truncated or partly unreadable this is stated.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [From Model Scaling to System Scaling: Scaling the Harness in Agentic AI, arXiv 2605.26112](https://arxiv.org/abs/2605.26112) | 200 OK (abstract page, re-read 2026-11-27). Paper verified to exist: single author Shangding Gu, submitted 25 May 2026, cs.AI / cs.LG | Existence, title, author, date; abstract names trustworthy memory as one of three bottlenecks and memory hygiene as a benchmark dimension. |
| [Same paper, HTML version](https://arxiv.org/html/2605.26112) | 200 OK (extracted view, 2026-11-27); section 4.2 statements re-confirmed (trust not storage; stale-but-confident ranking; staleness penalty against time of last verification; trust as a runtime decision; retrieved content as a hypothesis). "First-class confidence and recency fields" is section 3.1 and describes one reference harness; "inspectable traces" for memory writes is section 5.3. Neither is in 4.2. | Section 4.2 Trustworthy Memory: trust rather than storage as the hard problem; stale memory still ranks high; staleness penalty against time of last verification; "make trust a runtime decision"; retrieved content as a hypothesis to re-check; sections 3.1, 3.2, 5.2, 5.3 on first-class confidence and recency fields, drift, longitudinal evaluation and auditable memory writes. |
| [Same paper, PDF](https://arxiv.org/pdf/2605.26112) | 200 OK (2026-11-27), body still unreadable (compressed streams); only the section numbering recovered | Nothing beyond the outline; not relied on. |
| [Claude Code: How Claude remembers your project](https://code.claude.com/docs/en/memory) | 200 OK (2026-11-27; page large, read through targeted searches of the saved text) | Auto-memory note types, machine-local plain files, index (`MEMORY.md`) loaded at session start up to 200 lines or 25 KB, near-limit reminders, `/doctor prompt-audit` for instruction files, advice to remove outdated or conflicting instructions periodically, conversation-only instructions lost after compaction. |
| [Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/research/effective-context-engineering-for-ai-agents) | 200 OK (2026-11-27) | Context rot and finite attention budget; notes outside the window; just-in-time retrieval. |
| [Generative Agents, HTML v2, arXiv 2304.03442](https://arxiv.org/html/2304.03442v2) | 200 OK, truncated (first 100,000 of 153,383 characters read, 2026-11-27) | Retrieval scoring with equal-weight recency (exponential decay, factor 0.995 per game hour since last retrieval), importance and relevance; reflections citing evidence. |
| [Letta: memory configuration](https://docs.letta.com/configuration/memory) | 200 OK (2026-11-27); page now describes "dreaming" (`/sleeptime`) | Background consolidation by subagents, a review option that does not ask the user, backup of the repository before restructuring, `/doctor` audit of memory placement and duplication. |
| [Nygard: Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | 200 OK (2026-11-27) | Keep a reversed decision, mark superseded or deprecated, link the replacement; one to two pages. |
| [Architecture Decision Record repository (examples and guidance)](https://github.com/joelparkerhenderson/architecture-decision-record) | 200 OK (2026-11-27) | Immutability principle (amend or supersede with a new record), plus its note that some teams found dated in-place updates worked better; no statement about deleting. |
| [adr.github.io](https://adr.github.io) | 200 OK (2026-11-27) | ADR concept and decision log; no status or supersede guidance on the page. |
| [ADR templates](https://adr.github.io/adr-templates/) | 200 OK (2026-11-27) | Nygard, MADR, Y-statement templates; status listed as a field, values not defined. |
| [AD practices](https://adr.github.io/ad-practices/) | 200 OK (2026-11-27) | Definition of Done and review-plan criteria for decisions; nothing on immutability or superseding. |
| Third-party skill named "memory-hygiene" from a markdown knowledge-base project (MIT license visible) | Read locally for ideas, no text reused | Idea source: a periodic trust sweep with two buckets of claims, cheap read-only checks, per-entry stamps, propose-archive-never-delete, a time box per entry, a single sweep report with a scorecard and trend. That skill attributes its approach to the paper above; the paper was checked and the attribution held for the passages quoted in the reference files (trust as a runtime decision, last-verification time). The paper does not appear to prescribe the checks, stamps or report format; those are the idea source's and this skill's own. |

## Reading limits

- Paper content comes from an extracted HTML view, not a direct reading of the PDF; quotes are limited to short fragments and numbers were not cross-checked.
- The Generative Agents page was read in its first two thirds only.
- The memory page was read through searches of the saved text, not line by line.
- No scripts or data files in this skill; nothing left unverified on that front.
- The ADR pages read do not define status values or give supersede guidance; those come from Nygard's post and the repository page.

## Claims not adopted as fact

- Monthly cadence, the 30-day staleness default, the one-minute per-entry budget and the confidence scale are conventions of this skill (and of the idea source), not published figures.
- The paper's benchmark proposals and its reference harness are not adopted or evaluated here.
- Any statement in the idea source about specific tools, paths or folders is not reproduced.
- The claim that `/doctor prompt-audit` does not cover auto-memory entries is an inference from the page's description (it names instruction files only), not a stated limitation.
