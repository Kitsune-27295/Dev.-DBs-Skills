# Transcript Usage Accounting

Sources: https://platform.claude.com/docs/en/build-with-claude/prompt-caching · https://code.claude.com/docs/en/claude-directory · https://code.claude.com/docs/en/costs · https://ccusage.com/guide/ · https://github.com/ryoppippi/ccusage · Last verified 2026-11-24

(`https://docs.claude.com/en/docs/build-with-claude/prompt-caching` redirects to the `platform.claude.com` address above.)

## 1. What a usage record contains

The API's `usage` object (prompt caching documentation) has:

| Field | Meaning |
|---|---|
| `input_tokens` | input tokens after the last cache breakpoint, never cached |
| `cache_read_input_tokens` | input tokens served from the cache |
| `cache_creation_input_tokens` | input tokens written to the cache by this request |
| `cache_creation.ephemeral_5m_input_tokens` / `ephemeral_1h_input_tokens` | the same writes split by cache lifetime; they sum to `cache_creation_input_tokens` |
| `output_tokens` | generated tokens, including thinking tokens (billed as output per the costs page) |

Total input of one request = `cache_read_input_tokens + cache_creation_input_tokens + input_tokens`. A request whose prompt is below the model's minimum cacheable length is processed without caching and reports zero in both cache fields, with no error.

Claude Code session logs are JSONL files. Observed on a local installation during authoring (a version-dependent observation, not documented): assistant entries carry `message.id`, `message.model`, `message.usage` (with the fields above plus extras such as `speed`, `inference_geo`, `server_tool_use`, `service_tier`), `requestId`, `timestamp`, `sessionId`, `cwd`, `gitBranch`, `isSidechain`; other entry types (user, system, attachment, file snapshots) have no usage and are skipped. The extras can change; the five token fields are the stable core because they mirror the API.

## 2. De-duplication

Why duplicates exist (observed, with the reason inferred): a response with several content blocks (text, tool calls, thinking) can be persisted as one line per block, each repeating the same `usage`; the same response can also be present in more than one transcript file (for example a subagent's file and a parent's reference to it).

Rule: key = `(message.id, requestId)`. Keep one record per key. When two lines for one key disagree, prefer the last line (streamed usage is cumulative for output tokens) or the maximum of each counter; write down which you chose. A local check found identical usage across duplicate lines, so either rule gave the same totals there, but do not assume that for other versions. Count and print: lines read, lines skipped as unparsable, assistant lines with usage, distinct keys. A distinct-to-lines ratio far below 1 is normal; a ratio of exactly 1 may mean your key is wrong (for example a missing `requestId` collapsing everything or splitting nothing).

If `message.id` or `requestId` is missing, fall back to the entry's own `uuid` and say that de-duplication is weaker.

## 3. Windows and time zones

- Timestamps in logs are ISO 8601 UTC. Convert to the reader's timezone before bucketing days, or state clearly that days are UTC.
- Use `[start, end)` with end exclusive. The default "last N whole days" ends at the start of today in the stated timezone.
- A response belongs to the day of its own timestamp, not of the session start; a session crossing midnight splits across days.
- ccusage exposes `--since`, `--until` and `--timezone` for the same reasons; its docs do not state the default timezone or any de-duplication behavior (not read from source), so check any tool you compare against.

## 4. Scope and subagents

- Main conversation versus subagents: subagent requests are separate API requests with their own context and cost; include them when the question is "what did the work cost", exclude them only if the question is about the main thread. Mark `isSidechain` entries (or the subagent files) so the split can be reported.
- Per the Claude directory documentation, transcripts live at `projects/<project>/<session>.jsonl` under the configuration directory, subagent transcripts in a `subagents/` folder under the session's folder (same format, removed with the parent), and a superseded or orphaned earlier transcript of a session can sit beside the current one with a suffixed name. Read only the `.jsonl` transcripts you mean to count, and de-duplicate across them. These files are plaintext and can contain secrets from tool output: never paste transcript lines into a report or chat.
- A session's totals reset in the in-product display on `/clear`, but the log files persist; do not mix the two when reconciling.
- Only logs on this machine are visible. Other devices and web sessions are absent (the costs page says the same of its local breakdowns).
- Retention: session files are removed after `cleanupPeriodDays` (30 days by default in the costs documentation); a window older than that may be incomplete.
- Environment: logs can live under a custom configuration directory (`CLAUDE_CONFIG_DIR`); ccusage documents support for custom data directories and, in its guide, comma-separated lists for combining profiles and archives. Combining directories raises the overlap risk, so de-duplicate across all of them at once.

