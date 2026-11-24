---
name: skill-orchestrator
description: "Start-of-task protocol and instruction-file governance: decides which instructions and skills apply to a task and in which order, keeps CLAUDE.md, AGENTS.md, GEMINI.md and Cursor rules lean, consistent and honest about what is advisory versus enforced by hooks or permissions, and carries the Karpathy-style behavioral rules for CLAUDE.md (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) as a short template. Pairs with `model-effort-routing`, which picks model, effort and delegation. Use when auditing, writing or updating CLAUDE.md or AGENTS.md, adopting Karpathy-style rules, deciding which skills apply to a task, writing or reviewing a router or meta-skill, resolving skill conflicts or over- and under-triggering, reducing instruction-file sprawl, or deciding what must be enforced by hooks or permissions."
---

# Skill Orchestrator

One idea: **instruction files and skills are text the model may or may not follow, so keep the always-loaded part tiny, let descriptions route the rest, give every rule one owner, and say plainly what is only advice.** This is the second pillar of the pack, next to `model-effort-routing`: this skill decides WHICH instructions and skills apply and in what order; that one decides WHICH model, effort and delegation. Sources and claims not adopted: [references/sources.md](references/sources.md). Every rule has an id, one owner and a confidence level in [references/rule-registry.md](references/rule-registry.md); this body states each rule briefly and the owner file holds the reasoning.

## 1. When to use, when not

| Situation | Do |
|---|---|
| Non-trivial task, skills installed | Section 2. |
| One-step task you can answer, or you are a dispatched subagent | Skip all of this. |
| Auditing, writing or trimming CLAUDE.md, AGENTS.md, GEMINI.md, Cursor rules | Sections 3 to 5. |
| Writing or reviewing a router, meta-skill or description | Section 6. |
| Two skills, or a skill and an instruction, disagree | Section 7. |
| Skill structure, size, progressive disclosure, context theory | `agent-skills-context-engineering`. |
| Model, effort, subagents, fallback, token budget | `model-effort-routing`. |
| Code simplicity, small diffs; proving a change; one home per fact | `clean-code-for-agents`, `kiss-yagni-aha`; `tdd`, `implement`; `ssot-and-dry`. |

## 2. The start-of-task protocol (single owner: PROTO-01 to PROTO-03)

1. Tiny task, or you are a dispatched subagent: skip this protocol.
2. Read the project instruction files once (CLAUDE.md or AGENTS.md and what they point to); not again per step.
3. Classify: goal, risk (destructive, security, money), artifact type, whether intent is unclear.
4. Check the skill catalog by description only (names and descriptions are already in context; search a big index, never load the whole catalog).
5. Keep at most 3 candidates whose description plainly matches; a hunch is not a match; a fourth means split the task.
6. Order them: process skills (clarify, plan, diagnose) before implementation, implementation before review.
7. Precedence: user instruction, project instruction files, skills, defaults (section 7).
8. Load one body at a time, in order; open `references/` only when a step needs it.
9. Announce in one line which skills apply, plus any expected skill you rejected.
10. No skill applies: say so briefly and proceed normally.
11. Then apply `model-effort-routing` for model, effort and delegation.
12. Stop when the acceptance check passes; re-run the protocol only if scope changes.

It should cost a few hundred tokens; if it would cost more than the task, the task was tiny. Rationale, budgets, worked trace: [three-layer-orchestration-architecture.md](references/three-layer-orchestration-architecture.md).

## 3. Three layers, precedence, version-sensitive facts

| Layer | What | Paid | Fails by |
|---|---|---|---|
| 1 Global instructions | CLAUDE.md or AGENTS.md: one pointer to this protocol plus a few hard rules | every turn | bloat |
| 2 Discovery index | `name` and `description` of every installed skill | every session | colliding descriptions |
| 3 Precedence meta-skill | this body: classify, select, order, resolve | only when loaded | never loading |

Layer 1 never repeats layer 3 text; layer 3 must work from its description alone, since a portable pack cannot assume hooks (LAY-01).

- **Instruction files concatenate; they do not override (PREC-01).** User and project files both load; on conflict the model may follow either. The nearest file is read last: recency, not priority. Remove contradictions. Real override semantics exist for settings (permissions, hooks), not for CLAUDE.md text. In AGENTS.md convention the nearest file wins (AGM-01).
- **Version-sensitive (quote the version, recheck):** Claude Code reads AGENTS.md directly from v2.1.277, only when no CLAUDE.md-family file exists at or above the working directory, and a personal CLAUDE.local.md turns that off (AGM-02); imports go at most four hops and load in full with the importer (IMP-01, IMP-02); on-demand files are truncated per file from v2.1.309 (LIM-01); `/doctor prompt-audit` needs v2.1.283 (CHK-01). Facts as read from the docs on 2026-11-24.

