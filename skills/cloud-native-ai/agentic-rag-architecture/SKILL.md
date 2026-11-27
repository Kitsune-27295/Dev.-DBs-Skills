---
name: agentic-rag-architecture
description: "Choose and design the smallest AI system that works for a task needing retrieval or tool use: a direct call, standard RAG, a deterministic workflow, one agent with retrieval tools (agentic RAG) or multi-agent orchestration. Covers when agentic RAG earns its latency and cost, retrieval exposed as a typed tool, an ingest pipeline with hybrid search, access control enforced in the index query, loop caps, and staged evaluation (retrieval, tool selection, groundedness, cost). Not for picking model tiers or delegation briefs (use `model-effort-routing`) or for running a team of agents (use `multi-agent-coordination`). Use when designing, reviewing or evaluating a RAG, agent or LLM-workflow architecture, or when deciding whether a RAG feature needs an agent at all."
---

# Agentic & RAG Architecture

One idea: **start at the lowest rung of complexity that meets your evaluation metrics**: one augmented call or a deterministic workflow before an agent, standard RAG before agentic RAG, one agent before several. Climb only when a failing evaluation shows the cheaper rung cannot do the job. Sources, retrieved statuses and unadopted claims: [references/sources.md](references/sources.md).

Boundaries (one owner per rule): the five Anthropic workflow patterns and the workflow-versus-agent distinction live in `model-effort-routing` (`references/workflow-vs-agent-patterns.md`); this skill uses them and does not restate them. Running a group of agents (board, roles, stall monitor) is `multi-agent-coordination`. Document-level security principles are `never-trust-the-client` and `security-audit`; stage-by-stage ingest design uses `pipes-and-filters-pattern`.

## 1. Vocabulary

| Term | Meaning |
|---|---|
| Augmented LLM | The base unit: a model with retrieval, tools and memory (Anthropic). Every workflow and agent is built from it. |
| Standard RAG | Fixed pipeline: query, search, build prompt, generate. The designer, not the runtime, decides whether to search, which index and how many steps (Microsoft). |
| Agentic RAG | The agent treats retrieval as a tool it can call, decompose queries, pick sources, judge results and re-query, in a ReAct-style loop (Microsoft). |
| ACI | Agent-computer interface: tool names, parameters, descriptions and error text as the model sees them. Worth as much design effort as a human UI (Anthropic). |
| Hybrid search | Keyword plus vector search, optionally with semantic ranking; one of the index modes the Microsoft guides list. |

## 2. The escalation ladder (this skill's synthesis)

Microsoft's own ladder has three levels (direct call, single agent with tools, multi-agent). The five rungs below split the middle using Anthropic's vocabulary; the split is this skill's choice, not a vendor taxonomy.

1. **Direct call** with a good prompt and examples. If prompting solves it, there is no agent.
2. **Standard RAG** when one search against one index resolves the query.
3. **Deterministic workflow** (chain, route, parallelize, orchestrator-workers, evaluator-optimizer: patterns in `model-effort-routing`) when the steps or categories are known in code.
4. **Single agent with tools, including agentic RAG.** Microsoft calls this often the right default for enterprise use and easier to debug than multi-agent; set iteration limits.
5. **Multi-agent orchestration** only when one agent fails from prompt complexity, tool overload or separate security boundaries. Pattern choice: [multi-agent orchestration selection](references/multi-agent-orchestration-selection.md).

**Agentic RAG pays off** for five reasons the Microsoft guide lists: multistep reasoning, dynamic source selection, query decomposition, iterative refinement, and retrieval combined with actions. If none applies, stay on rung 2. Every reasoning step adds latency, tokens and complexity; the guide's illustrative figures are 2 to 3 seconds for one search plus one generation against 8 to 15 seconds for three to five tool calls.

## 3. Rules

