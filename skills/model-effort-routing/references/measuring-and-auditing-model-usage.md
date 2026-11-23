# Measuring and Auditing Model Usage

Sources: Local operating practice (private notes, summarised; not a public URL) · Last verified 2026-11-23

A routing policy that is not measured decays: callers forget the `model` parameter and everything runs on the session model. Measure launches, not intentions.

## What to measure

Every subagent launch is a tool call (named Agent or Task) recorded in session transcripts (JSONL files under the harness projects folder, main sessions plus their subagent transcripts). A call without a `model` input runs on the session model. The key metric: **share of built-in launches (general-purpose, catch-all, explore, untyped) that named a model.**

## Launch-report logic

1. Walk all transcript files; for speed, skip lines that do not contain the tool names.
2. Parse each line as JSON; skip unparsable lines.
3. Look in the message content for `tool_use` blocks whose name is Agent or Task.
4. De-duplicate by tool-call id (the same call can appear in several transcripts).
5. Optionally drop launches before a `--since` date (compare the timestamp's date part).
6. Key each launch by (agent type, model); untyped = general-purpose, missing model = "(none)".
7. Print counts sorted descending, then `named / total` for guarded types.

```python
counts, seen = Counter(), set()
for block in tool_use_blocks(all_transcripts):
    if block.id in seen: continue
    seen.add(block.id)
    if since and block.date < since: continue
    kind  = block.input.get("subagent_type") or "general-purpose"
    model = block.input.get("model") or "(none)"
    counts[(kind, model)] += 1
guarded = {k: n for k, n in counts.items() if k[0].lower() in GUARDED}
named = sum(n for (_, m), n in guarded.items() if m != "(none)")
```

The report reads only; it prints counts and never prompt text.

## Reading the result

- Baseline in the private notes (2026-11-06, all transcripts on one machine, each call counted once): **60 of 999 built-in launches (6%) named a model.** The remaining 94% ran on the session model. That gap is what motivated the guard hook (see agent-call-rules-and-enforcement-hook).
- After installing the guard, the named share on new launches should approach 100%; rerun with `--since <install date>` to check.
- Also look at the **mix**: if nearly everything now says the same model, the caller is complying mechanically; compare with the tier table (searches light, bulk edits mid, judgement strong).

## Pitfalls

- **Old transcripts get pruned**, so totals shrink over time. Compare windows with `--since`, not all-time totals.
- Counting the same call twice across parent and subagent transcripts: de-duplicate by id.
- Typed agents are not guarded: their model comes from their definition file, so audit those files separately (installed copies, mirrors and templates).
- A report can show that a model was *requested*, not that it was *used*: auto mode may ignore a model and an effort environment variable may override effort (see skill-header-limits-and-switch-cost). For ground truth, compare billed usage per model where the platform exposes it.

## Periodic audit checklist

1. Run the launch report for the last window; record named share.
2. Run the tier check script on all skill folders; fix mismatches and unclassified skills.
3. Size-check always-loaded files against the budget.
4. List agent definitions; each read-only agent light, each judging agent inherited; compare installed copies with templates.
5. Review the platform's usage view for unexpected spend on the strongest models.
6. Report: Implemented / Validated / Partially validated / Blocked, with the checks that actually ran.

## How an agent should apply this

- Run the report before and after any routing change and cite the numbers with their window.
- Use date windows, never all-time totals, when comparing.
- Treat a low named-share as a hook or caller problem first, a policy problem second.
- State clearly which results were measured and which come from documentation only.
