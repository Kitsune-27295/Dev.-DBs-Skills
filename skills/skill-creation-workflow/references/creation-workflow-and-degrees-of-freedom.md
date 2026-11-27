# Creation Workflow and Degrees of Freedom

Sources: https://agentskills.io/skill-creation/best-practices · https://agentskills.io/skill-creation/evaluating-skills · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md · Last verified 2026-11-27

## Contents
- Start from real expertise
- Baseline first
- Placing content
- Calibrating freedom
- Gotchas and templates
- Worked example
- How an agent should apply this

## Start from real expertise

Both the open specification's guide and Anthropic's authoring guide warn against asking a model to write a skill from its general knowledge alone: the result is generic ("handle errors appropriately"). Two grounded inputs work better. First, do a real task with an agent, then extract what worked, which corrections you made, the input and output shapes, and the project facts you had to supply. Second, synthesize from your own artifacts: runbooks, schemas, review comments, fix history, real failures. Generic articles add little.

## Baseline first

Anthropic's guide describes evaluation-driven development: run the agent on representative tasks without the skill, write down the specific failures, build at least three scenarios around those gaps, measure the baseline, then write the minimum instructions that close the gaps. The point is to document problems that exist rather than imagined ones. If the agent already handles the whole task, the skill may add nothing; that is a valid result and saves tokens.

## Placing content

Ask of every paragraph: would the agent get this wrong without it? If not, cut it. Then place what remains by load time: always-needed procedure in `SKILL.md`; long or conditional material in `references/`; deterministic logic in `scripts/`; output templates and static data in `assets/`. Both guides advise a body under 500 lines, one level of links, and a table of contents for long reference files. Tell the agent the condition for reading each file; a vague pointer is often ignored.

## Calibrating freedom

Anthropic frames three levels. High freedom (text guidance) fits tasks where many approaches work and context decides. Medium freedom (templates, parameterized scripts) fits a preferred pattern with some variation. Low freedom (exact command, no extra flags) fits fragile or order-critical operations. The bridge-and-field image helps: guardrails where a mistake is costly, open space elsewhere. For flexible parts, a stated reason beats a bare rule because the agent can adapt when it understands the purpose. Give one default tool or path with a short escape hatch instead of a list of equals.

## Gotchas and templates

The specification guide calls out gotchas as often the most valuable content: concrete facts that defy assumption (a soft-delete column, three names for one id). Keep them in `SKILL.md`, and add a line each time you correct the agent by hand. Output formats are more reliable as a short concrete template than as prose.

## Worked example

Goal: a skill that prepares release notes. Three requests: "write notes for v2.4 from the merged PRs", "summarize what changed since the last tag for customers", "draft a changelog entry, our format has Added/Fixed". Baseline shows the agent invents categories and includes internal tickets. In scope: notes from merged PRs. Out of scope: deploying, version bumping. Design: `SKILL.md` holds a six-step procedure and two gotchas (skip internal-labeled PRs; use the repo's category names); `assets/notes-template.md` holds the format; `scripts/list_merged.sh` is added only if traces show the agent re-deriving the PR list each run.

## How an agent should apply this

1. Refuse to draft until three example requests and a recorded baseline gap exist.
2. Source content from the user's real artifacts; list them in `references/sources.md`.
3. For each section choose a freedom level and write it accordingly.
4. Move anything conditional or long out of `SKILL.md` with a read-when line.
5. After the first real run, add corrections as gotchas, not as new prose.
