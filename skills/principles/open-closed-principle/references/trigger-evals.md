# Trigger Evals: open-closed-principle

Last verified 2026-11-27 (paper test against the description; not run on a host).

## Should trigger

1. "Every new shipping carrier means editing the same if/elif in checkout. How do I stop that?" -> `open-closed-principle`
2. "Should this be a Strategy class or just a function parameter?" -> `open-closed-principle`
3. "Our core imports every vendor SDK; how do I let vendors plug in without core edits?" -> `open-closed-principle` (then `microkernel-plugin-architecture` for the whole-system shape)

## Near misses

1. "The same tax rate is in code, docs and the schema." -> `ssot-and-dry`
2. "Where should I build the object graph and inject dependencies?" -> `dependency-inversion-composition-root`
3. "This class is edited by finance and ops for unrelated reasons." -> `single-responsibility-cohesion`