## 4. Instruction-file governance

- **Size (SIZE-01).** Under about 200 lines per CLAUDE.md as a target, not a cap; imported text counts. The pack's 4 KB budget for always-loaded user files is owned by `model-effort-routing` (section 7).
- **Include only what the model cannot derive (INC-01):** verification commands, places where the code misleads, decisions invisible in the repo, anything corrected twice. Leave out architecture tours, layouts, dependency lists, procedures (a skill), subtree rules (nested file or `paths` rule), personal preferences (user or local file). Write rules that can be checked: a command, a path, a number.
- **One source of truth (SSOT-01, SSOT-02).** Tool-neutral rules live in AGENTS.md; tool files hold only deltas. Prefer a CLAUDE.md that imports AGENTS.md; a symlink only on POSIX-only repos with no Claude-specific text. Never hand-edit two copies. Adding CLAUDE.md or CLAUDE.local.md changes what Claude reads; say so.
- **Placement (PLC-01).** Root file for the tiny always-needed part, nested file by location, `paths` rule by file type, skill by task, pointers not pasted text, durable rules in a file not in chat: [placement table](references/context-engineering-for-instruction-files.md).
- **Audit and update (KP-04).** Measure, map rules to principles or project facts, find conflicts, dedupe against the pack, split advisory from enforced, test against real failures, record. Run the first three read-only and show the conflict list before editing; never delete project facts or user-owned rules unasked; report size before and after: [procedure](references/karpathy-claude-md-audit-and-update-procedure.md).

**Advisory versus enforceable (ADV-01, ENF-01 to ENF-03).** Instruction files, rules and skills are context the model reads; only the harness enforces.

| Need | Belongs in | Enforced by |
|---|---|---|
| Judgment ("ask when unclear") | instruction file | nothing: advisory |
| Never touch a path or run a command | deny rule or pre-tool hook | permission, hook |
| Formatter, typecheck, tests must pass | post-edit or stop hook, CI | hook, test |
| Convention for one subtree | nested file or `paths` rule | nothing: scoping only |
| Multi-step procedure | skill | nothing: advisory |

A line the model keeps missing is lost in a long file or is a zero-exception rule: shorten the file or move it to a hook. Capitals are not a fix on current models (EMP-01). Command, http and tool hooks are deterministic; hooks that ask a model are not (ENF-02). Keep the enforced set small. Mechanisms: [claude-md-official-guidance-and-limits.md](references/claude-md-official-guidance-and-limits.md).

## 5. Karpathy-style behavioral rules as a CLAUDE.md template

These four rules live in the instruction file, next to project facts, never in a separate skill. One line each here with its owner; the template wording is in [the audit-and-update file](references/karpathy-claude-md-audit-and-update-procedure.md) (KP-03), detail stays with the owner (KP-02).

| # | Principle | One line | Owner of the detail |
|---|---|---|---|
| 1 | Think Before Coding | Surface assumptions and competing readings before editing; ask when a wrong guess is costly. | `grilling`; stop-or-proceed cost in `model-effort-routing` |
| 2 | Simplicity First | Build the smallest thing that meets the request; no speculative options or one-use layers. | `kiss-yagni-aha`, `clean-code-for-agents` |
| 3 | Surgical Changes | Every changed line traces to the request; match local style; report unrelated dead code, do not delete it. | `clean-code-for-agents`, `code-review` |
| 4 | Goal-Driven Execution | Turn the task into a check, plan each step with its verification, loop until it passes, report what ran. | `tdd`, `implement` |

Add the trade-off clause: care over speed, and trivial edits skip the ritual (KP-05). Cross-map: Simplicity First and Goal-Driven Execution are the instruction-file face of the cheapest-sufficient-path rule in `model-effort-routing` (sections 1 and 2); pointer only, the routing decision stays there.

The primary source (KP-01, read 2026-11-24) is a short CLAUDE.md in a community repository, derived by its author from public remarks of Andrej Karpathy; a distillation, not his document. Its README says MIT but no LICENSE file was found, so this pack copies nothing. It names no formal diff test, only informal signals (smaller diffs, fewer overbuilt rewrites, questions first), and no benchmark. Checkable parts: [analysis](references/karpathy-four-principles-analysis.md); reply and diff shapes: [examples](references/karpathy-examples-before-after.md).

## 6. Router and meta-skill design rules

