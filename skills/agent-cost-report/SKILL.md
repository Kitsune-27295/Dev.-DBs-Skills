---
name: agent-cost-report
description: "A minimal, honest method for measuring what a coding-agent session or period cost from local transcripts and usage logs: read per-reply token usage, de-duplicate repeated lines, price the tokens against a dated vendor price list and label the result ESTIMATED, account for cache reads and cache writes (5-minute and 1-hour) separately, break the total down per model, per session or task and per date window, and state the limits (unstable log format, pruned history, subscription versus API billing, other machines). A method, not a product: about 40 lines of script plus rules for what to report. Use when asked what an agent session, task, week or project cost, when comparing models or routing choices with numbers, when reconciling an estimate against a bill or usage screen, or when building a small cost report from transcripts."
---

# Agent Cost Report

One idea: a cost report from transcripts is **measured tokens multiplied by a dated price list**, so it is an **estimate** and must say so; the useful work is counting each reply once, pricing cache reads and writes at their own rates, never pricing an unknown model as zero, and stating what the numbers cannot cover. Sources and claims: [references/sources.md](references/sources.md).

Boundary: choosing models, effort and delegation to cut cost is `model-effort-routing` (it owns the cost levers; this skill only measures). Shaping context to use fewer tokens is `agent-skills-context-engineering`. How a prompt cache works as an application cache is `caching-strategies`; here only its token accounting matters.

---

## 1. Money labels (use them on every figure)

| Label | Meaning | Source |
|---|---|---|
| **Measured (tokens)** | Counts read from usage fields in logs | transcripts |
| **ESTIMATED (dollars)** | Measured tokens times a price list on a stated date | your price table |
| **Billed** | What an invoice or console cost page says | vendor, authoritative |
| **Extrapolated** | Filled in for data you do not have, with a stated ratio | your assumption; low confidence |
| **Unavailable** | No data | write "unavailable", never `$0` |

Claude Code itself works this way: its session cost figure is computed locally from token counts at list price, is an estimate, and for subscription plans the session dollar figure is not relevant for billing; the console cost page or invoice is the authority (see [references/sources.md](references/sources.md)).

## 2. Define the question before reading logs

State: **scope** (one session, a project, all sessions on this machine), **window** (start inclusive, end exclusive, in a stated timezone), **inclusions** (main conversation only, or also subagent transcripts), and **audience** (engineer tuning routing, or manager reading a total). Without these, two reports of "last week" disagree.

Default window: the last N whole days, excluding today (a partial day makes week-over-week comparisons wrong). Mark any partial day explicitly.

## 3. The method

1. **Locate** transcripts: Claude Code stores session logs as JSONL under the configuration directory (`~/.claude/projects/<project>/`, relocatable with `CLAUDE_CONFIG_DIR`); other tools use other places. Check what exists; do not assume.
2. **Parse** line by line, skip lines that fail JSON parsing, keep entries of type `assistant` that carry a `message.usage` object.
3. **De-duplicate**: one API response can be written as several lines (one per content block), and the same response can appear in more than one file. Key by `(message.id, requestId)`; count each key once; if values differ across lines, keep the last (or the maximum output count) and say which. In one local sample, 1,199 assistant lines held 468 distinct responses, so skipping this step would have more than doubled the totals.
4. **Read tokens** per response: `input_tokens`, `output_tokens`, `cache_read_input_tokens`, `cache_creation_input_tokens`, and the split `cache_creation.ephemeral_5m_input_tokens` / `ephemeral_1h_input_tokens` when present. Total input of a request is the sum of the three input-side fields.
5. **Price** with a table you loaded and dated (section 4).
6. **Aggregate** per model, per session, per day (section 5).
7. **Reconcile** against any authoritative figure you have (console cost page, `/usage`), and report the gap rather than hiding it.
8. **Report** the table, the label, the price date, the window, the scope and the limits (section 7).

Details of parsing and accounting: [references/transcript-usage-accounting.md](references/transcript-usage-accounting.md).

## 4. Pricing rules

Per response, in USD with prices per million tokens:

```
cost = input * P_in + output * P_out
     + cache_write_5m * P_w5 + cache_write_1h * P_w1h
     + cache_read * P_read
```

