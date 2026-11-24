# Code Smells in Agent-Generated Code

Sources: https://refactoring.guru/refactoring/smells · https://refactoring.guru/refactoring/catalog · https://grugbrain.dev/ · https://github.com/joshuadavidthomas/agent-skills/blob/main/grug-brained-dev/SKILL.md · Last verified 2026-11-24

Refactoring.Guru content is "all rights reserved" (footer, 2014-2026); this file only uses its taxonomy names and its own paraphrases. The smells page gives group-level summaries; per-smell wording below is my own. Which smells LLM output shows most is my inference from the grug agent skill's observations and general experience, not a measured statistic.

## The five groups (Refactoring.Guru)

| Group | Smells in it | Reads as |
|---|---|---|
| Bloaters | Long Method, Large Class, Primitive Obsession, Long Parameter List, Data Clumps | things grew too big |
| Object-Orientation Abusers | Alternative Classes with Different Interfaces, Refused Bequest, Switch Statements, Temporary Field | OO used badly |
| Change Preventers | Divergent Change, Parallel Inheritance Hierarchies, Shotgun Surgery | one change touches many places |
| Dispensables | Comments, Duplicate Code, Data Class, Dead Code, Lazy Class, Speculative Generality | stuff that can go |
| Couplers | Feature Envy, Inappropriate Intimacy, Incomplete Library Class, Message Chains, Middle Man | too much coupling or delegation |

The catalog's technique groups (Composing Methods, Moving Features between Objects, Organizing Data, Simplifying Conditional Expressions, Simplifying Method Calls, Dealing with Generalization) are the fix vocabulary; I name the technique per smell.

## The 12 smells to check first in LLM output

LLMs lean toward Dispensables and Couplers by over-building, and Bloaters by over-explaining. Order is by my estimated frequency.

| # | Smell (group) | Detection hint | Minimal fix (technique) |
|---|---|---|---|
| 1 | Speculative Generality (Dispensables) | interface/base class with one implementer; unused parameter, hook or option | delete it; Collapse Hierarchy, Remove Parameter |
| 2 | Lazy Class / pass-through layer (Dispensables) | class or module whose methods each call one other thing | Inline Class |
| 3 | Middle Man (Couplers) | service that only delegates to a repository/client | Remove Middle Man: call the target directly |
| 4 | Duplicate Code, both kinds | copy-pasted blocks in one change; or the opposite, a shared helper whose parameters keep growing | Extract Method if same fact; keep duplicate if coincidence (`ssot-and-dry`) |
| 5 | Dead Code (Dispensables) | unused imports, helpers, branches, commented-out code, leftover scaffolding | delete (DC-01 below) |
| 6 | Comments as deodorant (Dispensables) | comment restating the next line or explaining a confusing name | Rename, Extract Variable, then drop the comment (rules: CM-01 to CM-03) |
| 7 | Long Method (Bloaters) | one function mixing parse, validate, act, format, log | Extract Method along real steps, not per line |
| 8 | Long Parameter List / flag arguments (Bloaters) | 5+ args, boolean toggles that select behavior | Replace Parameter with Explicit Methods (FN-04); Introduce Parameter Object when args travel together (FN-05) |
| 9 | Primitive Obsession (Bloaters) | raw strings for ids, money, status with scattered validation | Replace Data Value with Object only if an invariant is repeated |
| 10 | Message Chains and nesting pyramids (Couplers, plus conditional simplification) | `a.b().c().d()`; four-deep ifs | Hide Delegate sparingly; Replace Nested Conditional with Guard Clauses |
| 11 | Switch Statements (OO Abusers) | the same type switch repeated in several places | Replace Conditional with Polymorphism only when repeated; one switch stays |
| 12 | Shotgun Surgery (Change Preventers) | adding one field requires edits in many layers/files created by the agent itself | Move Method/Field to colocate; remove needless layers |

Also watch: Data Class (DTOs duplicating domain types without a boundary reason; see `dto-mapper-anti-corruption-layer`) and Feature Envy (a method mostly poking another object's fields; Move Method).

## Dead code rule (DC-01, owned here)

Delete what nothing uses: unused imports, helpers, branches, parameters, members and scaffolding you created. Version control keeps the history. Before deleting something you did not write, find why it exists (SIM-05 in [simplicity-and-complexity-bias-of-llms.md](simplicity-and-complexity-bias-of-llms.md)). Commented-out code is a comment-rule case (CM-03).

Worked examples live with the rules, not here: a speculative interface plus pass-through (smells 1-3) is the fake-seam example in the simplicity file, section 4; a flag argument (smell 8) is the guard-clause example in the heuristics file.

## Detection workflow for an agent

1. Re-read the diff, not the whole repo. Count new files, classes, interfaces, parameters.
2. For each new construct ask: how many callers, how many implementations, what real detail does it hide?
3. Search the diff for unused names (imports, helpers, branches) and for comments that paraphrase code.
4. Check each function for more than one level of abstraction and for boolean arguments.
5. Apply the smallest technique from the table, re-run tests, stop.

Smells are prompts to look, not verdicts: a long method with a linear flow can beat ten tiny functions (see [rule-conflicts-and-resolutions.md](rule-conflicts-and-resolutions.md)).

## How an agent should apply this

- Run this table against your own diff before handing off; delete what you cannot justify.
- Prefer deletion and inlining over adding a new abstraction to fix a smell.
- Apply Extract and Replace-with-Object only when two or more real uses or an invariant exist.
- A smell in code you did not touch is reported, not fixed (SC-02 in [rule-registry.md](rule-registry.md)).
- For review of someone else's change use `code-review`; for structural moves across modules use `layered-refactor`.
