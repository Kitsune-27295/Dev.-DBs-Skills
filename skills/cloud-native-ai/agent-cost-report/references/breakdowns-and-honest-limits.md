# Breakdowns and Honest Limits

Sources: https://code.claude.com/docs/en/costs · https://platform.claude.com/docs/en/build-with-claude/prompt-caching · https://github.com/ryoppippi/ccusage · Last verified 2026-11-27

## 1. Breakdowns that answer real questions

| Question | Cut | Notes |
|---|---|---|
| Did routine work run on an expensive model? | per model: replies, tokens, est. USD | feed the result to `model-effort-routing`; do not restate its tier tables |
| Which conversations were expensive? | per session id, top 10 | include first and last timestamp and the working directory |
| What did one piece of work cost? | per task | attribute by a rule you state: session, branch, ticket id in the branch name, or manual labels |
| How much is delegation? | main thread vs subagent entries | subagent requests are separate requests with their own context |
| Is caching working? | cache-read share of input | `read / (read + write + uncached input)` per day or session |
| Is spend trending? | per day, whole days only | state the timezone |
| What did a long idle gap cost? | writes right after a gap | the first request after a break longer than the cache lifetime misses the cache and reprocesses the context (costs page) |

Keep each table small (10 rows or fewer, plus "other"). A report that needs a dashboard is a product; this skill is the minimal method.

## 2. Per-task attribution (the weakest number)

Tokens are measured per response; tasks are not in the logs. A task total is a grouping of measured responses under a rule, so:

- State the rule ("responses grouped by branch name") next to the table.
- Mark totals "attributed".
- Never present cost per task as a precise fact; present it as "about", with the sessions that make it up listed.
- Cost per completed outcome needs an outcome count from somewhere else (merged pull requests, closed tickets). If you do not have one, report cost per session and stop.
- Waste categories (looping, rework, wrong model) need human or reviewed labels; a keyword guess is a draft label and must be marked as such.

## 3. Cache accounting in practice

Per response: `read`, `write5m`, `write1h`, `uncached`. Summaries:

```
cache_read_share  = read / (read + write5m + write1h + uncached)
rewrite_ratio     = (write5m + write1h) / read
```

Reading the numbers:

- A high read share with modest writes means the prefix is stable and reused.
- Large writes with small reads means the cache is repeatedly rebuilt. The product documentation names causes: a first message after a break longer than the cache lifetime, switching models mid-session (each model has its own cache), changing effort on most models, toggling fast mode (separate cache), changing the set of loaded tool definitions, compaction, removal of old images and upgrading Claude Code. A subagent never reads the parent's cache.
- Claude Code's own `/usage` Session block can show a prompt-cache line (request count, share of input from cache, misses, warm or cold) (Claude Code v2.1.251 or later; main conversation only, not subagents); the counts come from the same token fields, so your numbers should agree in direction.
- Cache economics, 5-minute writes cost more than reads by 12.5x for a 0.1x read model; whether to use a 1-hour lifetime is an optimization question for `model-effort-routing` or the vendor's caching guide, not a reporting question.

## 4. Honest limits (copy into the report, drop the ones that do not apply)

1. **Estimate, not invoice.** Tokens are measured; dollars are tokens times a dated list price.
2. **Format instability.** Transcript fields are an internal format; this run was validated on N sample lines at version V.
3. **Completeness.** Only logs on this machine and within retention; session files are pruned on a schedule (30 days by default per the `.claude` directory documentation).
4. **De-duplication assumptions.** Key and conflict rule stated; ratio of lines to distinct responses shown.
5. **Billing mode.** Subscription usage is included in the plan; dollars here are a what-if. API usage approximates the bill.
6. **Prices.** List prices as of the stated date; contracted rates, batch, fast mode, regional multipliers and server-tool fees not modeled unless said.
7. **Unpriced models.** Listed with token counts; excluded from totals.
8. **Attribution.** Per-task figures are groupings by a stated rule.
9. **Tool comparison.** Other tools (ccusage and similar) differ in pricing source, time zone and de-duplication; compare cautiously. ccusage itself states that its costs are estimates that may not match actual billing, covers only the current machine and excludes tool API charges such as web search.

## 5. Example report skeleton

```
Scope: all sessions, this machine, main + subagents | Window: 2026-11-17 to 2026-11-24 (end excl.), UTC
Prices: first-party list of 2026-11-24 | Lines read 41,200, skipped 12, distinct responses 15,870

Model              Replies   Input   Output   Cache read   Cache write   Est. USD
model-a             9,120    ...     ...      ...          ...           $xx.xx  ESTIMATED
model-b             6,700    ...     ...      ...          ...           $xx.xx  ESTIMATED
UNPRICED: model-c (51 replies, tokens listed), excluded from totals

Cache read share of input: 91%    Estimated cache savings: $yy.yy (at list prices)
Total (priced models): $zz.zz ESTIMATED
Limits: see list (format V, 30-day retention, this machine only, subscription: what-if)
```

## How an agent should apply this

- Choose the cuts the question needs; keep tables to 10 rows.
- State the attribution rule for every per-task number and never present it as exact.
- Report cache read share, write tokens and uncached input separately; diagnose rebuilds from the causes the product docs list.
- Paste the relevant limits into every report and name the version of the log format you validated against.
- Offer a follow-up (routing change, context trimming) by pointing to `model-effort-routing` and `agent-skills-context-engineering`, without restating their rules.
