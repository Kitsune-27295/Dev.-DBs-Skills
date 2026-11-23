---
name: feature-flag-toggle-engine
description: "Design and operate feature toggles: classify them (release, experiment, ops, permission) by longevity and dynamism, structure toggle point / router / configuration / context, keep decisions out of business code, test on/off combinations, control toggle debt with expiry and removal, and integrate through the vendor-neutral OpenFeature API (evaluation context, providers, hooks). Use when adding a flag, building a toggle router, planning a canary or A/B test, adding a kill switch, reviewing stale flags, or choosing a flag vendor abstraction."
---

# Feature Flag & Toggle Engine

One idea: a feature toggle is **inventory with a carrying cost**; give each one a category (which fixes its lifetime, dynamism and owner), isolate its decision in one named place (**toggle point** asks a **router**, which reads **configuration** plus **context**), and schedule its removal when you create it. Application code talks to a vendor-neutral API (OpenFeature) so the flag backend stays swappable. Sources and claims: [references/sources.md](references/sources.md).

Boundary with neighbours: gradual schema/API migration without runtime flags is `parallel-change-expand-contract` (toggles may gate its switch-over step); resilience kill switches that trip automatically are `circuit-breaker-retry-telemetry`; per-user permission enforcement is `authn-authz-guard` (a permission toggle selects features, it does not replace authorization); throttling is `rate-limiter-throttler`; speculative flag-everything design is checked by `yagni-evolutionary-architecture`; test strategy is `testing-pyramid-and-shapes`; environment/config separation is `twelve-factor-cloud-native`.

---

## 1. Four Categories (decide before coding)

| Category | Purpose | Typical life | Dynamism | Config home |
|---|---|---|---|---|
| **Release** | Hide unfinished work; trunk-based development; decouple deploy from release | Days to weeks | Static per release | Source-controlled file |
| **Experiment** | A/B / multivariate; users in consistent cohorts | Hours to weeks | Per-request routing, **frozen config** | Experiment platform |
| **Ops** | Kill switch, load shedding, risky-feature back-off | Short; some permanent | Must change without a release | Runtime store / admin UI |
| **Permission** | Premium tiers, alpha/beta, internal-first | Months to years | Per-request by identity | Entitlement system |

A **canary** is a release toggle applied to a small, consistently assigned random cohort (for instance user ID modulo 100); permission toggles target a named group instead. A toggle that changes category (release becoming experiment) changes owner and config home. Details: [references/toggle-taxonomy-and-lifecycle.md](references/toggle-taxonomy-and-lifecycle.md).

## 2. Anatomy: Point, Router, Configuration, Context

```
code path ──► toggle point ──► router.decide("newCheckout", ctx) ──► config (+ context)
```

- **Toggle point:** the single place that branches. **Router:** decides which path is live. **Configuration:** what the router reads. **Context:** per-request data (user ID, cookie, header) used for decisions.
- Name decisions after **business meaning** (`showNewCheckout()`), not flag keys scattered as strings.
- **Inversion of decision:** inject the chosen behavior (strategy/function/no-op) into the component at wiring time, so the component never queries a flag system and is trivial to test.
- Prefer one toggle point per feature; replace chains of `if` with a Strategy when a feature spans several points or lives long.
- Place **edge** toggles (UI, per-request) in the web layer; **technical** toggles (cache choice) local to the service.

## 3. Configuration Rules

| Option (simple to rich) | Fits | Cost |
|---|---|---|
| Hardcode / compile switch | Throwaway release flag | Redeploy |
| Env var / CLI arg | Per-environment | Restart |
| Config file in repo | Release toggles; promoted through the pipeline | Redeploy |
| DB + admin UI | Fleet-wide consistency, non-dev control | Build and secure a UI |
| Distributed KV (etcd, Consul, ZooKeeper) / flag service | Ops/experiment/permission at runtime | Operate and monitor it |

- Prefer **static configuration in source control** for release toggles: same artifact and config promoted across environments, history preserved, less testing.
- Per-request overrides (cookie/header/query) let testers exercise production; **sign** them so end users cannot tamper.
- Expose current toggle state on a metadata endpoint like version info; store descriptions, owners and expiry per toggle.

