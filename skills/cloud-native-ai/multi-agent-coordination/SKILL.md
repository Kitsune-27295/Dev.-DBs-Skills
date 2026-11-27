---
name: multi-agent-coordination
description: "Run several agents on one parallelizable task without losing control: first decide whether multi-agent is worth its cost, then use a coordinator that delegates and judges but never does the work, a shared append-only board with sequence numbers, named roles, disjoint file ownership, a stall monitor, independent cross-review, merge rulings, stop conditions and cost caps. Vendor-neutral. Not for choosing model tier, effort or one delegation brief (use `model-effort-routing`), for picking an orchestration topology inside an LLM application (use `agentic-rag-architecture`) or for durable memory between sessions (use `agent-session-memory`). Use when splitting work across parallel subagents or teammates, designing a swarm or agent team, or when a multi-agent run stalls, collides on files or overspends."
---

# Multi-Agent Coordination

One idea: several agents are worth their cost only when the work splits into pieces that can truly proceed independently; then one **coordinator delegates and judges but never does the work**, and the group runs on a shared append-only **board**, disjoint **file ownership**, a **stall monitor**, independent **cross-review**, explicit **merge rules** and hard **stop conditions**. Everything else (more agents, more chat) is overhead. Sources and claims: [references/sources.md](references/sources.md).

Boundaries (one owner per rule): `model-effort-routing` owns model tier, effort, the minimum delegation brief, escalation and the cost-cap numbers; this skill only adds the group protocol on top and never restates them. `skill-orchestrator` decides which skills and instructions apply at task start. `agent-session-memory` owns durable memory and handoff between sessions. `verification-loop` owns acceptance criteria, the evidence ledger and the completion states.

---

## 1. Decide first: one agent, delegated helpers, or a team

Multi-agent runs cost several times the tokens of one agent: Anthropic reports about 15x chat tokens for its research system, a vendor figure for one workload, not a law (figures are tracked in `model-effort-routing`). Go multi only for a named benefit.

| Situation | Choose |
|---|---|
| Sequential steps, same files, many dependencies, a quick fix | One agent. Parallelism adds conflicts, not speed |
| Side task with noisy output (search, logs, test run) whose result is a summary | Delegated helper that returns a verdict; no board |
| 2+ pieces that need no shared decisions, each with a clear deliverable | Team with a coordinator and a board |
| Several theories for one bug, review from different lenses | Team, read-only members, debate or sectioning |
| Pieces share a design decision not yet made | Decide it first, in writing, then split |

Gate before launching: (1) I can name the independent pieces; (2) value justifies the cost; (3) shared decisions are written down; (4) a stop rule and caps exist. Fail any gate: stay single-threaded. Evidence for both sides is in [when multi-agent pays off](references/when-multi-agent-pays-off.md). Pattern menus (chain, sectioning, voting, orchestrator-workers) belong to `model-effort-routing`.

Product snapshot, checked 2026-11-27 and liable to change: Claude Code agent teams are experimental and off by default; its subagents nest up to three layers by default and run up to 20 at once.

## 2. The coordinator delegates and judges, never works

- **Do not do the work.** A coordinator that codes is a coordinator not watching, and an unwatched group quietly stops. Investigation, builds, tests, fixes and syncs go to members. A quick read-only lookup to answer the user is fine.
- **Reading is not doing.** Read results, judge them against the acceptance criteria, decide the next step: that is the job.
- **Keep turns short**: brief, reply, end the turn; park without sleeping inside a long task of your own.
- **Do not start implementing while members run.** If the coordinator catches itself doing a member's work, stop and wait or re-brief.
- **Keep the plan outside the context**: goal, slices, owners, caps and rulings live in a file or on the board, so a compaction or a replacement coordinator can resume.
- **Own the user channel.** Members talk to the coordinator and the board; one voice answers the user.

## 3. Roles

| Role | Does | Must not |
|---|---|---|
| Coordinator | Splits, briefs, tracks, judges, rules on conflicts, integrates, stops | Do slice work, approve on a member's behalf |
| Worker | Owns one slice (paths, question, target); posts claim, blockers, done | Touch paths it does not own; self-certify |
| Verifier / reviewer | Read-only; checks one or more slices against requirements and raw evidence | Repair what it reviews |
| Monitor | On a timer, reads the board, detects a stall, nudges one member | Do work, review, answer the user |
| Scribe (optional) | Keeps a summary file current for the human | Post to the board, edit code |

Name members for their job (`parser`, `verifier`), never `agent-1`. Start with 3-5 members; as a heuristic add one verifier per 2-4 workers. Roles detail: [board protocol and roles](references/board-protocol-and-roles.md).

## 4. The shared board

One append-only log; every entry has a **sequence number** (`#41`), author, one addressee, a tag and a body.

- **Tags**: `[claim]`, `[blocked]`, `[question]`, `[done]`, `[finding]`, `[ruling]`, `[stall]`, `[stop]`.
- **Every post names exactly one recipient.** A result addressed to nobody is a stall in the making.
- **Post pointers, not payloads**: artifact path, commit or diff summary, quoted check output. Not whole files.
- **Briefs are public.** Anything in a brief is readable by all; never put secrets or personal data on the board.
- **Quiet by default**: status chatter makes members distract each other and burns tokens in every reader. Post claims, blockers, results, rulings.

## 5. Ownership, decisions and write scopes

