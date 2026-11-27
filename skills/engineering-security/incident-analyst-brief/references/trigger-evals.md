# Trigger Evals: incident-analyst-brief

Last verified 2026-11-27. Prompts are starting points, not a scored run.

Should trigger (`incident-analyst-brief`):
1. "The integration test fails after my fix and I do not see why; get someone looking at the cause while I keep going."
2. "A guard refused my commit and I believe it is wrong. Hand the investigation to a background agent."
3. "A user reports a regression I cannot reproduce; brief a subagent to find the root cause."

Near-miss (other skill):
1. "Walk me through reproducing and bisecting this bug." Expected: `diagnosing-bugs`.
2. "Write the postmortem for last week's outage." Expected: `blameless-postmortem`.
3. "Which model and effort should the subagent use?" Expected: `model-effort-routing`.
