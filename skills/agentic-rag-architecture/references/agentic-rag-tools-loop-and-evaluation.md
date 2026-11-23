# Agentic RAG: Retrieval Tools, Loop Control, Evaluation

Sources: https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/rag/rag-agentic · Last verified 2026-11-23

## Contents
- When agentic RAG pays off
- Retrieval as a tool
- Single vs multiple tools
- Controlling the loop
- Evaluation dimensions
- Design considerations and numbers
- How an agent should apply this

## When agentic RAG pays off
Five triggers: multistep reasoning (SKUs from catalog, then recall lookup per SKU), dynamic source selection (market API vs earnings index vs filings store), query decomposition (compare two regions' SLAs = two lookups plus compare), iterative refinement (first pass insufficient, retry with new terms or filters), and retrieval plus action (read order history, then initiate a return). If one search against one index resolves the query, standard RAG wins: each reasoning step adds latency, tokens and complexity. The model acts as reasoning engine in a ReAct-style loop: emit a function call, runtime executes, model decides to call again or answer. Components: agent (instructions + model + tools), tools (at least one retrieval), reasoning loop.

## Retrieval as a tool
- **Description:** be specific about the data source ("search the HR policy base for benefits, leave, compliance" beats "search documents").
- **Parameters:** typed and described: `query` required, `top_k` default 5, optional metadata `filter`.
- **Return schema:** say what comes back (chunks with scores, or structured fields).
- **Implementation:** wrap your already-tuned search (hybrid, rerank, filters) in a function; return the top N with metadata (title, date, doc id, score) so the agent can judge quality and cite; start at 3-5 results per call; expose filters (date, category, product line) as parameters.
- **Built-ins vs custom:** managed file search or search-index tools for zero-code retrieval; custom function tools when you must query several stores, preprocess queries, rerank, or call non-search APIs.

## Single vs multiple tools
| Approach | Use when | Note |
|---|---|---|
| Single retrieval tool | one index, uniform queries | least routing burden |
| Multiple specialized tools | different indexes, sources or strategies | keep total tools **below 20** to preserve accuracy (the page's figure); this skill's own 3-7 heuristic is stricter |

## Controlling the loop
- Cap tool calls per request, typically 5-10; non-convergence means human help or a different approach.
- Track cumulative tokens per request and set budget thresholds.
- Put stop rules in the instructions, e.g. synthesise after two relevant sources; do not search more than three times for the same sub-question.
- Provide fallback behavior and timeouts when the agent cannot resolve.

## Evaluation dimensions (beyond standard RAG metrics)
1. **Tool-selection accuracy:** labeled queries with expected tools; low score means rewrite descriptions.
2. **Retrieval efficiency:** calls per request; many calls on easy questions point to poor descriptions, too few results per call, or an over-cautious prompt.
3. **End-to-end latency:** break down model reasoning, tool execution, result processing.
4. **Cost per request:** all model calls plus search calls, compared with a standard-RAG baseline.

## Design considerations and numbers
Illustrative figures from the page: a one-search standard request might take 2-3 s; an agentic one with 3-5 tool calls 8-15 s. Reliability risks: bad tool choices, loops, no answer, so add iteration limits, timeouts, fallbacks. Observability: log every tool call, parameters, results and the agent's reading of them. Security: each tool is an attack surface; validate and sanitize parameters, least-privilege data access, never put credentials in tool output.

```
loop(max=6):
    step = model(plan, history)
    if step.is_answer: break
    obs = run_tool(step.tool, validate(step.args))   # least privilege
    history += summarize(obs, max_tokens=800)
else: escalate_or_fallback()
```

## How an agent should apply this
- Prove that a fixed pipeline fails (decomposition, multi-source) on real queries before adding the loop.
- Write tool descriptions with source scope and examples; return metadata with every chunk.
- Set iteration, token and time caps up front; log each hop.
- Measure the four dimensions against a standard-RAG baseline and keep the agentic path only if quality gain justifies latency and cost.
- Wrap existing hybrid+rerank search as the tool instead of rebuilding retrieval.
