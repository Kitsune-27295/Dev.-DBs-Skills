---
name: kiss-yagni-aha
description: "Decide, per edit, whether to build or abstract now: KISS ordering of constructs, small-scale YAGNI for parameters, fields, hooks and interfaces added for later, duplication triage with the Rule of Three as a default and not a law, Wrong Abstraction (Sandi Metz) recovery by inlining, and AHA (Kent C. Dodds) differences-become-arguments, plus smells such as flag parameters and speculative generality. Overview lives in `pragmatic-solid-and-ssot`, the YAGNI cost model in `yagni-evolutionary-architecture`, one-fact-one-home in `ssot-and-dry`. Use when about to extract a helper or base class, add a parameter or extension point for later, extend a shared function with another boolean flag, or choose between duplicating and unifying code."
---

# KISS, YAGNI & AHA — Code-Level Decision Procedure

One idea: every line of shared code is a bet that its callers will keep changing for the **same reason**; make that bet only when you have evidence (real call sites, real differences between them), and undo it cheaply when it loses. Sources and fetch status: [references/sources.md](references/sources.md).

Boundaries (do not redo here): the four YAGNI costs, Design Stamina and Sacrificial Architecture live in `yagni-evolutionary-architecture`; the one-page overview of DRY/SSOT, SOLID and Rule of Three lives in `pragmatic-solid-and-ssot`; DRY-as-single-source-of-truth mechanics belong to `ssot-and-dry`. This skill is the **per-edit procedure** and the **refactoring recipes**.

---

## 1. The three questions before you write anything "for later"

Ask in this order; stop at the first "no / not yet".

| # | Question | If the answer is... |
|---|---|---|
| 1 | Is a caller using this capability **today** (merged code, ticket in this iteration)? | No -> do not write it (small-scale YAGNI; see `references/small-scale-yagni-procedure.md`) |
| 2 | Would adding it **later** cost much more than now (imagine the refactoring concretely)? | No -> wait; the "cheaper now" belief is usually wrong once delay and carry costs are counted |
| 3 | Does the speculative version add **complexity** to today's code (extra parameter, indirection, config, generic type)? | No -> a cheap preparation (lookup table for messages, named constant) is fine; YAGNI only bites when complexity grows |

YAGNI targets **capabilities**, never malleability: tests, refactoring, small functions, clean names and CI are what make "later" cheap. Never use YAGNI to skip them.

## 2. KISS as a concrete ordering

Own ordering (synthesis, not from a cited source): pick the first construct that works, in this order. Move down only with a stated reason.

1. Inline expression / local variable.
2. Plain function with explicit parameters, returning a value.
3. Plain data (record / dataclass / object literal) + functions over it.
4. Composition of two or three small functions.
5. A class with state, only if state genuinely must live with behavior.
6. A pattern (strategy, factory, visitor, plugin registry) — only after two real variants exist.
7. Inheritance / metaprogramming / framework hooks — last resort; justify in the PR.

Rejection list: a factory with one product, a strategy with one strategy, an `AbstractFooBase` with one subclass, a config option nobody sets, a generic `<T>` instantiated at one type, an event bus with one subscriber.

## 3. Duplication triage (decide per pair of similar blocks)

| Observation | Verdict | Action |
|---|---|---|
| Two copies, same actor, same reason to change | Tolerate | Copy, add a `// see also` pointer if in different files; do not abstract yet |
| Three copies, same reason to change, the differences are **values** | Extract | Differences become arguments (see `references/aha-differences-become-arguments.md`) |
| Three copies, differences are **behaviors/branches** | Wait or extract the stable core only | Extract only the identical middle; leave the varying parts at the call site or pass a function |
| Copies look alike but belong to different actors / contexts | Coincidence | Keep separate (see `ssot-and-dry` for the knowledge-vs-syntax test) |
| The same copy-paste bug was fixed in 3+ places | Real pain | Extract now, even before the "third" copy: the rule is a heuristic, pain is evidence |
| Existing abstraction needs a new boolean/enum parameter that only some callers use | Wrong abstraction signal | Stop; go to section 5 |

