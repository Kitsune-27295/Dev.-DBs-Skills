# Skill Format and Authoring Rules (Spec + Anthropic Best Practices)

Sources: https://agentskills.io/specification · https://github.com/agentskills/agentskills · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · Last verified 2026-11-23

## Contents
- Spec: what is mandatory vs recommended
- Authoring principles from the best-practices guide
- Evaluation-driven iteration (Claude A / Claude B)
- Scripts inside skills
- Anti-patterns
- How an agent should apply this

## Spec: mandatory vs recommended
The open standard (code Apache-2.0, docs CC-BY-4.0, originally from Anthropic) requires only a directory with `SKILL.md` containing YAML frontmatter plus a Markdown body.

| Field | Rule |
|---|---|
| `name` | required, 1-64 chars, unicode lowercase alphanumerics and hyphens, no leading/trailing hyphen, **no `--`**, must equal the parent directory name |
| `description` | required, 1-1024 chars, says what the skill does and when to use it, with task keywords |
| `license` | optional, short name or bundled file name |
| `compatibility` | optional, 1-500 chars, only when there are real environment needs (packages, network, product) |
| `metadata` | optional string-to-string map; pick unique key names |
| `allowed-tools` | optional, space-separated pre-approved tools, **experimental**, support varies |

Body: no format restrictions. The spec suggests step-by-step instructions, input/output examples and edge cases. Optional dirs `scripts/`, `references/`, `assets/` are conventions, not requirements. Keep references one level deep from `SKILL.md`; keep `SKILL.md` under 500 lines and about 5000 tokens; metadata costs about 100 tokens per skill at startup. Validate with `skills-ref validate ./my-skill`. (The GitHub repo page itself did not describe `skills-ref`; the command comes from the spec page.)

Note a divergence: Anthropic's guide additionally forbids XML tags in `name`/`description` and the reserved words `anthropic` and `claude` in `name`; the neutral spec does not list these. Satisfy both when targeting Claude products.

## Authoring principles (best-practices guide)
1. **Concise is key.** The context window is shared with system prompt, history and other skills. Only add what Claude lacks; ask of each paragraph "does this justify its token cost?" (the guide contrasts a ~50-token snippet with a ~150-token explanatory one for the same task).
2. **Degrees of freedom match fragility.** High freedom (prose heuristics) for context-dependent work such as code review; medium (templates or parameterised pseudocode) when a preferred pattern exists; low (exact command, "do not add flags") for fragile sequences such as migrations. Mental model: narrow bridge = guardrails, open field = direction only.
3. **Test on every target model.** Haiku may need more guidance, Opus may need less; aim for text that works on all you will use.
4. **Descriptions in third person**, specific, with triggers ("Use when ..."). The description is the only thing used to pick among 100+ skills. Vague ones ("Helps with documents") fail.
5. **Naming:** gerund (`processing-pdfs`) preferred, noun phrase or imperative acceptable; avoid `helper`, `utils`, `tools`, `documents`.
6. **Progressive disclosure patterns:** (a) overview in `SKILL.md` linking to `FORMS.md`/`REFERENCE.md`; (b) domain folders (`reference/finance.md`, `sales.md`) so only the relevant domain loads; (c) conditional details ("for tracked changes see REDLINING.md").
7. **No nested reference chains.** Claude may `head -100` a file reached via another file and miss content. Files over 100 lines get a table of contents.
8. **Workflows and feedback loops:** checklists Claude copies and ticks; "run validator, fix, repeat" loops; plan-validate-execute for batch or destructive work (write `changes.json`, validate with a script, then apply).
9. **No time-sensitive text.** Put deprecated behaviour in a collapsed "old patterns" section. Use one term per concept.
10. **Templates and examples:** strict templates for formats that must not vary, "sensible default" templates otherwise; input/output pairs convey style better than description.

## Evaluation-driven iteration
Build evaluations before prose: (1) run Claude on representative tasks without the skill and log failures; (2) write about three scenarios covering the gaps; (3) record the baseline; (4) write the minimum instructions that close the gaps; (5) rerun and compare. The guide's eval record has `skills`, `query`, `files`, `expected_behavior[]`; no built-in runner exists, so you build your own. The two-instance loop: "Claude A" drafts and refines the skill, "Claude B" uses it on real tasks, and observed failures (skipped filter, ignored file, unexpected read order) feed back to A. Watch for: files never read (unneeded or poorly signalled), the same file read repeatedly (move it into `SKILL.md`), missed links (make them explicit).

## Scripts inside skills
- Prefer shipping a script over asking the model to regenerate code: more reliable, cheaper, consistent. State clearly **run** versus **read as reference**.
- "Solve, don't defer": handle errors in the script (create default file, fallback) rather than crash and leave Claude to improvise. Justify constants; avoid "voodoo" values like `TIMEOUT = 47`.
- Validation scripts should emit specific messages ("field X not found; available: ...") so the model can self-repair.
- Package availability differs: claude.ai can install from npm/PyPI; the API has no network and no runtime install. List dependencies explicitly.
- Reference MCP tools fully qualified: `ServerName:tool_name`.

## Anti-patterns
Windows backslash paths; offering five libraries instead of one default plus an escape hatch; assuming a package is installed; `doc2.md`-style file names; deeply nested links; explaining what Claude already knows.

## How an agent should apply this
- Check frontmatter against the table (no `--`, name equals folder, description <=1024, third person, "Use when").
- Before adding a paragraph, apply the token-cost test; move detail to a one-level-deep reference with a ToC if over 100 lines.
- Choose freedom level per step: exact command for fragile steps, heuristics elsewhere.
- Require at least three eval scenarios and a no-skill baseline before declaring a skill done.
- Prefer a validated script plus plan-validate-execute for batch or destructive operations.
