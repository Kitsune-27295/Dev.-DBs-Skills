---
name: skill-creation-workflow
description: "Procedure for creating, evaluating and shipping a new Agent Skill, or improving an existing one, so that it triggers correctly, ports across hosts and costs few tokens: capture intent with three real example requests and a no-skill baseline, run the admission check, design the folder (SKILL.md vs references vs scripts vs assets, freedom matched to task fragility), write a trigger-focused description, validate, evaluate with should-trigger and should-not-trigger prompt sets and with-skill vs baseline runs, iterate, then package and install per host with provenance and licence notes. Includes a SKILL.md skeleton and a pre-publish checklist. Use when asked to create, write, scaffold, test, tune the description of, package, publish or install a skill, or to port one between hosts."
---

# Skill Creation Workflow

One idea: **a skill is shipped like code: define the behavior it must change, measure it against a no-skill baseline, keep it small, and test its trigger separately from its output.** The steps below are the order of work; every format, admission, runtime and security rule has a single owner elsewhere in this pack and is linked, not repeated. Sources, retrieved statuses and unverified claims: [references/sources.md](references/sources.md).

> **Scope boundary:** format fields, progressive disclosure, admission questions and supply-chain governance live in `agent-skills-context-engineering`. Routing and instruction files live in `skill-orchestrator`. Model and effort choices live in `model-effort-routing`. Writing style for the body lives in `clean-code-for-agents` and `text-quality-gate`. Security review of someone else's skill lives in `software-supply-chain-security` and `oss-deep-audit`. This skill owns only the creation, evaluation and shipping procedure.

## 1. Capture intent (before any file exists)

1. Write **three concrete example requests** a real user would type (vary phrasing and detail). If you cannot, the idea is not ready.
2. Write what is **in scope** and **out of scope** in one line each; the out-of-scope line becomes the "do not use when" boundary.
3. Run the task once **without** the skill and record what the agent got wrong or lacked. That list of gaps is the whole content budget. Prefer material from a real hands-on task, real runbooks or real failures over a generic "best practices" summary.
4. Name the expected output (format, files) in plain words; assertions come later, after the first run.

Detail and worked example: [references/creation-workflow-and-degrees-of-freedom.md](references/creation-workflow-and-degrees-of-freedom.md).

## 2. Admission check

Apply the admission questions and contract checklist in `agent-skills-context-engineering` (`references/skill-admission-and-baseline-first.md`). If the agent already does the task well without the skill, or the need is a one-line rule, stop: put it in an instruction file (`skill-orchestrator`) instead.

## 3. Design

- **One coherent unit**, like one function: too narrow forces several skills to load for one task; too broad makes triggering imprecise.
- **Match freedom to fragility.** Open field (many valid paths): state goals and the why, leave the steps free. Narrow bridge (fragile, order-critical): give an exact command and forbid variations. Most skills mix both; calibrate each section on its own.
- **Provide a default, not a menu.** Pick one tool or path and name the escape hatch.
- **Place content by when it is needed:**

| Goes in | What | Why |
|---|---|---|
| `SKILL.md` | Core procedure, decision checklist, gotchas, short templates | Read on every activation |
| `references/` | Long analysis, schemas, per-domain detail, loaded on a stated condition | Costs nothing until read |
| `scripts/` | Deterministic, error-prone steps (validate, convert, scaffold) | Only output enters context |
| `assets/` | Output templates, static data, images | Loaded when the step needs them |

- Keep links **one level deep** from `SKILL.md` and say *when* to read each file ("read X if Y"), not "see references".
- Prefer procedures that generalize over answers for one instance; keep specifics in templates and constraints.

## 4. Write the description

The description is the only text the host sees before activating, so it carries the whole trigger burden.

- Imperative and intent-focused: say when to act, in terms of what the user is trying to achieve, including cases where they do not name the domain.
- State what the skill does **and** when to use it; be a little pushy about contexts; add the near-miss boundary ("not for ...") when a sibling skill exists.
- Third person; no XML tags.
- **Length:** the Agent Skills specification and the Claude platform docs cap `description` at 1,024 characters; Claude Code truncates `description` plus `when_to_use` at 1,536 characters in its listing. This pack is stricter on purpose: **at most 1,000 characters, ending with "Use when ..."** so it stays under the spec limit on every host with margin. Verify the real count with a script, not by eye.

Wording patterns, trigger-eval design and the tuning loop: [references/description-writing-and-trigger-evals.md](references/description-writing-and-trigger-evals.md).

## 5. Write the body

Lead with the procedure; add only what the agent would get wrong without you; one term per concept; explain why for flexible steps and give exact commands for fragile ones; put gotchas in `SKILL.md` where they are read before the mistake. Keep the body well under the spec's 500 lines and about 5,000 tokens (this pack: at most 13 KB). Style rules: `clean-code-for-agents`, `text-quality-gate`.

## 6. Add scripts only where they remove error

Add a script when traces show the agent re-inventing the same logic each run, or a step must be deterministic (a validator, a converter). A script must print specific, actionable errors, avoid unexplained constants and state its dependencies. Say explicitly whether the agent should **run** it or **read** it. A validator that checks a plan file against a source of truth, before a batch or destructive step, is the highest-value script. Never rely on network or package installs without checking the target host (section 9).

## 7. Validate (structure)

1. Run this pack's checker (`python check_skills.py skills` at the repo root) as an example of a local gate: frontmatter, size, headings, link targets.
2. Optionally run the specification's reference validator `skills-ref validate ./my-skill` (the repository's own README calls it demonstration-only, so treat a pass as a format smoke test, not approval). It checks frontmatter fields, name rules and the 1,024 and 500 character limits, not the body.
3. Check LF line endings, forward-slash paths, no machine paths or secrets.

