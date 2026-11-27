---
name: simplification-audit
description: "Audit a codebase for what can be removed or collapsed, with evidence: dead APIs, flags, states, config keys and tests, habit obligations, features with no complete effect path, duplicated paths and parallel representations, speculative generality. Each candidate gets a consumer-evidence record (producers, consumers, search method, runtime evidence), what disappears and what remains, the strongest reason to keep it and alternatives rejected; nothing is proposed for deletion without proof of no consumers or a named capability loss. Delegates discovery by bounded domain and hands removal to safe-migration skills. Not for day-to-day simplicity while writing code (use kiss-yagni-aha) or auditing someone else's repository (use oss-deep-audit). Use when asked to simplify, prune, find dead code or unused options, cut maintenance burden, or decide whether to keep an old path."
---

# Simplification Audit — Find What Can Go, Prove Nobody Needs It

One idea: **every API, flag, state, config key, test and rule is a maintained obligation, and the audit's job is to find the ones whose cost exceeds their value, then prove, with evidence of consumers, that removing them is safe.** A candidate without consumer evidence is a guess; a deletion without it is a bet on other people's code. Sources and claims not adopted: [references/sources.md](references/sources.md).

Boundaries (one owner per rule): day-to-day code-level simplicity and abstraction timing is `kiss-yagni-aha`; the cost model of speculative building is `yagni-evolutionary-architecture`; executing a removal across consumers, including Branch by Abstraction, is `parallel-change-expand-contract`; moving code into layers without changing behavior is `layered-refactor`; authoring rules that keep new code lean are `clean-code-for-agents`; auditing someone else's repository is `oss-deep-audit`. This skill owns the **discovery, evidence and proposal** step, not the edit.

Default posture: **a survey is not permission to implement.** Report candidates and wait for a go-ahead unless the user asked for the change.

---

## 1. Fix scope and constraints before searching

- Ask or infer: which repository area, which kinds of removable thing, and what is protected (a public API, a deliberate twin implementation, a compliance obligation, an extension point for third parties).
- Read the project's architecture notes, decision records and agent instructions first. A decision that says "keep both implementations on purpose" is a constraint; do not propose deleting what it protects unless the user overrides it. Unused members **inside** a protected design stay candidates.
- Treat requirements, checks and notes introduced by the code under review as design choices to assess, not as independent proof the distinction is needed.
- Decide the output now: a ranked proposal list, small inline cleanups, or a branch comparison. Say it back in one line.

## 2. Delegate discovery by domain

For a broad request, split into **independent, bounded domains** (for example: core logic and persistence; model and tool assembly; public clients and SDKs; process and execution providers; composition, scripts, tests and docs) and give each agent a brief with: the domain boundary, the categories in section 3, the consumer-evidence rule in section 4, the record format in section 5, and a cap on candidates. Require **consumer evidence and rejected alternatives** back, not opinions. Merge results yourself, dedupe, and re-check any candidate two domains touch.

Do not stop after the first promising deletion. Inspect substantial production machinery, not only unused symbols; the large wins are usually subsystems, not helpers.

## 3. Where removable obligations hide

| Question | What you find |
|---|---|
| Does the declared feature have a **complete effect path**? | Field copied through every layer that has no setter, no reader, or only implementations that reject it; a CLI or config pass-through shadowed before use. Trace producer, transformation, support check, observable result. |
| Which **distinctions change a consumer's action**? | Several internal states that map to one outward status; a public enum value nobody branches on; adapters differing only in name. Delete the distinction separately from relocating its declaration. |
| Could a **smaller explicit behavior** remove the subsystem? | A fixed interval instead of a generalized scheduler; a caller-supplied value instead of a stored default; a reported failure instead of automatic rollback. Name the capability given up and the machinery deleted. |
| Can the consumer **read the authoritative value when needed**? | Copied histories, promotion ledgers, invalidation events followed by a read, a feature cache beside a shared stream. Derivation can delete subscriptions, stale handling and recovery paths together. |
| Is **composition mistaken for policy**? | A registry or dependency check that only restates "this optional service is present". Explicit configuration may replace it. |
| What owns the **complete maintenance cost**? | Duplicate application trees, demo launchers used as products, resolver-only workspaces, helpers with their own upgrade lifecycle. Compare the entire removed system with the replacement, including residual glue. |
| **Habit obligations** | Checks, reviews, reports, approvals, or tests kept because "we always did", with no consumer who reads them or failure they have ever caught. |
| **Dead and speculative code** | Unused variables, parameters, fields, methods, classes, branches unreachable after earlier changes, flags permanently on or off, config keys nothing reads. |
| **Tests and docs** | Tests that pin a removed or private behavior, duplicate coverage at several levels, docs restating code. |

Moving an unnecessary concept closer to its owner, or adding a gate to keep duplicate definitions equal, does not remove its maintenance cost: reject those as "relocation, not reduction".

Catalog with examples: [references/removal-candidates-catalog.md](references/removal-candidates-catalog.md).

## 4. Prove reachability: the consumer-evidence rule

