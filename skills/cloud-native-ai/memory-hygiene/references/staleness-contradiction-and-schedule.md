# Staleness, Contradiction and Schedule

Sources: https://arxiv.org/html/2605.26112 · https://arxiv.org/html/2304.03442v2 · https://code.claude.com/docs/en/memory · https://www.anthropic.com/research/effective-context-engineering-for-ai-agents · https://docs.letta.com/configuration/memory · Last verified 2026-11-27

## Why stale memory is dangerous

Retrieval and loading do not check truth. The Claude Code memory docs describe an index (`MEMORY.md`, first 200 lines or 25 KB loaded at session start) and topic files read on demand: nothing in that path asks whether a path or ID in a note still exists. Anthropic's context-engineering article describes context rot, where recall degrades as the window fills, so a wrong note competes with correct facts for a shrinking budget. The harness paper read for this skill (arXiv 2605.26112, section 4.2 as extracted) makes the sharper point that stale items rarely stop being retrieved: they keep ranking high while their targets have changed, and it proposes penalizing staleness relative to the last verification time. Generative Agents already uses a recency factor in retrieval scoring (exponential decay since last access), but access recency is not verification recency: a note read often can be wrong for months (inference).

## Prioritizing the queue

Sweep the riskiest entries first when time is limited. Own heuristic:

| Priority | Entry |
|---|---|
| 1 | Environment facts with no `last_verified` |
| 2 | Environment facts older than the last known environment change |
| 3 | Environment facts older than about 30 days (default; tune per project) |
| 4 | Entries that were recalled and acted on recently |
| 5 | Preferences and decisions (contradiction and premise checks only) |

Entries used to justify irreversible actions (deploys, deletions, migrations) jump the queue: verify them before acting, not at the next sweep.

## Contradiction rules

Detect: same subject (same path, tool, person, setting) with different values in two entries, or an entry that disagrees with an instruction file.

| Classes in conflict | Winner | Action |
|---|---|---|
| Environment fact vs environment fact | The live environment | Fix or supersede both; keep the verified value |
| Preference vs preference | The newer entry, unless the user says otherwise | Mark the older `superseded`; ask the user when the stakes are high |
| Decision vs decision | Neither automatically | Propose an explicit superseding decision; a person accepts (`adr-architecture`) |
| Memory vs instruction file | The instruction file owns rules (`skill-orchestrator`) | Remove or link the memory copy; one owner (`ssot-and-dry`) |

The Claude Code docs warn that two contradictory instructions may be followed arbitrarily and advise reviewing instruction files periodically for outdated or conflicting content; the same applies to memory entries. The docs' `/doctor prompt-audit` checks instruction files for outdated or conflicting content and proposes edits without applying them; auto-memory entries are not among the files it is described as covering, which is why this skill exists.

Example (own):

```
entry A (2026-08-02): "integration tests run with `make it`"
entry B (2026-10-19): "integration tests run with `just test-int`"
-> environment fact: check the repo. If a justfile target exists and the Makefile target does not,
   B is verified; mark A superseded_by B; report old -> new.
```

## Consolidation without silent loss

Some systems consolidate memory automatically in the background (the Letta page describes "dreaming": background subagents that review conversations and consolidate lessons, with an "agent reviews before applying" option that revises updates without asking the user, and a `/doctor` audit of placement and duplication). Consolidation is convenient but merges can erase the evidence that made a claim trustworthy. This skill's rule: merging or rewriting entries is a **proposal** listed in the report, applied only after confirmation, and always keeping a backup or the superseded originals. Letta's page describes backing up the repository before splitting, merging or restructuring; the same precaution applies here.

## Schedule

| Trigger | Scope |
|---|---|
| Monthly (default cadence; own default, not a standard) | Full sweep, environment facts first |
| A recalled fact turned out wrong | Entry and its neighbors on the same subject, immediately |
| Environment change (rename, migration, version upgrade, repo move) | Entries mentioning the changed thing |
| Before an irreversible action based on old notes | The specific entries relied on |
| Memory index nearing its size limit (Claude Code reminds the agent near 200 lines or 25 KB; text past the limit is dropped on load) | Merge or archive proposals (limits owned by `skill-orchestrator`) |

How to schedule: in an interactive session, note the next sweep date in the last report's "Waiting on you" line; for recurring runs use the harness's scheduler or a calendar reminder that opens a new session with this skill. A sweep never needs to run unattended with write access beyond stamps and logged corrections.

## Measuring whether it works

The paper argues that one-shot evaluation cannot show whether memory is becoming more useful or more harmful over repeated use, and that memory hygiene should be measured longitudinally. Practical form: the scorecard delta between reports. A rising `drifted` count means the environment is changing faster than the cadence (shorten it) or notes are recording volatile facts (stop storing them; point to the source instead). A rising `unverifiable` count means notes hold things nothing can check; consider turning them into a link or dropping them via proposal.

## Failure modes

| Failure | Prevention |
|---|---|
| Sweep becomes an investigation | Per-entry time box; mark unverifiable |
| Cadence ignored | Put the next date in the report; add event triggers |
| Volatile facts stored again right after cleanup | Store the pointer (where to look), not the volatile value |
| Merge destroys history | Proposals only; keep originals |

## How an agent should apply this

- Order the queue by risk (unstamped environment facts, then oldest), and verify before acting when the action is irreversible.
- Resolve conflicts with the class table; decisions are resolved only by a superseding record.
- Treat automatic consolidation as a proposal and keep originals.
- Read the scorecard delta: shorten the cadence or stop storing volatile facts when drift rises.
- State the next sweep date and the event triggers at the end of every report.
