# Skill Format and Authoring Rules (Spec + Anthropic Best Practices)

Sources: https://agentskills.io/specification · https://github.com/agentskills/agentskills · https://raw.githubusercontent.com/agentskills/agentskills/main/skills-ref/README.md · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview · https://code.claude.com/docs/en/skills · Last verified 2026-11-27

## Contents
- Spec: what is mandatory vs recommended
- Vendor rules on top of the spec
- Authoring principles from the best-practices guide
- Evaluation-driven iteration (Claude A / Claude B)
- Scripts inside skills
- Anti-patterns
- How an agent should apply this

This file is the single owner of the specification field table. Other skills point here instead of repeating it. Host install paths, packaging and per-host limits are owned by `skill-creation-workflow` (`references/validation-packaging-and-host-paths.md`); Claude Code-only frontmatter keys by `model-effort-routing` (`references/portable-skill-frontmatter.md`).

## Spec: mandatory vs recommended
The open standard (code Apache-2.0, docs CC-BY-4.0, "originally developed by Anthropic" per the repository page) requires a directory with `SKILL.md`: YAML frontmatter plus a Markdown body.

| Field | Rule |
|---|---|
| `name` | required, 1-64 chars, unicode lowercase alphanumerics (`a-z`, `0-9`) and hyphens, must not start or end with a hyphen, **no `--`**, must equal the parent directory name |
| `description` | required, 1-1024 chars, says what the skill does and when to use it, with task keywords |
| `license` | optional, short license name or the name of a bundled license file |
| `compatibility` | optional, 1-500 chars, only when there are real environment needs (product, system packages, network) |
| `metadata` | optional map of string keys to string values; pick reasonably unique key names |
| `allowed-tools` | optional, space-separated pre-approved tools, **experimental**, support varies by agent |

Body: no format restrictions. Suggested content: step-by-step instructions, input/output examples, edge cases. The agent loads the whole body on activation, so split long content into referenced files. Optional folders `scripts/`, `references/`, `assets/` are recommendations. Keep references one level deep, with relative paths from the skill root. Progressive disclosure numbers (recommendations, not parser limits): metadata about 100 tokens, body under 5,000 tokens, `SKILL.md` under 500 lines.

Validation: `skills-ref validate ./my-skill` checks that the frontmatter is valid and follows the naming rules. The `skills-ref` README documents `validate`, `read-properties` and `to-prompt` (emits the `<available_skills>` XML), and says the library is "intended for demonstration purposes only" and "not meant to be used in production". It does not validate the body. The spec's wording of unicode in `name` is the strict reading: ASCII `a-z` and digits are the safe choice for portability.

## Vendor rules on top of the spec
- **Claude platform docs** (overview and best practices): `name` max 64 chars, lowercase letters, digits and hyphens, no XML tags, and the reserved words `anthropic` and `claude`; `description` non-empty, max 1,024 chars, no XML tags, third person. The neutral spec does not list the XML-tag or reserved-word rules; satisfy both when targeting Claude products.
- **Claude Code:** accepts 20 frontmatter keys (the six standard ones plus Claude-specific ones); only `description` is recommended; the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing, so front-load the key use case. It reserves the folder name `synced` and the names `anthropic-skills` (and the `anthropic-skills:` prefix). Claude.ai uploads, the Skills API and `package_skill.py` accept only the six standard keys and fail on others.
- **Other hosts** (Antigravity, Codex, OpenAI API) follow the same `SKILL.md` format; Antigravity treats `name` as optional and defaults it to the folder name.
- **Naming advice** (Anthropic, not the spec): gerund form (`processing-pdfs`) preferred, noun phrase or imperative acceptable; avoid vague names (`helper`, `utils`, `tools`, `documents`) and inconsistent patterns within a collection.

## Authoring principles (best-practices guide)
1. **Concise is key.** The context window is a public good shared with the system prompt, history and other skills. Add only what the model lacks; ask of each paragraph "does this justify its token cost?" (the guide contrasts a roughly 50-token snippet with a roughly 150-token explanation of the same task).
2. **Degrees of freedom match fragility.** High freedom (prose heuristics) where many approaches are valid; medium (template or parameterized script) when a preferred pattern exists; low (exact command, "do not add flags") for fragile sequences such as migrations. Narrow bridge = guardrails, open field = direction only.
3. **Test on every model you plan to use.** The guide asks, for Haiku, whether the skill gives enough guidance; for Sonnet, whether it is clear and efficient; for Opus, whether it avoids over-explaining.
4. **Descriptions in third person**, specific, with triggers. The description is how one skill is chosen among 100+; vague ones ("Helps with documents") fail.
5. **Progressive disclosure patterns:** overview in `SKILL.md` linking to detail files; domain folders so only the relevant domain loads; conditional details ("for tracked changes see REDLINING.md").
6. **No nested reference chains.** The guide says Claude may preview a nested file with `head -100` and miss content. Files over 100 lines get a table of contents.
7. **Workflows and feedback loops:** a checklist the model copies and ticks; "run validator, fix, repeat" loops; plan-validate-execute for batch or destructive work (write `changes.json`, validate with a script, then apply).
8. **No time-sensitive text.** Put deprecated behavior in an "old patterns" section. One term per concept.
9. **Templates and examples:** strict templates where a format must not vary, "sensible default" templates otherwise; input/output pairs convey style better than description.
10. **Name files descriptively** (`form_validation_rules.md`, not `doc2.md`) and organize folders by domain.

## Evaluation-driven iteration
Build evaluations before extensive prose: (1) run the model on representative tasks without the skill and log failures; (2) write three scenarios covering the gaps; (3) measure the baseline; (4) write the minimum instructions that close the gaps; (5) rerun and compare. The guide's example eval record has `skills`, `query`, `files`, `expected_behavior`; it states that no built-in runner exists, so you build your own. The two-instance loop: "Claude A" drafts and refines the skill, "Claude B" uses it on real tasks, and observed failures feed back to A. Watch for files never read (unneeded or poorly signaled), the same file read repeatedly (move it into `SKILL.md`), and missed links (make them explicit). The full procedure (trigger evals, with-skill vs baseline runs) is owned by `skill-creation-workflow`.

## Scripts inside skills
- A pre-made script is more reliable, cheaper and more consistent than regenerated code. State clearly **run** versus **read as reference**.
- "Solve, don't defer": handle errors in the script rather than crash and leave the model to improvise. Justify constants; avoid "voodoo" values such as `TIMEOUT = 47`.
- Validation scripts should emit specific messages ("field X not found; available: ...") so the model can self-repair.
- Package availability differs by surface: claude.ai can install from npm and PyPI and pull from GitHub; the Claude API has no network access and no runtime package installation. List dependencies explicitly and do not assume a package is installed.
- Reference MCP tools fully qualified, `ServerName:tool_name`, to avoid "tool not found" with several servers.

## Anti-patterns
Windows backslash paths (use forward slashes); five libraries offered instead of one default plus an escape hatch; assuming a package is installed; generic file names; deeply nested links; explaining what the model already knows.

## How an agent should apply this
- Check frontmatter against the table: no leading, trailing or double hyphen, name equals folder, description at most 1,024 characters, third person, a "Use when" clause.
- Before adding a paragraph, apply the token-cost test; move detail to a one-level-deep reference with a table of contents if over 100 lines.
- Choose the freedom level per step: exact command for fragile steps, heuristics elsewhere.
- Require at least three eval scenarios and a no-skill baseline before declaring a skill done.
- Prefer a validated script plus plan-validate-execute for batch or destructive operations.
