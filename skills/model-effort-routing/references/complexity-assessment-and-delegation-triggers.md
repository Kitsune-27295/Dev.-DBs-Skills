# Complexity Assessment and Trigger-Based Delegation

Sources: https://github.com/wahidzzz/antigravity-skill-orchestrator · https://github.com/Sora-bluesky/antigravity-orchestra (.agents/rules/delegation-triggers.md; docs/delegation-triggers.md returned 503) · https://github.com/sickn33/antigravity-awesome-skills/blob/main/skills/subagent-orchestrator/SKILL.md · Last verified 2026-11-23

## 1. Complexity-assessment meta-skill (wahidzzz/skill-orchestrator)

Antigravity IDE meta-skill for complex multi-domain tasks. Workflow as described: break the task into parts, search memory (via an `agent-memory-mcp` skill) for similar past challenges, assemble a team of skills (e.g. a UI skill plus a data-fetching skill), execute, and record which combinations worked. It has guardrails against over-using specialized skills on simple tasks. The README gives no thresholds or frontmatter; license not visible. So: the idea is reusable, the numbers are not available. Anything numeric below is from subagent-orchestrator.

Concrete thresholds found (subagent-orchestrator): 3+ files = orchestrate; over 20 files or 500+ new lines = everything cheap tier; under 50 lines or single file = do it directly.

## 2. Trigger-based delegation (antigravity-orchestra, MIT, archived)

Template: Antigravity (Gemini) is the single user-facing orchestrator/researcher/implementer; Codex CLI is called through PowerShell scripts for design, debugging and review, with outputs saved under a logs folder. A Rules file replaces Claude Code Orchestra's hooks. Decision flow, in order:

1. Design judgment needed: suggest a planning workflow or consult the second model.
2. TDD needed: suggest the TDD workflow.
3. Debugging needed: delegate root-cause analysis to the second model.
4. Implementation finished: suggest an external review.
5. Else: execute directly.

Keyword triggers are bilingual (Japanese and English): design/architecture/how to build; debug/error/bug/why/not working; review/check/verify; test/TDD; plan. Transparency rule: tell the user the detected keyword and ask to confirm (yes / no, answer directly). Gaps: "complex bug" is undefined; multi-match behavior beyond flow order is unspecified; no quota logic (only notes Codex needs a ChatGPT plan or API key). Headless `agy -p` ignores workspace `.agents/`.

## 3. Failure modes of keyword triggers (inference)

- Substring noise: "check" or "error" appear in trivial requests; delegating them wastes quota.
- Order bias: first-match flow sends design-flavored debugging to the wrong branch.
- Silent delegation: without the confirm step the user pays for calls they did not expect.

## 4. Hybrid rule set (own synthesis)

```
if trivial(single file, <50 lines, question): do directly, cheapest model
elif keyword in {design, architecture, root cause} AND blast_radius>=3 files:
    delegate to strongest reviewer, tell the user which trigger fired
elif parallelisable and independent: fan out cheap subagents
else: do directly, review at the end
```
Confirmation is needed only when the delegation costs real quota or crosses to another vendor's CLI.

## How an agent should apply this

- Assess size first (files, lines, independence); only then match keywords.
- Order triggers by cost of being wrong: design, debug, review, test, plan.
- Always surface the trigger that fired and let the user veto a cross-vendor call.
- Keep a short memory of combinations that worked, but treat it as a hint, not a rule.
- Do not copy the Japanese/English keyword lists blindly; tune them to your repo's vocabulary.
