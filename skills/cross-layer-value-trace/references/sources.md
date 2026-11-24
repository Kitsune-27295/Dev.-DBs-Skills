# Sources — Cross-Layer Value Trace

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| [OpenTelemetry — Traces](https://opentelemetry.io/docs/concepts/signals/traces/) | 200 OK (fetched via WebFetch) | Definitions of trace, span, span context, attributes, span events vs attributes (timestamp test), span links, span status (Unset, Error, Ok) and span kind; used as the evidence-format analogy for the per-hop ledger. |
| [RFC 9413 — Maintaining Robust Protocols](https://www.rfc-editor.org/rfc/rfc9413) | 200 OK (fetched via WebFetch) | Critique of broadly applied tolerance ("be liberal in what you accept"): protocol decay, entrenchment, hidden faults; "virtuous intolerance", explicit error handling, documented workarounds with a removal plan; the applicability limit (updatable deployments). |
| [Martin Fowler — ContractTest](https://martinfowler.com/bliki/ContractTest.html) | 200 OK (fetched via WebFetch) | Contract tests verify that test doubles keep the real service's format; structure not data; failure means a stale double; supplier-side schedule; consumer-driven contracts. |
| [Pact documentation](https://docs.pact.io) | 200 OK (landing page; sub-pages not read) | Code-first consumer-driven contract testing for HTTP and messages; contract generated from consumer tests; "contract by example"; fewer brittle integration tests. |
| [Google SRE Book — Monitoring Distributed Systems](https://sre.google/sre-book/monitoring-distributed-systems/) | 200 OK (fetched via WebFetch) | Four golden signals; explicit, implicit and policy-based errors; slow errors worse than fast errors; symptoms vs causes and black-box vs white-box monitoring; averages hide the tail; measurement resolution. |
| [Martin Fowler — Special Case](https://martinfowler.com/eaaCatalog/specialCase.html) | 200 OK (fetched via WebFetch) | Replacing null with a same-interface special-case object; the page lists no caveats, so the risk of a special case posing as real data is marked as this skill's inference. |

## Reading limits

- Pages were read through a fetch tool that returns a model-generated summary of the page, not the raw text; wording attributed to a source is a paraphrase, and section numbers for RFC 9413 come from that summary.
- The Pact page was the documentation landing page only; the provider-verification flow and sub-pages (How Pact works, concepts, FAQ) were not read.
- No distributed-tracing semantic-conventions page was read; the trace concepts above come from the traces concept page only.
- Firecrawl was unavailable for this authoring pass; WebFetch was used for every URL.

## Claims not adopted as fact

- Mapping spans to data hops, treating a hop's "no error" status as separate from value correctness, and summing stacked cache delays for worst-case staleness are this skill's own adaptations, not statements from the sources.
- Applying RFC 9413 (about Internet protocols) to internal data layers is an analogy; the RFC itself limits its guidance to settings where implementations can be updated.
- The risk that a Special Case object reports zero or empty like real data is this skill's inference; the Fowler page does not discuss it.
- The ordering of drift families by frequency in `value-and-freshness-checks` is a practical heuristic, not a measured statistic.
- Third-party skill read for ideas, no text reused: an internal project's method note on tracing a value across layers (four questions per hop, walk in the data direction) informed the shape of this method; no names, layers, paths, products or commands were copied.
