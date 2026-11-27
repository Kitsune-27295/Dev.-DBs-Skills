---
name: cross-layer-value-trace
description: "Trace a wrong, missing, stale or disputed value hop by hop from its source of truth to the screen (source or collector, service or domain, API or router, backend-for-frontend, client cache, UI), asking four questions at each hop: value, absence, freshness, failure. Works in the direction of the data, records evidence per hop, finds the first hop where the truth is lost, and hands the fix to the right skill. Use when a number on screen is wrong, empty, stale or differs between screens, an empty result looks healthy, or each layer passes review but the composition lies. Not for crashes, exceptions or slowness (use diagnosing-bugs)."
---

# Cross-Layer Value Trace

One idea: in a layered system each layer can be correct on its own and the composition can still show the user a lie, so a bad value is found by **walking it forward from its source of truth, one hop at a time, and stopping at the first hop where it stops meaning what it meant** — never by arguing from the screen backwards or from blame. The method borrows the trace-and-span vocabulary of distributed tracing as an evidence format, and it pairs with contract tests to pin the fix. Sources and claims: [references/sources.md](references/sources.md).

Boundary: this skill is an **investigation of one value**. The general reproduce-and-bisect loop is `diagnosing-bugs`; a five-area audit of a whole app is `fundamentals-audit`; designing the layers themselves belongs to the pattern skills listed in section 7.

---

## 1. When to use it (and when not)

| Symptom | Use this skill? |
|---|---|
| A number on screen differs from the database, a report or another screen | Yes |
| A panel is empty, zero or "all green" while the system is plainly not healthy | Yes (absence and failure questions) |
| A value is "right but old", or right after reload and wrong later | Yes (freshness question) |
| A crash with a stack trace, a failing test, a slow endpoint | No: use `diagnosing-bugs` (or the matching fix skill) |
| "Is this app sound?" with no specific value | No: use `fundamentals-audit` |
| Two layers both look correct and the product owner must pick the meaning | Trace to find where they disagree, then stop: which side is right is a product decision |

---

## 2. The path a value takes

Draw the real path before reading any code. Use the project's own names; the generic shape is:

```text
source of truth (device, vendor API, table, file)
  -> collector / adapter           vendor payload -> domain type
  -> service / domain              the rule applied, aggregation, scoring
  -> API / router + schema         the published contract
  -> backend-for-frontend          narrowed or merged for one screen
  -> client cache / state store    memoized, persisted, polled
  -> UI component                  formatted, defaulted, rendered
```

Every arrow is a **hop** and every box can transform the value. Hops you cannot see in code (a proxy, a queue, a scheduled job, a materialized view) are still hops: add them. If the same metric is computed in two places on purpose, list both paths and trace each; do not unify them during the trace (`ssot-and-dry` decides later whether one owner is right).

**Direction rule:** start at the source and move toward the screen. Everything downstream of the first bad hop inherits the damage, so reading further adds noise, not evidence. Starting at the screen invites blaming the nearest layer.

---

## 3. The four questions at every hop

Ask all four at every hop and write each answer down. Questions 2 to 4 are the ones people skip. Detail and examples: [value-and-freshness-checks](references/value-and-freshness-checks.md) and [absence-and-failure-semantics](references/absence-and-failure-semantics.md).

| # | Question | What it catches | Typical tell |
|---|---|---|---|
| 1 | **VALUE** - is it exactly what we expect at this hop (same number, unit, scale, window, rounding, identity)? | Arithmetic, unit and aggregation drift, wrong key or tenant | Source says 73.4, this hop says 0.734 or 73 |
| 2 | **ABSENCE** - when the value is missing, how is that represented, and does it collapse into `0`, `""`, `false`, `[]` or a default? | "Unknown" rendered as healthy data | A fallback such as `?? 0`, `|| []`, a non-nullable DTO field, a default in a mapper |
| 3 | **FRESHNESS** - what is the timestamp, does it survive this hop, and who last updated it (poll, cache, replica, batch)? | Cached or lagging sample read as live | Timestamp dropped by a mapper; cache TTL longer than the screen's promise |
| 4 | **FAILURE** - if this hop's dependency fails, what does it return, and is that an error, a degraded marker or a normal-looking value? | A swallowed error rendered as a quiet empty state | `catch { return [] }`, retry that ends in a default, 200 with empty body |

Absence and failure are the same family: a **missing value** and a **failed fetch** both tend to become the type's zero value. The most expensive version is composed: a source returns nothing, a collector turns nothing into an empty list, and the UI turns an empty list into "no problems".

---

## 4. Procedure

1. **Name the value precisely.** Metric, entity (host, tenant, customer, order), time window, screen, the number the user sees and the number they expect. "The total is wrong" is not yet a question.
2. **Find the source of truth and read it directly**, bypassing every layer you own (a read-only query, a raw API call, the device or file itself). Record value, timestamp and how the source says "unknown". If you cannot read it directly, say so; everything after is weaker evidence.
3. **Walk forward one hop at a time.** At each hop capture the real value (log line, debugger, a recorded response, a test) and answer the four questions. Write the answers in the ledger from section 5 before moving on.
4. **Stop at the first hop where truth is lost.** Truth is lost when value changes without a rule that explains it, when absence turns into data, when the timestamp disappears or ages, or when a failure becomes a normal result.
5. **Check the contract at the boundary just before and after that hop**: do the producer's schema and the consumer's parser/type agree on names, types, nullability and units? A field renamed on one side and defaulted on the other gives a silent zero (see [contracts-and-hop-tests](references/contracts-and-hop-tests.md)).
6. **Prove the break with a test at that hop** (unit or contract level), watch it fail, fix, watch it pass. Do not prove it only end to end: an end-to-end test tells you something is broken, not where.
7. **Re-walk the remaining hops** after the fix to confirm nothing downstream was also wrong; one visible symptom can hide two defects.

