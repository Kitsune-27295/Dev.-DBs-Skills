# Prompt Cache and Mid-Conversation Effort Changes

Sources: https://platform.claude.com/docs/en/build-with-claude/effort · https://platform.claude.com/docs/en/build-with-claude/effort-per-message (extra page) · https://developers.openai.com/api/docs/guides/reasoning · https://reference.langchain.com/python/langchain-openai/chat_models/base/BaseChatOpenAI/reasoning_effort · https://code.claude.com/docs/en/model-config · Last verified 2026-11-27

## 1. The problem

Effort is a request-level parameter that shapes the rendered prompt. Changing it between requests can invalidate all or part of the cached prefix from earlier turns (Claude docs, LangChain note). A cache miss re-bills the whole prefix at full input price and adds latency. Claude Code prompt cache lifetime (best-practices page, re-read 2026-11-27): about one hour on a subscription, five minutes with an API key, cloud provider or usage credits; subagents get five minutes unless changed. API cache reads cost 0.1x base input on most models, 0.05x on Opus 5.5 and Sonnet 5.5, 0.025x on Fable 5.2 (pricing page).

## 2. Claude: two ways to change effort

| Method | Cache effect | Constraints |
|---|---|---|
| Top-level `output_config.effort` changed on the next request | Can invalidate all or part of the cache | Works everywhere effort is supported. On Fable 5.1 it also steers less reliably because earlier replies were written at the old level. |
| Per-message effort: a `role: "system"` message with empty `content` and its own `output_config.effort`, plus beta header `mid-conversation-output-config-2026-07-01` | Cached prefix still matches | Beta. Models: Fable 5.2, Mythos 5.2, Fable 5.1, Mythos 5.1, Opus 5.5, Opus 5, Sonnet 5.5, Haiku 5.5 (platform availability varies; Fable 5 and Opus 5 on Bedrock reject it). Not on Managed Agents. |

Per-message rules (from the page):
- Directly after a user turn with new input: reply uses the new level. Elsewhere: starts at the next user turn with new input. A tool_result-only user turn is not new input.
- Level persists until another message changes it. Append after everything already sent; never insert earlier, move or remove it on later requests (on preserved-thinking models that invalidates later thinking blocks).
- Errors: without the beta header, 400 "Extra inputs are not permitted"; unsupported model, 400. Sonnet 5.5 with `thinking: between_tools` and Haiku 5.5 with `thinking: disabled` cannot change effort mid-conversation (400); use adaptive thinking to vary per turn.

Sketch (structure only):
```
messages = [user1, assistant1,
            {"role": "system", "content": [], "output_config": {"effort": "low"}},
            user2]          # top-level effort stays "high"
```

## 3. OpenAI: `configuration_update` (verified)

Exists in both the OpenAI reasoning guide and the LangChain reference page (via summarizing reader).
- Purpose: raise reasoning effort for difficult work or lower it for routine follow-ups without breaking the prompt cache.
- Mechanism: add a `configuration_update` item to `input` before the next user message, e.g. `{"type": "configuration_update", "reasoning": {"effort": "high"}}` (shape from the LangChain page). Applies to that response and later ones until another update overrides it.
- Preserves the original prompt prefix for caching; supported on GPT-6 and later, standard single-agent mode. Can be combined with `text.format` in the same item.
- Caveat: the response's `reasoning.effort` still reports the request-level value, not the update's, so log the update yourself.
- LangChain: changing `reasoning_effort` mid-conversation invalidates the prefix; use the update item on models that support it.
- Related stateful notes: `previous_response_id` carries reasoning forward; `reasoning.context` accepts `auto`/`current_turn`/`all_turns`; with `store: false` or ZDR, reasoning items carry `encrypted_content` and you must append all output items in order; reasoning items can be dropped on a `prefix_mismatch` (GPT-6.2+) if earlier content changes.

## 4. Claude Code behavior

- Skill `effort:` applies until the end of that turn (or the whole forked run with `context: fork`); it is not persisted. A skill `model:` acts only on a user-typed `/name`. A subagent's `effort` applies while it runs. `CLAUDE_CODE_EFFORT_LEVEL` always wins.
- `ultrathink` affects one turn without altering the session setting.
- (Inference) Because skill/subagent effort is turn- or run-scoped, using them is a cache-friendlier way to vary depth than flipping a session-wide level repeatedly; the docs do not state cache effects for Claude Code effort, so treat this as untested.

## How an agent should apply this

- Pick one effort for a cached long session; vary effort across workloads, not within a conversation, unless the model supports per-message effort.
- Where supported, use per-message effort (Claude) or `configuration_update` (OpenAI GPT-6+) instead of changing the top-level parameter.
- Append effort-change messages at the tail and keep them in place on later requests.
- Check model-specific blockers (Sonnet 5.5 `between_tools`, Haiku 5.5 `disabled`) before planning dynamic effort.
- Beta features: pin the beta header and re-read the page before relying on it; the OpenAI item is documented only for GPT-6+.
