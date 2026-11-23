# Best-of-N, Verifiers and Test-Time-Compute Routing

Sources: https://www.microsoft.com/en-us/research/publication/best-route-adaptive-llm-routing-with-test-time-optimal-compute/ · https://github.com/ThreeSR/Awesome-Inference-Time-Scaling · https://openreview.net/forum?id=tFBIbCVXkG (unreadable) · https://arxiv.org/html/2610.04751v1 (exists, but different topic) · Last verified 2026-11-23

## 1. BEST-Route (Microsoft Research, arXiv 2506.22716, June 2025)

Read: the Microsoft publication page (abstract only; no tables, datasets or model names visible, so I cannot report per-benchmark numbers).

Idea in my words: ordinary routers pick one model per query and take one sample. A single sample from a small model often loses to a large model, so the router over-selects the large one. BEST-Route routes to a (model, number-of-samples) pair: for easier queries, draw several samples from a cheap model and keep the best one, which can beat one expensive-model response at lower total cost. The choice depends on predicted query difficulty and quality thresholds.

Claim: cost reduction of up to 60% with under 1% performance drop (abstract, "up to", on "real-world datasets"). Peak figure, authors' own experiments, not independently replicated here: treat as an upper bound.

Mechanics to copy (partly my inference from the abstract):
1. Predict difficulty cheaply per query.
2. Choose the cheapest option whose expected quality clears a threshold: small model n=1, small model n=k with selection, or large model.
3. Selection among samples needs a scorer (reward model, verifier, tests, or self-consistency vote); the abstract does not detail which. Without a reliable scorer, best-of-N buys nothing.

## 2. Best-of-N plus verifier: when it pays

Inference from the above and from the survey list in section 3:
- Works when verification is cheaper or more reliable than generation: code with tests, schema-valid extraction, math with checkable answers, SQL executed against a fixture.
- Fails when the "verifier" is the same model judging itself on open-ended prose; correlated errors survive selection.
- Cost: N samples of the small model must stay below one large-model call; also count verifier cost. Parallel sampling cuts latency compared to sequential escalation but multiplies spend.
- Diminishing returns in N: choose a small N (the sources give no universal value; derive it from your own pass-rate curve).

```
def solve(task, small, big, verify, n=4, budget):
    cands = [small(task) for _ in range(n)]
    ok = [c for c in cands if verify(c)]
    if ok: return pick(ok)          # tests/vote/score
    return big(task)                 # escalate only if none verified
```

## 3. What the Awesome-Inference-Time-Scaling list actually contains

Read via WebFetch in three chunks of a 300 KB page (first 200,000 characters; the last ~100,000 not read). It is an index of papers with one-line descriptions, not a methods document, and has no entry named best-of-N or routing in the part read. Entries found (descriptions are the list's, relayed by a summarizer):
- CATTS-style: "Agentic Test-Time Scaling for WebAgents" (Lee et al., 2026-02): spends extra sampling only at contested steps, using uncertainty from the agent's own vote distribution; reports gains over ReAct with fewer tokens than uniform scaling. The listing does not give numbers.
- Adaptive stopping: TUMIX (stop iterative refinement when an agent ensemble is confident, about half the inference cost, per the list); OptScale (minimum samples for a target confidence); PUMA (early exit when reasoning converges, with answer verification); Think-with-Me.
- Budget awareness: Budget-Aware Tool-Use (agents see a tool-call budget); Timely Machine (wall-clock budgets).
- Selection and verifiers: tournament voting for agentic coding, list-wise merging, Trae Agent patch selection, generative verifier for web actions, small critics steering larger coding agents, probes on internal states instead of reward models.
- Caveat: these are other people's abstracts; no figure from this list should be quoted as established.

## 4. The two unreadable or off-topic URLs

- OpenReview forum tFBIbCVXkG: the fetch returned a browser-verification page; not read. Likely a venue version of BEST-Route but this is unconfirmed; do not cite it.
- arXiv 2610.04751v1 does exist (not a 404). It is "Dynamic Routing as a New Dimension for Test-time Versatility of LLMs": routing of layers inside one model, selected by confidence, not routing between models. Reported in its abstract: on MMLU a confidence-arbitrated layer-routing method averaged +1.4 points, 0.712 combined with CoT vs 0.692 CoT alone; an oracle over the three arms reached 0.816, i.e. selection captures only part of the headroom. Relevant lesson (inference): confidence is a useful but imperfect arbiter between compute options. Only the first 100,000 of 130,000 characters were read.

## How an agent should apply this

- Use best-of-N only where a cheap, trustworthy verifier exists (tests, schema, execution, exact checks).
- Compare cost explicitly: n x small + verifier vs one large call; skip if not clearly cheaper.
- Treat "up to 60%" as a ceiling from a paper; plan with your own measured numbers.
- Escalate to the large model only when no candidate verifies.
- Do not use arXiv 2610.04751 as evidence for model-level routing.