**Never recommend deletion without evidence of consumers.** (Hyrum's Law: with enough users, every observable behavior is depended on by someone; absence of repository call sites is not proof of absence of dependents.)

1. **Search exact forms**: the symbol, property reads and writes, discriminant and event strings, wire and config keys, package and export names, both `.method(` and `method(` call forms, dynamic lookups (string-built names, reflection, registries, manifest-driven loading, generated code).
2. **Cover every place consumers live**: all packages, apps, scripts, shipped profiles and overlays, manifests and public exports, generated outputs, docs examples, and installed-package or downstream consumers. Classify examples and fixtures by their real entry point, not by directory name.
3. **Tests and declarations show a contract, not a consumer.** They do not prove a shipped producer or caller exists; they do show something expects it.
4. **Public and third-party extension paths can be intentional with zero in-repo call sites.** Decide whether the surface is internal or published; for published ones use the deprecation path, not deletion.
5. **Runtime evidence for dynamic cases**: logs, metrics or a temporary counter in the real environment over a representative window; a temporary rename or a planned brownout to flush hidden dependents.
6. **Record what you could not search** (private consumers, other repositories). Unknown consumers keep the candidate at "insufficient evidence".

Details and failure modes: [references/consumer-evidence-and-reachability.md](references/consumer-evidence-and-reachability.md).

## 5. The candidate record

One record per candidate, in this shape:

| Field | Content |
|---|---|
| Candidate | What would go (API, flag, state, key, test, path) |
| Owner and location | Current owner, files, how it is declared |
| Producers / consumers | Effective path with evidence and the search method used |
| Disappears / remains | Code, tests, docs, config, dependencies removed; what the replacement keeps |
| Capability and compatibility effect | What users or callers lose, if anything |
| Strongest reason to keep | The best argument against; if you cannot state one, search harder |
| Alternatives rejected | Smaller or different changes considered and why not |
| Classification | **Unreachable or unread** / **narrower behavior with an explicit loss** / **protected or insufficient evidence** |
| Verification and rollout | Tests, owning checks, and whether Parallel Change is needed |

Reject a candidate when it breaks a retained obligation, merely relocates complexity, or yields no meaningful reduction. A rejection of one proposal does not settle independent items in a mixed proposal; refresh evidence before re-proposing.

## 6. Preserve ownership and failure semantics

When collapsing copies, validators, freezes, callbacks or asynchronous machinery, name each value's origin, next owner and trust boundary. Same-process typed calls may borrow; parsers, config loaders, queues, durable files, workers and wire decoders own or validate their input, so do not delete validation at a trust boundary as "redundant". Collapse mechanisms only when they express the same fact: keep first-outcome arbitration, cancellation, disposal and rollback where required. Dropping interrupted-work records is a capability loss, not log cleanup.

## 7. Replace infrastructure only for a net reduction

Replacing home-grown machinery with a dependency counts only if you can name the implementation and tests it deletes, the added maintenance and transitive cost, and every residual behavior the glue still owns (limits, cancellation, platform packaging). A library that forces you to rebuild the same framing to enforce your size limit is not a simplification.

## 8. Hand off the removal safely

- Unreachable and unread: delete in small steps, run the suite, ship.
- Published or used by consumers you cannot edit: `parallel-change-expand-contract` (expand, migrate, contract), with an advisory or compulsory deprecation plan: [references/safe-removal-and-delegation.md](references/safe-removal-and-delegation.md).
- Entangled in a large file: `layered-refactor` first.
- Report: areas surveyed, supported candidates, meaningful rejections and deferrals, commands actually run, and what was **not** searched. Never call an unverified search exhaustive.

## Reject these

- Deleting because the symbol has no in-repo callers while it is exported, documented or reachable by name at runtime.
- "Unused" decided by one tool run that does not understand dynamic loading or generated code.
- Counting deletions as the goal; prefer a few well-supported candidates.
- Proposing removal of a deliberate, documented design choice without the override.
- Calling relocation a simplification; adding a gate to keep duplicates in sync.
- Implementing every proposal because the survey found them.

---

## Quick Decision Checklist

1. Scope, protected items and the expected output (proposal vs implementation) stated?
2. Discovery split into bounded domains, each returning evidence and rejected alternatives?
3. Every candidate has producers, consumers, the search method and what was not searched?
4. Dynamic and published surfaces considered (registries, wire strings, public exports, downstream)?
5. For each: what disappears, what remains, capability lost, strongest reason to keep?
6. Classified as unreachable / narrower with loss / protected-or-unknown?
7. Relocations and mixed proposals rejected or split?
8. Trust-boundary validation and failure semantics preserved?
9. Removal route chosen (direct delete vs Parallel Change vs deprecation)?
10. Report lists surveyed areas, rejections, commands run and gaps in coverage?

## Deep references

- [Removal candidates catalog](references/removal-candidates-catalog.md) — when you need the kinds of removable things, signals and example decisions
- [Consumer evidence and reachability](references/consumer-evidence-and-reachability.md) — when you must prove nobody uses something: search forms, dynamic cases, runtime evidence, Hyrum's Law
- [Safe removal and delegation](references/safe-removal-and-delegation.md) — when you brief domain agents, write the proposal, or choose between delete, Parallel Change and deprecation
- [Sources and claims not adopted](references/sources.md) — when you must check what was read and which claims are not facts
- [Trigger evals](references/trigger-evals.md) — when tuning the description or checking this skill against near-miss neighbors
