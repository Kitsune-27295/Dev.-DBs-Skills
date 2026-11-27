# Trigger Evals

Last verified 2026-11-27. Prompts checked by reading against the description.

## Should trigger (kiss-yagni-aha)

1. "These three functions look alike; should I extract a shared helper now?"
2. "Add a `legacy` boolean to `formatInvoice()` so the new caller works."
3. "Should I add a config option and an interface in case we need a second provider later?"

## Near misses (belong elsewhere)

1. "Is the Customer model duplicated across our billing and shipping services?" -> `ssot-and-dry`
2. "Should we build a multi-region layer before launch? Weigh build, delay, carry, repair costs." -> `yagni-evolutionary-architecture`
3. "Where should `new PostgresRepo()` be called?" -> `dependency-inversion-composition-root`
