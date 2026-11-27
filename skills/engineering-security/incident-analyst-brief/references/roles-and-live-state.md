# Roles and Live State for Agent Incidents

Sources: https://sre.google/sre-book/managing-incidents/ · https://docs.pagerduty.com/ops-guides/incident-response-guide · https://docs.pagerduty.com/ops-guides/incident-response-guide/incident-commander · Last verified 2026-11-27

## What human practice says

Two public sources agree on a small set of ideas.

**The SRE chapter on managing incidents** names three failure modes of an unmanaged incident: engineers absorbed in debugging who lose the bigger picture, poor communication (nobody knows who is doing what, helpers go unused), and freelancing (an uncoordinated production change made with good intentions). It then defines roles: an incident commander who holds the overall state and delegates, an operations role that is the only group changing the system, a communications role, and a planning role for longer-term items. It treats the live incident state document, editable by several people, template-based, most critical facts at the top, as the commander's most important artifact. Handoff of command must be explicit and live. It also says when to declare: a second team is needed, customers can see it, or an hour of focused work has not solved it.

**PagerDuty's incident response guide** frames the commander's purpose in one line (keep the incident moving toward resolution) and says the commander should not perform actions, check graphs or read logs, but delegate them. It adds a scribe who records what happens, and subject-matter experts who contribute without taking command. It notes that deep technical knowledge is not required of the commander; coordination is.

## Mapping onto a lead agent and an analyst agent

| Human role | In an agent session | Notes |
|---|---|---|
| Incident commander | The lead (the main agent, or the human directing it) | Decides what to try; keeps the state; does not wait on the analyst |
| Operations (the one who changes the system) | The lead only | Exactly one writer to the shared tree and to any live system |
| Subject-matter expert | The analyst | Reads, measures, proposes; does not apply |
| Scribe | The lead, or a short note file | Records timestamps, commands and outputs; this later feeds `blameless-postmortem` |
| Communications | The lead's messages to the human | One current status line, not a stream |
| Planning | Follow-up list | Open items, owners; later memory entries (`agent-session-memory`) |

The central rule survives translation: one actor changes the system. An analyst that also edits files or reruns jobs in the shared tree reproduces the freelancing hazard, and its changes make the evidence harder to read.

## The live state note

Keep one short note while the incident lasts. It can be a scratch file or a section in the session notes. Put the most important facts first:

```
STATE (updated 14:35)
Status:      investigating | mitigated | resolved
Impact:      what is broken for whom (as observed, with the source)
Current try: the one thing being attempted now
Analyst:     briefed 14:10, running; no report yet
Ruled out:   <each with evidence>
Open items:  <owner / next step>
```

Why it matters for agents: context is compacted or lost, and a second agent (or the same one after a break) must be able to continue from the note. The note is also the raw material for a timeline: entries carry a time and a source.

## Handoff

If the lead changes (a new session, a different agent, the human taking over), hand over explicitly: write the state note, say what is in flight (analyst, jobs, branches), what is forbidden (do not rerun the import; do not force-push), and wait for the receiver to confirm they have it. A silent handoff is how two writers end up changing the system at once. Use the single-use handoff mechanics from `agent-session-memory`.

## Severity and declaring

Pick a rough severity at the start (user-visible, data at risk, blocked work only) so the response is proportionate. A data-at-risk failure turns on `ops-safety` before anything else. Revisit severity when facts change; downgrade out loud.

## How an agent should apply this

- Name yourself lead; name the analyst; say aloud that only the lead changes shared state.
- Keep a state note with the time, the current attempt and what is ruled out, updated at each step.
- Do not investigate in the same thread as the analyst; delegate reads and measurements, keep decisions.
- On handoff, write the state note and the forbidden list, and wait for acknowledgment.
- Escalate severity when data is at risk and switch to the destructive-action gate.
