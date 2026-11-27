# Rule Registry (Single Source of Truth for Rule Ids)

Sources: all files listed in the Owner column, plus the source list in [sources.md](sources.md) · Last verified 2026-11-27

Registry method (id, canonical sentence, owner, agreement, confidence): `ssot-and-dry`. `SKILL.md` and the references cite the id; change the owner file and its row, nothing else.

Local legend. Agreement `own design` means the pack author's synthesis, no source states it. Enforceable by: `advisory instruction` is text the model may ignore; `hook`, `permission` and `test` are deterministic harness or CI mechanisms.

Files: SKILL = [../SKILL.md](../SKILL.md) · CMO = [claude-md-official-guidance-and-limits.md](claude-md-official-guidance-and-limits.md) · MEM = [memory-hierarchy-imports-and-rules.md](memory-hierarchy-imports-and-rules.md) · AGM = [agents-md-standard-and-interoperability.md](agents-md-standard-and-interoperability.md) · CTX = [context-engineering-for-instruction-files.md](context-engineering-for-instruction-files.md) · SPEC = [agent-skills-spec-and-progressive-disclosure.md](agent-skills-spec-and-progressive-disclosure.md) · DESC = [skill-description-and-trigger-design.md](skill-description-and-trigger-design.md) · META = [meta-skill-routing-patterns-compared.md](meta-skill-routing-patterns-compared.md) · TLA = [three-layer-orchestration-architecture.md](three-layer-orchestration-architecture.md) · KPA = [karpathy-four-principles-analysis.md](karpathy-four-principles-analysis.md) · KEX = [karpathy-examples-before-after.md](karpathy-examples-before-after.md) · KAU = [karpathy-claude-md-audit-and-update-procedure.md](karpathy-claude-md-audit-and-update-procedure.md).

## Start-of-task protocol, precedence, architecture

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence | Enforceable by |
|---|---|---|---|---|---|---|
| PROTO-01 | Non-trivial tasks start by reading the instruction files once, classifying the task, checking skills by description only, then applying `model-effort-routing`. | SKILL section 2 | TLA, META (using-superpowers) | partial: using-superpowers forces a check before any reply; the pack uses a plain-match threshold (META-01) | medium (own design) | advisory instruction; a session-start hook can inject a reminder where the host supports it |
| PROTO-02 | Keep at most 3 candidate skills whose descriptions plainly match, process before implementation before review; a fourth means split the task; load bodies one at a time. | SKILL section 2 | TLA, META, DESC | agree on ordering; the cap of 3 is own design | medium | advisory instruction |
| PROTO-03 | Tiny tasks and dispatched subagents skip the protocol; announce the choice in one line; say "no skill applies" when true. | SKILL section 2 | META (subagent guard), TLA | agree | medium | advisory instruction |
| CONF-01 | Conflict order: safety, explicit user instruction, project instruction files, skills, defaults; between skills the stricter safety rule then the more specific skill; then ask one question. | SKILL section 7 | META (user over skills over defaults), CMO section 7 (value ordering) | partial: the source states three levels; the rest is own design and inference | medium | advisory instruction; permissions and hooks bind only tool actions |
| LAY-01 | Three layers: global instructions (pointer plus hard rules), discovery index (descriptions), precedence meta-skill; layer 1 never repeats layer 3 text. | TLA sections 1-2 | SPEC, META | own design from several sources | medium | advisory instruction |
| BUD-01 | Estimate the discovery index as skills times about 100 tokens (spec figure), measure the real total, and prune before adding a competing skill. | TLA section 4 | SPEC section 2 | conflict: blog says 30-50 tokens, a long description can reach about 250; resolved by measuring | medium | test (a script that sums description sizes) |
| STOP-01 | Stop when the skill's done-check passes or the user changes scope; two failed routings mean ask the user; never use the router to delay a trivial answer. | TLA section 4 | none | own design | medium | advisory instruction |

