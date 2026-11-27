# Agent-Computer Interface: Tool Design

Sources: https://www.anthropic.com/research/building-effective-agents · Last verified 2026-11-27

The pattern table (chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer), the agent loop and the framework caution are owned by `model-effort-routing` (`references/workflow-vs-agent-patterns.md`). This file keeps only the tool-interface part that RAG and agent builders apply when writing tool signatures.

## What the source says

Anthropic's guide (dated 2024-12-19; the page now carries a note that much tooling has changed since) treats the interface between model and tools as an engineering surface to prompt-engineer as carefully as a human UI.

- **Format choice.** Give the model enough room to think before it commits to output; prefer formats close to text common on the internet; avoid formatting overhead. Its two examples: a diff forces the model to know line counts in the chunk header ahead of time, and code inside JSON needs extra escaping of newlines and quotes.
- **Write the tool like a function for a junior colleague.** The name and parameters should make usage obvious; include example usage, edge cases, input boundaries and what separates it from similar tools. Test with many inputs and iterate.
- **Poka-yoke.** Change the arguments so mistakes are harder. Cited example: once the team required absolute file paths, the errors that appeared after the agent changed directories stopped.

## Own illustration (not from the source)

```python
def search_kb(query: str, source: Literal["policies", "runbooks", "orders"],
              top_k: int = 5) -> list[Chunk]:
    """Search ONE source. Use source='orders' only with an order id in query."""
```

An enum for the source and a docstring that states when not to use it remove two classes of misuse. Return concise, actionable errors and cap output size with pagination or filters: these two are this skill's heuristics, not claims from the page.

## How an agent should apply this

- Rewrite tool signatures (enums, absolute identifiers, examples) whenever traces show repeated misuse of a tool.
- Choose argument and output formats the model produces cheaply; avoid line-number diffs and code escaped inside JSON.
- State in each description what the tool does, when to use it, when not to, and what it returns. Retrieval-specific description rules: `references/agentic-rag-tools-loop-and-evaluation.md`.
- Read any framework's raw prompts before adopting it.
