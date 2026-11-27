# Overthinking and Token Ceilings

Sources: https://developers.openai.com/api/docs/guides/reasoning · https://platform.claude.com/docs/en/build-with-claude/effort · https://code.claude.com/docs/pt/best-practices · https://blog.aifetchly.com/test-time-compute-scaling-modern-llm-reasoning-guide/ (secondary) · Last verified 2026-11-23

## 1. Reasoning tokens are real output tokens

- OpenAI: reasoning tokens are invisible in the API but occupy context and are billed as output tokens; counted in `usage.output_tokens_details.reasoning_tokens`. Pro modes bill at standard rates but do more work, so usage rises.
- `max_output_tokens` (OpenAI) caps reasoning plus visible output together. Hitting it yields `status: incomplete` with `incomplete_details.reason: max_output_tokens`, possibly before any visible text. OpenAI suggests reserving at least 25,000 tokens for reasoning plus output when starting, then tuning.
- Claude: `max_tokens` is a hard limit on thinking plus reply, and thinking counts even if its content is not returned. At `high`+ set it large; Opus 4.7/4.8/5 at `xhigh`/`max` suggest starting at 64k and tuning; Sonnet 5.5 agentic coding suggests 128,000 (its maximum) with streaming.
- Effort barely changes reply length on newer models; control length with the prompt, control thinking volume with effort.

## 2. What overthinking looks like

- Vendor-documented: `max` on Opus 4.7 gives "relatively small gains" at significant cost and can overthink structured-output or low-intelligence tasks. On Fable 5.2, `max` runs slower and costs more than `xhigh`, often for small gain.
- Claude Code best-practices (Portuguese page): phrases like "think hard" or "be thorough" are plain prompt text; effort is the control. Raise effort for subtle-correctness work (bug in unfamiliar code, flaky test, schema change); lower it for quick back-and-forth, brainstorming, small renames.
- Secondary (aifetchly blog, low trust): claims long reasoning on simple tasks can induce "doubt and hallucinations" and suggests a thinking cap near 2048 tokens for non-math work. Its only citation is an arXiv title with no results, the number looks like the author's own suggestion, and its "PRM" example is a GPT-4o scoring prompt rather than a trained reward model. Treat as hypothesis only; the direction (cap non-math reasoning) agrees with vendor advice but the number is unverified.

## 3. Under-thinking is the mirror failure

- Haiku 5.5 at `low` is more likely to skip a search, stop early or skip a check in long agent prompts.
- Opus 4.7 respects low/medium strictly and scopes work to what was asked; if reasoning is shallow, raise effort rather than prompt around it. If latency forces low, add a targeted line such as "this task involves multistep reasoning, think carefully" (vendor suggestion).

## 4. Ceilings and guardrails (decision table)

| Situation | Ceiling to set |
|---|---|
| Classification/extraction/routing | Lowest effort that passes eval; modest `max_tokens`; consider no/between-tools thinking where allowed |
| Standard agentic coding | `medium`/`high`, `max_tokens` 32-64k, stream |
| Hardest long-horizon work | `xhigh`, `max_tokens` 64k-128k, wall-clock and turn limits |
| `max` | Only to measure the ceiling; never a default |
| Any agent loop | Add turn/budget limits (`--max-turns`, `--max-budget-usd` in Claude Code print mode per best-practices page) |

## Example (pseudo-code)

```
def budget(task):
    tier = classify(task)            # cheap | standard | deep
    effort = {"cheap": "low", "standard": "medium", "deep": "high"}[tier]
    max_tokens = {"cheap": 2_000, "standard": 32_000, "deep": 64_000}[tier]
    r = call(effort=effort, max_tokens=max_tokens)
    if r.stop_reason in ("max_tokens", "incomplete"):
        # truncated mid-reasoning: raise the ceiling or lower effort, do not just retry
        r = call(effort=effort, max_tokens=max_tokens * 2)
    return r
```
(The numbers are illustrative defaults assembled from the vendor starting points above, not vendor requirements.)

## How an agent should apply this

- Always size `max_tokens`/`max_output_tokens` for thinking plus answer; treat a truncated or incomplete response as a ceiling bug, not a model failure.
- Do not buy depth with prompt phrases; change effort (or `ultrathink` for one Claude Code turn).
- Use `max` only after an eval shows `xhigh` is insufficient; flag overthinking risk for structured-output tasks.
- Watch for both failures: shallow answers at `low` and bloated cost at `max`; sweep levels on a small eval.
- Treat blog token numbers (e.g. 2048 caps) as unverified until reproduced on your own tasks.