## Instruction files: nature, size, content, enforcement

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence | Enforceable by |
|---|---|---|---|---|---|---|
| ADV-01 | CLAUDE.md and similar files are context the model reads, not configuration; adherence is not guaranteed. | CMO section 1 | KPA, KAU | agree; verified in the docs' own words | high | none: it is a fact about the mechanism |
| SIZE-01 | Keep each CLAUDE.md under about 200 lines as a target, not a cap; imported text counts. | CMO section 3 | CTX, MEM, secondary notes | agree (the secondary sources are not independent) | high | test (line-count script or CI); the host warns at startup |
| SIZE-02 | The pack's budget for always-loaded user files is about 4 KB. | `model-effort-routing` section 7 (pointer only) | TLA | pack policy, not a vendor rule | medium | test (size script) |
| LIM-01 | Launch-loaded files load whole up to a hard size; on-demand files are truncated per file (v2.1.309); the exact numbers depend on the context window. | CMO section 3 | none | version-sensitive; read from docs | high | none (host behavior) |
| INC-01 | Include only what the model cannot derive from the code (verification commands, misleading spots, invisible decisions, twice-corrected points); exclude layouts, dependency lists and procedures. | CMO section 2 | CTX section 3 | conflict: a 2025 article said include everything useful; the 2026 docs are stricter and are followed | high | advisory instruction; `/doctor` trims derivable content |
| VER-01 | Write each rule so it can be checked: a command, a path, a number. | CMO section 2 | KPA | agree | high | advisory instruction |
| EMP-01 | Do not rely on capital-letter emphasis on current models; shorten the file or move the rule to a hook. | CMO section 5 | CTX, KAU (claimed by a blog) | conflict: the 2025 article tuned adherence with emphasis; superseded by the 2026 docs | medium-high | hook (moving it) |
| ENF-01 | A rule the model keeps missing, a rule with zero exceptions, or a rule a command can check belongs in a hook, deny rule or managed setting; judgment stays prose; keep the enforced set small. | CMO section 4 | KPA, KAU, CTX | agree; one blog repeats it without a primary link | high | hook, permission, test |
| ENF-02 | Only command, http and mcp_tool hooks are deterministic; hooks that ask another model are not. | CMO section 4 | none | docs only | high | hook |
| ENF-03 | `.claude/rules/` files are loaded text: they scope guidance, they do not enforce it. | CMO section 4 | MEM section 3 | partly differs from the claim "mandatory rules belong in rules files" | high | none |
| CHK-01 | Verify what loaded and whether a rule fires: `/context all`, `/memory`, an `InstructionsLoaded` hook, `/doctor prompt-audit` (v2.1.283+), and a behavioral test; a rule never observed is unverified. | CMO section 6 | MEM, AGM | agree; version-sensitive | high | hook (logging), test |
| VAL-01 | Instruction files sit below safety and ethics in the value ordering; a CLAUDE.md line cannot be assumed to override them. | CMO section 7 | none | inference from the constitution's ordering | medium | none |
| PLC-01 | Place content by load pattern: root file for the tiny always-needed part, nested file by location, `paths` rule by file type, skill by task, pointer instead of pasted text, durable rules in a file. | CTX section 2 | CMO, MEM | agree; own synthesis | medium | advisory instruction |
| ORD-01 | Structure with headers and flat bullets, one statement per rule; hard constraints first is an unproven convention. | CTX section 4 | CMO (docs advice on structure) | partial: first-position benefit has no benchmark | low-medium | advisory instruction |

## Memory hierarchy, imports, rules, AGENTS.md

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence | Enforceable by |
|---|---|---|---|---|---|---|
| PREC-01 | Instruction files are concatenated, none overrides another; the file nearest the working directory is read last (recency, not priority); remove contradictions instead of relying on order. | MEM section 1 | CTX, CMO | agree; contradicts the claim that later files win | high | none; settings (permissions, hooks) do have real precedence |
| SCOPE-01 | Four scopes load broad to narrow: managed policy, user, project, local. | MEM section 1 | CMO | agree | high | permission (managed policy settings) |
| LOAD-01 | Ancestors of the working directory load at launch; subdirectory files load on demand when a file there is touched. | MEM section 1 | CTX | agree | high | none (host behavior) |
| IMP-01 | `@path` imports are recursive to at most four hops, relative to the importing file; code spans and fenced blocks are not parsed. | MEM section 2 | none | docs only; version-sensitive | high | none |
| IMP-02 | Imports do not save tokens: imported text loads with the importer. | MEM section 2 | CMO, CTX (pointers) | agree | high | none |
| IMP-03 | A project import or symlink that resolves outside the working directory needs a one-time approval; verify it happened. | MEM sections 2-3 | none | docs only | medium-high | permission (the approval dialog) |
| RUL-01 | `.claude/rules/` files with a `paths` field load when a matching file is touched; `paths` is the only frontmatter field read; confirm a glob matches before trusting it. | MEM section 3 | CMO | agree | high | hook (`InstructionsLoaded` logging), test |
| MEM-04 | Team-relevant rules go in versioned CLAUDE.md; auto memory is personal and machine-local, loaded as the first 200 lines or 25 KB of its index. | MEM section 4 | CMO (pointer) | agree | high | none |
| CMP-01 | Root CLAUDE.md is re-read after compaction; chat-only instructions and nested files may need reloading, so write durable rules to a file. | MEM section 5 | CTX | agree | high | none |
| AGM-01 | AGENTS.md is plain Markdown with no required fields; the nearest file wins in a monorepo and an explicit user prompt overrides it. | AGM section 1 | none beyond the site | site claims (adoption counts) are not verified | high for format, low for adoption | none |
| AGM-02 | Claude Code reads AGENTS.md directly from v2.1.277, only when no CLAUDE.md-family file exists at or above the working directory; a personal CLAUDE.local.md switches the fallback off. | AGM section 2 | MEM | verified in the docs; a news article was unreadable | high; version-sensitive | none (host behavior); `/memory` shows it |
| SSOT-01 | Keep one hand-edited source for tool-neutral rules (AGENTS.md); tool-specific files hold only their deltas and import or derive the rest; never maintain two copies. | AGM section 3 | KEX (multi-editor PR), `ssot-and-dry` | agree | medium-high | test (a diff or CI check that a derived file matches) |
| SSOT-02 | Prefer a CLAUDE.md that imports AGENTS.md; use a symlink only for POSIX-only repos with no Claude-specific text. | AGM section 3 | none | docs recommend the import; symlink caveats from the docs | medium-high | test (check the file is listed by `/context all`) |

