---
name: agent-skills-context-engineering
description: Use when designing portable Agent Skills (agentskills.io specification, progressive disclosure, Microsoft Agent Framework SkillsProvider/MCP skill:// integration), engineering finite LLM context windows (context rot mitigation, Goldilocks system prompts, just-in-time retrieval, compaction, structured note-taking, sub-agent isolation), or designing outer coding-agent harnesses (feedforward Guides vs. feedback Sensors, Computational vs. Inferential controls).
---

# Agent Skills, Context Engineering & Harness Design

One idea: **LLM attention is a finite resource subject to `context rot` ($n^2$ pairwise attention dilution)** — engineer every system around delivering the **smallest high-signal token set** at each turn (**Context Engineering**), packaged into **portable progressive-disclosure modules** (`agentskills.io`), and governed by an outer cybernetic loop of **feedforward Guides and feedback Sensors** (**Harness Engineering**). Sources and their claims: [references/sources.md](references/sources.md).

> **Scope Boundary:** For runtime LLM application topologies (Workflows vs. Agents, Hybrid RAG indexing, ACI tool ergonomics), use `agentic-rag-architecture`. Focus here on portable Skill packaging, context-window curation, and agent-steering harnesses.

## 1. The Open `agentskills.io` Specification & Progressive Disclosure

A portable skill is a folder containing at minimum `SKILL.md`, with optional `scripts/` (executable code), `references/` (on-demand docs), and `assets/` (static templates/schemas).

### `SKILL.md` YAML Frontmatter Contract

| Field | Required | Constraints & Semantics |
|---|---|---|
| `name` | Yes | 1–64 chars; lowercase alphanumeric + hyphens (`a-z`, `0-9`, `-`); no leading/trailing `-` or `--`; **must match parent directory name** |
| `description` | Yes | 1–1024 non-empty chars; states *both* what the skill does and specific trigger keywords/contexts for *when* to activate it |
| `license` | No | Short license identifier (e.g., `Apache-2.0`) or bundled license file name |
| `compatibility` | No | 1–500 chars; only include for hard runtime dependencies (tools, Python version, network) |
| `metadata` | No | Flat string-to-string key/value map (`author`, `version`); avoid nested collections |
| `allowed-tools` | No | Experimental space-separated pre-approved tool list (support varies by runtime) |

### Three / Four Stages of Progressive Disclosure
1. **Discovery / Advertise (~100 tokens/skill `*claim*`):** Only `name` and `description` load into the system prompt at startup so agents can route among 100+ skills cheaply.
2. **Activation / Load (<5,000 tokens & <500 lines recommended):** Full `SKILL.md` body loads only when relevant (or via `load_skill` tool).
3. **Read Resources (on demand):** Linked files in `references/` or `assets/` load selectively (`read_skill_resource`). **Keep file links 1 level deep** from `SKILL.md` with forward slashes (`/`) and unique lowercase filenames (case-insensitive filesystems & MCP archives collide on `Guide.md` vs. `guide.md`). Add a Table of Contents to reference files >100 lines.
4. **Execute Scripts (on demand):** Bundled `scripts/` run via shell/`run_skill_script` so deterministic logic and large files stay *out* of the context window — only script output consumes tokens. Clarify explicitly whether to **run** a script or **read** it.

### Production Runtime Integration & Supply-Chain Governance (Microsoft Agent Framework)
- **Composable Skill Sources:** Combine `FileSkillsSource`, code-defined `InlineSkill`/`ClassSkill`, and remote MCP `skill://index.json` sources using combinators (`Aggregating`) and decorators (`Deduplicating`, `Caching` with tenant isolation keys, `Filtering`).
- **Compaction & Context Hygiene:** Unload stale skill instructions/resources once a sub-task finishes (`UnloadSkillsCompactionStrategy` pattern).
- **Treat Untrusted Skills Like Third-Party Code:** Require explicit approval or sandboxing for `run_skill_script`; never auto-execute scripts inside untrusted remote MCP `archive` skills; inject host secrets/context through typed invocation context rather than model-controlled `kwargs`; sanitize `IncludeDetailedErrors` exceptions before feeding them back to the model to prevent credential leaks or indirect prompt injection.

## 2. Context Engineering Principles (Anthropic)

Prompt engineering optimizes static wording; **Context Engineering** iteratively curates the *entire token state* across system prompt, tool definitions, retrieved artifacts, message history, and tool outputs at every turn:

- **Find the "Goldilocks Altitude" for System Prompts:** Avoid both brittle hardcoded `if-else` decision trees and vague platitudes ("be helpful"). Provide concrete heuristics + clear XML/Markdown section structure, starting minimal and adding rules *only* for observed model failures.
- **Canonical Few-Shot Examples Over Exhaustive Edge-Case Lists:** Curate diverse input/output pairs that anchor format and judgment rather than padding prompts with endless edge-case prose.
- **Minimal Orthogonal Toolsets & Token-Efficient Outputs:** Overloaded or overlapping tools degrade selection; cap/paginate large outputs (`agentic-rag-architecture`).
- **Hybrid Just-in-Time Retrieval:** Pre-load tiny always-needed anchors (like `AGENTS.md`), then let the agent navigate filesystems via lightweight identifiers (paths, queries, `rg`/`grep`, `head`/`tail`) so metadata (folder names, sizes, timestamps) guides progressive discovery without pre-stuffing stale chunks.
- **Three Techniques for Long-Horizon Tasks (Beyond Single Context Windows):**
  1. **Compaction:** Periodically distill nearing-limit history into high-signal summaries (architectural decisions, unresolved bugs, recent file pointers) + lightest-touch **tool-result clearing** for old raw tool outputs. Tune compaction for *recall first*, then *precision*.
  2. **Structured Note-Taking (Agentic Memory):** Persist state externally (`NOTES.md`, task checklists, memory tools) and pull back into fresh contexts after resets.
  3. **Sub-Agent Context Isolation:** Delegate deep exploratory searches (consuming tens of thousands of tokens) to clean-window sub-agents that return only 1,000–2,000 token distilled syntheses (`*claim*`).

## 3. Outer Harness Engineering (`Agent = Model + Harness`, Böckeler / Fowler)

Build trust in non-deterministic coding agents through a cybernetic steering loop pairing **before-action** and **after-action** controls:

| Control Axis | **Feedforward — Guides** (increase first-try accuracy) | **Feedback — Sensors** (enable self-correction) |
|---|---|---|
| **Computational** (fast, deterministic CPU; milliseconds–seconds) | LSP / type intelligence, deterministic `scripts/`, deterministic code-mod recipes | Compilers/typecheckers, unit/integration tests, structural boundary tests (ArchUnit / `check_skills.py`), linters with LLM-actionable fix hints, mutation tests |
| **Inferential** (semantic GPU/LLM; slower, non-deterministic) | `AGENTS.md`, `SKILL.md` workflows, domain architecture specs, MCP doc retrievers | Automated review agents, AI rubric/compliance judges, continuous codebase dead-code / SLO drift monitors |

### Harness Engineering Operating Rules
1. **Never rely on Guides alone or Sensors alone:** Guides without Sensors never verify compliance; Sensors without Guides burn tokens repeating predictable mistakes.
2. **Shift Quality & Feedback Left:** Run fast **Computational** sensors before commits and on every edit; reserve slow **Inferential** reviews and mutation testing for PR/CI gates and background drift checks.
3. **Match Control to the 3 Regulation Categories:**
   - **Maintainability Harness:** Strongest today via linters, complexity checks, coverage, dependency-boundary tests, and scheduled "garbage collection" for drift.
   - **Architecture Fitness Harness:** Architectural Fitness Functions (latency benchmarks, logging rules, import-direction checks).
   - **Behavior Harness (Hardest):** Never blindly trust AI-generated green tests alone; anchor functional behavior with specs, approved fixtures, contract tests, and targeted human review.
4. **Engineer Codebase "Harnessability":** Strongly typed languages, explicit module boundaries, and clean conventions amplify harness reliability. Keep humans focused on **steering the harness** (turning repeated agent failures into tighter Guides or Sensors) and making high-stakes judgment calls.

## Mistakes to Catch

- **Bloated Always-On Context (`SKILL.md` >500 Lines or Vague Triggers):** Loading massive monolithic rulebooks upfront triggers `context rot` and steals attention from the actual task.
- **Feedforward-Only Prompting:** Writing strict `AGENTS.md` / `SKILL.md` rules without adding fast computational Sensors (validators, tests, linters) to catch violations automatically.
- **Unsafe Skill Runtime Execution:** Treating third-party `SKILL.md` instructions or bundled scripts as trusted input without sandboxing, approval gates, or MCP integrity boundaries.
- **Unbounded History in Multi-Hour Tasks:** Allowing 50k tokens of raw tool logs to accumulate without tool-result clearing, structured notes, compaction, or sub-agent delegation.


## Deep references

- [Skill Format and Authoring Rules](references/skill-format-and-authoring-rules.md) — read when writing or validating SKILL.md frontmatter, descriptions, evals and bundled scripts.
- [Skill Runtime, Providers and Security](references/skill-runtime-providers-and-security.md) — read when hosting skills in an agent runtime (caching, approval, tenant isolation) or auditing third-party skills.
- [Long-Horizon Context Strategies](references/long-horizon-context-strategies.md) — read when a task outgrows one window: compaction, notes, sub-agents, JIT retrieval.
- [Harness Guides, Sensors and the Steering Loop](references/harness-guides-sensors-and-steering.md) — read when designing feedforward/feedback controls for coding agents.
