# Agent Memory Research Compared

Sources: https://arxiv.org/abs/2310.08560 · https://arxiv.org/abs/2304.03442 · https://arxiv.org/abs/2303.11366 · https://docs.letta.com/configuration/memory · Last verified 2026-11-27

What published systems do about agent memory, and which parts a plain coding-agent session convention should (and should not) take. Facts are from the pages read; the "take / leave" column is this skill's judgment.

## MemGPT (arXiv 2310.08560, Packer et al., 2023)

- **Idea:** manage the limited context window like an operating system manages memory: a small fast tier inside the window, larger slow tiers outside, with the model moving data between them through function calls.
- **Tiers (from the paper's HTML):** main context holds read-only system instructions, a fixed-size read/write working context (key facts, preferences) and a rolling message queue starting with a recursive summary of evicted messages; external context has recall storage (full message history) and archival storage (arbitrary text), both explicitly retrieved.
- **Memory pressure:** when prompt tokens pass a warning threshold (example given: 70% of the window, with eviction at 100%; the paper presents these as examples, not fixed values), the system warns the model so it can save important content before messages are evicted at the flush threshold.
- **Take:** a small writable fixed-size "working context" is the hot channel; the warning-then-save behavior is the model for wrapping up **before** a likely compaction.
- **Leave:** automatic tier management needs an engine; a convention for files should stay simple.

## Generative Agents (arXiv 2304.03442, Park et al., 2023)

- **Idea:** store all experiences in a natural-language memory stream; retrieve by a score; periodically synthesize reflections.
- **Retrieval:** memories are ranked by recency (exponential decay, factor 0.995 per game hour since last retrieval), importance (an integer 1 to 10 assigned by the model at creation) and relevance (embedding cosine similarity to the query), each min-max scaled and equally weighted.
- **Reflection:** triggered when recent importance sums past a threshold (150 in the paper, about two or three times a day); the model is given the 100 most recent records, asks itself 3 high-level questions, retrieves evidence and stores insights that cite their source memories, forming trees from observations up to abstractions.
- **Take:** reflections that **cite their evidence** is the same discipline as "a lesson carries the incident". The recency factor is the seed of staleness handling, developed in `memory-hygiene`.
- **Leave:** a full memory stream plus embedding retrieval is a research system for simulation, not a session convention; importance scores assigned by the model at write time are not reliable enough to gate what a coding agent keeps.

## Reflexion (arXiv 2303.11366, Shinn et al., 2023)

- **Idea:** agents improve through language feedback, not weight updates: after a failed attempt they write a verbal reflection and keep it in an episodic memory buffer used in later attempts.
- **Take:** the lessons channel is this pattern made durable across sessions: a failure becomes a short written rule, anchored to what happened.
- **Leave:** the paper's loop is within one task across trials with an external feedback signal; across sessions you also need to expire and verify lessons, which the paper does not address (inference).

## Letta (docs.letta.com/configuration/memory)

- **What the page says:** agent memory is a git-backed filesystem the agent can inspect and edit, shared across the agent's conversations; the agent writes durable lessons into it; users can add with a remember command and review stored content; a doctor command checks placement, duplication and prompt-token use; background "dreaming" subagents review recent conversations and consolidate lessons, optionally after a compaction; reorganization backs up the repository first; repositories have size limits and bulky data should stay outside memory with summaries and links inside.
- **Take:** version-controlled memory (history for free), periodic consolidation, backup before restructuring, and links instead of bulk.
- **Leave:** automatic background consolidation that applies changes without approval; the page itself notes it uses more tokens and does not ask for approval. For decisions and lessons this skill keeps a person in the loop.
- **Note:** the page I could read did not describe memory blocks or archival memory; I did not rely on those from this source.

## Anthropic: structured note-taking and compaction

Owned by `agent-skills-context-engineering` (`references/long-horizon-context-strategies.md`). The one idea used here: notes written outside the window and read back later give persistent memory at low overhead, so write them before a compaction, not after.

## Common pattern across sources

1. A small, always-available core (working context, index, hot notes).
2. Larger stores fetched on demand.
3. A deliberate write step when pressure or a milestone arrives.
4. Consolidation that turns raw events into short, evidence-backed statements.

What none of the pages read here provides is a trust mechanism for stored claims over time; that gap is the subject of `memory-hygiene`.

## How an agent should apply this

- Keep a small writable hot block and save to it **before** a compaction, not after.
- Write lessons as reflections: the rule plus the event that justifies it.
- Prefer version-controlled, human-readable files so every change is inspectable.
- Do not adopt automatic consolidation that rewrites memory without review; propose, then let a person confirm.
- Treat research numbers (thresholds, decay factors) as the papers' settings, not as values to copy.
