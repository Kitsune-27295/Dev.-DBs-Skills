# Tool Definition Context Economy

Sources: https://www.anthropic.com/engineering/writing-tools-for-agents · https://modelcontextprotocol.io/specification/latest/server/tools (spec version 2026-07-28) · https://modelcontextprotocol.io/specification/2025-06-18/server/tools · https://www.anthropic.com/engineering/code-execution-with-mcp · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · Last verified 2026-11-27

## Contents
- Why definitions are a resident cost
- Five rules for lean definitions
- Bounded outputs with marked truncation
- Measure first-turn tokens
- Code execution as the other lever
- What this file does not own
- How an agent should apply this

## Why definitions are a resident cost
Every tool name, description and parameter schema is sent whether or not the tool is called. A skill description is the same kind of cost: only name and description are pre-loaded, and the best-practices guide calls the window a public good. So a tool definition is judged like an always-loaded file: each sentence must change what the model does. Anthropic's code-execution article (2025-11-04) says most MCP clients load all tool definitions up front, so with very many tools an agent can process hundreds of thousands of tokens before reading the request.

The MCP tools page (2026-07-28) defines a tool as `name`, optional `title`, optional `description`, optional `icons`, `inputSchema`, optional `outputSchema` and optional `annotations` (the 2025-06-18 page listed `description` without "optional"). Both versions say clients must treat annotations as untrusted unless they come from trusted servers, and servers must validate all inputs and sanitize outputs, so safety-relevant limits cannot live only in a description or annotation. The 2026-07-28 page recommends tool names of 1 to 128 characters from letters, digits, `_`, `-` and `.`, and suggests prefixing names with a server identifier when aggregating servers to avoid collisions.

## Five rules for lean definitions
These combine Anthropic's engineering guidance (unambiguously named parameters, namespacing, avoiding overlapping tools) with a minimal-context discipline. The "delete obvious constraints" and "say every fact once" framing is this skill's synthesis, not a quote.

1. **Start minimal.** Purpose, available actions, and constraints that change a decision. Detail loads later (a skill, a resource, a follow-up call).
2. **Delete obvious constraints.** If the model learns the rule from the call result (a missing file fails to read), the sentence is dead weight. Keep rules the result cannot teach: destructive effects, permissions, ordering that fails silently.
3. **Describe behavior, not implementation.** What it does and returns; not internal mechanisms or enforcement details.
4. **Put the rule on the parameter.** Defaults, ranges, pairing and when-to-set belong in that parameter's `description` or schema (`enum`, `minimum`, `default`). Name parameters unambiguously (`user_id`, not `user`). A tool description that changes with configuration usually hides a missing parameter.
5. **Say every fact once.** Not in the tool description and again in a system-prompt section; not one tool's rules copied into another. When tools overlap, merge or sharpen them rather than cross-warn.

```text
Before: search_logs(q) "Searches logs. Returns up to 50 results. Always set limit
        under 50. If a query is invalid an error is returned. limit defaults to 50."
After:  search_logs(query, limit?)   description: "Search service logs."
        limit: integer 1-50, default 50
```

## Bounded outputs with marked truncation
- Cap large results by default: pagination, range selection, filters, or truncation with sensible defaults. The Anthropic article says Claude Code restricts tool responses to 25,000 tokens by default; treat the number as that product's setting.
- When truncating, steer the agent toward narrower calls: "showing 20 of 340; filter by `since`". A silent cut reads as complete data (this marking advice is the skill's own; the article asks for truncation to steer toward efficient calls).
- Offer a `response_format` switch (`concise` / `detailed`) where useful: the article's Slack example used 72 tokens for the concise form versus 206 for the detailed one, about a third.
- Prefer meaningful names over low-level identifiers (UUIDs, mime types); the article reports that resolving UUIDs to names improved retrieval precision by reducing hallucination. When a later call needs an ID, return it in the detailed format.
- Errors should state a specific fixable problem, not an opaque code or traceback. MCP separates protocol errors (unknown tool, malformed request) from tool execution errors returned with `isError: true`; the 2026-07-28 page says clients should give the latter to the model for self-correction, and lists input validation errors (a date in the wrong format) among them.
- Many redundant calls often mean the cap or pagination is wrong, and saving context that causes extra searches is a net loss (own judgment: watch total tokens next to accuracy).

## Measure first-turn tokens
Before and after any definition change, compare first-turn prompt tokens (provider usage field, a count-tokens endpoint, or the host's context breakdown). Keep the change only if tokens fell and a small task set still passes. The Anthropic article stresses evaluation on realistic multi-call tasks with verifiable outcomes and held-out test sets, tracking accuracy, call counts, tokens and tool errors.

## Code execution as the other lever
Trimming definitions cuts the cost of every call. Letting the model write code that calls tools, filters results and returns only a summary cuts model round trips and keeps large intermediate results out of context. The code-execution article's own example drops from 150,000 to 2,000 tokens (its figure, not a benchmark) and warns that running generated code needs sandboxing, resource limits and monitoring. Claude Code's experimental Code Mode: requirements and control model are owned by `model-effort-routing` (`references/code-mode-and-tool-call-batching.md`).

## What this file does not own
Tool contracts and ACI ergonomics at the application level: `agentic-rag-architecture`. Instruction-file governance, routing and spec limits: `skill-orchestrator`. Model, effort and spend levers: `model-effort-routing`.

## How an agent should apply this
- Draft the definition, then delete every sentence the call result would teach anyway.
- Move each rule into the parameter it constrains; keep one copy of each fact.
- Add default caps and truncation notices to any tool that can return unbounded output.
- Record first-turn tokens before and after; revert changes that do not pay.
- Enforce safety limits in the server, never only in descriptions or annotations.
