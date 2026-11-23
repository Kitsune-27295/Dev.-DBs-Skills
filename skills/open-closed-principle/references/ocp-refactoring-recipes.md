# Conditional-to-Strategy Recipes and OCP Review Checklist

Sources: https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html · https://refactoring.guru/design-patterns/strategy · Last verified 2026-11-23
Note: this file applies the two sources' ideas; the recipes, examples and thresholds are the author's own inference.

## Recipe A: single switch to strategy map

Before:
```python
def fee(order):
    if order.kind == "standard": return order.total * 0.02
    elif order.kind == "premium": return 0
    elif order.kind == "marketplace": return order.total * 0.05 + 1
```
After (new `kind` = new entry only):
```python
FEES = {"standard": lambda o: o.total*0.02,
        "premium": lambda o: 0,
        "marketplace": lambda o: o.total*0.05 + 1}
def fee(order):
    rule = FEES[order.kind]
    return rule(order)
```
Use a function map when each variant is a pure expression; promote to classes when a variant needs several methods or config.

## Recipe B: scattered switches to polymorphism

Symptom: `if kind == X` in pricing, rendering, export. Move all behaviors of one kind into one object with methods `price()`, `render()`, `export()`; each switch disappears. Warning: this makes *adding a new kind* easy but *adding a new operation* hard (touches every kind). Choose by which axis changes more (inference; known as the expression problem). If operations grow, keep data classes plus functions per operation.

## Recipe C: parallel change for live systems

When the conditional is in production code with many callers: introduce the strategy interface, route one branch through it, ship; migrate the next branch; delete the conditional last (`parallel-change-expand-contract`).

## Recipe D: plugin registration at the edge

```python
# plugins register themselves by convention, core never imports them
for mod in discover("plugins"):          # composition root
    REGISTRY[mod.NAME] = mod.build(config)
```
Fail startup on duplicate names or missing required plugins.

## OCP review checklist for a diff

| Question | Red flag |
|---|---|
| Did adding the feature edit an existing tested function? | Edit to a switch/if chain |
| Did `core` gain an import of a provider/vendor module? | Reversed dependency |
| Did an interface gain a method that only one implementer uses? | Leaky seam |
| Did a boolean or `mode` parameter appear? | Variant smuggled in as flag |
| Is there exactly one implementation and no I/O? | Speculative seam: remove |
| Is the variant list duplicated (enum, registry, docs)? | SSOT breach (`ssot-and-dry`) |

## Thresholds (heuristic, adjust to context)

- 1 variant: no seam. 2 variants: tolerate a conditional if stable. 3+ or a third arriving soon: extract.
- Conditional touched in 3+ recent commits for new variants: extract now.

## Testing the seam

- Contract test run against every implementation (same assertions, parametrized).
- Context tested with a trivial fake strategy.
- A "new variant" test: add a dummy strategy in the test file and assert the context needs no change.

## How an agent should apply this

- Count variants and look at git history before deciding to open a seam.
- Prefer a map of functions first; escalate to classes only when needed.
- Migrate incrementally; never rewrite a live switch in one step.
- Decide the axis (new variants vs new operations) explicitly.
- Add a contract test for each interface you introduce.
- Report which existing files stayed untouched as the evidence of OCP.
