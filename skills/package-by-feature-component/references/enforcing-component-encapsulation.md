# Enforcing Component Encapsulation: Access Modifiers, Assemblies and Architecture Tests

Sources: https://milanjovanovic.tech/blog/clean-architecture-the-missing-chapter · Last verified 2026-11-23

## What the article says
- `internal` limits visibility to one assembly but cannot stop every violation: a public class in the same assembly can implement the public interface in an unintended way, and anything in the assembly can reach internals.
- **Multiple assemblies** give stronger encapsulation but cost build complexity, slower IDE navigation and more deployment artifacts.
- Recommended pragmatic path: a single assembly, implementations `internal` (add `sealed`), only component interfaces public, and **architecture tests** that fail the build on violations (example rule: controllers may depend only on component interfaces).
- Summary slogan: pragmatism beats purism.

## Escalation ladder
| Step | Mechanism | Catches | Cost |
|---|---|---|---|
| 1 | internal/package-private implementations | accidental use, by the compiler | free |
| 2 | architecture tests | dependency rules the compiler allows | small test suite |
| 3 | assembly/module per component | everything at compile time | build and artifact overhead |
Escalate only when the previous step has failed in practice.

## Language notes
- C#: assembly-scoped `internal`; NetArchTest-style tests. Java: package-private works per package. TypeScript barrels plus lint boundary rules come from the existing `sources.md`, not from this article (inference).

## Example architecture test (pseudo-code)
```
rule: types in namespace *.Web must not depend on *.Policies.Internal
rule: only IPoliciesComponent is public in assembly Policies
fail the build on any violation
```

## How an agent should apply this
- Start at step 1 and add the architecture test in the same change that introduces a component.
- Propose separate assemblies only after a concrete violation that tests cannot stop.
- Keep DI registrations next to the component so the interface-to-implementation map stays private.
- Never widen visibility to make a test compile; test through the public interface.
