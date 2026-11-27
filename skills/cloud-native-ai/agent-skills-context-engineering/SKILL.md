---
name: agent-skills-context-engineering
description: "Owns the Agent Skills specification facts for this pack (SKILL.md frontmatter limits, directory layout, progressive-disclosure stages, skills-ref validation, runtime provider and approval rules) and the context-engineering and harness-engineering ideas behind them: smallest high-signal context, just-in-time retrieval, compaction, notes, sub-agent isolation, and feedforward Guides versus feedback Sensors. Not for the procedure of writing and testing one skill (use skill-creation-workflow), instruction-file routing (use skill-orchestrator), model and effort choice (use model-effort-routing) or RAG and agent topologies (use agentic-rag-architecture). Use when checking what the specification allows, deciding how skills, context budget or a harness should be organized, hosting or auditing third-party skills, or designing guides and sensors for a coding agent."
---

# Agent Skills, Context Engineering & Harness Design

One idea: **model attention is a finite resource, and recall degrades as the window fills ("context rot")**, so every system should deliver the **smallest high-signal token set** at each turn (**Context Engineering**), packaged as **portable progressive-disclosure modules** (the open Agent Skills format), and governed by an outer loop of **feedforward Guides and feedback Sensors** (**Harness Engineering**). Sources, retrieved statuses and claims not adopted: [references/sources.md](references/sources.md).

> **Scope boundary:** runtime LLM application topologies (workflows vs agents, hybrid RAG, tool ergonomics at application level) belong to `agentic-rag-architecture`. This skill covers portable skill structure, context-window curation and agent-steering harnesses. The step-by-step procedure for creating a skill is `skill-creation-workflow`.

## 1. The open specification and progressive disclosure

A skill is a folder with at least `SKILL.md` (YAML frontmatter plus Markdown body). Optional folders by convention: `scripts/` (executable code), `references/` (docs read on demand), `assets/` (templates, schemas, data). Only `name` and `description` are required; the complete field table (limits, optional `license`, `compatibility`, `metadata`, experimental `allowed-tools`) and the vendor-specific extra rules live in one place: [references/skill-format-and-authoring-rules.md](references/skill-format-and-authoring-rules.md).

Loading is staged (the specification gives these numbers as recommendations, not parser limits):
1. **Metadata (about 100 tokens per skill):** only `name` and `description` are resident, so an agent can route among many skills cheaply.
2. **Instructions (under 5,000 tokens, under 500 lines recommended):** the whole `SKILL.md` body loads on activation.
3. **Resources (on demand):** files in `references/`, `assets/` and `scripts/` load only when needed. Keep links **one level deep** from `SKILL.md`: an agent that reaches a file through another file may read only its head. Give reference files over 100 lines a table of contents.
4. **Scripts:** run through the shell so only their output enters context; say explicitly whether the agent should **run** or **read** each one.

Validation: `skills-ref validate ./my-skill` checks frontmatter and naming only; the library calls itself demonstration-only (details in the format reference).

### Runtime integration and supply-chain governance

When a framework hosts skills (the Microsoft Agent Framework is the documented example), the same four stages appear as tools (`load_skill`, `read_skill_resource`, `run_skill_script`). Rules that matter regardless of framework, in full in [references/skill-runtime-providers-and-security.md](references/skill-runtime-providers-and-security.md):
- **Approval:** skill tools require approval by default; auto-approve read-only tools at most, and keep script execution gated.
- **Treat third-party skills like third-party code:** read `SKILL.md`, scripts and dependencies before enabling; sandbox script runs; scripts inside remote MCP archives are never executed by that framework.
- **Multi-tenant caching:** cache a context-aware source with a per-tenant isolation key, or one tenant's skills can be served to another.
- **Errors:** do not forward raw exception text to the model; it can carry secrets or an injection payload.
- **Unload** stale skill instructions after a sub-task when the framework supports it.

## 2. Context engineering principles

Prompt engineering optimizes static wording; **context engineering** curates the whole token state (system prompt, tool definitions, retrieved data, message history, tool outputs) on every turn. Source: Anthropic's context-engineering article.

- **Altitude:** avoid both brittle hardcoded if-else logic and vague guidance. Use clear sections, start from a minimal prompt on the strongest model, and add instructions only for observed failure modes.
- **Examples over edge-case lists:** a few diverse canonical examples anchor behavior better than long rule lists.
- **Tools:** self-contained, clearly scoped, token-efficient; overlapping tools make selection ambiguous. Trimming definitions: [references/tool-definition-context-economy.md](references/tool-definition-context-economy.md).
- **Hybrid just-in-time retrieval:** pre-load a small stable core (for example `CLAUDE.md`), keep lightweight handles (paths, queries, links) for the rest, and let the agent load on demand; folder names and timestamps act as relevance signals.
- **Long-horizon tasks (details and selection rule in [references/long-horizon-context-strategies.md](references/long-horizon-context-strategies.md)):** (1) **compaction** (keep decisions and open bugs, drop redundant tool output; tune for recall first, then precision; clearing old tool results is the lightest form), (2) **structured note-taking** outside the window, (3) **sub-agent isolation**, where a clean-window specialist explores and returns a condensed summary (the article says often 1,000 to 2,000 tokens).

