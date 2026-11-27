# Pricing and Estimate Labeling

Sources: https://platform.claude.com/docs/en/about-claude/pricing · https://platform.claude.com/docs/en/build-with-claude/prompt-caching · https://code.claude.com/docs/en/costs · Last verified 2026-11-27

(`https://docs.claude.com/en/docs/about-claude/pricing` redirects to the `platform.claude.com` address above.)

## 1. What the price page defines

- Prices are USD per million tokens (MTok), per model, in columns: base input, 5-minute cache writes, 1-hour cache writes, cache hits and refreshes, output.
- Cache multipliers relative to base input: 5-minute write 1.25x, 1-hour write 2x, cache read 0.1x "on most models". The page states per-model exceptions for the newest models (2026-11-27): 0.05x on Opus 5.5 and Sonnet 5.5, 0.025x on Fable and Mythos 5.1 and 5.2. Example from the page: Opus 5.5 has a $4 base input price, a cache-hit price of $0.20 (0.05x) and a 1-hour write price of $8.
- Caching pays back after one read for 5-minute writes and after two reads for 1-hour writes.
- Modifiers that stack with cache multipliers: batch discount (50% on input and output; not applicable to interactive sessions), US-only inference (`inference_geo`, 1.1x on supported models), fast mode (separate higher input and output prices; listed for Fable 5.2, Opus 5.5, Opus 5 and Opus 4.8, and not combinable with batch), and the Haiku 5.5 prompt-length tier (higher prices when a request's prompt, including cache reads and writes, exceeds 100,000 tokens, priced per request). Other 4.6-and-later models include the full 1M context at standard price. The 1.1x US-only multiplier applies to Claude 4.6 and later on the first-party API; Bedrock and Google-managed Vertex price independently.
- Newer models use a tokenizer that produces roughly 30% more tokens for the same text than earlier ones (page statement). Because your counts come from the logs, the tokenizer is already in the numbers; it only matters when you compare "same text" across models.
- Server tools have extra charges (web search is $10 per 1,000 searches on the Claude API; code execution is billed by container time only when used without web search or fetch); web fetch adds no charge beyond tokens. These do not appear in token fields.
- Prices change. This skill deliberately keeps no price table; the example numbers in these files are dated illustrations.

## 2. Formula and an example

```
usd = (input*P_in + output*P_out + w5m*P_w5 + w1h*P_w1h + read*P_read) / 1_000_000
```

Example (illustrative numbers in the shape the page uses): a response with 10,000 uncached input tokens, 40,000 cache-read tokens and 15,000 output tokens, on a model with $4 input, $20 output and 0.05x cache hits:

```
uncached  10,000 x $4     /1e6 = $0.040
cache rd  40,000 x $0.20  /1e6 = $0.008
output    15,000 x $20    /1e6 = $0.300
total                           $0.348  ESTIMATED
```

Without caching the same 50,000 input tokens would have cost $0.20 instead of $0.048; the difference is the savings attributable to cache hits at those prices. Report it as "estimated cache savings", labeled the same way.

## 3. Handling gaps honestly

| Situation | Do this |
|---|---|
| Model name not in your table | list name and token counts as UNPRICED; add nothing; flag in the headline |
| Price table older than the window | warn that prices may have changed; keep the date next to the total |
| Placeholder or synthetic model entries | list and exclude; they are not real requests |
| `cache_creation` split missing | price all writes at the 5-minute rate and state it |
| Field present but zero for all rows | do not infer "no caching"; check the model's minimum cacheable length and whether the tool reports cache fields at all |
| Contracted or discounted rates | apply a stated multiplier; an administrator can set the `modelPricing` managed setting (rates or a multiplier, Claude Code v2.1.242 or later) so `/usage` figures match a contract; they remain estimates, not invoices |
| Mixed providers (cloud marketplaces, gateways) | their invoices follow their own price lists; say your estimate uses the first-party list |

## 4. Labels in the report

- Headline: `$X.XX ESTIMATED (tokens measured from local logs x list prices of YYYY-MM-DD)`.
- Table column header: "est. USD".
- Two decimals everywhere; never show unknowns as `$0`.
- If you have a billed figure for the same window, show both and the difference, with the likely reasons (window and timezone mismatch, other machines, discounts, server tools, unpriced models).
- Do not fold an extrapolation into the headline. Show it on its own line with the ratio used.

## 5. Subscription versus API billing

The Claude Code costs page says the Session block of `/usage` shows API token usage intended for API users; for Pro, Max and Ultra subscribers usage is included in the plan, so the session dollar figure is not relevant for billing. Team and Enterprise seat usage inside the allowance is not metered in dollars either (the spend report covers usage-credit spend). So:

| Billing mode | What your estimate means |
|---|---|
| API key / console | close to the bill; reconcile with the console cost page |
| Subscription plan | a what-if at list price; useful for comparing models and tasks, not an invoice |
| Cloud provider (marketplace) | estimate at first-party list; the cloud console is the authority |
| Usage credits beyond the plan | the part billed; see the plan's usage page |

For team-wide numbers the docs point to console dashboards, an analytics API, spend reports or OpenTelemetry export; a local-transcript script covers one machine only.

## 6. Reconciliation checklist

1. Same window, same timezone as the authority?
2. Same scope (one account, one machine, subagents included)?
3. De-duplicated?
4. Any unpriced models in the window?
5. Any modifiers (fast mode, US-only inference, long-prompt tier, batch) that your formula ignored?
6. Server-tool charges outside tokens?
7. Past retention (older logs missing)?

Explain each remaining gap; do not tune the formula to force agreement.

## How an agent should apply this

- Load prices from the vendor page on the run date; write the date in the output.
- Use per-model cache prices, and the 5-minute versus 1-hour write split when present.
- Label every dollar ESTIMATED, list unpriced models, never write `$0` for unknown.
- State the billing mode and what the estimate means under it.
- Reconcile against a billed or product figure when one exists and list the reasons for any gap.
