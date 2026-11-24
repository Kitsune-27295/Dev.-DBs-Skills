# Rule Registry (Single Source of Truth for Rule Ids)

Sources: all files listed in the Owner column, plus the source list in [sources.md](sources.md) · Last verified 2026-11-24

This is the canonical registry. Each rule has one id, one canonical sentence, and one owner file that holds the full discussion. `SKILL.md` and the reference files cite the id and do not restate the rule (method: `ssot-and-dry`). If a rule changes, change the owner file and this row, nothing else.

How to read the columns. Agreement: `agree` means the sources say the same thing; `agree (one lineage)` means several sources descend from the same book, so the agreement is not independent evidence; `partial` means they agree on the principle and differ on detail; `conflict` names the decision id in [rule-conflicts-and-resolutions.md](rule-conflicts-and-resolutions.md). Confidence: high when a primary source states it or independent sources agree; medium when it rests on secondary summaries or on my own inference; low when it is opinion. Source tags: G = wojteklu gist, V = victorcorcos repo, T = tahsinature repo, K = Linux kernel style, P10 = Power of 10, TB = TigerStyle, GO = Google review guide, SO = Stack Overflow comments article, GR = grug essay and agent skill, RG = Refactoring.Guru, AG = AGENTS.md-style gist. Numeric limits are never rules here: they are soft heuristics (FN-02, FN-03).

Files: SIM = [simplicity-and-complexity-bias-of-llms.md](simplicity-and-complexity-bias-of-llms.md) · HEU = [clean-code-heuristics-canonical.md](clean-code-heuristics-canonical.md) · SMELL = [code-smells-for-agent-generated-code.md](code-smells-for-agent-generated-code.md) · CMT = [comments-why-not-what.md](comments-why-not-what.md) · KERN = [linux-kernel-style-functions-and-comments.md](linux-kernel-style-functions-and-comments.md) · P10F = [power-of-10-and-tigerstyle-transferable-rules.md](power-of-10-and-tigerstyle-transferable-rules.md) · GOF = [google-review-standard-and-looking-for.md](google-review-standard-and-looking-for.md) · AGF = [agent-guideline-files-reviewed.md](agent-guideline-files-reviewed.md) · CONF = [rule-conflicts-and-resolutions.md](rule-conflicts-and-resolutions.md).

## Simplicity and abstraction timing

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence |
|---|---|---|---|---|---|
| SIM-01 | Write only what today's requirement uses: no extra layer, manager, one-implementation interface, single-use helper or unrequested option. | SIM (section 2) | GO complexity, RG Speculative Generality, V and T YAGNI, G | agree (one lineage for G, V, T) | high |
| SIM-02 | Decline speculative features; if you must deliver, ship the 80% version and say in one line what you left out. | SIM (section 3) | GR, GO | agree | medium |
| SIM-03 | Wait for a second real use or a real difficulty before cutting an abstraction; a cut point hides real mess behind a narrow interface. | SIM (section 4) | GR, V and T (Rule of Three, via neighbors) | agree | medium |
| SIM-04 | Same fact changing together shares one home; lookalikes stay local; do not make a reader visit five files for one behavior. | SIM (section 5) | G, V, T DRY, GR | conflict: CF-01 | high |
| SIM-05 | Find why odd code exists before removing it; refactor in small steps that keep tests green. | SIM (section 6) | G boy scout rule | conflict: CF-06 | medium |
| SIM-06 | Split dense clever expressions into named locals a debugger can inspect. | SIM (section 2) | G, K (no tricky expressions) | agree | high |

## Naming

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence |
|---|---|---|---|---|---|
| NAM-01 | Names are intention-revealing, pronounceable, searchable and distinct; no type or scope prefixes; follow language and team conventions. | HEU | K, GO, TB, AG | agree | high |
| NAM-02 | Name length follows scope: short for tiny locals, descriptive for anything wide. | KERN | TB, G | conflict: CF-12 | high |
| NAM-03 | Put units in names (`timeout_ms`); keep index, count and size distinct. | P10F | TB only | transferable idea, word order is style | medium |
| NAM-04 | Replace magic numbers with named constants. | HEU | G | agree | medium |
| NAM-05 | Command-named functions signal failure; predicate-named ones return a boolean; name and return type agree. | KERN | none | single source | medium |

## Functions and control flow

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence |
|---|---|---|---|---|---|
| FN-01 | A function does one thing at one abstraction level; split along a real boundary, not per line, and keep a narrow public surface. | HEU | K, P10, TB, G, V, RG Long Method | partial; conflict: CF-02 | high |
| FN-02 | Nesting beyond about 3 levels and more than about 5-10 locals are triggers to split (kernel numbers, C kernel code only). | KERN | none | soft heuristic; conflict: CF-09 | medium |
| FN-03 | A function longer than about 60 lines (P10, safety-critical C) or 70 lines (TB, a Zig database) is a trigger to look, not a law. | P10F | K (no number) | conflict: CF-09 | medium |
| FN-04 | No boolean flag arguments; write two named functions or an enum with distinct behavior. | HEU | G, V, RG | agree (one lineage); V's string-switch fix is rejected | high |
| FN-05 | Keep parameter lists short; args that travel together become one object. | HEU | G, RG Long Parameter List | agree | medium |
| FN-06 | Use guard clauses and early returns; state conditions positively; name a complex condition. | HEU | TB, AG, RG | agree; conflict on named predicate vs local: CF-05 | high |
| FN-07 | Declare data in the smallest scope, near first use; never reuse a variable for two meanings. | P10F | G, TB | agree | high |
| FN-08 | No hidden side effects; avoid long call chains (Law of Demeter). | HEU | G, RG Message Chains | agree | medium |
| FN-09 | Read order is top-down: callers above callees; defer to the project formatter. | HEU | G, V | agree (one lineage) | medium |
| FN-10 | Write cleanup once (`finally`, `defer`, `with`), not per return path. | KERN | none | transferable principle of a C mechanism | medium |
| FN-11 | Bound loops over external work (retries, pagination, queues, timeouts) and fail loudly when exceeded. | P10F | TB | partial: do not bound in-memory loops | medium |

