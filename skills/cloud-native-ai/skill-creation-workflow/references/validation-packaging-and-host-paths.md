# Validation, Packaging and Host Paths

Sources: https://agentskills.io/specification · https://github.com/agentskills/agentskills · https://code.claude.com/docs/en/skills · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview · https://antigravity.google/docs/skills/ · https://developers.openai.com/api/docs/guides/tools-skills · https://learn.chatgpt.com/docs/build-skills · https://learn.microsoft.com/en-us/agent-framework/agents/skills · Last verified 2026-11-27

## Contents
- Validators
- Portable frontmatter
- Host paths and install
- Limits and constraints
- Boundary notes
- How an agent should apply this

## Validators

The specification page recommends the `skills-ref` library: `skills-ref validate ./my-skill`. The repository's `skills-ref` README says to create a virtual environment and run `pip install -e .` (or `uv sync`), then lists `validate`, `read-properties` and `to-prompt`. It also states the library is "intended for demonstration purposes only" and not for production. Its validator (source read, not run) checks that the directory has a `SKILL.md`, that only `name`, `description`, `license`, `allowed-tools`, `metadata`, `compatibility` appear, name rules and match with the folder name, description at most 1024 characters, compatibility at most 500; it does not validate the body. Treat it as a format smoke test. This pack's `check_skills.py` is an example of a stricter local gate (size, structure, links); build an equivalent for your own repo. Google's published write-up also mentions CI linters for frontmatter, line counts, layout and naming plus link checkers, which is the same idea.

## Portable frontmatter

Specification fields and their limits: see `agent-skills-context-engineering` (`references/skill-format-and-authoring-rules.md`). Claude Code adds fields (for example `disable-model-invocation`, `model`, `effort`, `context`, `when_to_use`); the Claude Code page says Claude.ai uploads, the Skills API and `package_skill.py` accept only the six standard keys and error on others. Keep a portable skill to the standard keys. Antigravity's page lists `name` as optional (defaults to the folder name) and `description` as required. Codex can read an optional `agents/openai.yaml` for UI metadata and invocation policy.

## Host paths and install

| Host | Where skills go (as documented) | Notes |
|---|---|---|
| Claude Code | `~/.claude/skills/<name>/SKILL.md` (personal), `.claude/skills/<name>/SKILL.md` (project), `<plugin>/skills/<name>/` (plugin) | Live reload in session; `/reload-skills` if missing. Also lists enterprise (managed settings), nested `<subdir>/.claude/skills/`, `--add-dir` and claude.ai-account locations; account skills show as synced under `~/.claude/skills/synced/`, while the overview page says Claude Code skills are separate from claude.ai and the API: state both, do not claim they never sync |
| Claude.ai | Upload a zip in settings (paid plans with code execution on) | Not synced to API or Claude Code |
| Claude API | Upload via `/v1/skills`; reference by `skill_id` in `container.skills` | Needs code execution tool; workspace-wide sharing |
| Antigravity | Workspace `<root>/.agents/skills/<folder>/`; global `~/.gemini/config/skills/<folder>/` | CLI also reads `~/.gemini/antigravity-cli/skills/`; `/skills reload` |
| Codex | `$REPO_ROOT/.agents/skills` (and each directory up from the working directory), user `$HOME/.agents/skills`, admin `/etc/codex/skills` | Restart if a new skill does not appear; plugins for distribution |
| OpenAI API | `POST /v1/skills` with a zip or multipart folder; attach as `skill_reference` | Limits below |
| Microsoft Agent Framework | Directories scanned up to two levels deep by `SkillsProvider.from_paths` (Python) or `AgentSkillsProvider` (C#) | Also inline, class-based, MCP-based sources |

## Limits and constraints

- OpenAI API: one `SKILL.md` per bundle (case-insensitive), zip upload max 50 MB, max 500 files per version, max 25 MB uncompressed file size.
- Claude API: no network access and no runtime package installation in the container; Claude.ai network access varies by settings; Claude Code has the user's network.
- Claude Code re-attaches the first 5,000 tokens of each skill after compaction, within a shared 25,000-token budget.
- Microsoft Agent Framework: the load, read-resource and run-script tools need approval by default; file-based scripts need a runner, and the sample subprocess runner is for demonstration only.
- Use forward slashes in all paths.

## Boundary notes

Skills are not MCP tools: MCP is a protocol between a host and servers; the 2026-07-28 specification page lists an optional "Skills over MCP" extension. A2A is an agent-to-agent protocol; its AgentSkill is an Agent Card concept, not a `SKILL.md`. The A2A page read does not define AgentSkill, so only that distinction is claimed.

## How an agent should apply this

1. Run the local checker, then optionally `skills-ref validate`; fix format errors first.
2. Keep frontmatter to standard keys when the skill must cross hosts; add host-specific keys only in a host-specific copy.
3. Confirm the target host's path and network or package limits from its current docs before promising a script works there.
4. Zip with the skill folder as the single top-level entry for upload hosts.
5. Tell the user that a zipped skill uploaded to one Claude surface will not appear on the others.
6. Review third-party skills as code before installing (`software-supply-chain-security`, `agent-skills-context-engineering`).
