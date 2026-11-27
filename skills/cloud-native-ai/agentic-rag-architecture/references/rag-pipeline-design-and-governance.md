# RAG Pipeline Design, Evaluation Phases and Governance

Sources: https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/rag/rag-solution-design-and-evaluation-guide · https://learn.microsoft.com/en-us/azure/foundry/concepts/retrieval-augmented-generation · Last verified 2026-11-23

The first page is the intro of a series; the per-phase sub-articles (chunking, embeddings, etc.) were not read, so only the intro's phase list is used here.

## Contents
- Two flows
- Phase-by-phase design questions
- Index and search modes
- Agentic retrieval inside Foundry
- Security, cost, known limits
- How an agent should apply this

## Two flows
**Application flow:** user query -> orchestrator -> chooses and runs a search -> packages top N results plus query into a prompt -> model -> response. **Data pipeline flow:** ingest (push or pull) -> per file: chunk (semantic pieces, ideally one idea each) -> enrich (title, summary, keywords as discrete fields) -> embed (chunk and any vector-searched fields) -> persist in the index. In standard RAG the orchestrator follows a fixed sequence; the designer, not the runtime, decides whether to search, which index, and how many steps.

## Phase-by-phase design questions
| Phase | Decide / do |
|---|---|
| Preparation | define domain and business requirements; collect representative media; collect test queries, add synthetic queries and queries the corpus does not cover |
| Chunking | cost of chunking across the collection; what to ignore vs capture; approach (sentence, fixed size, custom, LLM-augmented, layout analysis, ML models) chosen by how structured the file is |
| Enrichment | clean chunks (remove differences that do not change meaning, which helps closeness matching); augment with metadata fields |
| Embedding | model choice strongly affects relevance; evaluate by visualizing embeddings and computing distances |
| Retrieval | index and vector config; vector, full-text, hybrid, or manual multiple searches; split queries into subqueries; filters; evaluate searches |
| End-to-end | model metrics: groundedness, completeness, utilization, relevancy; document hyperparameters and results; aggregate and visualize across queries |

Method rule: evaluate each step independently to optimize it, but remember customers experience only the end result; set acceptance criteria per step only after understanding the whole chain. Microsoft points to an open-source "RAG experiment accelerator" for running many configurations.

## Index and search modes
An index organizes content for fast retrieval: keyword, semantic, vector, or hybrid (keyword + vector, optionally semantic ranking). Store citation fields (title, URL, file name) so answers can cite.

## Agentic retrieval inside Foundry
Evolution of classic single-query retrieval: a model decomposes a complex input into focused subqueries, runs them in parallel, returns structured grounding data. Claimed advantages: context-aware planning from conversation history, parallel execution (lower latency, broader coverage), structured output with citations and execution metadata, built-in semantic ranking, optional LLM-written answer or raw verbatim passages. Choice guide: RAG for private or changing knowledge; fine-tuning to change behavior or style, not to add fresh facts; agent tools when retrieval is one tool among several.

## Security, cost, limits
- Enforce document-level access control **at retrieval time** (security filters), never only in the prompt.
- Prefer managed identity/Entra ID over API keys in production.
- Treat retrieved text as untrusted: prompt-injection can ride in on documents.
- Costs: retrieval round trips, embeddings at index and often query time, extra input tokens.
- Known failure chain: poor chunking or index strategy -> irrelevant passages -> wrong answers even when "grounded"; hallucination can persist despite context (mitigate with citations and instructions to stay within retrieved text); token budgets overflow (filter, rank, summarize passages).

```
# retrieval step with ACL (own sketch)
hits = index.search(q, mode="hybrid", top=20, filter=f"acl/any(g: g eq '{user.group}')")
ctx  = rerank(q, hits)[:5]
```

## How an agent should apply this
- Build a labeled query set (including out-of-corpus queries) before tuning chunking or embeddings.
- Change one phase at a time and score retrieval (recall, precision) before judging generation.
- Put access filters in the index query; test with a user who must not see a document.
- Store titles/URLs/ids per chunk so every claim can be cited.
- Escalate to agentic retrieval only when query decomposition or multi-source routing demonstrably fails the fixed pipeline.