1. **Retrieval is a scoped tool.** Name the data source, say when to use it, type the parameters (`query`, `top_k`, filters), describe the return shape. One tool for one uniform index; one tool per distinct source or strategy otherwise. Keep total tools below 20 (Microsoft's figure); this skill's own, stricter heuristic is 3 to 7 task-oriented tools. Details: [agentic RAG tools, loop and evaluation](references/agentic-rag-tools-loop-and-evaluation.md).
2. **Design the ACI against model mistakes.** Pick formats cheap for the model, test tools with varied inputs, reshape arguments so errors are hard (poka-yoke). Details: [ACI tool design](references/agent-computer-interface-tool-design.md).
3. **Build ingest as a staged pipeline:** extract and parse, chunk, enrich, embed, index. Keep document structure, attach source and access metadata per chunk, store title and URL fields so answers can cite. Details and phase questions: [RAG pipeline design](references/rag-pipeline-design-and-governance.md).
4. **Enforce access in the index query.** Document-level security filters at retrieval time, never only in the prompt; treat retrieved text as untrusted input (prompt injection can ride in on documents).
5. **Use hybrid search where exact identifiers matter** (SKUs, error codes, clause numbers). The reason is lexical matching, which vector-only similarity does not guarantee; this is the skill's inference, not a measured claim from the pages read.
6. **Bound every loop:** cap tool calls per request (the guide calls 5 to 10 typical), budget tokens, set timeouts and a fallback, and gate consequential or destructive actions behind a human.
7. **Do not adopt a framework blind.** Anthropic advises starting with direct API calls and reading the prompts and responses any framework sends.

## 4. Evaluate in stages

| Stage | Question | Method |
|---|---|---|
| Retrieval | Did the index return the right chunks (recall, precision)? | Labeled query set, including queries the corpus does not cover |
| Tool selection | Right tool, valid arguments? | Queries with expected tool calls |
| Retrieval efficiency | Calls per request on easy queries | Trace counts |
| Groundedness | Are answer claims supported by the retrieved text? | Rubric or evaluator against the chunks |
| Latency and cost | Per-component latency; tokens and search calls per request, against a standard-RAG baseline | Tracing every reasoning step |

Evaluate each phase on its own to tune it, but accept the system on the end-to-end result, which is what users see. Keep the agentic path only if the quality gain over the baseline justifies its latency and cost.

## 5. Mistakes to catch

- Agentic RAG or multi-agent where standard RAG or a chain suffices (the same search run on every request).
- Dozens of fine-grained endpoints exposed as raw tools; consolidate into few task-oriented ones.
- Vector-only search for exact identifiers.
- Access control written as a prompt instruction.
- Unbounded retries and raw payloads in history until cost and accuracy collapse.
- Tuning chunking or prompts before any labeled query set exists.

## Quick Decision Checklist

- [ ] Did I stop at the lowest rung that meets the evaluation metrics?
- [ ] Do the steps need to be decided at runtime, or can code fix them?
- [ ] Does one of the five agentic-RAG reasons apply, with a measured failure of the fixed pipeline?
- [ ] Are retrieval tools scoped, typed, few, and do they return metadata for citation?
- [ ] Are access filters in the index query, tested with a user who must not see a document?
- [ ] Is every loop capped by calls, tokens, time and a fallback?
- [ ] Do I have a labeled query set and a standard-RAG baseline before tuning?

## Deep references

- [references/agent-computer-interface-tool-design.md](references/agent-computer-interface-tool-design.md): tool format and poka-yoke rules; read when writing or fixing tool signatures.
- [references/agentic-rag-tools-loop-and-evaluation.md](references/agentic-rag-tools-loop-and-evaluation.md): retrieval as a tool, loop control, evaluation dimensions; read when exposing retrieval to an agent.
- [references/rag-pipeline-design-and-governance.md](references/rag-pipeline-design-and-governance.md): ingest and retrieval phases, security, cost; read when designing or tuning the pipeline.
- [references/multi-agent-orchestration-selection.md](references/multi-agent-orchestration-selection.md): Microsoft's five orchestration patterns with use and avoid rules; read before adding a second agent.
- [references/trigger-evals.md](references/trigger-evals.md): should-trigger and near-miss prompts for the description.
- [references/sources.md](references/sources.md): every URL with retrieved status, reading limits, claims not adopted.
