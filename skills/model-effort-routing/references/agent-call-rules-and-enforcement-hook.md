# Agent-Call Rules and the Enforcement Hook

Sources: Local operating practice (private notes, summarised; not a public URL) · Last verified 2026-11-23

Agents that have a definition file choose their own model there. Built-in agent types (general-purpose, a catch-all, an explore type) have **no file**: unless the launching call sets `model`, they silently run on the session model, which is usually the most expensive one. A routing policy therefore needs both per-call rules and enforcement.

## Per-call rules

| Kind of agent / call | Model | Effort | Why |
|---|---|---|---|
| Read-only search, lookup, trace, fetch, count (tools limited to read/grep/glob/shell) | lightest | low | Mechanical gathering; no judgement to protect. |
| Bulk mechanical work that edits files: ingest waves, translation, extraction, i18n, doc moves, surveys that write a report | mid | medium | Needs reliable tool use, not deep reasoning. |
| Review, audit, root cause, design, security, shared-state queries, anything that judges | strongest, or omit/`inherit` | high | Errors here are expensive; do not downgrade. |
| Planning agent | inherit the session model | n/a | Design work keeps the session model on purpose. |
| Fork | inherits the lead's effort | omit | A fork runs at the lead's own effort. |

Rules for agent *definition files*:
- A read-only search/lookup/trace agent sets the light model in its file; every mirror copy of the definition (e.g. a second agents directory) must match, and so must any **template** kept as documentation: an installed light copy whose template has no model reverts to the expensive model on the next install.
- A reviewer, auditor, root-cause or editing agent omits `model` or sets `inherit`.
- Judge each agent by what it does, not its name.

## Research-skill caps

Research skills fan out and are the easiest place to burn tokens. Typical caps in this policy: light model in the header, at most 3 researcher subagents (default 2), no extra research round, one web search first and a second only if the first is thin or contradictory, at most 3 sources captured per question, redundant steps merged.

## A related environment variable

A global "subagent model" environment variable has changed rank across versions: in older versions it overrode every subagent model (including per-call and `inherit`, which would also downgrade reviewers); in newer ones (stated as v2.1.251 in the notes) it is only the default for subagents that set nothing. Check the CLI version before relying on it.

## Enforcement: a pre-tool hook

Prose rules are ignored under load; a hook makes the omission impossible. Logic of the guard, in words:

1. Run before every Agent/Task tool call; read the JSON event from stdin.
2. Pass immediately if the event is malformed, is not an Agent/Task call, or has no object input: a broken hook must never block the harness.
3. Extract the agent type (lower-cased, trimmed) and `model` (trimmed).
4. If the type is in the guarded set (empty/untyped, general-purpose, the catch-all, explore) **and** model is empty, emit a *deny* decision whose reason lists the choice by work (light = read-only search/lookup/fetch/count; mid = bulk mechanical editing; session model = review/audit/root cause/design/security) and points at the rule.
5. Otherwise pass: typed agents (their file decides), forks, and calls that already name a model.

```python
GUARDED = {"", "general-purpose", "claude", "explore"}
def decide(event):
    if event.get("tool_name") not in ("Agent", "Task"): return None
    inp = event.get("tool_input")
    if not isinstance(inp, dict): return None
    kind  = str(inp.get("subagent_type") or "").strip().lower()
    model = str(inp.get("model") or "").strip()
    if kind in GUARDED and not model:
        return deny("Set `model` by the work: light=search, mid=bulk edit, session=judge")
    return None            # anything else, or any parse error: allow
```

Install: copy the script into the hooks folder and register it under the PreToolUse hook list with matcher `Agent|Task`. The refusal is one-shot: the retry that names a model passes, so the cost of the guard is one extra round-trip, paid only when the caller forgot.

## Failure modes

- Hook that fails closed on bad input: blocks all agents. Always fail open.
- Guarding typed agents too: they already decide via their file; guarding them causes loops.
- Planner agent denied: design work should keep the session model.
- Rule text lives only in prose: callers drift back to the default within days (see measuring-and-auditing-model-usage for the evidence approach).

## How an agent should apply this

- Always set `model` (and `effort`) on a built-in agent call, chosen by the table above, before the hook has to ask.
- Never put a reviewer or auditor on the light model to save tokens.
- When creating an agent definition, set its model by function and update every mirror and template.
- Cap research fan-out: 2 subagents by default, 3 sources per question.
- Install the guard hook if you control the harness config; keep it fail-open.
