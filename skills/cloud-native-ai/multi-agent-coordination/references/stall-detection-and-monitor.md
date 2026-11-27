# Stall Detection and Monitor

Sources: https://code.claude.com/docs/en/agent-teams · https://www.anthropic.com/engineering/multi-agent-research-system · Third-party skills read for ideas, no text reused (see sources.md) · Last verified 2026-11-27

A group can stall without any error: every member (the coordinator included) is parked waiting for someone else, nobody posts, nobody wakes, and the job is unfinished. A timer-driven monitor wakes regardless and breaks the silence. The design below is this skill's own; the failure modes it targets are documented in the sources (agents stopping early, task status lagging, a lead that declares the team finished too soon, endless searching, agents that keep going after having enough).

## Definition

Stalled = every live member except the monitor is `waiting` or `stopped`, **and** the job is not marked done. If anyone is `working`, it is not a stall: a long build or a slow research loop is normal. Do not nudge a working member.

## Member states the monitor needs

For each member: `state` (working, waiting, stopped, killed), what it waits on (mentions only, or anything after sequence N), `last_read_seq`, `last_post_seq` and its time. If the runtime exposes no state, the monitor infers it from the log: time since the member's last post, and whether it was addressed after that post.

## Procedure per tick

```
read board entries after LAST; LAST = highest seq read
if board has [stop] or [done] from the coordinator -> go dormant
if any member is working -> no stall; end tick
find cause (table below); post at most ONE nudge to ONE member
record: alert key (cause + seqs) and tick number
wait for next tick (mentions only)
```

## Causes and the one nudge

| Cause (from the log) | Nudge |
|---|---|
| A result was posted after the coordinator's last read and names nobody | To the coordinator: `[stall] #41 (parser result) and #42 name nobody; waiting since 20:31.` |
| The coordinator parked with unread posts | Same, naming the unread `#seq` values |
| A member was addressed after its own last post and never answered | Re-ping that member: `@verifier [stall] #38 is for you.` |
| Same member ignored a re-ping on a later tick | To the coordinator: member may be out of quota or crashed; replace it or switch its model |
| A chain: A waits on B waits on C | To the coordinator: who waits on whom, since which `#seq`; the root is the member at the end |
| Everyone waiting, nothing above matches (for example no work handed out) | To the coordinator: who is waiting and each member's last `#seq` |

Always cite sequence numbers and "since when". A nudge without numbers cannot be verified by the receiver.

## Monitor rules

- **Never do the work**: no editing, building, reviewing, answering the user.
- **One nudge, one member, by name.** No broadcast, no reply to replies, no posting about the monitor's own state.
- **No repeats**: do not alert about the same stall twice in a row; alert again only if something changed or after a few more ticks; after about three unanswered alerts on one stall, stop alerting about it and leave it to the coordinator.
- **Channels** (if the board has them): an unaddressed post inside a side channel reaches only that channel's members, so check each channel for a result that went to nobody.
- **Go dormant** when the coordinator posts `[done]` or `[stop]`, when no live member is left, or when nothing has changed and nobody is working for several ticks. Wake on any new post. A dormant monitor costs nothing.
- Tick interval: a few minutes is enough; shorter ticks cost tokens for nothing.

## Other silence the monitor cannot see

- **Silent loops**: a member that keeps working but makes no progress (the research write-up lists endless searches and continuing after enough results). Detect by a **no-progress counter** on the coordinator side: no new `[done]` or `[finding]` for N ticks while members work, then ask each for a one-line status and apply the round cap.
- **Early stop**: a member that stops after an error without telling anyone, or a coordinator that declares the team finished before all tasks are done. The coordinator re-checks the ownership table against evidence before accepting `[done]`.
- **Hooks as gates** (where the runtime has them): run a check when a member is about to go idle or a task is about to complete, and bounce it back with feedback if the check fails. Cheaper than a monitor for quality, not for liveness.

## How an agent should apply this

- Add a monitor to any group of three or more members that runs unattended for more than a few minutes; skip it for short interactive runs.
- Give the monitor board-read and post tools only, and a brief that repeats the rules above.
- Make the addressing rule part of every worker brief, since most stalls are results sent to nobody.
- Keep a no-progress counter and a round cap on the coordinator side; the monitor detects silence, not futility.
- When the monitor says a member is unresponsive after two nudges, replace it rather than waiting.