## Skills, descriptions, routers

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence | Enforceable by |
|---|---|---|---|---|---|---|
| SPEC-01 | `name` is 1 to 64 characters and equals the folder name; `description` is 1 to 1024 characters and says what and when. | SPEC section 1 | `agent-skills-context-engineering` (pointer) | agree | high | test (`skills-ref validate` or a script) |
| SPEC-02 | Metadata is about 100 tokens per skill; body under about 5000 tokens and `SKILL.md` under 500 lines are recommendations, not validator rules. | SPEC section 2 | skill-creator, a PDF guide, a blog | conflict: words vs tokens, 30-50 vs 100 tokens; spec figures used, others labeled claims | medium | test (size script) |
| SPEC-03 | The claim "26 or more platforms" is unverified and must not be hard-coded. | SPEC section 3 | a blog | the spec home page gives no count | low | none |
| SPEC-04 | Reserved words, tag bans and `model`/`effort` header keys are vendor extensions, not portable. | SPEC section 5 | `model-effort-routing` | agree | medium-high | test (a portability lint) |
| SPEC-05 | A structure validator checks format, not routing quality; routing needs trigger evals. | SPEC section 4 | DESC | agree | high | test (evals) |
| RT-01 | Route from `name` and `description` only; load a body after selection. | DESC section 1 | SPEC section 6, TLA | agree | high | none |
| RT-02 | A description is capability plus `Use when` trigger plus exclusion, in third person, with real user phrasing, at most 1024 characters. | DESC section 2 | SPEC, a PDF guide, skill-creator | agree | high | test (lint for the clauses and length) |
| RT-03 | Give each overlapping pair an exclusion naming the other and one owner per noun; the protocol, not the description, orders residual overlaps. | DESC section 4 | TLA | agree; own design for the owner-per-noun table | medium | test (a collision report) |
| RT-04 | Undertriggering needs concrete phrasing; overtriggering needs narrower scope and exclusions; resolve the pushy-versus-negative-triggers tension with data. | DESC section 3 | skill-creator, a PDF guide | conflict: opposite advice; resolved by evals, strict in packs with many overlaps | medium | test (evals) |
| RT-05 | Keep 10 or more labeled trigger queries per skill with near-misses and a held-out split; test on the lightest target model and effort. | DESC section 5 | skill-creator, a PDF guide | partial: counts differ (20 queries vs 10-20) | medium-high | test (evals) |
| META-01 | Invoke a skill when its description plainly matches; reject the "any chance, even 1%" rule and the absolute "before clarifying questions" rule. | META section 5 | `model-effort-routing` (inspect before asking) | conflict with using-superpowers; pack choice, own design | medium | advisory instruction |
| META-02 | Keep rationalization lists to 3-4 lines; enforce with a hook where one exists. | META section 4 | using-superpowers (twelve-row table) | partial | medium | hook |

