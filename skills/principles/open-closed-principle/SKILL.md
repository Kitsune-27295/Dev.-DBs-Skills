---
name: open-closed-principle
description: "Deep dive on the Open-Closed Principle (OCP) and the Strategy pattern as its everyday mechanism: Meyer's original idea vs Martin's plugin-boundary reading, switch/if-chain to Strategy refactoring steps, strategy vs function parameter, selection at the composition point, plugin direction of dependencies, shotgun-surgery detection and when NOT to open a seam. Deep dive; for the overview see `pragmatic-solid-and-ssot`. Use when a new variant keeps forcing edits to tested core code, when replacing growing conditionals on a type/mode, or when deciding if a strategy or plugin is worth its cost."
---

# Open-Closed Principle & Strategy

One idea: **add behavior by adding code, not by editing code that already works.** The mechanism is a *seam*: stable policy talks to a small abstraction, and variants live behind it; the dependency arrows point from variants toward the core, never the reverse. Strategy is the workhorse; plugins are the same idea at deployable-unit scale. Sources and fetch outcomes: [references/sources.md](references/sources.md). Deep dive; the overview row for OCP lives in `pragmatic-solid-and-ssot`.

Boundaries with neighbors: *where the arrows point and who wires them* is `dependency-inversion-composition-root`; *which code belongs together by actor* is `single-responsibility-cohesion`; *one source for a fact* is `ssot-and-dry`; whole-system plugin shape is `microkernel-plugin-architecture` and ports/adapters is `hexagonal-architecture`; do not open seams speculatively: `kiss-yagni-aha`.

---

## 1. Two readings of the principle

| Reading | Statement | Practical meaning |
|---|---|---|
| **Meyer (1988)** | A module is *open* if it can be extended, *closed* if others can depend on its stable interface | Historic: compiled libraries, approved specs |
| **Martin (2014)** | You should be able to extend a system's behavior without modifying it | New feature = new code; no recompile/redeploy of old modules; jars/DLLs/gems as isolatable features |

Martin's evidence that this is not absurd: IDEs and editors accept plugins without being modified. Their design separates high-level policy from low-level detail and manages dependencies: plugin depends on core; the core does not know plugins exist. Treat "closed" as **closed against a *specific, expected* axis of change**, not against all change (inference: no module can be closed against every change). Details and diagnostics: [references/ocp-and-plugin-boundaries.md](references/ocp-and-plugin-boundaries.md).

## 2. Strategy: the standard seam

Strategy defines a family of algorithms, each in its own class behind one interface, and lets the **context** delegate to whichever one it holds. Participants: Context (holds a reference, talks only through the interface), Strategy (interface), Concrete Strategies, Client (chooses and may swap at run time). The Context never changes when a new strategy appears: that is OCP in code. Full mechanics, pseudocode and relations (State, Template Method, Decorator, Command): [references/strategy-pattern-mechanics.md](references/strategy-pattern-mechanics.md).

Rule: **the choice of strategy is made outside the context**, at a composition point (`dependency-inversion-composition-root`), by configuration or a registry; a `switch` inside the context just relocates the modification.

## 3. When to open a seam (decision table)

| Signal | Action |
|---|---|
| Third variant of the same algorithm arrives, each needing edits to one `if/switch` | Extract Strategy now |
| Same `switch(type)` repeated in several files | Replace with polymorphism/strategy per type (scattered knowledge) |
| Variants differ in *data* only (rates, labels) | Use a table/config, not classes |
| Variant is one line, language has first-class functions | Pass a function; skip the class |
| Only one implementation, no I/O, no second one planned | Do **not** add the seam (`kiss-yagni-aha`) |
| Variants must be chosen at run time by user/config | Strategy; keep selection in one factory/registry |
| Sequence is fixed but steps vary | Template Method or strategy-per-step; prefer composition |
| Variants have transitions between them | That is State, not Strategy |

## 4. Refactoring recipe: conditional to Strategy

1. **Pin behavior** with tests on the current `switch` (`tdd`, characterization tests).
2. **Pick the axis**: what varies (`shipping cost by carrier`). Name the interface by the *role*, not the first implementation (`ShippingRate`, not `FedexShipping`).
3. **Declare the interface** with the smallest signature the context needs; pass data as parameters so strategies stay stateless.
4. **Move each branch** into its own class/function behind the interface; tests stay green.
5. **Give the context a field** (or parameter) of that type and delete the conditional.
6. **Move selection out**: a registry/dict or factory built at the composition root.
7. **Add the new variant** as new code only; confirm no existing file changed.

```python
class Shipping(Protocol):
    def cost(self, order) -> Money: ...
class Flat:            # new variant = new class, nothing else edited
    def cost(self, order): return Money(5)
RATES = {"flat": Flat(), "weight": ByWeight()}   # composition root
def checkout(order, shipping: Shipping): return order.total + shipping.cost(order)
```

## 5. Seams that fail OCP

- **Leaky interface:** adding a variant forces a new method on the interface, editing every implementer. Redesign the abstraction; the seam guessed the wrong axis.
- **Type-check at call site:** `if isinstance(s, Special)` after the seam defeats it (Liskov issue, `pragmatic-solid-and-ssot`).
- **Strategy that needs the context's internals:** pass what it needs as arguments rather than the whole context.
- **Registry edited in a core file:** registration should live at the composition point or be discovered by convention.
- **Speculative seam:** one implementation forever. Cost: extra classes, clients must know which to choose (stated drawback of Strategy).

## 6. Detection heuristics

- Shotgun surgery: a feature request touches many existing modules.
- Parallel `switch`/`if-elif` on an enum or string in 3+ places.
- Git history: the same function edited for every new customer/provider/format.
- Boolean/mode parameters that select behavior.
- Core package importing concrete provider SDKs: arrow points the wrong way.

## Quick Decision Checklist

1. Is there a real, *recurring* axis of variation (2-3 instances)? If no, keep the plain code.
2. Is a function parameter enough? Prefer it over a class.
3. Does the interface let a new variant arrive without editing existing files?
4. Is selection outside the context, at one composition point?
5. Do dependencies point from variants to core?
6. After adding the variant, was any pre-existing, tested file edited? If yes, find why.

## Deep references

- [OCP: Meyer, Martin and plugin boundaries](references/ocp-and-plugin-boundaries.md) — read when judging if a seam is warranted or designing plugin direction.
- [Strategy pattern mechanics](references/strategy-pattern-mechanics.md) — read when implementing or reviewing a Strategy, or choosing between Strategy, State, Template Method, Decorator.
- [Conditional-to-strategy recipes and review checklist](references/ocp-refactoring-recipes.md) — read when refactoring a live `switch` or reviewing a diff for OCP.
