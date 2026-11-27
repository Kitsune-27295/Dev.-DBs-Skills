# Small-Scale YAGNI Procedure

Sources: https://martinfowler.com/bliki/Yagni.html · Last verified 2026-11-23

## What Fowler's article says (relevant to single edits)

- A **presumptive feature** is code supporting a capability nobody can use yet. The article names four costs (build, delay, carry, repair) — see `yagni-evolutionary-architecture` for the cost model; this file only uses them as a checklist per edit.
- Predictions are often wrong; the article cites Kohavi et al.: only about one in three features moved its target metric, so a speculative feature is more likely unneeded than needed.
- The argument applies at **small scale**: abstractions, parameters, fields, methods. Fowler himself does not extend a regex highlighter beyond what he needs and does not add fields or methods before use. Small decisions escape planning but add up to less complexity and faster urgent work.
- Two practical techniques: (1) **imagine the later refactoring** and see that it is often cheap; (2) **cheap preparations** with no added complexity (his example: message lookup tables instead of inline strings, easing later translation).
- Yagni is about capabilities, not malleability. It is only safe with refactoring, self-testing code and continuous delivery. It applies only when the speculative work adds complexity.
- Failures of yagni exist but are memorable (availability bias in the author's words) and relatively rare.

## Per-edit procedure

1. **Name the consumer.** Write one sentence: "Caller X needs Y in this change." If you cannot name X, remove Y.
2. **Cost-check each speculative element** (own inference, keyed to the four costs):
   - Build: minutes spent now on something unused.
   - Delay: what current work did I postpone?
   - Carry: does every reader of this function now parse an extra parameter/branch?
   - Repair: if the guess is slightly wrong, which callers must be reworked?
3. **Imagine the later change** concretely: "to add this I would add a parameter and one branch, ~15 minutes with tests." If that sentence is true, wait.
4. **If a preparation is free** (no new branches, params or indirection), do it: named constants, one place for strings, keeping a function pure.
5. **Record intent, not code**: a TODO with a ticket or a short note in the PR ("piracy pricing deferred") beats dead extension points.

## Typical presumptive items and what to do

| Speculative item | Verdict | Cheaper alternative |
|---|---|---|
| Parameter "for future callers" | Reject | Add when the second caller exists |
| Optional field on a model "we'll need it" | Reject | Add with the migration that needs it |
| Interface with one implementation | Reject unless an I/O seam | Concrete type; extract later (IDE refactoring) |
| Config flag with one value | Reject | Constant |
| Plugin registry for one plugin | Reject | Direct call |
| Generic `<T>` used with one type | Reject | Concrete type |
| Error-message strings inline | Prefer a lookup | Free preparation |
| Logging/metrics at I/O boundaries | Usually keep | Operational need is present, not speculative |
| Tests, small functions, clear names | Always keep | Enable cheap change |

## Worked example

```ts
// Before (speculative): nobody passes `currency` or `rounding` yet.
function priceWithTax(net: number, rate: number, currency = "EUR", rounding: "half-up" | "bankers" = "half-up") { ... }

// After: today's need only.
function priceWithTax(net: number, rate: number): number {
  return Math.round(net * (1 + rate) * 100) / 100;
}
// When a second currency arrives, change the signature in one commit; the compiler lists every caller.
```

The compiler-assisted change is what makes "later" cheap in typed code; in untyped code compensate with tests.

## Failure modes of YAGNI itself

- Using it to skip tests or refactoring (removes the enabling practices; the principle then backfires).
- Using it against operational necessities (observability, security checks) that are present requirements.
- Using it to refuse structure that costs nothing (naming, separating pure logic from I/O).

## How an agent should apply this

- Before adding a parameter, field, hook or interface, state its current consumer; if none, omit it.
- Prefer deleting speculative code in review over discussing it; cite "no caller today".
- Do not remove genuinely free preparations (constants, lookup tables) in the name of YAGNI.
- Never trade away tests/refactoring for YAGNI; say so when a reviewer conflates them.
- Leave a ticket/TODO with the trigger condition ("when a second currency is required") instead of building ahead.
