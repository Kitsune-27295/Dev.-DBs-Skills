---
name: ssot-and-dry
description: "Deep dive on DRY as Single Source of Truth (SSOT): one authoritative representation per piece of knowledge, the five kinds of duplication (code, documentation, data, representational, interdeveloper), coincidental-similarity tests, derived-data and accessor recipes, generating artifacts from one schema, and where DRY must stop at Bounded Context boundaries. Deep dive; for the overview see `pragmatic-solid-and-ssot`. Use when hunting duplicated business rules, drifting docs/schemas/types, stored derived fields, or deciding whether two similar blocks or two contexts should share one definition."
---

# SSOT & DRY — Knowledge Has One Home

One idea: **every piece of knowledge has a single, unambiguous, authoritative representation** — and *knowledge* means a rule, a fact or an intent, not a run of identical characters. Duplicated syntax that encodes two different facts is fine; one fact written in two formats (code + comment, schema + class, API + client) is the real bug. Sources and fetch outcomes: [references/sources.md](references/sources.md). This is a deep dive; for the compact overview tables (and Rule of Three, KISS) see `pragmatic-solid-and-ssot`.

Boundaries with neighbors: extension via strategies/plugins is `open-closed-principle`; grouping code by who asks for changes is `single-responsibility-cohesion`; dependency direction and wiring is `dependency-inversion-composition-root`; "do not build it yet" is `kiss-yagni-aha`; type-level single definition of a rule is `value-objects-type-invariants`; DB-level enforcement is `schema-and-constraints`; contract-first APIs are `arc42-api-contracts-architecture`.

---

## 1. The acid test (use it before touching any code)

> When one facet of the system must change, do you edit several places, possibly in different formats?

If yes, there is knowledge duplication. If a change touches exactly one place, there is none, however similar two blocks look. Always phrase the finding as "fact X lives in A and B", never as "these lines look alike". If you cannot name the shared fact, you have found coincidence (section 3), not a DRY violation.

## 2. Five kinds of duplication, five different fixes

| Kind | Symptom | Fix (the mechanism) |
|---|---|---|
| **Code** | Same rule copied; copy-paste edits | Extract the function that *owns the rule*, then re-read the callers for the next layer (section 5). |
| **Documentation** | Comment restates what the code does | Delete the comment; improve names/layout so code is the single statement. Keep comments for *why*, never for *what*. |
| **Data** | Stored value derivable from other fields (`length` beside `start`/`end`) | Compute it behind an accessor. If caching is needed, hide the cache inside the module so only one class keeps it consistent. |
| **Representational** | Your code mirrors an external API, schema or error-code table | Generate, introspect or validate against one neutral spec (OpenAPI, DB schema introspection, shared contract). |
| **Interdeveloper** | Same feature written by different people, undetected | Process fix: make reuse easier than rewriting, central utility home, reviews that read other code. Code cannot detect it for you. |

Representational duplication is *inevitable* at system edges; the goal is to make it **mechanically checked or generated**, not eliminated.

## 3. Coincidence vs duplication (reject false DRY)

Two functions with identical bodies are duplicate **only if a change to the rule in one would always require the same change in the other**. `validate_age` and `validate_quantity` both check "integer > 0" today, but they answer to different rules; when age becomes `>= 18` a merged helper grows a flag. Protocol:

1. Name the rule each block enforces in one sentence of business language.
2. If the sentences differ, keep them separate and, if the shared mechanics matter, share only the *mechanism* (`validate_min_integer`) not the *policy* (`validate_age`).
3. If the sentences are identical, find the single owner and delete the rest.

## 4. Where DRY stops: Bounded Context

The same word (Customer, Product, Meter) has different attributes and invariants in different contexts; total unification of a large domain model is usually infeasible or not worth its cost. So: **apply SSOT inside one context; across contexts keep separate models and translate at the boundary** (DTO, mapper, anti-corruption layer). Never merge two contexts' classes to save lines. A shared *kernel* is a deliberate, small, jointly-owned exception, not a default. Mechanics, boundary signals and a worked example: [references/bounded-context-limits.md](references/bounded-context-limits.md). Module-level consequences: `modular-monolith-architecture`, `ddd-domain-heuristics-debiasing`.

## 5. Refactoring recipes

Do these one step at a time, tests green after each (`tdd`):

1. **Extract-and-recheck.** Pull out the repeated rule, then re-scan: copy-paste fixes often reveal a second duplication (field width repeated in every format string) and a third *implicit* one (separator length tied to column width). Decide per case whether the link is real intent or coincidence.
2. **Make derived data derived.** Replace stored `total` with `total()`; where the DB needs it, use a generated column/constraint, not application discipline.
3. **Uniform access.** Expose stored and computed attributes through the same notation, so storage can change without caller edits.
4. **Generate, don't mirror.** Replace hand-written DTO/doc/client with output from one spec; add a CI step that fails when generated output is stale.
5. **Table-driven validation over duplicated types.** When mirroring an external schema as fixed classes is costly, keep a map plus one declarative validator that checks required keys and formats.

Worked examples and before/after: [references/dry-refactoring-recipes.md](references/dry-refactoring-recipes.md).

## 6. Detection heuristics for agents

- grep for magic constants appearing in code **and** docs/tests/config (rate, limit, status list).
- Look for pairs: enum in code vs CHECK constraint vs OpenAPI enum vs UI dropdown.
- Look for fields named `*_total`, `*_count`, `is_*` stored next to their inputs.
- Look for comments that paraphrase the next 5 lines.
- Same regex/validation in client and server: server is the authority, share the spec or generate (`never-trust-the-client`).
- Divergent copies of "the same" helper in different packages: diff them; differences reveal whether the rule really was one.

## 7. Anti-patterns to reject

| Anti-pattern | Why it fails |
|---|---|
| Merging lookalikes into one helper with `mode`/`isX` flags | Couples unrelated reasons to change; this is the wrong abstraction (see `pragmatic-solid-and-ssot`, `kiss-yagni-aha`). |
| One enterprise-wide `Customer`/`User` class | Violates context boundaries; every team's change breaks others. |
| "Single source" that is a God `constants` or `utils` module | Dumping ground with no owner; SSOT needs a *meaningful owner*. |
| Generated code hand-edited | Re-creates duplication invisibly. |
| Comments as the spec | Two sources, one of them unchecked. |

## Quick Decision Checklist

1. Can I state the shared fact in one sentence? If not, it is coincidence: leave it.
2. Where is the single owner (module/schema/spec)? Name it before extracting.
3. Does the duplication cross a Bounded Context? Then translate, do not share the model.
4. Is the duplicated item derived from other data? Compute it.
5. Is the mirror at a system edge? Generate or validate it mechanically.
6. After the fix, does a change to the fact touch exactly one place?

## Deep references

- [Rule registry format](references/rule-registry-format.md) — read when building or maintaining a rule registry: row fields, agreement and confidence scales, maintenance rule. (added 2026-11-27)
- [DRY as knowledge: the five duplication kinds](references/dry-as-knowledge.md) — read for the Pragmatic Programmer's definitions, acid test and worked examples.
- [DRY refactoring recipes and detection](references/dry-refactoring-recipes.md) — read when executing a deduplication step by step.
- [Bounded Context limits on DRY](references/bounded-context-limits.md) — read before sharing a model or type across modules, services or teams.
