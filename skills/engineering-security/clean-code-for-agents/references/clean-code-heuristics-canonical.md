# Clean Code Heuristics (Canonical, Deduplicated)

Sources: https://gist.github.com/wojteklu/73c6914cc446146b8b533c0988cf8d29 (summary of Robert C. Martin's book; no license visible) · https://github.com/victorcorcos/clean-code (MIT) · https://github.com/tahsinature/coding-principles (no license; default branch `master`, thin README plus per-principle pages) · Last verified 2026-11-24

Abbreviations: G = wojteklu gist, V = victorcorcos repo, T = tahsinature repo. All three are secondary summaries of the same book, so agreement among them is shared lineage, not independent evidence (see `ssot-and-dry`: one fact, one owner). Each rule below is stated once with its source tags; the owner of the full discussion is named when a neighbor skill has it.

## Naming
- Descriptive, unambiguous, intention-revealing (G, V). Pronounceable and searchable (G, V).
- Meaningful distinctions; no `data1`/`data2` pairs (G).
- Named constants instead of magic numbers (G).
- No type or scope prefixes/encodings (G).
- Names should follow language, domain and team conventions (V).
- Disagreement: G asks for pronounceable names, V adds team vocabulary; compatible. Existing public names are not renamed in a drive-by change (scope: SC-02).

## Functions
- Small, doing one thing, with a descriptive name (G, V via SRP; T states SRP at class level).
- Few arguments (G); no flag/boolean arguments, split into two functions (G, V). V's "fix" replaces the boolean by a string switch, which only hides the flag: prefer two functions or an enum with distinct behavior.
- No hidden side effects (G). Early returns instead of nested ifs (V "Hadouken"). Positive conditionals (G, V). Extract complicated conditions into a named predicate (G, V).
- "Small" is contested (CF-02); numeric limits live in [linux-kernel-style-functions-and-comments.md](linux-kernel-style-functions-and-comments.md) and [power-of-10-and-tigerstyle-transferable-rules.md](power-of-10-and-tigerstyle-transferable-rules.md).

```ts
// Before: nested, negated, flagged
function fee(u: User, rush: boolean) { if (!u.blocked) { if (rush) { return 20 } else { return 5 } } else { return 0 } }
// After: guard clause, two named paths
const rushFee = 20, normalFee = 5
function normalOrderFee(u: User) { return u.blocked ? 0 : normalFee }
function rushOrderFee(u: User) { return u.blocked ? 0 : rushFee }
```

## Vertical structure and formatting
- Read top to bottom: callers above callees; related and dependent functions close (G, V).
- Declare variables near use; blank lines separate concepts, density groups related lines (G).
- Keep lines short; consistent indentation; no horizontal alignment (G). In practice defer to the project formatter.

## Error handling and boundaries
- G and V say little on errors beyond "find the root cause" (G) and encapsulating boundary conditions in one place (G). Detailed policy lives in `error-handling-problem-details` and `defensive-domain-modeling`; do not add rules here.
- Keep configurable data at high levels and avoid over-configurability (G); dependency injection (G) belongs to `dependency-inversion-composition-root`.
- Law of Demeter: talk to direct collaborators, avoid long chains (G).

## Dead code and deleting
- V adds "deleting beats creating", framing removal as a first-class improvement. The rule itself (DC-01) is owned by [code-smells-for-agent-generated-code.md](code-smells-for-agent-generated-code.md).
- Source quirk: T's YAGNI example drops unused methods; V's own YAGNI example merely stops initializing unused fields and still keeps the accessors (inconsistent, do not copy).

## Comments
Owned entirely by [comments-why-not-what.md](comments-why-not-what.md) (rules CM-01 to CM-06). G and V both say: explain in code first; V prefers extracting a well-named function.

## Objects, data, tests
- Hide internals; avoid half-object half-data hybrids; small objects with few fields (G). Prefer many explicit functions to passing behavior selectors (G).
- Tests (G): one assert per test is a heuristic; the stronger criteria are readable, fast, independent, repeatable. Test strategy lives in `tdd` and `testing-pyramid-and-shapes`.

## Smells named by G and V
G lists six (rigidity, fragility, immobility, needless complexity, needless repetition, opacity); V keeps four (rigidity, complexity, fragility, immobility). Needless complexity is the one LLM output most often triggers; see [code-smells-for-agent-generated-code.md](code-smells-for-agent-generated-code.md).

## Contestable rules (do not apply blindly)
- "Prefer polymorphism to if/else" and "prefer value objects to primitives" (G): decided in CF-03 of [rule-conflicts-and-resolutions.md](rule-conflicts-and-resolutions.md).
- V's SRP example splits one private method per line of a short report routine (CF-02). V's greeting DRY example merges shape, not knowledge (CF-01).
- T's KISS example (iterative Fibonacci) and V's KISS example (branching replaced by `case`) show simplification measured by reader effort, not line count.

## How an agent should apply this
- Use these as a self-review checklist after writing code, not as a reason to restructure working code.
- Fix names, flags, nesting and dead code first: cheap, low-risk, high-readability.
- When a rule would add a function, class or layer, check [rule-conflicts-and-resolutions.md](rule-conflicts-and-resolutions.md) first.
- Rule ids for everything above are in [rule-registry.md](rule-registry.md).
- Project conventions and scope limits come first (CN-01, SC-02 in [rule-registry.md](rule-registry.md)).
