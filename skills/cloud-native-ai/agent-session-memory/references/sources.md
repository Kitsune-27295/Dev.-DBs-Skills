# Sources: Agent Session Memory

Every URL below was re-fetched during the 2026-11-27 rebuild (WebFetch; Firecrawl was unavailable). Earlier authoring pass: 2026-11-24. Pages were read through a fetch tool that returns an extracted view; truncation is stated where it happened.

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Claude Code: How Claude remembers your project](https://code.claude.com/docs/en/memory) | 200 OK; large page, memory sections re-read via targeted extraction | Instruction file versus auto memory, four note types (user, feedback, project, reference), index of the first 200 lines or 25KB loaded at start with topic files on demand, one line per entry, machine-local storage, on by default in local sessions, `/memory`, project-root instruction file re-read after compaction, conversation-only instructions can be lost |
| [Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/research/effective-context-engineering-for-ai-agents) | 200 OK, dated 2025-09-29 | Context rot, compaction and its tuning, structured note-taking outside the window; detail owned by `agent-skills-context-engineering` |
| [MemGPT, arXiv 2310.08560](https://arxiv.org/abs/2310.08560) | 200 OK (abstract page): v1 2023-10-12, v2 2024-02-12 | Authors, dates, virtual context management idea |
| [MemGPT, HTML](https://arxiv.org/html/2310.08560) | 200 OK | Main versus external context, working context, FIFO queue with recursive summary, recall and archival storage, warning and flush thresholds given as examples (70% and 100%) |
| [Generative Agents, arXiv 2304.03442](https://arxiv.org/abs/2304.03442) | 200 OK (abstract page): v1 2023-04-07, v2 2023-08-06 | Authors, dates, abstract |
| [Generative Agents, HTML v2](https://arxiv.org/html/2304.03442v2) | 200 OK, truncated: 153,383 characters, the first 100,000 read | Memory stream, retrieval score (decay 0.995, importance 1 to 10, cosine relevance, equal weights), reflection threshold 150, three questions from 100 records, evidence-citing reflections |
| [Reflexion, arXiv 2303.11366](https://arxiv.org/abs/2303.11366) | 200 OK (abstract only): v1 2023-03-20, v4 2023-10-10 | Verbal reinforcement and an episodic memory buffer of reflections |
| [Letta docs home](https://docs.letta.com) | 200 OK | Locates the memory docs; says nothing on blocks or tiers |
| [Letta: Memory and dreaming](https://docs.letta.com/configuration/memory) | 200 OK | Git-backed memory filesystem, durable-lesson writes, doctor audit, background consolidation and its no-approval nature, backup before reorganizing, size limits per plan, links instead of bulk data |
| [Nygard: Documenting Architecture Decisions](https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions) | 200 OK, dated 2011-11-15 | Five-part record, proposed and accepted statuses, deprecated or superseded kept with a link, one to two pages, monotonic numbering never reused |
| [adr.github.io](https://adr.github.io) | 200 OK | ADR and decision-log framing; no status values or supersede guidance on the page |
| [ADR templates](https://adr.github.io/adr-templates/) | 200 OK | Lists MADR, Nygard and Y-statement templates; status values not defined |
| Private skills from an own vault template and an own private project, tied to a private engine | Read locally for ideas, no text reused | Idea sources only: read-first brief with capped channels, "missing tool means stop and say so", a closing routine ending in a 3-line report, an append-only handoff row with required fields. Engine-specific names abstracted away |
| Third-party generic "handoff" skill | Read locally for ideas, no text reused | Idea only: point to existing artifacts instead of duplicating them; redact sensitive data |

## Reading limits

- The fetch tool summarizes pages; paper numbers come from its extraction of the HTML and were not cross-checked against PDFs.
- The last 53,383 characters of the Generative Agents HTML were not read.
- Reflexion was read at abstract level only; Letta pages do not cover memory blocks or archival memory and nothing here depends on them.
- The validator snippet in `references/handoff-record-and-regrounding.md` is an own example and was not run.

## Claims not adopted as fact

- The caps in this skill (60 lines hot, 500 characters per entry, about 40 lessons, one page per decision) are the skill's own defaults. Only the 200 lines / 25KB index limit and the one-to-two-page ADR guidance come from sources.
- Thresholds and weights from the papers (70% warning, 150 importance, 0.995 decay) describe those systems, not recommendations.
- The "single-use handoff" and "required fields, no defaults" rules are this skill's design, informed by private idea sources, not a published standard.
- Letta's automatic "dreaming" is not adopted: the page describes no human approval step.
