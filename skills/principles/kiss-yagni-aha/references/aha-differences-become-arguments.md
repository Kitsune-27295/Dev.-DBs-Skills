# AHA, DRY/WET and the Rule of Three

Sources: https://kentcdodds.com/blog/aha-programming · https://martinfowler.com/bliki/RuleOfThree.html (404 — see note) · Last verified 2026-11-27

## Vocabulary as used by the article

- **DRY**: Dodds cites the single-unambiguous-authoritative-representation phrasing and follows it less dogmatically than the wording suggests.
- **WET** ("Write Everything Twice", Conlin Durbin): repeat once or twice, never a third time. Dodds calls it equally dogmatic.
- **AHA** ("Avoid Hasty Abstractions", Cher Scarlett): built on Sandi Metz's advice to prefer duplication over the wrong abstraction. Optimize for **change** first.

## Rule of Three — status

The Fowler page `RuleOfThree.html` returned 404 again on 2026-11-27, so nothing was read from it. As **background knowledge, not read from source**: the heuristic says tolerate one repetition and consider abstracting at the third occurrence, because three data points reveal what varies. Treat it as a default waiting period, not a law (own inference, consistent with Dodds' "abstract when it feels right").

## The three experiences in the article

1. **Too much duplication**: heavy copy-paste in an inherited codebase; one bug had to be fixed in eight places.
2. **Bad abstraction**: AngularJS controllers handed `this` to a function that attached members (pseudo-inheritance). The author found it confusing, was afraid to change it, and wished the code had been duplicated instead.
3. **Late, good abstraction**: running a copy-paste detector (jsinspect) over a client codebase made the right abstractions obvious from outside.

The article also warns that an early abstraction tends to be bent to fit later use cases. Lesson: the count of call sites is not the criterion; **quality of understanding** is, and no fixed count is given.

## Differences become arguments (procedure)

1. Place the copies side by side (diff them).
2. Mark every difference and classify it:
   - **Value** (literal, name, threshold) -> candidate parameter.
   - **Data shape** (field mapping) -> candidate parameter object or mapping table.
   - **Behavior** (different steps/branches) -> do not hide behind a flag; pass a function or leave at the call site.
3. If more than about two behavioral differences remain, the copies are not the same concept; keep them separate.
4. Extract the common core with the value differences as arguments; name it for the **concept**, not the first caller.
5. Keep call sites explicit (no default parameters that silently pick one caller's behavior).

```ts
// Three copies differ only in endpoint, field list and page size -> values.
const fetchAll = (endpoint: string, fields: string[], pageSize = 100) => paginate(endpoint, { fields, pageSize });
// A copy that also transforms the result differently stays in its caller:
const users = (await fetchAll("/users", ["id", "email"])).map(toUserView);
```

## Cost model of getting it wrong (article)

- A wrong abstraction makes people afraid to touch it (experience 2); the Metz article describes each new use case adding a conditional.
- Over-early design work can be wasted when features change (own inference).
- The opposite error (never abstracting) has a real cost too: parallel edits and drift.

## Decision table

| Evidence | Action |
|---|---|
| 1 copy | Write it once, plainly |
| 2 copies, differences unclear | Copy, wait |
| 2 copies, spec-defined identical (protocol, formula) | Extract |
| 3+ copies, value-only differences | Extract with arguments |
| 3+ copies, behavioral differences | Extract the common core only, or stay duplicated |
| Fix applied in several places repeatedly | Extract now (pain beats count) |
| Existing abstraction + new divergent need | Recover; see `wrong-abstraction-recovery.md` |

## How an agent should apply this

- Diff the candidate copies and classify each difference before writing the helper.
- Extract at two only with a spec-level reason; otherwise wait for a third real use.
- Refuse flag/mode parameters that select behavior; prefer passing a function or keeping call-site code.
- When asked to cite the Rule of Three, say the Fowler page could not be read (404) and describe it as background knowledge.
- Name the extracted function after the concept it captures, not after its first caller.
