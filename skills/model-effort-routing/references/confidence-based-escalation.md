# Confidence-Based Escalation and Adaptive Compute

Sources: https://ai.blocksize.hr/blog/en/ai-model-routing-cost-optimization-2026 · https://vercel.com/i/llm-routing-strategies · https://github.com/ThreeSR/Awesome-Inference-Time-Scaling · https://arxiv.org/html/2610.04751v1 · Last verified 2026-11-23

## 1. Cascade = cheap first, check, escalate

Blocksize calls the cascade the most reliable routing pattern: try the cheap model, run a check (confidence score, validator, schema check or similar), escalate only if the check fails. The expensive model is paid for only when needed. Cost: failed cheap attempts are wasted spend plus extra latency (inference; Blocksize notes predictive routers avoid the "double inference").

DevelopersDigest adds that Luna-first style fleets are defensible because a failed cheap attempt costs little; no measurement is given.

## 2. What counts as a confidence signal

Ordered by how much I would trust them (my ranking, an inference):
1. External, deterministic checks: tests pass, JSON schema validates, citation exists, SQL runs, linter clean.
2. Agreement signals: vote or self-consistency across several cheap samples (the CATTS-style idea in the inference-time-scaling list: spend extra samples only at steps where the agent's votes disagree).
3. Verifier or judge model scores (correlated with the generator; calibrate on labeled data).
4. Model-reported or token-probability confidence: cheap, but often poorly calibrated; the sources give no thresholds.
5. User signals (retry, thumbs-down, edit distance): lagging but real; Blocksize recommends watching satisfaction alongside spend.

None of the read sources publishes a numeric confidence threshold or target escalation rate. Any threshold must be fitted on your own labeled traffic. Do not copy a number from a blog.

## 3. Adaptive compute beyond model choice

From the Awesome-Inference-Time-Scaling index (descriptions only): stop iterating once an ensemble is confident (TUMIX, "about half the inference cost" per the list), pick the minimum number of samples for a target confidence (OptScale), exit reasoning early when it has converged with answer-level verification (PUMA), give agents a visible budget to decide dig-deeper vs pivot (Budget-Aware Tool-Use). Common pattern: compute (samples, thinking length, steps) is a variable allocated per query/step by an uncertainty or budget signal, not a constant. Mapping to an agent harness (inference): "effort" is that knob. Low effort first, raise effort or switch model only on failed checks.

arXiv 2610.04751 (layer-level routing) offers a caution: even with a confidence arbiter, an oracle over compute options was far above the achieved accuracy (0.816 vs 0.712 on MMLU, per its abstract), so confidence selection leaves most headroom unused. Also its note that confidence saturates after post-training, favoring the default computation, is a warning that model self-confidence can be uninformative (the paper concerns layer-routing programs; extension to model-level escalation is my inference).

## 4. Failure modes

- Silent cheap failure: no detector, wrong answer ships (Blocksize's explicit rule against it).
- Overconfident small model never escalates, so savings look great and quality quietly drops.
- Threshold too strict: nearly everything escalates; you pay cheap + expensive (Vercel's calibration warning).
- Escalation storms: retries at several layers amplify an outage (Vercel).
- Irreversible actions gated by a weak signal: do not let a cheap-tier "confident" result trigger deletes, payments or deploys.

## 5. Procedure

```
1. Collect 100-300 labelled tasks per task type (pass/fail by your real check).
2. Run cheap tier; record signal s and pass/fail.
3. Pick threshold t so that pass-rate of non-escalated >= target (e.g. what the big model achieves).
4. Escalation rate = P(s < t). Expected cost = c_small + rate*c_big.
5. Ship only if expected cost < c_big by a margin that covers router and monitoring overhead.
6. Re-fit monthly or on any model/price change.
```

## How an agent should apply this

- Prefer deterministic checks as the escalation trigger; use model confidence only with a calibration set.
- Escalate one tier at a time and cap escalations per task (and total spend) to avoid loops.
- Never gate irreversible or security-sensitive actions on cheap-tier confidence alone.
- Log (task type, tier, signal, outcome) so thresholds can be re-fitted.
- Report escalation rate with every savings claim.