## 3. Outer harness engineering (`Agent = Model + Harness`)

Source: Birgitta Böckeler on martinfowler.com (2026-04-02). "Harness" here means the user-built controls around a coding agent, so a human can supervise less.

| | **Feedforward: Guides** (before the agent acts) | **Feedback: Sensors** (after it acts) |
|---|---|---|
| **Computational** (deterministic, fast, CPU) | LSP and code intelligence, codemod recipes, scaffolds | Tests, type checkers, linters, structural tests (ArchUnit-style), mutation tests |
| **Inferential** (semantic, slower, non-deterministic) | `AGENTS.md`, skills, conventions in prose | AI code review, LLM-as-judge |

Operating rules (full text: [references/harness-guides-sensors-and-steering.md](references/harness-guides-sensors-and-steering.md)):
1. **Pair them.** Guides alone never learn whether the rules worked; sensors alone let the agent repeat predictable mistakes.
2. **Keep quality left.** Cheap computational sensors before integration; expensive inferential ones and mutation testing later, plus continuous drift sensors (dead code, dependency rot, SLO signals).
3. **Three regulation categories:** maintainability (easiest today, mature tooling), architecture fitness (fitness functions: performance, import direction, observability), behavior (the "elephant in the room": a green AI-written test suite is weak evidence; anchor with a spec, approved fixtures, contract tests and human review).
4. **Harnessability:** strong typing, explicit module boundaries and opinionated frameworks make sensors easier to build. The human job is steering: turn a recurring failure into a tighter guide or a new sensor.

## Mistakes to Catch

- **Bloated always-on context:** a `SKILL.md` over 500 lines or a vague description loads detail nobody needs and dilutes the task.
- **Feedforward only:** strict `AGENTS.md` or `SKILL.md` rules with no fast sensor to catch violations.
- **Unsafe skill execution:** third-party instructions or scripts treated as trusted with no sandbox or approval gate.
- **Unbounded history:** tens of thousands of tokens of raw tool logs kept in a long task instead of clearing, notes, compaction or delegation.
- **A quiet sensor taken as proof:** a sensor that never fires may mean good quality or weak detection; seed a known defect to find out.

## Quick Decision Checklist

- [ ] Does `SKILL.md` carry only what must load up front, with detail in one-level-deep references?
- [ ] Is the body under 500 lines, and does the description say both what it does and when to trigger?
- [ ] Is every feedforward guide paired with a fast computational sensor?
- [ ] Are third-party skills and bundled scripts reviewed, sandboxed or approved before they run?
- [ ] For a long task, are old tool results cleared, notes kept, or work delegated to a clean sub-agent?
- [ ] Are AI-generated green tests anchored by specs, fixtures, contract tests or human review?

## Deep references

- [Skill Format and Authoring Rules](references/skill-format-and-authoring-rules.md): read when writing or validating SKILL.md frontmatter, names, descriptions, scripts, or checking the spec against vendor rules.
- [Skill Runtime, Providers and Security](references/skill-runtime-providers-and-security.md): read when hosting skills in an agent runtime (sources, caching, approval, tenant isolation) or auditing third-party skills.
- [Long-Horizon Context Strategies](references/long-horizon-context-strategies.md): read when a task outgrows one window: compaction, notes, sub-agents, just-in-time retrieval.
- [Harness Guides, Sensors and the Steering Loop](references/harness-guides-sensors-and-steering.md): read when designing feedforward and feedback controls for coding agents.
- [Tool Definition Context Economy](references/tool-definition-context-economy.md): read when writing or trimming tool definitions: minimal context, rules on the parameter, bounded outputs, first-turn token measurement.
- [Skill Admission, Contract Checklist and Baseline-First Authoring](references/skill-admission-and-baseline-first.md): read before adding or reviewing a skill: admission questions, contract checklist, baseline-first evals.
- [Context Stack Audit (Report-Only)](references/context-stack-audit-report.md): read when asked to audit always-loaded context: token ranking, risk classes, delta against the previous report.
- [Trigger Evals](references/trigger-evals.md): three should-trigger and three near-miss prompts for this skill's description.
- [Sources](references/sources.md): every URL with retrieved status, reading limits and claims not adopted.
