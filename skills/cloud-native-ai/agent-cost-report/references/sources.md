# Sources — Agent Cost Report

Every URL below was re-fetched on 2026-11-27 (first checked 2026-11-24). Status is what the fetch tool returned.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://platform.claude.com/docs/en/about-claude/pricing (the docs.claude.com address redirects here) | 200 OK, whole page read 2026-11-27 | Per-model price columns, cache multipliers (1.25x, 2x, 0.1x; 0.05x on Opus 5.5 and Sonnet 5.5, 0.025x on Fable and Mythos 5.1 and 5.2), Haiku 5.5 over-100k tier, fast mode model list, 1M context at standard price on other 4.6+ models, web search $10 per 1,000, batch discount, US-only inference 1.1x, fast mode prices, prompt-length tier on one model, server-tool charges, tokenizer note, worked example with cache reads. |
| https://platform.claude.com/docs/en/build-with-claude/prompt-caching (docs.claude.com redirects here) | 200 OK; first 100,000 of about 155,400 characters read 2026-11-27 | Usage fields (`input_tokens`, `cache_read_input_tokens`, `cache_creation_input_tokens`, `cache_creation` TTL split), total input formula, 5-minute versus 1-hour lifetime, minimum cacheable lengths (512, 1,024, 2,048, 4,096 by model). |
| https://code.claude.com/docs/en/costs | 200 OK, read 2026-11-27 | Session cost computed locally from token counts at list price and described as an estimate; subscriber session cost not relevant for billing; the prompt-cache line of `/usage`; plan attribution; console, analytics and OpenTelemetry options; retention (`cleanupPeriodDays`, 30 days by default); causes of cache misses and of climbing usage in long sessions; `modelPricing` managed setting for contracted rates, `/usage` clears on `/clear` since v2.1.211, 1.1x data residency reflected in the session figure. |
| https://code.claude.com/docs/en/claude-directory | 200 OK, read 2026-11-27 | Transcript paths and naming (`projects/<project>/<session>.jsonl`, `subagents/` folder, superseded and orphaned copies), `cleanupPeriodDays` default of 30 days and what it removes, plaintext storage warning. |
| https://github.com/ryoppippi/ccusage | 200 OK (README only, 2026-11-27) | Reports (daily, weekly, monthly, session, blocks), `--since`, `--until`, `--timezone`, `--breakdown`, pricing from a LiteLLM data file with overrides, cache tokens tracked separately. The README gives no data paths, de-duplication behavior or cost-mode definitions. |
| https://ccusage.com/guide/ | 200 OK (2026-11-27) | Default data locations, local-only analysis, cost estimates "may not match actual billing", excludes tool API charges such as web search, logs never modified. Does not describe de-duplication. |
| https://code.claude.com/docs/en/prompt-caching (added 2026-11-27) | 200 OK, whole page read | Each model, effort level (on most models) and speed has its own cache; cache-invalidating actions; default TTL by billing mode (1 hour for the main conversation on a subscription within plan usage, otherwise 5 minutes; subagents 5 minutes); `Prompt cache (main)` line needs v2.1.251; subagents do not read the parent's cache. |
| Third-party skill read for ideas, no text reused (an agent cost report skill with about 52 files; Apache-2.0 per its repository) | Read locally; main skill file read, scripts not copied | Idea only: honest labeling (measured, estimated, extrapolated, unavailable), de-duplication by response id and request id, cache write and read terms in the formula, default whole-day window excluding today, unpriced models listed instead of zero. All wording, structure and code here are original; none of its product features (report rendering, behavior detectors, memory integration) are reproduced. |

## Reading limits

- Transcript field names (`message.id`, `requestId`, `usage.*`, `isSidechain`, `sessionId`, `cwd`, `gitBranch`) were observed on a local installation and are not documented by the vendor; they are described as version-dependent observations. The five token fields mirror the documented API usage object.
- The "lines versus distinct responses" figures in the text come from one local transcript and illustrate the effect; they are not general rates.
- The pricing page changes; the numbers in examples are dated 2026-11-27 and illustrative.
- The API caching page was read only up to character 100,000 of about 155,400; the rest (pricing details, cache storage and sharing) was not read.
- The shell script and Python example were not re-run in this rebuild; they were not re-verified.
- Claude Code version numbers (v2.1.211, v2.1.242, v2.1.251) come from the fetched pages and move quickly.

## Claims not adopted as fact

- Any claim about typical per-developer or per-team spend (figures on the costs page are the vendor's own and context-specific) is not repeated here.
- Third-party statements of percentage savings from caching or routing are not used.
- Per-task and "waste" categories are method suggestions, not measured facts.
- The costs page's enterprise averages (per developer per day) are the vendor's own and are not repeated.
- ccusage de-duplication behavior: neither its README nor its guide describes it, so no claim is made.
