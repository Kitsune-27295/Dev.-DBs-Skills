---
name: agentic-rag-architecture
description: Use when designing, reviewing, or evaluating an AI Agent, LLM Workflow, or Retrieval-Augmented Generation (Standard RAG vs Agentic RAG) system — choosing the minimum complexity tier (Direct Call, Deterministic Workflow, Single Agent with Tools, Multi-Agent Orchestration), designing tool contracts (ACI), hybrid indexing/chunking pipelines, loop guardrails, and scientific RAG/Agent evaluation. Synthesizes Anthropic and Microsoft Azure AI Architecture guidelines.
---

# Agentic & RAG (Retrieval-Augmented Generation) Architecture

One idea: **start with the lowest level of complexity that reliably solves the problem** — a single augmented LLM call or a deterministic **Workflow** before an autonomous **Agent**, and **Standard RAG** before **Agentic RAG** — escalating to dynamic tool-calling loops or multi-agent orchestration only when multistep reasoning, dynamic source selection, or query decomposition provably earns the extra latency, token cost, and failure modes. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Anthropic & Microsoft Azure AI Architecture)

| Term | Meaning | Test sentence |
|---|---|---|
| Augmented LLM | the foundational building block: an LLM equipped with retrieval, tools, and memory | "every workflow and agent is composed of augmented LLM calls" |
| Workflow vs. Agent (Anthropic) | **Workflow**: LLMs and tools are orchestrated through **predefined, deterministic code paths**; **Agent**: the LLM **dynamically directs its own process and tool usage** in a loop | "if you know the exact sequence of steps in advance, write a Workflow in code, not an autonomous Agent" |
| Standard RAG | a fixed pipeline (`Query -> Retrieve top-N from index -> Augment prompt -> Generate grounded answer with citations`) | "fast, predictable, 1 retrieval pass + 1 LLM generation call" |
| Agentic RAG | the agent treats **retrieval as one or more callable tools**, dynamically decomposing complex questions, selecting across heterogeneous sources, evaluating intermediate results, and re-querying if gaps remain | "handles multi-hop questions across multiple indexes/APIs at higher latency and cost" |
| Agent-Computer Interface (ACI) | the ergonomics of tool names, descriptions, parameter schemas, and error messages presented to the model | "invest as much engineering effort in ACI tool design as in human UI/UX" |
| Hybrid Search Index | combining **Vector search** (semantic similarity via embeddings), **Full-Text keyword search** (BM25 exact terms/SKUs/acronyms), and **Semantic Reranking** | "consistently outperforms vector-only or keyword-only retrieval in enterprise RAG" |

## The Complexity Escalation Ladder (Check before building)

Always climb one rung at a time and stop at the first rung that meets your evaluation metrics:

1. **Level 0 — Direct Model Call + In-Context Prompting:** Single LLM call with clear instructions and few-shot examples. Zero tools, zero agent loop.
2. **Level 1 — Standard RAG (Deterministic Retrieval Pipeline):** Fixed retrieve-augment-generate flow over a hybrid index when the query maps cleanly to a single search pass.
3. **Level 2 — Deterministic LLM Workflows (Anthropic's 5 Patterns):**
   - **Prompt Chaining:** Sequential steps ($A \to \text{code gate} \to B$) where code checks intermediate output programmatically.
   - **Routing:** Classify input intent and route to a specialized prompt, tool, or smaller/faster model.
   - **Parallelization:** **Sectioning** (independent subtasks run in parallel) or **Voting** (multiple passes aggregated for high-stakes accuracy).
   - **Orchestrator-Workers:** Central LLM breaks an unpredictable task into dynamic subtasks (e.g., files to edit, sources to search) and synthesizes worker results.
   - **Evaluator-Optimizer:** One LLM generates a draft while an evaluator LLM critiques against a rubric in a bounded loop.
4. **Level 3 — Single Agent with Tools (including Agentic RAG):** One model reasoning in a bounded tool-call loop (`Reason -> Call Tool -> Observe -> Repeat or Answer`). This is the right default for open-ended single-domain enterprise assistants.
5. **Level 4 — Multi-Agent Orchestration (Azure's 5 Topologies):** Only when a single agent suffers from tool overload (>15-20 tools), excessive prompt complexity, or strict per-agent security boundaries:
   - **Sequential** (pipeline of specialist agents), **Concurrent** (fan-out/fan-in perspectives), **Group Chat / Maker-Checker** (collaborative validation with a thread manager), **Handoff** (triage transfers control to a specialist), or **Magentic** (dynamic task ledger built and refined on the fly for open-ended problems).

## Core architectural rules and invariants

1. **Design Retrieval as an explicit, well-scoped Tool in Agentic RAG:**
   - Write crystal-clear tool descriptions specifying **what data source** the tool queries, **when to use it** (and when *not* to), and **what format** it returns.
   - Use **one retrieval tool** when querying a single unified index; use **separate retrieval tools per distinct data domain** (e.g., `search_product_catalog`, `search_regulatory_recalls`, `query_live_order_status_api`) so the agent selects only relevant sources.
2. **Engineer the Agent-Computer Interface (ACI) against model mistakes (Poka-Yoke):**
   - Give the model enough tokens to think before acting.
   - Use natural formats close to training data (Markdown, clean JSON without double-escaped strings; absolute paths instead of relative paths; full block replacements or anchored edits instead of raw line-number diffs).
   - Return actionable, concise tool error messages (never raw 200-line stack traces) and cap tool output size with pagination/filtering so one tool result does not blow up the context window.
3. **Build the RAG Data Ingestion Pipeline as a rigorous `pipes-and-filters-pattern`:**
   - **Extract & Parse:** Preserve document structure (headings, tables, lists, metadata).
   - **Chunk by semantic/structural boundaries:** Keep tables and code blocks intact; attach parent-section context and metadata (`source_uri`, `updated_at`, `tenant_id`, `acl_roles`) to every chunk.
   - **Enrich & Embed:** Clean noise, generate summaries/keywords, and compute embeddings using the same embedding model at index and query time.
   - **Index for Hybrid Search:** Configure keyword (BM25) + vector fields + metadata filter fields.
4. **Enforce Document-Level Security and Tenant Isolation at the Search Index Query:** Never rely on the LLM prompt ("do not show data from other users") to enforce access control! Pass the authenticated caller's `tenant_id` and security principal claims as **hard pre-filters on the search index / database query** inside the retrieval tool (`never-trust-the-client`, `security-audit`).
5. **Bound every Agentic Loop with hard guardrails:** Always enforce `maxIterations` / `maxToolCalls`, per-tool timeouts, token/cost budgets per request, and human-in-the-loop confirmation gates before any consequential, external, or destructive tool action.

## Evaluation and verification strategy (Scientific RAG & Agent Evals)

| Phase / Metric | What it verifies | How to measure |
|---|---|---|
| **1. Retrieval Evaluation** (before touching the LLM prompt) | Recall@K, Precision@K, NDCG — did the index return the right grounding chunks? | Curated golden query-to-chunk test set across representative and adversarial queries |
| **2. Tool Selection Accuracy** (Agentic RAG) | Did the agent pick the right retrieval tool(s) and form valid query arguments without redundant calls? | Trace assertions on `expected_tools_called` and **Retrieval Efficiency** (calls per query) |
| **3. Groundedness & Citation Faithfulness** | Is every claim in the answer supported by the retrieved context (zero hallucination), with accurate source citations? | Automated evaluator / rubric check comparing answer statements strictly against retrieved chunks |
| **4. End-to-End Latency & Cost per Request** | P50/P95 latency and total input/output tokens across all reasoning turns | Production OpenTelemetry tracing per agent turn and tool invocation |

## Mistakes to catch

- **Using Multi-Agent Orchestration or Agentic RAG where Standard RAG or a Prompt Chain suffices:** Paying 3-5x latency and token cost for an agent to "decide" to run the exact same search query on every request.
- **Framework Opacity Trap (Anthropic):** Adopting heavy multi-layered agent frameworks without reading the underlying prompts and tool schemas they send to the model. Start with direct SDK calls (20 lines of code); if you use a framework, inspect the raw model requests.
- **Dumping 50 fine-grained REST endpoints as 50 raw Agent Tools:** Overwhelming the model's tool selector. Consolidate related low-level calls into 3-7 high-signal, task-oriented tools with clear ACI documentation.
- **Vector-Only Search for exact identifiers:** Using pure embedding similarity when users search for exact SKU codes, error codes, legal clauses, or names — always use **Hybrid Search (BM25 + Vector + Reranker)**.
- **Unbounded Agent Loops and Context Bloat:** Letting an agent retry a failing search 20 times or inject 100 KB of raw HTML/JSON into its conversation history until latency, cost, and accuracy collapse.