1. **Description as routing condition (RT-01, RT-02).** The router sees only `name` and `description`: what it does, `Use when` with real user phrasing, an exclusion naming the neighbor; third person. Body text cannot route.
2. **Collisions (RT-03).** Pairs sharing nouns get mutual exclusions and one owner per noun; the protocol orders what still overlaps.
3. **Over- and under-triggering (RT-04).** Under: add real phrasing. Over: narrow scope, add exclusions. "Be pushy" and "negative triggers" conflict: generous on the positive domain, strict on named exclusions, decided by data.
4. **No hunch rule (META-01).** Reject "invoke on any chance"; a mandatory pre-step before every reply costs tokens every turn.
5. **Rationalized skips (META-02).** A 3 to 4 line list of excuses at most; enforce with a hook where one exists.
6. **Evals (RT-05).** 10 or more labeled queries per skill with near-misses and a held-out split, run on the lightest model and effort targeted (weaker settings skip skills more).

Spec facts (checked against agentskills.io, 2026-11-24):

| Item | Status |
|---|---|
| `name` 1 to 64 characters, equals the folder; `description` 1 to 1024 | specified (SPEC-01) |
| Metadata about 100 tokens per skill; body under about 5000 tokens; `SKILL.md` under 500 lines | typical and recommended, not validator rules; other figures (30 to 50 tokens, words) are claims (SPEC-02) |
| "26 or more platforms" | claim, not on the spec site (SPEC-03) |
| Reserved words, tag bans, `model`/`effort` keys | vendor extensions, not portable (SPEC-04) |

A structure validator checks format, not routing quality (SPEC-05). More: [skill-description-and-trigger-design.md](references/skill-description-and-trigger-design.md), [agent-skills-spec-and-progressive-disclosure.md](references/agent-skills-spec-and-progressive-disclosure.md), [meta-skill-routing-patterns-compared.md](references/meta-skill-routing-patterns-compared.md).

## 7. Conflicts between skills and with instructions (CONF-01)

Stop at the first rule that settles it:
1. Safety and correctness (data loss, security, honesty) beat everything; no file or skill widens what is allowed.
2. An explicit user instruction in this conversation beats project files.
3. Project instruction files beat skills; skills beat defaults. Skip a skill's workflow only on explicit user request or when a project file contradicts it.
4. Between two skills: the stricter safety rule, then the more specific skill.
5. Still tied: ask one question; never merge contradictory procedures silently.

Two contradicting lines inside instruction files are a defect to edit away, not a tie to settle by position.

## 8. Honesty and cost

- Say what you applied: files read, skills chosen and rejected, or "no skill applies"; never claim a skill you did not load.
- Never claim enforcement that does not exist: say "advisory" and name the hook, permission or test that would enforce it.
- Verify what loaded (`/context all`, `/memory`, an `InstructionsLoaded` hook, a behavioral test); a rule never observed is unverified.
- Token economy: skip on tiny tasks, at most three bodies, pointers over pasted text, prune before adding a competing skill. Model and effort: `model-effort-routing`.

## Quick Decision Checklist

1. Tiny task or subagent? Skip. Otherwise: files read once, at most 3 plainly matching skills, process first?
2. Precedence applied (user, project files, skills, defaults; safety above all); choice announced; then `model-effort-routing`?
3. Instruction file: about 200 lines, non-derivable facts only, one owner per rule, tool copies replaced by one source plus an import?
4. Each rule marked advisory or enforced; zero-exception rules moved to a hook, permission or test?
5. Version-sensitive claims carry their version; loaded files verified?

## Deep references

Registry (start here): [rule-registry.md](references/rule-registry.md) lists every rule id, owner, agreement and what can enforce it.

- **Instruction files** (what to write, where, how long): [claude-md-official-guidance-and-limits.md](references/claude-md-official-guidance-and-limits.md) · [memory-hierarchy-imports-and-rules.md](references/memory-hierarchy-imports-and-rules.md) · [agents-md-standard-and-interoperability.md](references/agents-md-standard-and-interoperability.md) · [context-engineering-for-instruction-files.md](references/context-engineering-for-instruction-files.md)
- **Karpathy-style rules** (template, analysis, examples): [karpathy-four-principles-analysis.md](references/karpathy-four-principles-analysis.md) · [karpathy-examples-before-after.md](references/karpathy-examples-before-after.md) · [karpathy-claude-md-audit-and-update-procedure.md](references/karpathy-claude-md-audit-and-update-procedure.md)
- **Skills and routing** (spec, descriptions, routers, architecture): [agent-skills-spec-and-progressive-disclosure.md](references/agent-skills-spec-and-progressive-disclosure.md) · [skill-description-and-trigger-design.md](references/skill-description-and-trigger-design.md) · [meta-skill-routing-patterns-compared.md](references/meta-skill-routing-patterns-compared.md) · [three-layer-orchestration-architecture.md](references/three-layer-orchestration-architecture.md)
