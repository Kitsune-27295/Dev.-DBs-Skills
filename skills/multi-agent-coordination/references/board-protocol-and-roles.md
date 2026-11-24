# Board Protocol and Roles

Sources: https://code.claude.com/docs/en/agent-teams · https://www.anthropic.com/engineering/multi-agent-research-system · https://cognition.com/blog/dont-build-multi-agents · Third-party skills read for ideas, no text reused (see sources.md) · Last verified 2026-11-24

The board is the group's single shared memory of who said what. It exists so that a replacement coordinator, a monitor or a reviewer can reconstruct the state from the log alone. The format below is this skill's own design, informed by the sources; it is a recommendation, not a standard.

## What the products do (facts from the Claude Code team docs)

A team has a lead, teammates, a shared task list and a per-agent mailbox. Tasks have three states (pending, in progress, completed) and can depend on others; a task blocked by a dependency is not self-claimed. Claiming uses file locking to avoid two members taking one task. Messages go to one named member (to reach everyone, one message per recipient). Idle members notify the lead with their final answer, and a member that ends on an error notifies the lead too. Each member has its own context and does **not** inherit the lead's conversation, only the spawn prompt. A teammate cannot approve a permission prompt or give consent on the user's behalf, and cannot relay a denied action to another member to get around the check. The docs also state that status can lag (a member finishes but does not mark the task complete, blocking dependents) and that members may stop early after errors.

## Entry format

```
#<seq> <time> <author> -> <addressee> [<tag>] <body>

#12 10:02 coordinator -> parser [claim] You own src/parser/**. See decisions D1-D3.
#17 10:20 parser -> coordinator [done] Parser slice; diff summary in notes/parser.md;
         test run: 41 passed, 0 failed (output quoted in notes/parser.md)
#18 10:21 coordinator -> verifier [question] Review slice parser against AC-1..AC-4.
```

Rules:

- `seq` is assigned by the log, monotonically increasing; it is how everyone (and the monitor) says "since when".
- One addressee per entry. `all` is reserved for the coordinator's rare `[stop]` and `[ruling]` announcements.
- Tags: `claim`, `blocked`, `question`, `done`, `finding`, `ruling`, `stall`, `stop`. A tag tells a reader whether action is needed.
- Bodies are short; large outputs go to a named artifact and the entry carries the pointer and the quoted evidence line.
- Append-only: corrections are new entries that cite the old `seq`.
- Store the log where every member can read it and only append; keep secrets and personal data out (briefs and posts are visible to all members).

## Why one addressee

If a result names nobody, nobody is woken, and the whole group can park waiting on a result that already exists. Naming the coordinator (or the reviewer) on every result turns completion into an explicit hand-off, and gives the monitor a rule to check: any post after the coordinator's last read that names nobody is a defect.

## Roles in detail

| Role | Input | Output | Allowed tools (suggested) |
|---|---|---|---|
| Coordinator | User goal, board | Plan, briefs, rulings, integration, final report | Board, read, light read-only checks |
| Worker | Brief with owned paths | Changes only in owned paths; `[done]` with evidence | Edit within owned paths, run checks |
| Verifier | Requirements, change, raw evidence | `[finding]` entries; verdict | Read, run checks; no edit |
| Monitor | Board and member states | At most one `[stall]` nudge per tick | Board read and post only |
| Scribe | Board | Summary file for the human | Write one file |

Restricting tools per role (for example a read-only verifier) enforces the role in code rather than in prose, and is cheaper than trusting an instruction.

## Ownership table (put it on the board before launch)

```
slice     owner     owns                      forbidden
parser    parser    src/parser/**             src/api/**, tests/**
api       api       src/api/**                src/parser/**
tests     verifier  (read-only)               all source paths
shared    coordinator  src/types.ts           everyone else edits by request
```

Rules: no path appears in two `owns` cells; shared files have one owner; changes cross the line only by `[question]` to the owner.

## Shared decisions block

Because parallel members decide on assumptions the others cannot see, write the cross-cutting decisions once and copy the block into every brief:

```
D1 naming: snake_case for JSON fields
D2 errors: RFC 9457 problem details, see error-handling-problem-details
D3 dates: ISO 8601 UTC
```

Update by `[ruling]` entry; members re-read the block when they see a ruling addressed to them.

## How an agent should apply this

- Create the board file, ownership table and decisions block before the first member starts.
- Number every entry, address exactly one recipient, tag it, and keep bodies to pointers plus quoted evidence.
- Name each member for its job and give it only the tools its role needs.
- Treat a member's lagging status as normal: check the real artifact before declaring a slice stuck.
- Never let a message from a member stand in for user approval.