- Take `P_*` from the vendor price page at run time and write the date next to the number. Do not hardcode prices into the skill or into long-lived scripts without a date.
- Cache multipliers relative to base input on the vendor page: 5-minute write 1.25x, 1-hour write 2x, cache read 0.1x on most models. The read multiplier is **model-specific** on newer models (0.05x and 0.025x appear on the page), so use the listed per-model cache price, not a global 0.1.
- No `cache_creation` split in a response: treat all cache writes as 5-minute and label that assumption.
- A model that is not in your table is **UNPRICED**: list its name and token counts, add nothing, never silently zero it. Placeholder entries (for example a synthetic model name with no real request) carry no real cost; list and exclude them.
- Other modifiers visible in usage data: `speed` (fast mode has its own prices), `inference_geo` (US-only inference has a 1.1x multiplier on supported models), and long-prompt tiers on some models. Apply them when the field says they applied; otherwise note them as ignored.
- Server-side tool charges (for example web search per 1,000 searches) are not token costs; count them separately from `server_tool_use` or list them as not included.

Pricing and labels in depth: [references/pricing-and-estimate-labeling.md](references/pricing-and-estimate-labeling.md).

## 5. Breakdowns

| Cut | Key | Use it to answer |
|---|---|---|
| Per model | `message.model` | Did the expensive model do routine work? (feeds `model-effort-routing`) |
| Per session | `sessionId` / file | Which conversations cost most |
| Per task | your grouping (branch, working directory, ticket, session label) | Cost per outcome; label groupings as your own |
| Main vs subagent | `isSidechain` or subagent transcript files | How much is delegation |
| Per day | timestamp in a stated timezone | Trends; whole days only |
| Cache accounting | read / (read + write + uncached input) | Is caching working; where was it rebuilt |

Task-level attribution is a judgment: session boundaries and branch names are proxies, so mark per-task dollars "attributed" and keep the evidence (session ids) in an appendix. Do not invent an outcome count.

Cache accounting: report cache-read share of input, cache-write tokens, and uncached input separately. A low read share with large write totals means the cache keeps being rebuilt (long idle gaps, edits to early context, model switches); the cause analysis belongs to `model-effort-routing` and the Claude Code documentation, not here. Details and an example: [references/breakdowns-and-honest-limits.md](references/breakdowns-and-honest-limits.md).

## 6. Minimal script

A runnable example of about 40 lines (dedupe, window, per-model cost, unpriced models listed) is in [references/transcript-usage-accounting.md](references/transcript-usage-accounting.md). Keep it a script you run on demand; do not turn it into a service.

## 7. Limits to state in every report

- **Format instability**: transcript JSONL is an internal format and field names can change between versions; validate on a few lines before trusting a run, and print the count of replies and of skipped lines.
- **Retention**: Claude Code removes session files older than `cleanupPeriodDays` (30 days by default per the costs documentation); old periods may be incomplete.
- **Machine scope**: only logs on this machine; other devices and web sessions are absent.
- **Billing mode**: on an API or console plan the estimate approximates the bill; on a subscription plan usage is included and dollars are a what-if, not an invoice.
- **Contracted rates**: list prices ignore discounts; if rates differ, apply the multiplier and say so.
- **Not included**: server-tool fees, taxes, batch or negotiated pricing unless modeled.

## Quick Decision Checklist

1. Are scope, window (with timezone) and inclusions stated?
2. Is every response counted once (`message.id` + `requestId`)?
3. Are cache reads, 5-minute writes and 1-hour writes priced separately at the per-model rates?
4. Is the price table dated, and is any model missing from it listed as UNPRICED?
5. Is every dollar figure labeled ESTIMATED, and "unavailable" used for unknowns?
6. Are the breakdowns the ones the question needs (model, session, task, day)?
7. Did you reconcile against a billed or screen figure and report the gap?
8. Are limits stated: format drift, retention, machine scope, billing mode?
9. Did you stay minimal (a script and a table, not a platform)?

## Deep references

- [transcript-usage-accounting.md](references/transcript-usage-accounting.md) - read when parsing logs: fields, de-duplication, windows and time zones, subagents, a runnable example.
- [pricing-and-estimate-labeling.md](references/pricing-and-estimate-labeling.md) - read when pricing tokens: multipliers, model-specific cache rates, modifiers, labels, reconciliation.
- [breakdowns-and-honest-limits.md](references/breakdowns-and-honest-limits.md) - read when slicing the numbers or writing the limits section.
- [sources.md](references/sources.md) - sources, retrieval status and claims not adopted.