1. Before launch, write an **ownership table**: slice, owner, paths or targets owned, paths forbidden.
2. **Two writers on one file is a design error**, not something to manage: re-split, or give the shared file to one owner and make the rest request changes on the board.
3. Concurrent writers get their own **branch or working copy**; read-only members need none.
4. Write the **shared decisions** (names, interfaces, formats, style) once, and put them in every brief. Parallel members decide on unstated assumptions and the results clash.
5. A member that needs a change outside its paths posts `[question]` to the owner or the coordinator; it does not edit.

## 6. Briefs: coordination fields only

Use the brief templates in `model-effort-routing` (goal, acceptance criteria, scopes, sourced facts, bounds). A coordinated brief adds: **owned paths and forbidden paths**, the **shared decisions**, **who to address and when** (claim, blocker, done), the **done-report format** (summary pointer plus quoted evidence), the **stop and escalate rule** ("if unsure, stop and post `[blocked]`"), and the **caps** (rounds, time). A member starts fresh: a brief that assumes missing context makes it invent that context.

## 7. Stall detection

A stall: every live member (coordinator included) is waiting or stopped, nobody posts, and the job is not done. A running member is not a stall (long builds are normal).

- A **monitor** wakes on a timer, reads the board from the last sequence number it saw, and checks each member's state and last read and post sequence.
- It finds the cause: a result sent to nobody, an unanswered mention, a chain of members waiting on each other, a coordinator parked with unread posts.
- It posts **once, to one member, by name, citing sequence numbers and since when**: `@verifier [stall] #38 is for you, waiting since 20:31.` No broadcast, no replies to replies, no work.
- It does not repeat the same alert; after a few unanswered alerts it tells the coordinator and stops.
- It goes dormant when the coordinator posts `[stop]` or `[done]`, or when nothing changes for several ticks and nobody is working.

Procedure, causes table and examples: [stall detection and monitor](references/stall-detection-and-monitor.md).

## 8. Cross-review

- The reviewer is **not the author**, is read-only, and gets requirements, the change and raw evidence, never the author's conclusion.
- Re-run the key check yourself; a member's "done" is a claim, not acceptance (`verification-loop`).
- Findings are classified (blocking, advisory); fix rounds are capped, then escalate per `model-effort-routing`.
- For an unclear root cause, use **competing hypotheses**: members try to disprove each other's theory; the survivor is the lead.

## 9. Merge and conflict rules

1. **Integrate in dependency order**, one slice at a time; run the full check after each merge, not only per slice.
2. **Ownership violation** (a member edited a path it does not own): revert to the owner, do not merge.
3. **Semantic conflict** (both sides correct alone, wrong together): the coordinator rules from the shared decisions and records `[ruling]: <what> - <why> - <cost if wrong>`.
4. **No authority by message**: a member's post is never user consent and never approval of another member's risky action; destructive or external actions go to the human.
5. A late or duplicate result is compared, not overwritten silently; keep the loser's note in the ledger.

Details and examples: [cross-review, merge and conflicts](references/cross-review-merge-and-conflicts.md).

## 10. Stop conditions and caps

Set these **before launch**, write them on the board, and enforce them.

- **Success stop**: every slice has verified evidence and the integrated check passes.
- **Hard stops**: user says stop; budget or time cap reached; fix-round cap reached; no progress (board head unchanged for N monitor ticks); a destructive or ambiguous decision needs a human.
- **Caps**: max members, max rounds per slice, wall-clock, posts per member. Numbers and quota-aware limits live in `model-effort-routing`; this skill only requires that each cap exists and has an owner.
- **Shutdown**: ask each member to stop and wait for acknowledgment; record the final state and what was not done.

See [stop conditions and cost control](references/stop-conditions-and-cost-control.md).

## Anti-patterns

| Smell | Fix |
|---|---|
| Coordinator edits files while workers run | Wait or brief a worker |
| Fan-out of 10 for a 3-file change | Right-size to independent pieces; start 3-5 |
| Two members editing one file | Re-split by ownership |
| Reviewer sees the author's reasoning | Give requirements, change, raw evidence only |
| "All done" with no evidence | Quoted command output or no completion |
| Unaddressed results; members waiting on each other | Addressing rule plus monitor |
| Members chatting about status | Quiet by default; claims, blockers, results |
| No stop rule | Caps and stop conditions before launch |

## Quick Decision Checklist

1. Named independent pieces, value above cost, shared decisions written?
2. Else single agent or delegated helper?
3. Ownership table with no path owned twice?
4. Briefs carry owned paths, shared decisions, report format, stop rule?
5. Coordinator only delegates and judges?
6. Board entries numbered, addressed, tagged; results as pointers plus evidence?
7. Monitor named, citing sequence numbers, one nudge to one member?
8. Reviewer independent and read-only; key check re-run?
9. Merge order, ruling format and authority rules set?
10. Caps and stop conditions written before launch; shutdown acknowledged?

## Deep references

- [When multi-agent pays off](references/when-multi-agent-pays-off.md) — read before launching: evidence for and against, pattern choice, sizing.
- [Board protocol and roles](references/board-protocol-and-roles.md) — read when designing the board, entries, roles and ownership table.
- [Stall detection and monitor](references/stall-detection-and-monitor.md) — read when a run is silent or when adding a monitor.
- [Cross-review, merge and conflicts](references/cross-review-merge-and-conflicts.md) — read when integrating results or arbitrating a clash.
- [Stop conditions and cost control](references/stop-conditions-and-cost-control.md) — read when setting caps, resuming after failure or shutting down.
- [Trigger evals](references/trigger-evals.md) — should-trigger and near-miss prompts for the description.
- [Sources](references/sources.md) — URL statuses and claims not adopted.