## 5. Worked example (Python, standard library)

Run during authoring against a local transcript folder; it produced a per-model total and listed three models missing from the demo price table as UNPRICED. Prices in the example table are illustrative and dated; replace them from the vendor page on the day you run.

```python
#!/usr/bin/env python3
"""Estimate agent cost from Claude Code transcripts: tokens measured x price list = ESTIMATED."""
import json, sys, glob, collections

# USD per million tokens, copied by hand from the vendor price page on the date below.
PRICES = {  # model: (input, output, cache_write_5m, cache_write_1h, cache_read)
    "claude-sonnet-5-5": (2.00, 10.00, 2.50, 4.00, 0.10),
}
PRICE_DATE = "2026-11-24"

def replies(paths, since, until):
    seen = {}
    for path in paths:
        for line in open(path, encoding="utf-8", errors="replace"):
            try: o = json.loads(line)
            except ValueError: continue
            m = o.get("message")
            if o.get("type") != "assistant" or not isinstance(m, dict) or "usage" not in m: continue
            day = o.get("timestamp", "")[:10]          # UTC date; convert if you need local days
            if since <= day < until:
                seen[(m.get("id"), o.get("requestId"))] = (m.get("model"), m["usage"])  # last line wins
    return seen.values()

def cost(usage, p):
    cc = usage.get("cache_creation") or {}
    w1h = cc.get("ephemeral_1h_input_tokens", 0)
    w5m = usage.get("cache_creation_input_tokens", 0) - w1h   # no breakdown: all counted as 5m
    t = (usage.get("input_tokens", 0), usage.get("output_tokens", 0), w5m, w1h,
         usage.get("cache_read_input_tokens", 0))
    return sum(n * rate for n, rate in zip(t, p)) / 1e6, t

if __name__ == "__main__":
    since, until, *paths = sys.argv[1:]                # e.g. 2026-11-17 2026-11-24 "<dir>/*.jsonl"
    files = [f for pat in paths for f in glob.glob(pat)]
    total, unpriced = collections.Counter(), collections.Counter()
    for model, usage in replies(files, since, until):
        if model not in PRICES: unpriced[model] += 1; continue   # never price an unknown model at zero
        usd, _ = cost(usage, PRICES[model]); total[model] += usd
    for model, usd in total.items(): print(f"{model}: ${usd:.2f} ESTIMATED (list prices of {PRICE_DATE})")
    for model, n in unpriced.items(): print(f"{model}: {n} replies UNPRICED, not in the price table")
```

Extend it by returning the `t` tuple to a second `Counter` keyed by session for a per-session cut, and by printing the cache-read share (see `breakdowns-and-honest-limits.md`).

Known simplifications: UTC days; model price table is manual; no modifiers (fast mode, US-only inference, long-prompt tiers); synthetic placeholder entries show up as an unpriced model name and should be filtered out by name.

## 6. Validate before trusting

1. Parse 5 lines by eye: do the five token fields exist and look sane?
2. Check that the distinct count is plausible (section 2).
3. Compare one short session's total against the product's own session figure (`/usage` Session block) and expect the same order of magnitude, not equality (the in-product figure resets on `/clear`, and the log may include more entries).
4. Record the tool or script version and the log format version (the log entries carry a `version` field in the sample read).

## How an agent should apply this

- De-duplicate by `(message.id, requestId)` before any sum; print line, skip and distinct counts.
- Read the five token fields; treat extras as optional and version-dependent.
- Use `[start, end)` windows in a stated timezone and report partial days explicitly.
- Include or exclude subagent entries on purpose and show the split.
- State retention and machine-scope limits whenever the window is older than a few weeks.