## Comments (all text lives in CMT)

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence |
|---|---|---|---|---|---|
| CM-01 | Try to remove the need for a comment first: rename, extract, name a constant. | CMT | GO, K, SO, V | agree | high |
| CM-02 | Comment only what code cannot hold: reason, constraint, reference, surprise; inline comments say why, function-level comments state the contract. | CMT | GO, K, SO, TB | conflict: CF-04 (resolved in CMT) | high |
| CM-03 | Never leave restating comments, task chatter, journals or commented-out code. | CMT | G, V, AG, SO | agree | high |
| CM-04 | Document the contract of public functions; do not restate the signature. | CMT | GO, K | agree | medium |
| CM-05 | A TODO names the gap and ideally an issue; it never defers work you were asked to do. | CMT | SO, AG (bans TODO) | conflict: AG vs SO, resolved in CMT | medium |
| CM-06 | When you change code, fix or delete the stale comments around it. | CMT | GO, SO | agree | high |

## Errors and boundaries (policy detail: `error-handling-problem-details`, `defensive-domain-modeling`)

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence |
|---|---|---|---|---|---|
| EB-01 | Handle only failures that can really occur at this boundary; name the failure and who observes it; no defensive wrapper without one. | SIM (section 2) | GR | conflict: CF-10 | medium |
| EB-02 | Handle or explicitly ignore every error or return value, with a stated reason when ignored. | P10F | TB, K | agree; P10 calls it the most violated rule | high |
| EB-03 | Validate untrusted input and return errors; assert only states that cannot happen; never pad assertions to a count. | P10F | TB | partial: CF-10 | medium |
| EB-04 | Validate and fail fast near the top of a function; give error messages context. | AGF | G (root cause), P10 | single secondary source | low |
| EB-05 | Do not halt the process for a recoverable condition; reserve crashes for corrupt state. | KERN | TB (crashes on corruption) | partial: right for a database, not a web request | medium |

## Dead code, scope and consistency

| Id | Canonical rule | Owner | Other sources | Agreement / conflict | Confidence |
|---|---|---|---|---|---|
| DC-01 | Delete what nothing uses (imports, helpers, branches, scaffolding, speculative members); version control remembers. | SMELL | G, V, T, AG | agree (one lineage); V's own example is inconsistent | high |
| SM-01 | Scan your own diff for the 12 smells before handoff; a smell is a prompt to look, not a verdict. | SMELL | RG | taxonomy from RG, frequency order is my inference | medium |
| CN-01 | Existing linter, formatter and project conventions win; where silent, match the surrounding code; strict tooling at its strictest from the first commit (P10 rule 10). | GOF | G, P10, AG | agree; conflict: CF-11 | high |
| CN-02 | Do not mix reformatting or renames with functional changes. | GOF | none | single primary source | high |
| SC-01 | Ship the smallest complete change that clearly improves code health; better, not perfect; never knowingly worsen health. | GOF | GR (small steps) | agree | high |
| SC-02 | No drive-by refactors or unrelated improvements; report them instead. | GOF | AG (rejected opposite), SMELL | agree | high |
| SC-03 | Tests and docs for the change ship in the same change; delete docs of deleted code. | GOF | GR, G | agree | medium |
| SC-04 | Reread your own diff line by line and read the whole function you touched; rewrite what you cannot read without effort. | GOF | none | single primary source, applied to the author (my inference) | medium |

## Not generalized (do not copy outside their home)

| Id | Rule family | Owner | Why not general | Confidence |
|---|---|---|---|---|
| NG-01 | Zig/TigerBeetle-specific: static allocation, explicit-width integers instead of `usize`, no dependencies, 80-column limit, allocator rules, "zero technical debt" as policy | P10F, AGF | Language and organization choices of one database team | high |
| NG-02 | C and safety-critical-specific: no dynamic allocation after init, no function pointers, preprocessor limits, no recursion or goto as absolutes, two assertions per function as a quota | P10F | Provable-bound rules for real-time C; apps in managed languages should not copy them | high |

## How an agent should apply this

- Cite rule ids in your hand-off summary instead of rewriting rules.
- When two ids disagree, read the CF id in the last column before choosing.
- Treat anything in the Not generalized table as out of scope unless the project itself adopts it.
- When adding a rule to any reference file, add or update its row here first.
