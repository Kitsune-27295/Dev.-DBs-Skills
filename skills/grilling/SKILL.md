---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, resolve design decisions before building, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent with a **fresh context window** to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. When architectural trade-offs, domain boundaries, or data invariants arise in the design tree, ground your recommendations in relevant pack skills (such as `architecture-decision-trees-tradeoffs`, `ddd-domain-heuristics-debiasing`, or `schema-and-constraints`). The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.

Variants: with docs (keep a glossary and ADRs while grilling; see `domain-modeling`, `adr-architecture`): [references/docs-variant.md](references/docs-variant.md). Before asking anything about identity or meaning, run the search chain first and ask with a hypothesis: [references/resolve-before-asking.md](references/resolve-before-asking.md).

## Deep references

- [Docs variant](references/docs-variant.md) — read when the user wants decisions and terms written down as they settle.
- [Resolve before asking](references/resolve-before-asking.md) — read before asking the user who or what something is.

> Sources & MIT attribution: [references/sources.md](references/sources.md).
