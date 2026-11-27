# Stop Conditions and Cost Control

Sources: https://www.anthropic.com/engineering/multi-agent-research-system · https://www.anthropic.com/research/building-effective-agents · https://code.claude.com/docs/en/agent-teams · https://code.claude.com/docs/en/sub-agents · Last verified 2026-11-27

Boundary: numeric budgets, quota-aware agent counts, effort and escalation rules are owned by `model-effort-routing`. This file only says which stop conditions and caps a coordinated run needs, and what the sources say about failure and resumption.

## Cost drivers specific to groups

- Each member is a separate context; token use scales with the number of active members, and every post is read by every other reader who sees it. Idle members still cost nothing, but chatty ones do.
- Vendor token multipliers and their caveats are tracked in `model-effort-routing` (`references/claims-vs-evidence-on-savings.md`). Reading for groups: spending more tokens helps only on tasks valuable enough; members beyond the independent pieces do not help.
- Team docs: tokens scale linearly with teammates, coordination overhead grows, returns diminish. Their advice: three focused members often beat five scattered ones; routine tasks belong to one session.
- In Claude Code, an in-process teammate's prompt cache holds five minutes by default (one hour with a setting, billed at a higher write rate), which makes sporadic long-idle members expensive to wake; keep members either busy or finished (product detail, may change).

## Stop conditions (set before launch)

| Type | Condition | Action |
|---|---|---|
| Success | Every slice has verified evidence; integrated check passes | Coordinator posts `[done]`, final report |
| User | User says stop or changes the goal | `[stop]`, shutdown protocol |
| Budget | Token, money or wall-clock cap reached | `[stop]` with state; report what is incomplete |
| Rounds | Fix-round or hypothesis-round cap reached | Escalate (fresh member, stronger tier, then human) |
| No progress | No new `[done]` or `[finding]` for N ticks while members work | Status check from each member, then re-split or stop |
| Risk | A destructive, external or ambiguous action is needed | Stop that slice; ask the human |

Agent-design guidance supports the same shape: stopping conditions such as a maximum iteration count keep autonomy in check, and agents should pause for human checkpoints when blocked or at risky points. Agents also need ground truth at each step (tool results, test output) rather than their own assertion.

## Caps to write on the board

- Max members and max depth of delegation (members creating members).
- Max rounds per slice and per hypothesis.
- Wall-clock limit; monitor tick count before dormancy.
- Max size of any single post; results by pointer.
- Who may raise a cap: the coordinator within a stated margin, the human beyond it.

## Failure and resumption (from the research write-up)

- Errors compound in long stateful runs. Resume from the last checkpoint instead of restarting; make tool failures visible to the agent so it adapts; add retries for transient faults.
- Long runs overflow context: summarize finished phases, store essentials outside the context, and when near the limit start a fresh member with a clean context handed off through the stored plan and summary. Members can return lightweight references to artifacts instead of copying content through the coordinator.
- Non-determinism makes identical runs diverge, so debugging needs the log (the board) and traces of decision patterns, not memory.
- Evaluate by **end state** and checkpoints for stateful work, not by exact path; a small set of representative cases already shows large effects.
- Session-level resumption can be weak in a product's team mode (members are not restored); design so a new member can pick up from the board and artifacts. For cross-session durability use `agent-session-memory`.

## Shutdown protocol

1. Coordinator posts `[stop]` to `all` with the reason.
2. Each member finishes its current step, posts a final `[done]` or `[blocked]` with the state of its owned paths, and acknowledges.
3. Coordinator waits for every acknowledgment (a member may finish its current call first, so shutdown can be slow), then records the final state: what was merged, what was not, open findings, rulings.
4. Release resources: worktrees, branches, background processes, timers (the monitor goes dormant).

## How an agent should apply this

- Write the stop table and caps on the board before launch; get a human OK on caps that spend money.
- Track one no-progress counter and one rounds counter; both trigger escalation, not another loop.
- Persist the plan and decisions outside the context so a restart resumes from a checkpoint.
- Measure the run: tokens per member, rounds used, outcome against criteria, and report it.
- Close with the shutdown protocol and a state per `verification-loop` (Implemented, Validated, Partially validated, Blocked).
