# Removal Candidates Catalog

Sources: https://martinfowler.com/bliki/Yagni.html · https://refactoring.guru/smells/dead-code · https://abseil.io/resources/swe-book/html/ch15.html · https://refactoring.com/ · Last verified 2026-11-27

## Why removal is worth the effort

Fowler's YAGNI article names four costs of a presumptive feature: build, delay, carry and repair (cost model owned by `yagni-evolutionary-architecture`). The one that matters for an audit is **carry**: extra complexity that slows every change to other features for as long as the feature stays, plus the cost of removing it later. Fowler puts the odds that a presumptive feature is unnecessary at least two in three, citing Kohavi et al., who found that only a third of features deployed at one company improved the metrics they targeted (a statement about metrics, not proof a feature is unused; the study itself was not read). The software-engineering-at-Google deprecation chapter frames the same idea as "code is a liability, not an asset": value lies in functionality delivered, so removing unneeded code is a real gain, though removal is hard because heavily used systems attract unexpected dependencies.

Refactoring (behavior-preserving change in small steps, with frequent tests) is what makes deletion safe enough to try. The dead-code smell description recommends deleting unused code and files and, for structure, Inline Class, Collapse Hierarchy or Remove Parameter; it also says a good IDE finds dead code fastest, which is true only for static, in-project references (see the consumer-evidence reference).

## Catalog

Signals are prompts for investigation, never proof.

| Category | Typical signal | Evidence needed before proposing |
|---|---|---|
| Unused symbol (function, class, parameter, field) | No references in search | Exports, reflection, string lookups, generated code and downstream consumers all checked |
| Dead branch | Condition cannot be true after earlier changes; flag fixed at one value everywhere | The flag's value at every deployment; no external setter |
| Permanently-on or permanently-off flag | Flag default never overridden; both branches' tests exist | Config history and runtime values; who may still toggle it |
| Config key with no reader | Key in schema/docs, no read site | Read through loaders, env mapping, overlays and precedence (a value shadowed before use counts as unread) |
| Declared feature without an effect path | Field exists on a type, set by nobody, or read only by tests | Trace producers, transformations, capability checks and the observable result |
| Distinction with no consumer action | Many states, enums or error types that all produce one outcome | Every branch on the discriminant; emitters and authorization checks |
| Parallel representation | Same fact stored or derived twice (copied history, cached projection beside the stream) | The required time of observation; the authoritative read path |
| Duplicated path | Two implementations of one capability, a demo launcher used as a product, a second app tree | Which one callers reach; maintenance of both; whether duplication is a deliberate twin |
| Over-general subsystem | Calendar, rule engine or plugin registry used by one fixed case | The single real usage; the capability a smaller explicit behavior gives up |
| Habit obligation | Review step, report, approval, checklist item, test with no reader or no failure ever caught | Who consumes the output; history of what it caught; what breaks if skipped |
| Test pinning removed or private behavior | Test asserts internals or a deleted contract | The behavior it protects, if any, is covered elsewhere |
| Redundant docs and comments | Prose restating code, or owned elsewhere | The remote owner still states the rule |
| Dependency doing little | A package used for one small function | Net deleted code vs added glue and transitive cost |

## Example decisions (own illustrations)

1. **Flag**: `enable_new_checkout` is `true` in every environment for a year; the old branch has tests. Evidence: config history, no override in any environment profile, no runtime reads of `false`. Decision: unreachable branch, remove the flag and the old path in two steps (inline the winning branch, then delete the flag and its tests).
2. **State**: an order has nine internal statuses mapped to four user-visible ones, and no consumer reads the nine except one reporting script. Decision: narrower behavior with an explicit loss; propose only if the reporting script can use the four or is retired.
3. **Cache beside a stream**: a feature keeps its own copy of data that a shared projection already provides, plus invalidation events and stale-response handling. Decision: derive from the projection; the deleted pieces are the copy, the subscription and the stale handling together. Classify as narrower if a consumer needs a snapshot at a time the projection does not offer.
4. **Not a candidate**: two storage adapters kept deliberately so a seam stays real. Protected; unused members inside either adapter remain candidates.

## Habit obligations

These are the least visible and often the cheapest to cut. For each recurring check or artifact, ask: who reads it, what decision does it change, and when did it last catch something? If nobody reads it and nothing has been caught, propose retiring or automating it; if a compliance or safety rule requires it, mark protected. Do not cut a control because it has been quiet: a control that works looks the same as one that does nothing, so ask for evidence of the detection history before judging.

## How an agent should apply this

- Use the table's signals to generate candidates, then collect evidence per candidate; never report a signal as a finding.
- Look for subsystems and parallel representations, not only unused symbols; they carry the largest cost.
- State the capability given up for every "narrower behavior" candidate.
- Check the project's decision records for protected items first.
- Prefer a short list of well-supported candidates to a long list of guesses.