---

## 5. The evidence ledger (the deliverable)

One row per hop. The tracing model of spans with attributes, status and timestamps is the template: a hop is a span-like unit of work, and what you record per hop is its attributes. See [hop-evidence-ledger](references/hop-evidence-ledger.md).

```text
VALUE      <metric> for <entity>, <window>, shown on <screen>: expected X, seen Y
SOURCE     <how read directly>: value, timestamp, how "unknown" is encoded

| hop | value in / out | absence | freshness (ts, age, updater) | on failure | evidence |
|-----|----------------|---------|------------------------------|------------|----------|
| collector   | ... | ... | ... | ... | <log, test, response id> |
| service     | ... | ... | ... | ... | ... |
| API/schema  | ... | ... | ... | ... | ... |
| BFF         | ... | ... | ... | ... | ... |
| client cache| ... | ... | ... | ... | ... |
| UI          | ... | ... | ... | ... | ... |

BREAKS AT   <first hop>: <what changes and why it is wrong>
DELIBERATE  <intentional duplicates met, and which side applies>
NOT CHECKED <hops not verified and what it would take>
```

Rules: a cell is **evidence or "not checked"**, never an assumption. "Looks fine in code" is not evidence for a value; a captured value is. If distributed tracing exists, trace IDs go in the evidence column; if it does not, do not pretend it does: state that the trace is manual.

---

## 6. Where truth is usually lost (hypothesis seeds, not conclusions)

| Hop | Common loss | Next move |
|---|---|---|
| Source / collector | Dead source returns an empty set, not "degraded"; clock or timezone differs | Compare against the source read directly; check how outages are encoded |
| Mapper / adapter | Unit or scale change; optional field made required with a default; timestamp dropped | `dto-mapper-anti-corruption-layer` |
| Service / domain | Aggregation window or filter differs from what the screen says; missing sample counted as zero | `defensive-domain-modeling` (absence as a distinct state) |
| API / schema | Nullability lost; error returned as 200 with empty body; undocumented enum value mapped to a default | `error-handling-problem-details`, `arc42-api-contracts-architecture` |
| BFF | Merge of two sources where one failed and the other fills in; recomputed value | `bff-pattern` |
| Client cache | TTL longer than the freshness the UI implies; cache key missing tenant or filter; stale-on-error shown as fresh | `caching-strategies` |
| UI | Format rounds or truncates; `undefined` coerced to 0; empty list styled as success; no stale or error state exists | Add the missing states; see absence reference |

---

## 7. Hand the fix to the right skill

This skill finds the hop; it does not own the repair.

| What the first bad hop needs | Owner |
|---|---|
| Boundary translation bug or leaking vendor semantics | `dto-mapper-anti-corruption-layer` |
| Missing value representable as a normal one (primitive obsession) | `defensive-domain-modeling` |
| Errors swallowed or returned in the wrong shape | `error-handling-problem-details` |
| No degraded or fallback signal, no tracing, retries that mask outages | `circuit-breaker-retry-telemetry` |
| Stale or wrongly keyed cache | `caching-strategies` |
| Edge or BFF aggregation hiding partial failure | `bff-pattern` |
| Test that pins the hop | `integration-tests`, `tdd`, `testing-pyramid-and-shapes` |
| Broad "is the app sound" question that surfaced this | `fundamentals-audit` |
| Reproduction, minimization, hypothesis loop for a hop that behaves oddly | `diagnosing-bugs` |

---

## 8. Anti-patterns to reject

- **Reading from the screen backwards** and stopping at the first layer that "looks wrong".
- **Comparing only the two ends** (source vs screen) and declaring the middle innocent.
- **Treating `0`, empty list or `false` as proof of health** without asking how "no data" would look.
- **Fixing the symptom at the UI** (hide the zero, add a spinner) while the lost hop stays lost.
- **"Be liberal in what you accept" defaults** that silently repair malformed input; a tolerated fault travels downstream as a valid-looking value.
- **An end-to-end test as the only proof**; it cannot say which hop broke.
- **Deciding which layer is right** when the trace shows two defensible meanings: report the disagreement and escalate the decision.
- **Unifying intentional duplicates mid-investigation.** Verify they still agree and report drift.

---

## Quick Decision Checklist

- [ ] The value is named (metric, entity, window, screen, expected vs seen).
- [ ] The source of truth was read directly, with its timestamp and its "unknown" encoding.
- [ ] The real path is listed, including hidden hops (proxy, queue, job, cache).
- [ ] Walked source to screen; all four questions answered per hop with captured evidence.
- [ ] Stopped at the first hop where truth is lost; later hops not blamed.
- [ ] Boundary contract on both sides of that hop compared.
- [ ] A failing test exists at that hop before the fix.
- [ ] Remaining hops re-walked after the fix.
- [ ] Fix handed to the owning skill; "not checked" hops listed honestly.

---

## Deep references

- [Hop evidence ledger](references/hop-evidence-ledger.md) - read to record the trace in a reusable form, borrow trace/span concepts, and decide manual vs instrumented tracing.
- [Value and freshness checks](references/value-and-freshness-checks.md) - read for questions 1 and 3: unit, scale, window and identity drift, timestamps that die in a mapper, averages that hide a tail.
- [Absence and failure semantics](references/absence-and-failure-semantics.md) - read for questions 2 and 4: how "unknown" becomes zero, silent tolerance, implicit errors, special-case values.
- [Contracts and hop tests](references/contracts-and-hop-tests.md) - read when checking producer/consumer agreement at the broken hop and pinning the fix with a contract or hop-level test.