Commands and caveats: [references/validation-packaging-and-host-paths.md](references/validation-packaging-and-host-paths.md).

## 8. Evaluate and iterate

**Trigger eval** (does the description fire?): about 20 realistic prompts, 8 to 10 should-trigger and 8 to 10 near-miss should-not-trigger; split roughly 60 percent train, 40 percent validation, fixed across iterations, positives and negatives in both; run each prompt about 3 times and count it as passing at a trigger rate above 0.5; edit the description using train failures only; pick the iteration with the best validation rate (often not the last); about five iterations is usually enough.

**Output eval** (is the result better?): 2 or 3 realistic test prompts first; run each **with the skill** and **without it** (or with a snapshot of the previous version when improving), each in a fresh context; record tokens and duration; add objective assertions after seeing the first outputs; grade with evidence; drop assertions that pass in both arms; review a few outputs by hand; fix the underlying cause, not the single example; rerun in a new iteration directory. Stop when feedback is empty or gains flatten.

Test on every model tier you plan to support (see `model-effort-routing`).

## 9. Package, install, record provenance

- Ship the folder (or a zip with the folder as the single top-level entry). Install location is host-specific; see the table in [references/validation-packaging-and-host-paths.md](references/validation-packaging-and-host-paths.md) (Claude Code, Claude.ai and API, Antigravity, Codex, Microsoft Agent Framework). Custom skills do not sync between Claude surfaces.
- Frontmatter portable across hosts: `name`, `description`, and optionally `license`, `compatibility`, `metadata`, `allowed-tools`. Claude-Code-only keys can break uploads elsewhere; keep them out of a portable skill.
- Write `references/sources.md` while you research: URL, real retrieved status, what it contributed, reading limits, claims **not** adopted, and the licence of anything reused. Reuse third-party text only with a confirmed licence; otherwise take ideas and rewrite in your own words.
- Before installing someone else's skill, review it as third-party code (`software-supply-chain-security`, `oss-deep-audit`, runtime and approval rules in `agent-skills-context-engineering`).

## 10. Boundary: skills, MCP and A2A are different things

A **skill** is a folder of instructions and resources an agent loads on demand. **MCP** is a protocol connecting a model host to tools, resources and prompts (it also has an optional "Skills over MCP" extension for serving skills). **A2A** is an agent-to-agent protocol; its "AgentSkill" belongs to an Agent Card and describes a capability an agent advertises to other agents. Same word, different artifact: do not apply this procedure to an A2A AgentSkill, and do not model a skill as an MCP tool.

## Skeleton SKILL.md

```markdown
---
name: <kebab-case-same-as-folder>
description: "<What it does, in user-intent terms. Not for <near miss>. Use when <triggers, including indirect phrasings>.>"
---

# <Title>

One idea: <single sentence>.

## 1. <First step as an imperative>
## 2. <Next step; exact command only if the step is fragile>

## Gotchas
- <Concrete correction the agent would otherwise get wrong>

## Quick Decision Checklist
- [ ] <yes/no gate>

## Deep references
- one line per reference file: path, then when to read it
```

## Pre-publish checklist

- [ ] Three example requests written; baseline without the skill recorded
- [ ] Admission check passed; no rule duplicated from a neighbor skill (linked instead)
- [ ] Description at most 1,000 characters, imperative, ends "Use when ...", boundary stated
- [ ] Body under the size cap; links one level deep, each with a "read when" condition
- [ ] Scripts print actionable errors and are labeled run vs read
- [ ] Local checker passes; optional spec validator run
- [ ] Trigger eval run with a held-out validation set; output eval beats the baseline
- [ ] `references/sources.md` has real statuses, reading limits, claims not adopted, licences
- [ ] LF endings; no machine paths, hostnames, secrets
- [ ] Install path and portability notes match the target host

## Quick Decision Checklist

- [ ] Can I name three real requests and a gap the baseline shows? If no, do not build yet.
- [ ] Does it need to be a skill rather than a line in an instruction file?
- [ ] Is every section either fragile-and-exact or flexible-and-explained, never vague?
- [ ] Did the trigger eval include near-miss negatives and a held-out set?
- [ ] Does the skill beat the baseline on quality or cost, and did I measure tokens?
- [ ] Is the target host's path, field support and network or package limit confirmed?

## Mistakes to Catch

- Generating a skill from general knowledge alone, with no real task or failure as input.
- Describing the skill's mechanics in the description instead of the user's intent.
- Tuning the description against every query, then reporting that same score as success.
- Only easy negatives ("what is the weather"); no near-misses.
- A menu of tools with no default; deep link chains; "see references" with no condition.
- Treating `skills-ref` or any validator pass as proof of quality or safety.
- Copying a third-party skill's text without a confirmed licence.

## Deep references

- [references/creation-workflow-and-degrees-of-freedom.md](references/creation-workflow-and-degrees-of-freedom.md): intent capture, baseline, content placement, freedom calibration, gotchas, a worked example. Read in steps 1 to 6.
- [references/description-writing-and-trigger-evals.md](references/description-writing-and-trigger-evals.md): description patterns, real limits, eval set design, train/validation loop, output-eval layout. Read in steps 4 and 8.
- [references/validation-packaging-and-host-paths.md](references/validation-packaging-and-host-paths.md): validators, packaging, install paths and limits per host. Read in steps 7 and 9.
- [references/reference-repos-audit-notes.md](references/reference-repos-audit-notes.md): what the public skills repositories actually contain (licence, structure, validators). Read before borrowing from them.
- [references/sources.md](references/sources.md): every URL with retrieved status, reading limits and claims not adopted.
