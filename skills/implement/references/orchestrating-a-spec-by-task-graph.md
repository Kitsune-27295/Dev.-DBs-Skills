# Orchestrating a Whole Spec by Task Graph

Sources: https://github.com/mattpocock/skills/blob/main/skills/engineering/implement-spec/SKILL.md (MIT, read 2026-11-24 via the raw upstream file) · https://git-scm.com/docs/git-worktree · Last verified 2026-11-24

Scope: `implement` builds one ticket or a small set. Use this reference only when the request is to implement an entire spec and all its tickets end to end with subagents. Tiers and effort for each subagent are owned by `model-effort-routing`; do not restate them here. Spec and ticket creation are owned by `to-spec` and `to-tickets`.

## Core model (upstream idea, paraphrased)

The tickets of a spec are not a list of steps; they form a graph with blocking relations. At any moment a **ready frontier** exists: tickets whose blockers are all merged. The goal state is the entire spec on one **integration branch**, each ticket closed the way the issue tracker closes work.

## The loop

1. Read the spec and tickets; build the graph (which ticket blocks which).
2. Optionally run one **exploration subagent** to gather codebase or external-doc facts the tickets need, saving markdown notes outside the repo where every later subagent can read them. This keeps implementers on implementation.
3. Create the integration branch. If tracker or user wants a PR, open a draft only after the first merge (a branch with no commits ahead of the trunk cannot open one), marked as closing the spec and tickets.
4. For every ticket on the frontier start an **implementer subagent**, in the background where possible, each in its own worktree on its own branch. Each implementer: confirms its worktree is based on the integration branch (resets onto it if not), builds the ticket with `tdd`, and merges the integration tip into its branch before reporting done.
5. When an implementer finishes, a **merger subagent** merges its branch into the integration branch.
6. If a merge changes the frontier, immediately launch implementers for the newly ready tickets.
7. When all tickets are done, run `code-review` on the integration branch; fix everything in one implementer.
8. Mark the draft PR ready, or close each ticket per tracker convention and report the branch.
9. Remove all implementer worktrees (`git worktree remove`; submodule caveat in `git-atomic-commits`, reference on worktrees).

## Communication rules

- Pass **context pointers** (spec, tickets, research notes, commit ids), not copies of their content.
- Keep messages to and from subagents sparse; the report is a status and a commit pointer.
- Upstream starts every subagent with a fresh context window; this is why pointers must be sufficient on their own.

## Weights per subagent (local policy, not upstream)

The upstream file does not assign models. Local policy, with tiers deferred to `model-effort-routing`: exploration is read-and-gather, so the cheapest tier; implementers and mergers do bounded mechanical-to-moderate work, so the mid tier; the final `code-review` sets its own reviewer weights. Raise an implementer's tier only on evidence (a ticket that failed twice, or one touching money, auth or concurrency).

## Failure modes

- Parallel implementers editing the same files: the graph should isolate them; if two ready tickets touch one file, serialize them.
- Implementer starts from a stale base: step 4's base check and trunk merge prevent silent divergence.
- Merger resolves a conflict by guessing: it must stop and report when tests fail after merge.
- Orchestrator duplicating ticket text in prompts: drift; use pointers.
- Declaring done without the full-suite run and review on the integration branch.

## How an agent should apply this

- Use this loop only for whole-spec requests; for one ticket use `SKILL.md` directly.
- Compute the frontier from blocking relations before launching anyone; launch the entire frontier at once.
- Give each subagent a worktree, a branch, pointers, and acceptance criteria; read its report and re-run the key check yourself before merging further.
- Set `model` and `effort` on every call per `model-effort-routing`; never rely on the session default.
- Finish with `code-review` on the integration branch and clean up worktrees you created.
