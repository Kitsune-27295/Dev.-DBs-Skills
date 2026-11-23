# OCP: Meyer, Martin and Plugin Boundaries

Sources: https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html · Last verified 2026-11-23

## What the article argues

Martin traces OCP to Bertrand Meyer's 1988 *Object Oriented Software Construction*. Meyer wanted modules both **open** (extendable: new fields, new functions) and **closed** (usable by others through a stable, well-defined interface). Martin says Meyer's phrasing reflects older practices (modules compiled into libraries, specifications approved by management) that he finds dated, but keeps the core claim: you should be able to extend a system's behaviour without modifying it.

Implication drawn: if behaviour is extendable without edits, new features are new code only; old code is not recompiled or redeployed. So deployable units (jars, DLLs, gems) should be **isolatable features**.

He anticipates the objection that this is absurd, since most teams add features by changing code throughout the codebase (the "shotgun surgery" smell named by Fowler). His counter-evidence: IDEs and editors extend through plugins without being modified or redeployed.

## How plugin systems manage it

- High-level policy is separated from low-level detail.
- Dependencies are managed: plugin code depends on the core; **nothing in the core depends on a plugin**. The core does not know its plugins exist; plugins know the core.
- A whole system can be built this way: databases, GUIs, web services and frameworks are plugins; behaviour is driven by plugin configuration. Business rules at the centre tie the system to no particular feature set, interface, database or framework.
- Martin concludes critics are mistaken and predicts plugin architectures will be the most important aspect of future software.

## Reading it correctly (partly inference)

| Question | Answer |
|---|---|
| Closed against what? | Against the *anticipated* axis of change (new provider, format, rule), not against everything. Any seam is a bet on an axis. |
| Granularity | Function seam, class seam, module seam and process seam are the same idea at different scale. |
| Where is the "open" part? | A registry, configuration or composition point outside the core. |
| Is inheritance required? | No. The source ties OCP to dependency management; strategies, function values and structural interfaces all work. |

## Mechanics: making the arrow point inward

```
core/            # policy; defines the port it needs
  payment.py     class PaymentGateway(Protocol): def charge(...)
plugins/
  stripe.py      imports core.payment; implements it
main.py          # composition: registry["stripe"] = StripeGateway()
```
`core` imports nothing from `plugins`. Adding `adyen.py` edits `plugins/` and `main.py` only. If `core` must be edited, the seam is in the wrong place or the axis was misjudged.

## Failure modes

- **Anticipating every change:** speculative factories for a single implementation; high cost, no benefit.
- **Closed against the wrong axis:** the first real change cuts across the abstraction, and the team edits the core anyway and also pays for the dead seam.
- **Plugins that reach into core internals:** the core is then not closed in practice.
- **Core importing a plugin "just for the default":** reverses the arrow; move the default to the composition point.
- **Plugin explosion:** dozens of tiny plugins with unclear contracts; keep the contract small and versioned.

## Use when / avoid when

Use when changes arrive repeatedly on a known axis (providers, formats, tariffs, rules) or when teams must ship independently. Avoid when there is one implementation, the axis is unknown, or change is rare; wait for the second or third case.

## How an agent should apply this

- Name the axis of change before adding any abstraction; if you cannot, do not add it.
- Verify the dependency direction with an import check: core must not import variants.
- Put registration and defaults at the composition point (`dependency-inversion-composition-root`).
- Measure success by "new variant touched zero existing files".
- For whole-system plugin shapes link to `microkernel-plugin-architecture` and `hexagonal-architecture`; do not re-derive them here.
