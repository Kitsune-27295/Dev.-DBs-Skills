# Sources — Cross-Layer Value Trace

Every URL below was re-checked on 2026-11-27 (WebFetch; Firecrawl unavailable).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [OpenTelemetry — Traces](https://opentelemetry.io/docs/concepts/signals/traces/) | 200 OK, read | Trace, span, span context, attributes, span events vs attributes (timestamp test), span links, span status (Unset default, Error, Ok set explicitly and usually unnecessary), span kinds; the evidence-format analogy for the per-hop ledger |
| [RFC 9413 — Maintaining Robust Protocols](https://www.rfc-editor.org/rfc/rfc9413) | 200 OK, read; Informational, June 2023, IAB; not unanimously approved | Critique of broad tolerance: protocol decay (4.1), hidden faults (6), "virtuous intolerance" (5.1), workarounds with a removal plan, applicability limit (updatable deployments) |
| [Martin Fowler — ContractTest](https://martinfowler.com/bliki/ContractTest.html) | 200 OK, read | Contract tests check that test doubles keep the real service's format; structure not data; failure means a stale double and need not break the build; run on the supplier's schedule; consumer-driven contracts |
| [Pact documentation](https://docs.pact.io) | 200 OK, landing page read | Code-first consumer-driven contract testing for HTTP and message integrations; contract generated from consumer tests; "contract by example"; fewer brittle integration tests |
| [Google SRE Book — Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) | 200 OK, read; each cited claim re-checked | Four golden signals; explicit, implicit and policy-based errors; only end-to-end tests catch wrong content; black-box vs white-box; slow errors worse than fast ones; averages hide the tail; measurement resolution |
| [Martin Fowler — Special Case](https://martinfowler.com/eaaCatalog/specialCase.html) | 200 OK, read | Replacing null with a same-interface special-case object; the page lists no caveats, so the risk of a special case posing as real data is this skill's inference |

## Reading limits

- Pages were read through a fetch tool that returns a model-written summary, not raw HTML; wording is paraphrased and RFC section numbers come from that summary.
- The Pact page was the landing page only; provider verification and sub-pages were not read.
- No semantic-conventions page was read; trace concepts come from the traces concept page only.
- No scripts exist in this skill.

## Claims not adopted as fact

- Mapping spans to data hops, separating a hop's "no error" status from value correctness, and summing stacked cache delays for worst-case staleness are this skill's own adaptations.
- Applying RFC 9413 (Internet protocols) to internal data layers is an analogy; the RFC limits its advice to updatable deployments.
- The risk that a Special Case object reports zero or empty like real data is this skill's inference.
- The ordering of drift families by frequency in the value-and-freshness reference is a practical heuristic, not a statistic.
- Pact versus a shared schema for in-process layers is this skill's recommendation, not a docs statement.
- Third-party skill read for ideas, no text reused: an internal project's method note on tracing a value across layers (four questions per hop, walk in the data direction) informed the shape of this method; no names, layers, paths, products or commands were copied.