## Karpathy-style rules

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence | Enforceable by |
|---|---|---|---|---|---|---|
| KP-01 | The four principles are a distillation by the repo author from public remarks, not a document written by Karpathy; the README says MIT but no LICENSE file was found; nothing is copied; no formal diff test exists. | KPA | KEX, a listing site, a vendor blog | agree across sources; star counts and dates volatile | high | none |
| KP-02 | Each principle has one owner for its detail: Think to `grilling`, Simplicity to `kiss-yagni-aha` and `clean-code-for-agents`, Surgical to `clean-code-for-agents` and `code-review`, Goal-Driven to `tdd` and `implement`. | KPA (owner column) | SKILL section 5, KAU | agree; own mapping | medium | advisory instruction |
| KP-03 | The canonical wording of the four rules is the template in KAU; other files link to it. | KAU | KPA, SKILL section 5 | own design | medium | test (a diff against the template) |
| KP-04 | Audit order: measure, map, find conflicts, dedupe against the pack, split advisory from enforced, test against real failures, record. | KAU | a vendor blog | own synthesis | medium | advisory instruction |
| KP-05 | The rules carry a trade-off clause: care over speed, trivial edits use judgment. | KPA | KAU, SKILL | agree | high | advisory instruction |
| KP-06 | Per principle, checkable parts (tests pass, formatter clean, edits inside an allowlist) go to hooks or CI; the rest stays advisory. | KPA | CMO section 4 (ENF-01) | own suggestion | medium | hook, test |
| KP-07 | Good replies show assumptions before edits, a minimal diff, and a plan with a check per step. | KEX | KPA | own examples | medium | advisory instruction |
| KP-08 | Simplicity First and Goal-Driven Execution map to the cheapest-sufficient-path rule of `model-effort-routing`. | `model-effort-routing` sections 1-2 (pointer only) | SKILL section 5 | own cross-map | medium | advisory instruction |

## Rules owned by existing pack skills (pointers only)

| Topic | Owner skill |
|---|---|
| Simplicity, small diffs, naming | `clean-code-for-agents`, `kiss-yagni-aha` |
| Verification, tests, plans with checks | `tdd`, `implement` |
| Diff review | `code-review` |
| Model, effort, delegation, 4 KB budget | `model-effort-routing` |
| Context theory and skill authoring | `agent-skills-context-engineering` |
| One home per fact (method) | `ssot-and-dry` |

## Deduplication log

Rules that were stated in more than one reference were cut from the less authoritative file and replaced by a link to the owner:
- Imports do not load less (IMP-02) and auto memory limits (MEM-04): removed from CMO and CTX; owner MEM.
- Rules are loaded text (ENF-03) and hooks for zero-exception rules (ENF-01): removed from MEM, KPA, KAU and CTX; owner CMO.
- Recency is not priority (PREC-01), emphasis (EMP-01), compaction (CMP-01): removed from CTX; owners MEM and CMO.
- Include and exclude list (INC-01), 200-line target (SIZE-01): removed from CTX; owner CMO.
- Copy drift across editors (SSOT-01): removed from KEX; owner AGM.
- Full spec field table, third-person rule, discovery-budget estimate (SPEC-01, RT-02, BUD-01): trimmed in SPEC; owners `agent-skills-context-engineering`, DESC, TLA.
- The numbered protocol, load cap and instruction priority (PROTO-01 to PROTO-03, CONF-01): removed from TLA and META; owner SKILL.
- Principle wording (KP-03) and advisory text: KPA now carries labels only; owner KAU for wording.
- Context-engineering theory: removed from CTX; owner `agent-skills-context-engineering`.

## Moved on 2026-11-24

`SKILL.md` was cut from about 15.1 KB to under 13 KB (the pack budget for a pillar skill). No rule was dropped: the body now keeps the protocol, load cap, conflict order, decision matrices, the four Karpathy lines with owners and the checklist, and states every other rule as one line with its id. Each id still points to the owner in the table above:
- Three-layer table and failure modes (LAY-01): owner TLA sections 1-2; the body keeps a one-paragraph summary.
- Version-sensitive facts (AGM-02, IMP-01, IMP-02, LIM-01, CHK-01): owners AGM, MEM and CMO; the body keeps a pointer line and the instruction to quote the version.
- Include and exclude list, size, placement, single source, audit steps (INC-01, VER-01, SIZE-01, PLC-01, SSOT-01, SSOT-02, KP-04): owners CMO, CTX, AGM and KAU; the body keeps one line each.
- Primary-source status of the Karpathy file (KP-01): owner KPA; the body keeps a pointer.
- Router rules and the spec table (RT-01 to RT-05, META-01, META-02, SPEC-01 to SPEC-05): owners DESC, META and SPEC; the body keeps four numbered lines and a one-line summary of the spec limits.

## Re-verified on 2026-11-27

Every version-gated rule (SIZE-01, LIM-01, IMP-01, AGM-02, CHK-01, EMP-01, ENF-02) was re-read against the memory and best-practices pages; no rule id, owner or limit changed. ENF-02 now names `mcp_tool` instead of "tool". Not re-checked: PDF guide text (binary fetch), blocked pages.
