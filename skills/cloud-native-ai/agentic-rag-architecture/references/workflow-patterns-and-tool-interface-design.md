# Workflow Patterns and Tool (ACI) Design

Sources: https://www.anthropic.com/research/building-effective-agents · Last verified 2026-11-23

## Contents
- Workflows vs agents
- Five workflow patterns (when each fits)
- Agent loop and stopping
- Framework caution
- Tool interface design (ACI, poka-yoke)
- How an agent should apply this

## Workflows vs agents
Workflows run LLMs and tools along predefined code paths; agents let the LLM steer its own steps and tool use. Agentic designs trade latency and cost for flexibility, so start with the simplest thing: often one well-tuned call with retrieval and examples. The base unit is the augmented LLM (model plus retrieval, tools, memory) with a clear, documented interface; MCP is one way to attach third-party tools.

## Five workflow patterns
| Pattern | Shape | Use when | Typical cost |
|---|---|---|---|
| Prompt chaining | step N consumes step N-1, optional programmatic gates | task splits into fixed subtasks | latency for accuracy |
| Routing | classify input, dispatch to specialized path | categories are distinct and classification is reliable (LLM or classic classifier) | one extra call; can send easy queries to a small model |
| Parallelization | sectioning (independent subtasks) or voting (same task repeated) | speed, or several perspectives for confidence | more tokens |
| Orchestrator-workers | central LLM decomposes at runtime, workers execute, orchestrator synthesizes | subtasks unpredictable (edits across unknown files, multi-source search) | highest of the workflows |
| Evaluator-optimizer | generator plus critic loop | clear criteria and measurable gain from iteration | N rounds |

Distinction worth remembering: parallelization has subtasks fixed in code; orchestrator-workers decides them at runtime.

RAG mapping (own inference): a standard RAG pipeline is a chain with a retrieval step; query-type dispatch is routing; multi-index fan-out is sectioning; "is the evidence enough, search again?" is evaluator-optimizer.

## Agent loop and stopping
An agent plans, acts, reads environment feedback (tool result, code execution) each step, may pause for human input at checkpoints, and needs stopping conditions such as a maximum iteration count. Use for open-ended problems where steps cannot be predicted and the model's decisions are trusted. Expect higher cost and compounding errors; test in sandboxes with guardrails. Good fits: support (verifiable resolution, customer data plus actions) and coding (tests give feedback; humans still review fit).

## Framework caution
SDKs speed setup but hide prompts and responses, complicate debugging and invite needless complexity. Begin with direct API calls; if using a framework, understand what it sends. Three principles: simplicity, visible planning steps, a carefully engineered agent-computer interface.

## Tool interface design
- **Format choice:** pick formats that are cheap for the model: diffs force counting lines ahead of time; code embedded in JSON forces escaping. Leave room to reason before committing; favor formats common in online text.
- **Think like writing a function for a junior colleague:** obvious from name and parameters, include examples, edge cases, input boundaries, and distinguish similar tools. Test with many inputs and iterate.
- **Poka-yoke:** reshape arguments so errors are hard to make. Cited example: requiring absolute file paths removed failures that appeared once the agent changed directory.

```python
# retrieval tool shaped for fewer mistakes (own illustration)
def search_kb(query: str, source: Literal["policies","runbooks","orders"],
              top_k: int = 5) -> list[Chunk]:
    """Search ONE source. Use source='orders' only with an order id in query."""
```

## How an agent should apply this
- Default to a single augmented call; justify each added pattern with a failing eval, not intuition.
- Pick the pattern by what is fixed: fixed steps = chain, fixed categories = routing, unknown subtasks = orchestrator-workers.
- Cap iterations and surface the plan so a human can inspect it.
- Read the framework's raw prompts before adopting it.
- Rewrite tool signatures (enums, absolute identifiers, examples) whenever traces show repeated misuse.
