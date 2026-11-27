# Wrong Abstraction: Formation and Recovery

Sources: https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction · Last verified 2026-11-23

## How a wrong abstraction forms (Metz's sequence)

1. Programmer A spots duplication and extracts a named method/class.
2. Duplicated sites are replaced; the code now looks tidy.
3. Time passes; a new requirement almost fits the abstraction.
4. Programmer B, respecting the existing abstraction, adds a parameter and a conditional for the difference.
5. More requirements: more parameters, more conditionals, until the logic is hard to follow.
6. A later developer inherits something painful to change and easy to break.

Key point: the abstraction may have been **right when created**; it stops fitting when requirements diverge. The harm is in *keeping* it.

## Why teams keep it (sunk cost)

Existing code reads as proof it is necessary; it embodies effort already spent; and the more convoluted it is, the more important it appears. Metz calls this the sunk cost fallacy. Her guidance: do not get trapped by it; reconsidering past decisions is progress.

## Recovery recipe

1. **Re-introduce duplication.** Inline the abstraction body into every caller (mechanical; keep tests green after each caller).
2. **Specialize per caller.** Each caller knows which arguments it passed; use them to see which branches execute and which do not.
3. **Delete** the dead branches and unused parameters in each inlined copy.
4. **Remove** the old abstraction once no caller references it.
5. **Observe.** Metz reports callers often turn out quite different and further features become easier. Re-extract only a real shared subset, later.

## Mechanical example

```python
# Wrong abstraction: three callers, two flags.
def render(order, as_pdf=False, internal=False):
    rows = order.lines if not internal else order.lines + order.cost_lines
    out = to_pdf(rows) if as_pdf else to_html(rows)
    return out if internal else sanitize(out)

# Step 1-3: inline into each caller and keep only live paths.
def customer_email(order):   return sanitize(to_html(order.lines))
def customer_invoice(order): return sanitize(to_pdf(order.lines))
def finance_report(order):   return to_html(order.lines + order.cost_lines)
# Step 5 (later, if warranted): extract `lines_for(order, audience)`; never re-merge the renderers behind flags.
```

## Detection checklist (own synthesis from the article's signals)

- Callers pass different constants for the same parameter.
- Branches keyed on who is calling.
- A parameter used by exactly one caller.
- Tests that enumerate flag combinations.
- Developers describe the function with "it depends".

## Safety checklist before inlining

- Characterization tests exist for each caller (or add them first).
- Inline one caller per commit; run the tests each time.
- Use IDE "inline function" refactoring where available; avoid hand-editing logic while inlining.
- Keep public/exported signatures stable until the last caller migrates (`parallel-change-expand-contract` when the function crosses a module or API boundary).
- Do not rename and restructure in the same commit.

## Anti-patterns

- Adding "just one more" flag because the abstraction is already there.
- Treating the existing helper as authoritative because it has many callers.
- Replacing booleans with an enum or options bag — same coupling, better disguised.
- Re-extracting immediately after inlining, before the callers have diverged enough to show the real shape.

## How an agent should apply this

- When asked to extend a shared function with a mode flag, first count callers and variants; if flags already exist, propose inline-and-reduce instead.
- Do the inlining in small, test-green commits, one caller at a time.
- Delete dead branches aggressively after inlining; report what was removed.
- Postpone re-extraction; mention the candidate subset in the PR description instead of implementing it.
- Phrase it as progress ("fastest way forward is back"), not as a defect of the original author.