The rule of three is a **default waiting period, not a law**: it exists so that you see enough variation to pick the right seam. If you already understand the variation (e.g. a protocol spec, a math formula), extract at two. If you cannot say what the third caller will vary, wait even at five.

## 4. Detection heuristics (code smells that say "this abstraction is wrong / premature")

- **Flag parameters:** `fn(x, { skipValidation, isAdmin, legacy })` where callers pass different constants. Each flag is a hidden second function.
- **Parameter that only one caller passes**, or parameters that are always passed together.
- **Conditional ladders keyed on caller identity** (`if (caller === 'invoice') ...`).
- **Speculative generality:** hooks, abstract methods, config keys, type parameters with no second user.
- **Dead branches:** code paths that no caller can reach any more because the abstraction was never trimmed.
- **Name drift:** the helper's name no longer describes what it does for all callers (`processData`, `handleItem`, `Manager`, `Util`).
- **Fear:** people avoid touching it, or tests must exercise every flag combination.
- **Pseudo-inheritance:** passing `this`/self into a function that bolts members onto it.

Three or more of these on one helper means recover (section 5); one smell means watch and do not extend it further.

## 5. Recovery recipe: the fastest way forward is back

When a shared abstraction no longer fits a new requirement, do **not** add a flag. Instead:

1. **Inline** the abstraction into every caller (mechanical, tests stay green).
2. In each caller, use the arguments it passed to see which branches are live; **delete the dead ones** and the unused parameters.
3. Let each caller's code settle for a while; the callers usually turn out to differ substantially.
4. **Re-extract** only a genuinely common, clean subset — possibly smaller, differently named, with different seams.
5. Do not defend the old code because of effort spent (sunk cost); more convolution is evidence of a wrong abstraction, not of importance.

Full step-by-step with before/after and a safety checklist: [references/wrong-abstraction-recovery.md](references/wrong-abstraction-recovery.md).

## 6. AHA in one table

| Mode | Behavior | Failure if overdone |
|---|---|---|
| Dogmatic DRY | Extract at the first repetition | Wrong abstraction, flag soup |
| Dogmatic WET | Never extract after the third | Same bug fixed in eight places |
| **AHA** | **Optimize for ease of change; extract once the differences are understood** | None systematic; needs judgment |

Practical AHA loop: copy -> note how the copies differ -> wait for another real use -> if the differences are values, extract with arguments; if they are behaviors, extract less. Abstract when it feels right, not on a fixed count.

## 7. Review comments to leave (copy-ready)

- "Which caller needs this parameter today?" (YAGNI)
- "Could this be a plain function instead of a class/strategy?" (KISS)
- "Three callers share this flag-less core; the fourth wants a switch. Inline for #4 rather than adding the flag." (Wrong abstraction)
- "These two blocks change for different actors; I would keep them separate." (Coincidental similarity)
- "Please delete the extension point until a second implementation exists."

## Quick Decision Checklist

1. Is there a real caller for this capability today? If not, delete it.
2. Is the simplest construct (section 2) enough? Use it.
3. Count real copies and their reason to change; extract only when differences are understood.
4. Are callers passing mode flags? Inline and reduce instead of adding another flag.
5. Did the same fix land in 3+ places recently? Pain justifies extraction now.
6. Is the "fix" a new abstraction on top of a failing one? Go back (inline) first.

## Deep references

- [Small-scale YAGNI procedure](references/small-scale-yagni-procedure.md) — when you are about to add a parameter, field, hook, or generic "just in case"; Fowler's presumptive-feature reasoning applied per edit.
- [Wrong abstraction recovery](references/wrong-abstraction-recovery.md) — when a shared helper has grown flags/conditionals; Metz's sequence, sunk cost, and an executable inline-and-reduce recipe.
- [AHA: differences become arguments](references/aha-differences-become-arguments.md) — when deciding whether and how to extract from copies; Dodds' guidance plus Rule of Three status.
- [Trigger evals](references/trigger-evals.md) — read when tuning this skill's description or checking that a request belongs here.
- [Sources](references/sources.md) — fetch status per URL (including the 404 for the Rule of Three page).
