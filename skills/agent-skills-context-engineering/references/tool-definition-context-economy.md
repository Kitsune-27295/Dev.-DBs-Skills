# Tool Definition Context Economy

Sources: https://www.anthropic.com/engineering/writing-tools-for-agents · https://modelcontextprotocol.io/specification/2025-06-18/server/tools · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · Last verified 2026-11-24

## Contents
- Why definitions are a resident cost
- Five rules for lean definitions
- Bounded outputs with marked truncation
- Measure first-turn tokens
- What this file does not own

## Why definitions are a resident cost
Every tool name, description and parameter schema is sent on every turn (or at least on the first one), whether or not the tool is called. A skill description is the same kind of cost: only name and description are pre-loaded, and the best-practices guide calls the window a shared public good. So a tool definition is judged like an always-loaded file: each sentence must change what the model does.

The MCP tools page defines a tool as `name`, optional `title`, `description`, `inputSchema`, optional `outputSchema` and optional `annotations`. It also says clients must treat annotations as untrusted unless the server is trusted, so safety-relevant limits cannot live only in a description or annotation; enforce them server-side (servers must validate inputs and sanitize outputs per the same page).

## Five rules for lean definitions
These combine the Anthropic engineering guidance (describe a tool like onboarding a new teammate, unambiguous parameter names, avoid overlapping tools) with a minimal-context discipline. The "delete / say once" framing is this skill's synthesis, not a quote.

1. **Start minimal.** Purpose, available actions, and constraints that change a decision. Detail loads later (a skill, a resource, a follow-up call).
2. **Delete obvious constraints.** If the model learns the rule from the call result (a missing file fails to read; a failed send is reported), the sentence is dead weight. Keep rules the result cannot teach: destructive effects, permissions, ordering that fails silently.
3. **Describe behavior, not implementation.** What it does and returns; not internal mechanisms, result markers the model already sees, or enforcement details.
4. **Put the rule on the parameter.** Defaults, ranges, pairing and when-to-set belong in that parameter's `description` or schema (`enum`, `minimum`, `default`). Name parameters unambiguously (`user_id`, not `user`). A tool description that changes with configuration usually hides a missing parameter.
5. **Say every fact once.** Not in the tool description and again in a system-prompt section; not a parameter rule repeated in the tool text; not one tool's rules copied into another. When tools overlap, merge or sharpen them rather than cross-warn.

```text
Before: search_logs(q) "Searches logs. Returns up to 50 results. Always set limit
        under 50. If a query is invalid an error is returned. limit defaults to 50."
After:  search_logs(query, limit?)   description: "Search service logs."
        limit: integer 1-50, default 50
```

## Bounded outputs with marked truncation
- Cap large results by default: pagination, range selection, filters, or truncation with sensible defaults. The Anthropic article cites a 25,000-token default cap on tool responses in one product; treat the number as that product's setting.
- When truncating, say so and say how to narrow: "showing 20 of 340; filter by `since`". A silent cut reads as complete data.
- Offer a `concise` / `detailed` switch where useful; the article's example used about a third of the tokens for the concise form (72 vs 206).
- Return identifiers or paths for follow-up instead of whole logs or documents; prefer human-meaningful names over raw UUIDs.
- Include a small bounded amount of likely-needed neighbor context (for example a few preceding messages with a reply), marked as such.
- Errors should say what to fix and show a valid input shape, not a bare code or a stack trace. MCP separates protocol errors (unknown tool, bad arguments) from tool-execution errors returned with `isError: true`; the latter is what the model sees and can act on.
- Many redundant calls usually mean the cap or pagination is wrong. Watch total tokens next to accuracy: saving context that causes extra searches is a net loss.

## Measure first-turn tokens
Before and after any definition change, compare the first-turn prompt tokens (provider usage field, a count-tokens endpoint, or the host's context breakdown). Keep the change only if tokens fell and a small task set still passes. Anthropic's article stresses evaluation on realistic multi-call tasks with verifiable outcomes and held-out tasks, tracking accuracy, calls, tokens and tool errors.

## What this file does not own
Tool contracts and ACI ergonomics at the application level belong to `agentic-rag-architecture`. Instruction-file governance, routing and spec limits belong to `skill-orchestrator`. Model/effort and spend levers belong to `model-effort-routing`.

## How an agent should apply this
- Draft the definition, then delete every sentence the call result would teach anyway.
- Move each rule into the parameter it constrains; keep one copy of each fact.
- Add default caps and truncation notices to any tool that can return unbounded output.
- Record first-turn tokens before and after; revert changes that do not pay.
- Enforce safety limits in the server, never only in descriptions or annotations.
