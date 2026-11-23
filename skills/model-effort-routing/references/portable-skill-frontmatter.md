# Portable SKILL.md Frontmatter vs Claude Code Extensions

Sources: https://code.claude.com/docs/en/skills (first ~100k of ~120k chars read) · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices · https://code.claude.com/docs/pt/best-practices · secondary (low trust, never sole basis): https://www.cubic.dev/blog/claude-code-skills · https://neuraltrust.ai/blog/claude-code-skills · https://www.zently.com.br/blog/melhores-skills-claude-code-2026-guia-completo · Last verified 2026-11-23

## 1. Field table (Claude Code docs)

Frontmatter is YAML between `---`, starting on line 1. All fields optional (`description` recommended). Unknown keys are silently ignored, so a typo such as `disable_model_invocation` does nothing. A YAML parse failure loads the skill with no fields.

| Field | Portable? | Meaning and scope |
|---|---|---|
| `name` | Universal | Command name; defaults to directory name. Platform rules: max 64 chars, lowercase letters/digits/hyphens, no XML tags, no reserved words `anthropic`/`claude`. |
| `description` | Universal | What + when. Platform max 1,024 chars, non-empty, no XML tags, third person. Claude Code listing truncates `description`+`when_to_use` at 1,536 chars, so lead with the key use case. |
| `license`, `compatibility` (<=500 chars), `metadata` | Agent Skills spec | Accepted everywhere, not acted on by Claude Code. |
| `allowed-tools` | Accepted by API/claude.ai too | Tools usable without asking during the invoking turn; does not restrict other tools. |
| `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `disallowed-tools`, `paths`, `shell`, `hooks` | Claude Code only | Invocation control and activation. `disable-model-invocation: true` removes the description from context and blocks subagent preloading and scheduled runs. `user-invocable: false` hides from `/` menu, Claude can still load it. `disallowed-tools` clears at your next message. `hooks` stay active for the session. |
| `model` | Claude Code only | Override for the rest of the current turn only; session model resumes next prompt; `inherit` keeps active. With `context: fork` it sets the subagent's model. |
| `effort` | Claude Code only | low/medium/high/xhigh/max for the rest of the current turn (or the whole forked run). Does not beat `CLAUDE_CODE_EFFORT_LEVEL`; org caps still apply. |
| `context: fork`, `agent`, `background` | Claude Code only | Run the skill body as a subagent task; `agent` defaults to `general-purpose` (also Explore, Plan, custom); `background` defaults true, only with fork. |

## 2. Portability rule (important)

Per the Claude Code docs: claude.ai uploads, the Skills API and `package_skill.py` allow only `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. Any other key (e.g. `argument-hint`, `model`, `effort`) is a hard error ("Unexpected key(s)"), not ignored. `!`cmd`` injection also does not run there. So a skill meant for multiple surfaces should keep Claude Code extras in a separate Claude Code-only copy or accept that it will not upload.

## 3. Lifecycle facts that affect routing

- Invoked SKILL.md enters the conversation as one message and stays; it is not re-read, so write standing instructions.
- `allowed-tools`, `disallowed-tools`, `model`, `effort` apply only for the invoking turn; re-invoking re-applies them.
- Identical re-invocation adds a short "already loaded" note; changed content is appended again.
- After auto-compaction the latest invocation of each skill keeps its first 5,000 tokens, sharing a 25,000-token budget (most recent first); older skills may be dropped.

## 4. Authoring guidance (platform best-practices)

- Body under 500 lines; references one level deep from SKILL.md; add a table of contents to reference files over 100 lines.
- Test with Haiku, Sonnet and Opus: Haiku needs enough guidance, Opus tolerates less explanation. A skill written for Opus may be too thin for Haiku; this is the main reason a `model:` pin must be evaluated, not assumed.
- Match freedom to fragility: low freedom (exact script) for fragile steps, high for context-dependent ones. Build evals first (at least three), avoid time-sensitive text, use consistent terms, forward-slash paths, give one default option.
- Secondary sources agree (cubic, NeuralTrust) on 1,536/500-line/5,000-token numbers and add: use `disable-model-invocation` for side effects; use hooks, not skills, for rules that must always hold. Zently mentions only name/description; it is marketing-style and was used for no fact here.

## How an agent should apply this

- Put routing hints in portable fields only (`name`, `description`) and treat `model`/`effort`/`context` as optional Claude Code overlays, never required for correctness.
- Use `effort:` on a skill to raise or lower depth for one turn; use `model:` with `context: fork` when the work should run on a cheaper or stronger model in isolation.
- Validate a skill against the target surface before uploading: remove non-portable keys for the API/claude.ai.
- Never rely on a `model:` pin without testing the skill on that model; never expect the override to persist past the turn.
- Re-check field lists against the live docs; the Claude Code page is the single source for the extension fields.