## 4. OpenFeature: Vendor-Neutral API

| Concept | Role |
|---|---|
| **Evaluation API / client** | What app code calls: typed `getBooleanValue(key, default, ctx)` etc.; **always a default**, returned on any error. Detailed variants return value, variant, reason, error code |
| **Evaluation context** | Data for targeting: global, client, invocation levels merged per evaluation; a **targeting key** (stable subject ID) enables deterministic percentage rollouts; keep PII minimal |
| **Provider** | Translation layer to a flag backend (vendor SDK, REST, file); one registered globally; domains allow several providers per client name |
| **Hooks** | before / after / error / finally at API, client or invocation level; use for context enrichment, validation, logging, telemetry |
| **Events** | Provider ready/error/configuration-changed notifications |

```ts
const client = OpenFeature.getClient("checkout");
const enabled = await client.getBooleanValue("new-checkout", false, { targetingKey: user.id, plan: user.plan });
```

Rules: default must be the **safe legacy behavior**; wrap the client behind your own named decision methods; add no vendor SDK calls outside the provider adapter. Details: [references/openfeature-api-and-providers.md](references/openfeature-api-and-providers.md).

## 5. Testing

- Validate each release candidate with **expected production config** and the **fallback config (new toggles off)**; sometimes an all-on config. Do not test every combination.
- Convention: **off = legacy behavior, on = new behavior.**
- Unit-test the decision logic with injected behavior (no flag system); test the router separately, including provider failure returning defaults.
- Runtime override endpoints are for test environments; avoid in shared or production environments as a general control.
- Add a test that the app starts and serves with all flags at their defaults when the flag service is unreachable.

## 6. Toggle Debt

- Creating a release toggle also creates a **removal ticket** with an owner.
- Store an **expiry date**; add a "time bomb" (failing test or startup refusal after expiry) for release toggles.
- Cap the number of live toggles; add one only by removing one.
- Cleanup order: ship 100%, delete the off-path code, delete the config entry, delete the flag in the vendor.
- Fowler cites Knight Capital as the cost of poor flag hygiene (reused flag, stale code path).

Details: [references/toggle-taxonomy-and-lifecycle.md](references/toggle-taxonomy-and-lifecycle.md).

## 7. Anti-Patterns

| Smell | Fix |
|---|---|
| `if (flags["x"])` scattered across layers | One decision method, inject behavior |
| Release toggle older than its planned removal | Time bomb + removal ticket |
| Permission toggle used instead of authorization | Authorize separately (`authn-authz-guard`) |
| Reusing an old flag key for a new meaning | Unique keys; delete retired keys everywhere |
| Experiment config changed mid-run | Freeze config; restart the experiment |
| Flag default is the new, risky path | Default to legacy/safe |
| Vendor SDK calls in business code | OpenFeature client + provider adapter |
| Ops flag needing a deploy | Move to a runtime store |

## Quick Decision Checklist

- [ ] Category chosen (release/experiment/ops/permission) and owner named?
- [ ] One toggle point, decision named by business meaning?
- [ ] Config home matches the category's dynamism?
- [ ] Safe default returned when the flag system fails?
- [ ] On and off paths both tested; fallback config tested?
- [ ] Expiry date and removal ticket created with the flag?
- [ ] Vendor access only through OpenFeature provider?
- [ ] PII in evaluation context minimized; targeting key stable?
- [ ] Toggle state observable (metadata endpoint, logs via hooks)?

## Deep references

- [Toggle Taxonomy and Lifecycle](references/toggle-taxonomy-and-lifecycle.md) — when classifying a toggle, choosing config storage, testing combinations, or paying down debt
- [OpenFeature API and Providers](references/openfeature-api-and-providers.md) — when wiring evaluation context, providers, hooks, defaults and errors
- [Toggle Point Implementation Patterns](references/toggle-point-implementation-patterns.md) — when coding the decision point, inversion of decision, strategy replacement, cohorts
