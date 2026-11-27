# Trigger Evals

Last verified 2026-11-27 (prompts written by the author; not run against a host).

Should trigger `blameless-postmortem`:
1. "The nightly load wrote zero rows for three days and we restored from backup. Write up what happened."
2. "Draft the incident report for yesterday's outage; I have the logs and the chat export."
3. "We need a postmortem with action items and owners after the bad deploy was rolled back."

Near misses:
1. "The service is down right now, find the cause" -> `diagnosing-bugs`.
2. "Do a retro on this coding session: what went well?" -> `retro`.
3. "Save a one-line lesson about this mistake for future sessions" -> `agent-session-memory`.
