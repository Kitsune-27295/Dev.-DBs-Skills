# Sources: Agentic and RAG Architecture

Every URL below was re-fetched during the 2026-11-27 rebuild (WebFetch; Firecrawl was unavailable).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [Anthropic, Building effective agents](https://www.anthropic.com/research/building-effective-agents) | 200 OK, dated 2024-12-19; page now notes that much tooling has changed since | Workflows versus agents, augmented LLM, the five workflow patterns (owned elsewhere), start-simple and framework advice, stopping conditions, ACI format guidance, absolute-path poka-yoke example |
| [Microsoft, AI agent orchestration patterns](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns) | 200 OK, page dated 2026-02-12, updated 2026-09-21 | Three-level complexity table, the five orchestration patterns with use and avoid rules, group chat limited to three or fewer agents, context, state, reliability, security, cost and pitfalls |
| [Microsoft, Develop an agentic RAG solution](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/rag/rag-agentic) | 200 OK, dated 2026-06-23 | Five reasons for agentic RAG, retrieval-tool design, tool count below 20, 5 to 10 iteration cap, four evaluation dimensions, illustrative 2 to 3 s versus 8 to 15 s latency |
| [Microsoft, Design and develop a RAG solution](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/rag/rag-solution-design-and-evaluation-guide) | 200 OK, dated 2025-12-17 | The two flows, phase-by-phase design questions, evaluation metric names, structured-evaluation rule |
| [Microsoft Foundry, RAG and indexes](https://learn.microsoft.com/en-us/azure/foundry/concepts/retrieval-augmented-generation) | 200 OK, dated 2026-08-21 | Index modes, agentic retrieval (parallel subqueries), access control at retrieval time, Entra ID over API keys, untrusted retrieved content, cost and limitation notes |

## Reading limits

- Microsoft's per-phase sub-articles (chunking, enrichment, embeddings, information retrieval, evaluation) were not read; only the intro's phase list is used.
- The Anthropic page was read through a summarizing fetch tool; quotations are from its extract.
- The Azure orchestration page is long; its use and avoid lists and cross-cutting sections were read, the code and image captions were not.
- Reference files contain no scripts or data files.

## Claims not adopted as fact

- "Hybrid search consistently outperforms vector-only or keyword-only retrieval": not stated on any page read. Kept only as the skill's inference for exact identifiers.
- "More than 15 to 20 tools" as a threshold for multi-agent: not in the sources. The page says keep retrieval tools below 20; the 3 to 7 range is this skill's heuristic.
- "3 to 5 times the latency and token cost" of an agent: not in the sources; replaced by Microsoft's illustrative 2 to 3 s versus 8 to 15 s.
- "A 20-line SDK call" as Anthropic's advice: the page says many patterns take a few lines and gives no count.
- "Full block replacements or anchored edits" as Anthropic's tool-format advice: not on the page; only the diff and JSON-escaping examples are.
- "Same embedding model at index and query time": plausible general practice, not on the pages read.
- The five-rung ladder is this skill's synthesis, not a vendor taxonomy.
