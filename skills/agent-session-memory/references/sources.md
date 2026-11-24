# Sources — Agent Session Memory

Every URL below was checked during skill authoring (2026-11-24).

Pages were read with a fetch tool that returns an extracted, summarized view of each page; where a page was truncated or partly unreadable this is stated.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Claude Code: How Claude remembers your project](https://code.claude.com/docs/en/memory) | 200 OK (full page read, large; relevant sections re-read in full) | Instruction file vs auto memory, four auto-memory note types, index loaded at session start (first 200 lines or 25 KB) with detail in topic files, "one line per entry, merge or drop stale entries", machine-local storage, `/memory` for inspection, instructions given only in conversation can be lost after compaction, project instruction file re-read after compaction. |
| [Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/research/effective-context-engineering-for-ai-agents) | 200 OK | Context rot and finite attention budget, compaction (what it keeps, tune recall then precision, risk of over-aggressive compaction), structured note-taking outside the window, sub-agent summaries, just-in-time retrieval. |
| [MemGPT: Towards LLMs as Operating Systems, arXiv 2310.08560](https://arxiv.org/abs/2310.08560) | 200 OK (abstract) | Authors, date, virtual context management idea. |
| [MemGPT, HTML version](https://arxiv.org/html/2310.08560) | 200 OK | Main vs external context, working context, FIFO queue with recursive summary, recall and archival storage, memory-pressure warning and flush thresholds. |
| [Generative Agents, arXiv 2304.03442](https://arxiv.org/abs/2304.03442) | 200 OK (abstract) | Authors, date, abstract. |
| [Generative Agents, HTML v2](https://arxiv.org/html/2304.03442v2) | 200 OK, truncated (first 100,000 of 153,383 characters read) | Memory stream, recency/importance/relevance retrieval scoring, reflection trigger and cited-evidence reflection trees. |
| [Reflexion, arXiv 2303.11366](https://arxiv.org/abs/2303.11366) | 200 OK (abstract only) | Verbal reinforcement and episodic memory buffer of reflections; no mechanism details beyond the abstract were read. |
| [Letta docs home](https://docs.letta.com) | 200 OK | Memory docs location; did not describe memory blocks or tiers. |
| [Letta: memory configuration](https://docs.letta.com/configuration/memory) | 200 OK | Git-backed memory filesystem, durable-lesson writes, audit command, background consolidation ("dreaming") and its no-approval option, backup before reorganizing, size limits, links instead of bulk data. |
| [Nygard: Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | 200 OK | Five-part record, statuses proposed/accepted/deprecated/superseded, keep superseded records and link the replacement, one to two pages, monotonic numbering. |
| [adr.github.io](https://adr.github.io) | 200 OK | ADR concept and decision-log framing; status values and supersede guidance not on this page. |
| [ADR templates](https://adr.github.io/adr-templates/) | 200 OK | Nygard, MADR and Y-statement templates listed; no status-value definitions or supersede guidance on the page. |
| Private skills from an own vault template (session memory, wrap-up) and an own private project (session handoff), tied to a private engine | Read locally for ideas, no text reused | Idea sources only: a read-first brief with capped short entries in several channels, "missing tool means stop and say so", a closing routine ending in a 3-line report, and an append-only handoff row with required fields and no defaults. The engine-specific tool names and layout were abstracted away. |
| Third-party generic "handoff" skill (compact the conversation for another agent) | Read locally for ideas, no text reused | Idea only: point to existing artifacts instead of duplicating them and redact sensitive data. |

## Reading limits

- The fetch tool summarizes pages; numbers quoted from papers (thresholds, decay factors) come from that extraction and were not cross-checked against the PDFs.
- The Generative Agents HTML was read only in its first two thirds; claims about the memory stream, retrieval and reflection come from that part.
- Reflexion was read at abstract level only.
- The Letta page read does not cover memory blocks or archival memory; nothing here depends on them.

## Claims not adopted as fact

- The cap numbers in this skill (60 lines hot, 500 characters per entry, about 40 lessons, one page per decision) are the skill's own defaults, not figures from any source. Only the 200 lines / 25 KB index limit and the one-to-two-page ADR guidance come from sources.
- Thresholds and weights from the papers (70% warning, 150 importance, 0.995 decay) describe those systems, not recommendations.
- The "single-use handoff" and "required fields, no defaults" rules are the skill's design, informed by the private idea sources, not a published standard.
