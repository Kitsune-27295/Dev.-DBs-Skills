# Effort Levels by Provider (OpenAI, LangChain, Claude, Claude Code)

Sources: https://developers.openai.com/api/docs/guides/reasoning · https://reference.langchain.com/python/langchain-openai/chat_models/base/BaseChatOpenAI/reasoning_effort · https://platform.claude.com/docs/en/build-with-claude/effort · https://code.claude.com/docs/en/model-config · Last verified 2026-11-23

Reading note: pages were fetched through a summarising reader (Firecrawl had no credits), so exact wording below is paraphrased from those summaries, not raw page text.

## 1. Level vocabularies differ per vendor

| Vendor / surface | Names seen | Notes |
|---|---|---|
| OpenAI Responses (guide) | `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max` | "Supported values are model-dependent": always check the model page. |
| LangChain `BaseChatOpenAI.reasoning_effort` | `minimal`, `low`, `medium`, `high` | Type `str or None`, default `None` (provider decides). Chat Completions only; its list is narrower than OpenAI's own guide, so do not treat it as the full set. |
| Claude API (`output_config.effort`) | `low`, `medium`, `high`, `xhigh`, `max` | `adaptive` is a thinking mode, never an effort value. |
| Claude Code `/effort`, `--effort`, skill `effort:` | `low`, `medium`, `high`, `xhigh`, `max` | Opus/Sonnet 4.6 lack `xhigh` (runs as `high`). |

Agent rule: never hard-code one vendor's level list into another's request; map your internal tier (cheap/standard/deep) to each provider's accepted names.

## 2. OpenAI model restrictions (as read)

- GPT-6 Astra: rejects `none` (HTTP 400). GPT-6.1 Sol: rejects `none` and `minimal`. GPT-6.2 Astra/Sol: reject `none`.
- Defaults: gpt-5.5, GPT-5.6 (standard and pro), GPT-6 Sol/Luna, GPT-6.1 Sol default to `medium`. No universal default.
- The guide gives no full per-model matrix. Anything beyond the bullets above is unverified.

## 3. Claude effort: exact facts (effort doc)

- Set on Messages API as `output_config.effort`; omitted means the model default. Setting the default explicitly behaves identically to omitting it.
- Default is `high` everywhere except Claude Opus 5.5 and Claude Haiku 5.5, which default to `medium` (so a request omitting `effort` runs one level lower on Opus 5.5 than on Opus 5).
- `max` is available on Fable/Mythos 5-5.2, Mythos Preview, Opus 5.5/5/4.8/4.7/4.6, Sonnet 5.5/5/4.6, Haiku 5.5. `xhigh` is available on Fable/Mythos 5-5.2, Opus 5.5/5/4.8/4.7, Sonnet 5.5/5, Haiku 5.5. Not every `max` model has `xhigh`.
- Effort is a behavioural signal, not a token budget; at low levels the model still thinks on hard problems, just less.
- It affects all output tokens: text, tool-call arguments and thinking. Lower effort means fewer, terser tool calls; higher means more calls, plans, summaries.
- Opus 5.5: adaptive thinking always on; `thinking: disabled` returns 400 at every level. Sonnet 5.5: `thinking: between_tools` works at low/medium/high, 400 at xhigh/max. Haiku 5.5: `disabled` works at high or below, 400 at xhigh/max.
- Per-model starting points: Fable/Opus 5: start `high`, `xhigh` for hardest agentic coding. Opus 4.7/4.8: start `xhigh` for coding. Sonnet 5.5: `medium` for well-specified agentic work, `high` for harder. Haiku 5.5: start `medium`, `low` for high-volume simple work (more likely to skip a search or check at `low`). Sonnet 4.6: `medium` recommended.
- `max` caution: small gain over `xhigh`, higher cost, can overthink structured-output tasks (Opus 4.7 note).
- Opus 5: changing effort does not reliably shorten replies; prompt for length instead.

## 4. Claude Code controls (model-config doc)

- Resolution order: `CLAUDE_CODE_EFFORT_LEVEL` env, then in-session pick (`/effort`, `/model`), then `--effort`, then settings (`modelSettings` / `effortLevel`), then model default.
- `max` is session-only unless set by env var. `effortLevel` key accepts low/medium/high/xhigh, not `max`. `/effort auto` clears the saved level.
- Unsupported level falls back to the highest supported at or below it.
- `ultrathink` in a prompt raises depth for that one turn only; "think hard" is plain text, not a keyword.

## How an agent should apply this

- Express routing as tiers, then translate to the target provider's accepted level names; verify against the model page, because acceptance is model-dependent (e.g. `none` is rejected on some GPT-6 variants).
- Do not assume the default is `high`: Opus 5.5 and Haiku 5.5 default to `medium`, and OpenAI defaults to `medium` on listed models.
- Set effort explicitly in production code and run an effort sweep on your own evals before carrying a setting to a new model.
- Reserve `max`/`xhigh` for measured gains; start agentic coding at `medium`/`high` on the 5.5 models.
- LangChain's four-value list is not exhaustive; pass newer values through model kwargs only after checking the model page.
