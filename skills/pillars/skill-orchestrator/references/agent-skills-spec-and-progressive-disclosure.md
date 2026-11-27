# Agent Skills Specification and Progressive Disclosure

Sources: https://agentskills.io/specification · https://github.com/agentskills/agentskills · https://raw.githubusercontent.com/agentskills/agentskills/main/skills-ref/README.md · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf · https://github.com/anthropics/skills · https://strapi.io/blog/what-are-agent-skills-and-how-to-use-them · https://github.com/coleam00/cole-medin-knowledge-base/blob/main/concepts/progressive-disclosure.md · Last verified 2026-11-24

An orchestrator that routes among skills must know exactly what a skill is, what the host loads for free, and what each stage costs. This page separates the open specification (portable) from vendor extensions (not portable).

## 1. Open specification facts (agentskills.io/specification)

A skill is a directory with a required `SKILL.md` (YAML frontmatter + Markdown body). Optional directories by convention: `scripts/`, `references/`, `assets/`, plus any other files.

| Field | Required | Constraint in the spec |
|---|---|---|
| `name` | yes | 1-64 chars; unicode lowercase letters, digits, hyphens; no leading/trailing hyphen; no `--`; must equal the parent directory name |
| `description` | yes | 1-1024 chars; says what the skill does and when to use it; include keywords that help an agent recognize the task |

The body has no format restriction. Optional fields (`license`, `compatibility`, `metadata`, experimental `allowed-tools`) and the body layout rules are tabulated in `agent-skills-context-engineering` section 1 and not repeated here. File references use relative paths from the skill root, one level deep.

## 2. Three loading stages: claimed versus specified

| Stage | Spec wording | Other claims found |
|---|---|---|
| 1 Metadata (`name` + `description`) | about 100 tokens, loaded at startup for all skills | skill-creator says about 100 words; the Strapi blog says 30-50 tokens per skill |
| 2 Body | under 5000 tokens recommended; keep `SKILL.md` under 500 lines | skill-creator: under 500 lines ideal and "approximate"; Anthropic's PDF guide: under 5,000 words |
| 3 Resources | loaded only when needed | scripts can run without being read into context (skill-creator) |

Findings: the 500-line limit is a spec recommendation, not a validator rule. The body budget is stated in tokens by the spec but in words by the PDF guide (words are roughly 1.3 tokens, my own estimate, so the PDF number is looser). The per-skill discovery cost is a typical figure, not a limit; the index budget rule is owned by [three-layer-orchestration-architecture.md](three-layer-orchestration-architecture.md) (BUD-01).

## 3. "More than 26 platforms" claim

The Strapi post says the standard is adopted by "26+ platforms" (Claude, Codex, Gemini CLI, Copilot, Cursor, VS Code named). The agentskills.io home page, which I read, says only that skills are supported by "a large number" of tools and points to a client list; it gives no count. Verdict: unverified number, plausible direction. Do not hard-code it in any rule.

## 4. Validation with skills-ref

The repo `agentskills/agentskills` (code Apache 2.0, docs CC-BY-4.0, as shown on its page) hosts `skills-ref`. Commands: `skills-ref validate path/to/skill` (checks frontmatter and naming), `skills-ref read-properties` (JSON), `skills-ref to-prompt a b` (emits the XML block of available skills for a system prompt). Its README says it is for demonstration, not production. It checks structure, not whether the description routes well; that needs trigger evals (`skill-description-and-trigger-design.md`).

## 5. Spec versus vendor extensions

- Anthropic's best-practices page adds rules the open spec does not state: no XML tags in `name`/`description`, `name` may not contain the reserved words `anthropic` or `claude`, gerund-style names recommended (preferred, not required). Description writing style (third person, what plus when) is owned by [skill-description-and-trigger-design.md](skill-description-and-trigger-design.md).
- Claude Code adds header keys such as `model`, `effort`, `context`, invocation controls; `model-effort-routing` covers them. A portable pack keeps routing rules in the body (the spec lets clients ignore unknown keys, but strict uploaders reject them: see `portable-skill-frontmatter` in `model-effort-routing`).
- The Anthropic PDF guide requires kebab-case folder and `name`, forbids `<` `>` in frontmatter, and lists a zip step for upload; treat these as vendor packaging advice.

Example of a portable header that passes every rule above:

```yaml
---
name: skill-orchestrator
description: Routes a task to 1-3 skills or instruction files and orders them. Use when ...
license: MIT
metadata:
  tier: process
---
```

## 6. Why progressive disclosure matters for routing

Only stage 1 is paid for every skill on every session; that is the routing surface. The Cole Medin note frames it as "just in time, not just in case": load only what you are confident is needed. Consequence: routing uses stage-1 text only (rule RT-01, owner [skill-description-and-trigger-design.md](skill-description-and-trigger-design.md)).

## How an agent should apply this

- Before creating or reviewing a skill, check the section 1 table; run `skills-ref validate` when installed, otherwise check name equals folder and description length by script.
- Treat 500 lines and 5000 tokens as targets; move depth to `references/` one level deep.
- Never cite "26 platforms" or "30-50 tokens" as facts; quote the spec numbers and label other numbers as claims.
- Keep vendor-only keys out of the portable copy and mark them as extensions.
- Decide routing from stage-1 text; load a body only after selection.
