# Sources — Agent Cost Report

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://docs.claude.com/en/docs/about-claude/pricing | 302 to https://platform.claude.com/docs/en/about-claude/pricing (canonical variant used; read OK, whole page) | Per-model price columns, cache multipliers (1.25x, 2x, 0.1x with per-model 0.05x and 0.025x exceptions), batch discount, US-only inference 1.1x, fast mode prices, prompt-length tier on one model, server-tool charges, tokenizer note, worked example with cache reads. |
| https://docs.claude.com/en/docs/build-with-claude/prompt-caching | 302 to https://platform.claude.com/docs/en/build-with-claude/prompt-caching (canonical variant used; first 100,000 of about 155,500 characters read) | Usage fields (`input_tokens`, `cache_read_input_tokens`, `cache_creation_input_tokens`, `cache_creation` TTL split), total input formula, 5-minute versus 1-hour lifetime, minimum cacheable lengths. |
| https://code.claude.com/docs/en/costs | 200 OK | Session cost computed locally from token counts at list price and described as an estimate; subscriber session cost not relevant for billing; the prompt-cache line of `/usage`; plan attribution; console, analytics and OpenTelemetry options; retention (`cleanupPeriodDays`, 30 days by default); causes of cache misses and of climbing usage in long sessions; contracted-rate setting. |
| https://code.claude.com/docs/en/claude-directory | 200 OK | Transcript paths and naming (`projects/<project>/<session>.jsonl`, `subagents/` folder, superseded and orphaned copies), `cleanupPeriodDays` default of 30 days and what it removes, plaintext storage warning. |
| https://github.com/ryoppippi/ccusage | 200 OK (README only) | Reports (daily, weekly, monthly, session, blocks), `--since`, `--until`, `--timezone`, `--breakdown`, pricing from a LiteLLM data file with overrides, cache tokens tracked separately. The README gives no data paths, de-duplication behavior or cost-mode definitions. |
| https://ccusage.com/guide/ | 200 OK | Default data locations, local-only analysis, cost estimates "may not match actual billing", excludes tool API charges such as web search, logs never modified. Does not describe de-duplication. |
| Third-party skill read for ideas, no text reused (an agent cost report skill with about 52 files; Apache-2.0 per its repository) | Read locally; main skill file read, scripts not copied | Idea only: honest labeling (measured, estimated, extrapolated, unavailable), de-duplication by response id and request id, cache write and read terms in the formula, default whole-day window excluding today, unpriced models listed instead of zero. All wording, structure and code here are original; none of its product features (report rendering, behavior detectors, memory integration) are reproduced. |

## Reading limits

- Transcript field names (`message.id`, `requestId`, `usage.*`, `isSidechain`, `sessionId`, `cwd`, `gitBranch`) were observed on a local installation and are not documented by the vendor; they are described as version-dependent observations. The five token fields mirror the documented API usage object.
- The "lines versus distinct responses" figures in the text come from one local transcript and illustrate the effect; they are not general rates.
- The pricing page changes; the numbers in examples are dated 2026-11-24 and illustrative.
- The Claude Code prompt caching page (`code.claude.com/docs/en/prompt-caching`) is linked from the costs page but was not fetched; cache-lifetime claims here come from the costs page and the API caching page.

## Claims not adopted as fact

- Any claim about typical per-developer or per-team spend (figures on the costs page are the vendor's own and context-specific) is not repeated here.
- Third-party statements of percentage savings from caching or routing are not used.
- Per-task and "waste" categories are method suggestions, not measured facts.
